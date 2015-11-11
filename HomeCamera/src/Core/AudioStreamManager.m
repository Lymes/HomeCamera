//
//  AudioStreamManager.m
//  homecamera
//
//  Created by Leonid Mesentsev on 27/10/15.
//  Copyright (c) 2015 Leonid Mesentsev. All rights reserved.
//

#import "AudioStreamManager.h"

#import <AudioToolbox/AudioToolbox.h>

#include "adpcm.h"



static void audioQueueOutputCallback( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer )
{
}


@interface AudioStreamManager () {
    
    NSURLConnection *_connection;
    AudioQueueRef _aq;
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
        
        AudioStreamBasicDescription asbd;
        asbd.mSampleRate       = 8000;
        asbd.mFormatID         = kAudioFormatLinearPCM;
        asbd.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;    // | kAudioFormatFlagsNativeEndian;;
        asbd.mBytesPerPacket   = 2;
        asbd.mFramesPerPacket  = 1;
        asbd.mBytesPerFrame    = 2;
        asbd.mChannelsPerFrame = 1;
        asbd.mBitsPerChannel   = 16;
        asbd.mReserved         = 0;
        OSStatus s = AudioQueueNewOutput( &asbd, audioQueueOutputCallback, NULL, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_aq );
        if ( s != noErr )
        {
            return nil;
        }
        
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
        
        AudioQueueBufferRef aq_buffer;
        s = AudioQueueAllocateBuffer( _aq, 2048, &aq_buffer );
        if ( s != noErr )
        {
            NSLog( @"Cannot allocate audio buffer." );
            break;
        }
        
        aq_buffer->mAudioDataByteSize = 2048;
        
        adpcm_state state = { 0, 0 };
        adpcm_decoder( start, (short *)aq_buffer->mAudioData, 1024, &state );
        
        s = AudioQueueEnqueueBuffer( _aq, aq_buffer, 0, NULL );
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
