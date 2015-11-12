//
//  AudioStreamManager.h
//  homecamera
//
//  Created by Leonid Mesentsev on 27/10/15.
//  Copyright (c) 2015 Leonid Mesentsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


#define ASM AudioStreamManager.sharedInstance

@protocol AudioListener <NSObject>

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end


@interface AudioStreamManager : NSObject

@property (nonatomic) AudioStreamBasicDescription streamDecription;
@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, weak) id<AudioListener> audioListener;

+ (AudioStreamManager *)sharedInstance;

- (void)play;
- (void)stop;

@end
