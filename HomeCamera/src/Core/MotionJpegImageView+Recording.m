//
//  MotionJpegImageView+Recording.m
//  homecamera
//
//  Created by Leonid Mesentsev on 29/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "MotionJpegImageView+Recording.h"
#import <AVFoundation/AVFoundation.h>


#define kRecordingFPS 16

static BOOL _isRecording;

static AVAssetWriter *_videoWriter;
static AVAssetWriterInput *_videoWriterInput;
static AVAssetWriterInputPixelBufferAdaptor *_adaptor;
static NSInteger _frameCount;

static dispatch_queue_t _backgroundQueue;



@implementation MotionJpegImageView (Recording)


- (void)startRecordingToFile:(NSString *)path
{
    if ( !self.isPlaying || self.isRecording )
    {
        return;
    }

    _backgroundQueue = dispatch_queue_create( "com.lymes.homecamera.bgqueue", NULL );

    dispatch_async( _backgroundQueue, ^{
                        NSError *error = nil;

                        _videoWriter = [[AVAssetWriter alloc] initWithURL:
                                        [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
                                                                        error:&error];
                        NSParameterAssert( _videoWriter );

                        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       AVVideoCodecH264, AVVideoCodecKey,
                                                       [NSNumber numberWithInt:self.size.width], AVVideoWidthKey,
                                                       [NSNumber numberWithInt:self.size.height], AVVideoHeightKey,
                                                       nil];

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

                        // Start a session:
                        [_videoWriter startWriting];
                        [_videoWriter startSessionAtSourceTime:kCMTimeZero];

                        _frameCount = 0;
                        self.isRecording = YES;
                    } );
}


- (void)stopRecording
{
    dispatch_async( _backgroundQueue, ^{
                        self.isRecording = NO;
                        [_videoWriterInput markAsFinished];
                        [_videoWriter endSessionAtSourceTime:CMTimeMake( _frameCount, kRecordingFPS )];
                        [_videoWriter finishWritingWithCompletionHandler:^() {

                         }];
                        _videoWriterInput = nil;
                        _videoWriter = nil;
                    } );
}


- (void)pushFrame:(UIImage *)frame
{
    dispatch_async( _backgroundQueue, ^{
                        if ( self.isRecording )
                        {
                            CVPixelBufferRef buffer = [self pixelBufferFromCGImage:[frame CGImage] andSize:frame.size];
                            if ( _adaptor.assetWriterInput.readyForMoreMediaData )
                            {
                                CMTime frameTime = CMTimeMake( _frameCount++, (int32_t)kRecordingFPS );
                                BOOL res = [_adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                                if ( !res )
                                {
                                    NSLog( @"Skipping frame!" );
                                }
                            }
                            if ( buffer )
                            {
                                CVBufferRelease( buffer );
                            }
                        }
                    } );
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


@end
