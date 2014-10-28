//
//  AppDelegate.m
//  HomeCamera
//
//  Created by Leonid Mesentsev on 5/25/13.
//  Copyright (c) 2013 Leonid Mesentsev. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	UIStoryboard *storyboard = [[[self window] rootViewController] storyboard];
	CameraViewController *controller = (CameraViewController *)[storyboard instantiateInitialViewController];
	[controller stop];
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
	[controller play];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
