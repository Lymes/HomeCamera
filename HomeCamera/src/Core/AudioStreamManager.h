//
//  AudioStreamManager.h
//  homecamera
//
//  Created by Leonid Mesentsev on 27/10/15.
//  Copyright (c) 2015 Leonid Mesentsev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ASM AudioStreamManager.sharedInstance

@interface AudioStreamManager : NSObject

@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readonly) BOOL isPlaying;

+ (AudioStreamManager *)sharedInstance;

- (void)play;
- (void)stop;

@end
