//
//  ViewController.h
//  HomeCamera
//
//  Created by Leonid Mesentsev on 5/25/13.
//  Copyright (c) 2013 Leonid Mesentsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionJpegImageView.h"
#import "PreferenceViewController.h"


@interface CameraViewController : UIViewController <UIGestureRecognizerDelegate, PreferenceViewControllerDelegate> {
	
	
	NSString *cameraURL;
	
	IBOutlet MotionJpegImageView *imageView;
	
	
}

- (void)preferenceViewControllerDone:(PreferenceViewController *)controller;


@end
