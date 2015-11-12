//
//  AudioStreamManager.m
//  homecamera
//
//  Created by Leonid Mesentsev on 27/10/15.
//  Copyright (c) 2015 Leonid Mesentsev. All rights reserved.
//

#import "AudioStreamManager.h"

#include "adpcm.h"



static void audioQueueOutputCallback( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer )
{
    void *buffer = inBuffer->mAudioData;

    buffer = (char *)buffer;
    UInt32 len = inBuffer->mAudioDataByteSize;

    AudioStreamManager *Self = (__bridge AudioStreamManager *)inUserData;

    CMSampleBufferRef sampleBuffer = NULL;
    OSStatus status = -1;

    AudioStreamBasicDescription streamDesc = Self.streamDecription;

    CMFormatDescriptionRef format = NULL;
    status = CMAudioFormatDescriptionCreate( kCFAllocatorDefault, &streamDesc, 0, nil, 0, nil, nil, &format );

    CMFormatDescriptionRef formatdes = NULL;
    status = CMFormatDescriptionCreate( NULL, kCMMediaType_Audio, 'lpcm', NULL, &formatdes );
    if ( status != noErr )
    {
        NSLog( @"Error in CMAudioFormatDescriptionCreater" );
        CFRelease( format );
        return;
    }

    /* Create sample Buffer */
    CMSampleTimingInfo timing   = { .duration = CMTimeMake( 1, 8000 ), .presentationTimeStamp = kCMTimeZero, .decodeTimeStamp = kCMTimeInvalid };
    CMItemCount framesCount     = len / 2;
    status = CMSampleBufferCreate( kCFAllocatorDefault, nil, NO, nil, nil, format, framesCount, 1, &timing, 0, nil, &sampleBuffer );
    if ( status != noErr )
    {
        NSLog( @"Error in CMSampleBufferCreate" );
        CFRelease( format );
        CFRelease( formatdes );
        return;
    }

    /* Copy BufferList to Sample Buffer */
    AudioBufferList theDataBuffer;
    theDataBuffer.mNumberBuffers = 1;
    theDataBuffer.mBuffers[0].mDataByteSize = len;
    theDataBuffer.mBuffers[0].mNumberChannels = 1;
    theDataBuffer.mBuffers[0].mData = buffer;
    status = CMSampleBufferSetDataBufferFromAudioBufferList( sampleBuffer, kCFAllocatorDefault, kCFAllocatorDefault, 0, &theDataBuffer );
    if ( status != noErr )
    {
        NSLog( @"Error in CMSampleBufferSetDataBufferFromAudioBufferList: %d", status );
        CFRelease( sampleBuffer );
        CFRelease( format );
        CFRelease( formatdes );
        return;
    }

    if ( Self.audioListener )
    {
        [Self.audioListener processSampleBuffer:sampleBuffer];
    }

    CMSampleBufferInvalidate( sampleBuffer );
    CFRelease( sampleBuffer );
    CFRelease( format );
    CFRelease( formatdes );
}


@interface AudioStreamManager () {

    NSURLConnection *_connection;
    AudioQueueRef _aq;
    AudioQueueBufferRef _aq_buffer;
    NSMutableData *_data;

}


@end


@implementation AudioStreamManager


+ (AudioStreamManager *)sharedInstance
{
    static AudioStreamManager *_sharedInstance = nil;

    if ( !_sharedInstance )
    {
        _sharedInstance = [[AudioStreamManager alloc] init];
    }
    return _sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        _connection = nil;
        _data = [NSMutableData new];

        _streamDecription.mSampleRate       = 8000;
        _streamDecription.mFormatID         = kAudioFormatLinearPCM;
        _streamDecription.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;    // | kAudioFormatFlagsNativeEndian;;
        _streamDecription.mBytesPerPacket   = 2;
        _streamDecription.mFramesPerPacket  = 1;
        _streamDecription.mBytesPerFrame    = 2;
        _streamDecription.mChannelsPerFrame = 1;
        _streamDecription.mBitsPerChannel   = 16;
        _streamDecription.mReserved         = 0;
        OSStatus s = AudioQueueNewOutput( &_streamDecription, audioQueueOutputCallback, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_aq );
        if ( s != noErr )
        {
            return nil;
        }
        
        s = AudioQueueAllocateBuffer( _aq, 2048, &_aq_buffer );
        if ( s != noErr )
        {
            NSLog( @"Cannot allocate audio buffer." );
            return nil;
        }
        _aq_buffer->mAudioDataByteSize = 2048;
    }
    return self;
}


#pragma mark - Overrides

- (void)dealloc
{
    if ( _connection )
    {
        [_connection cancel];
        [self cleanupConnection];
    }

}


#pragma mark - Private Methods

- (void)cleanupConnection
{
    if ( _connection )
    {
        _connection = nil;
    }
    AudioQueueStop( _aq, YES );
    _isPlaying = NO;
}


#pragma mark - Public


- (void)play
{
    if ( _connection )
    {
        // continue
    }
    else if ( _url )
    {
        AudioQueueStart( _aq, NULL );
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:10];

        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        _isPlaying = YES;
    }
}


- (void)stop
{
    if ( _connection )
    {
        [_connection cancel];
        [self cleanupConnection];
    }
}


#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    OSStatus s;

    [_data appendData:data];

    NSLog( @"Received %lu bytes, buffered %lu bytes", data.length, _data.length );

    while ( _data.length >= 544 )
    {
        char *start = (char *)_data.bytes;
        // Skip data header
        start += 32;

        adpcm_state state = { 0, 0 };
        adpcm_decoder( start, (short *)_aq_buffer->mAudioData, 1024, &state );

        s = AudioQueueEnqueueBuffer( _aq, _aq_buffer, 0, NULL );
        if ( s != noErr )
        {
            NSLog( @"Cannot enqueue audio buffer." );
        }

        NSLog( @"Enqueued 512 bytes" );

        [_data setData:[_data subdataWithRange:NSMakeRange( 544, _data.length - 544 )]];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cleanupConnection];
}


- (void)connection:(NSURLConnection *)connection
    didFailWithError:(NSError *)error
{
    [self cleanupConnection];
    [self play];
}


@end
