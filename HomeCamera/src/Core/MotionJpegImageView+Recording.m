//
//  MotionJpegImageView+Recording.m
//  homecamera
//
//  Created by Leonid Mesentsev on 29/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "MotionJpegImageView+Recording.h"
#import <AVFoundation/AVFoundation.h>


#define kPreferredFPS   16
#define kBitRateKey     @"BitRate"
#define kRecordQueueKey "com.lymes.homecamera.RecordQueue"

static BOOL _isRecording;
static dispatch_queue_t _recordQueue;
static AVAssetWriter *_videoWriter;
static AVAssetWriterInput *_videoWriterInput;
static AVAssetWriterInput *_assetWriterAudioInput;
static AVAssetWriterInputPixelBufferAdaptor *_adaptor;
static CFTimeInterval _initTime;


@implementation MotionJpegImageView (Recording)


- (void)startRecordingToFile:(NSString *)path
{
    if ( !self.isPlaying || self.isRecording )
    {
        return;
    }

    self.isRecording = YES;
    if ( !_recordQueue )
    {
        _recordQueue = dispatch_queue_create( kRecordQueueKey, nil );
    }

    dispatch_async( _recordQueue, ^{

        NSError *error = nil;

        _videoWriter = [[AVAssetWriter alloc] initWithURL:
                        [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
                                                        error:&error];
        NSParameterAssert( _videoWriter );

        NSInteger bitRate = [[NSUserDefaults standardUserDefaults] integerForKey:kBitRateKey];
        NSDictionary *videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                         AVVideoCompressionPropertiesKey : @{
                                             AVVideoAverageBitRateKey : @(bitRate),
                                             AVVideoMaxKeyFrameIntervalKey : @(1),
                                             AVVideoCleanApertureKey : @{
                                                 AVVideoCleanApertureWidthKey : @(self.imageSize.width),
                                                 AVVideoCleanApertureHeightKey : @(self.imageSize.height),
                                                 AVVideoCleanApertureHorizontalOffsetKey : @(10),
                                                 AVVideoCleanApertureVerticalOffsetKey : @(10)
                                             },
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264Main30
                                         },
                                         AVVideoWidthKey : @(self.imageSize.width),
                                         AVVideoHeightKey : @(self.imageSize.height) };

        _videoWriterInput = [AVAssetWriterInput
                             assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];

        _adaptor = [AVAssetWriterInputPixelBufferAdaptor
                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput
                                               sourcePixelBufferAttributes:nil];

        NSParameterAssert( _videoWriterInput );
        NSParameterAssert( [_videoWriter canAddInput:_videoWriterInput] );
        _videoWriterInput.expectsMediaDataInRealTime = YES;
        [_videoWriter addInput:_videoWriterInput];

//        _videoWriterInput.mediaTimeScale = kRecordingFPS;
//        _videoWriter.movieTimeScale = kRecordingFPS;


        // Audio
        AudioChannelLayout acl;
        bzero( &acl, sizeof( acl ));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;

        double preferredHardwareSampleRate = [[AVAudioSession sharedInstance] sampleRate];
        NSDictionary *audioOutputSettings = @{
            AVFormatIDKey : @(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey : @(1),
            AVSampleRateKey : @(preferredHardwareSampleRate),
            AVChannelLayoutKey : [ NSData dataWithBytes:&acl length:sizeof( acl ) ],
            AVEncoderBitRateKey : @(64000)
        };
        _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
        _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        if ( [_videoWriter canAddInput:_assetWriterAudioInput] )
        {
            [_videoWriter addInput:_assetWriterAudioInput];
        }

        // Start a session:
        [_videoWriter startWriting];
        [_videoWriter startSessionAtSourceTime:kCMTimeZero];

        _initTime = 0;
    } );
}


- (void)stopRecording
{
    dispatch_async( _recordQueue, ^{

        if ( _videoWriter.status == AVAssetWriterStatusWriting )
        {
            [_videoWriterInput markAsFinished];
            [_assetWriterAudioInput markAsFinished];
        }

        [_videoWriter finishWritingWithCompletionHandler:^() {
             _videoWriterInput = nil;
             _assetWriterAudioInput = nil;
             _videoWriter = nil;
             self.isRecording = NO;
         }];
    } );
}


- (void)pushFrame:(UIImage *)frame
{
    static int64_t lastFrameTime = 0;

    if ( self.isRecording )
    {
        CVPixelBufferRef buffer = [self pixelBufferFromCGImage:[frame CGImage] andSize:frame.size];
        if ( _adaptor.assetWriterInput.readyForMoreMediaData )
        {
            CFTimeInterval currentTime = CACurrentMediaTime();
            !_initTime && ( _initTime = currentTime );
            int64_t frameTime = ( currentTime - _initTime ) * kPreferredFPS;

            if ( frameTime != lastFrameTime )
            {
                CMTime presentTime = CMTimeMake( frameTime, kPreferredFPS );
                BOOL res = [_adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                if ( !res )
                {
                    NSLog( @"Skipping frame!" );
                }
            }
            lastFrameTime = frameTime;
        }
        if ( buffer )
        {
            CVBufferRelease( buffer );
        }
    }
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    static CMSampleTimingInfo pInfo[ 3 ];

    if ( self.isRecording )
    {
        CMItemCount count;
        // CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &count);
        // CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
        CMSampleBufferGetSampleTimingInfoArray( sampleBuffer, 3, pInfo, &count );
        for ( CMItemCount i = 0; i < count; i++ )
        {
            pInfo[i].decodeTimeStamp = kCMTimeZero; // _presentationTime;
            pInfo[i].presentationTimeStamp = kCMTimeZero; // _presentationTime;
        }
        CMSampleBufferRef syncedSample;
        CMSampleBufferCreateCopyWithNewTiming( kCFAllocatorDefault, sampleBuffer, count, pInfo, &syncedSample );
        // free(pInfo);
        CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp( syncedSample );
        if ( !_assetWriterAudioInput.readyForMoreMediaData )
        {
            NSLog( @"Had to drop an audio frame %@", CFBridgingRelease( CMTimeCopyDescription( kCFAllocatorDefault, currentSampleTime )));
        }
        else if ( _videoWriter.status == AVAssetWriterStatusWriting )
        {
            if ( ![_assetWriterAudioInput appendSampleBuffer:syncedSample] )
            {
                NSLog( @"Problem appending audio buffer at time: %@", CFBridgingRelease( CMTimeCopyDescription( kCFAllocatorDefault, currentSampleTime )));
            }
        }
        CFRelease( syncedSample );
    }

}


- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image andSize:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate( kCFAllocatorDefault, size.width,
                                           size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options,
                                           &pxbuffer );

    status = status; // Added to make the stupid compiler not show a stupid warning.
    NSParameterAssert( status == kCVReturnSuccess && pxbuffer != NULL );

    CVPixelBufferLockBaseAddress( pxbuffer, 0 );
    void *pxdata = CVPixelBufferGetBaseAddress( pxbuffer );
    NSParameterAssert( pxdata != NULL );

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate( pxdata, size.width,
                                                  size.height, 8, 4 * size.width, rgbColorSpace,
                                                  (CGBitmapInfo)kCGImageAlphaNoneSkipFirst );
    NSParameterAssert( context );

    // CGContextTranslateCTM(context, 0, CGImageGetHeight(image));
    // CGContextScaleCTM(context, 1.0, -1.0);//Flip vertically to account for different origin

    CGContextDrawImage( context, CGRectMake( 0, 0, CGImageGetWidth( image ),
                                             CGImageGetHeight( image )), image );
    CGColorSpaceRelease( rgbColorSpace );
    CGContextRelease( context );

    CVPixelBufferUnlockBaseAddress( pxbuffer, 0 );

    return pxbuffer;
}


- (BOOL)isRecording
{
    return _isRecording;
}


- (void)setIsRecording:(BOOL)isRecording
{
    _isRecording = isRecording;
}


- (dispatch_queue_t)recordQueue
{
    return _recordQueue;
}


- (void)setRecordQueue:(dispatch_queue_t)recordQueue
{
    _recordQueue = recordQueue;
}


@end
