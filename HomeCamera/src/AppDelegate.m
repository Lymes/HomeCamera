//
//  AppDelegate.m
//  HomeCamera
//
//  Created by Leonid Mesentsev on 5/25/13.
//  Copyright (c) 2013 Leonid Mesentsev. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraViewController.h"
#import "InAppSettings.h"
#import "BundleVersion.h"
#import "AudioStreamManager.h"


@implementation AppDelegate


+ (void)initialize
{
    if ( [self class] == [AppDelegate class] )
    {
        [InAppSettings registerDefaults];
        [[NSUserDefaults standardUserDefaults] setObject:BUNDLE_VERSION forKey:@"Version"];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    UIStoryboard *storyboard = [[[self window] rootViewController] storyboard];
    CameraViewController *controller = (CameraViewController *)[storyboard instantiateInitialViewController];

    [controller stopVideo];
    [ASM stop];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UIStoryboard *storyboard = [[[self window] rootViewController] storyboard];
    CameraViewController *controller = (CameraViewController *)[storyboard instantiateInitialViewController];

    [controller playVideo];
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"audio"] )
    {
        [controller playAudio];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
}


@end
