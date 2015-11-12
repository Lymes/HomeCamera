//
//  MotionJpegImageView+Recording.h
//  homecamera
//
//  Created by Leonid Mesentsev on 29/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "MotionJpegImageView.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioStreamManager.h"


@interface MotionJpegImageView (Recording) <AudioListener>

@property (nonatomic) BOOL isRecording;
@property dispatch_queue_t recordQueue;

- (void)startRecordingToFile:(NSString *)path;
- (void)stopRecording;

- (void)pushFrame:(UIImage *)frame;
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
