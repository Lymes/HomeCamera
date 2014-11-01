//
//  MotionJpegImageView+Recording.h
//  homecamera
//
//  Created by Leonid Mesentsev on 29/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "MotionJpegImageView.h"

@interface MotionJpegImageView (Recording)

@property (nonatomic) BOOL isRecording;

- (void)startRecordingToFile:(NSString *)path;
- (void)stopRecording;

- (void)pushFrame:(UIImage *)frame;

@end
