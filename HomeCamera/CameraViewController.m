//
//  ViewController.m
//  HomeCamera
//
//  Created by Leonid Mesentsev on 5/25/13.
//  Copyright (c) 2013 Leonid Mesentsev. All rights reserved.
//

#import "CameraViewController.h"
#import "Base64.h"


enum {
	TILT_UP = 0,
	TILT_UP_STOP,
	TILT_DOWN,
	TILT_DOWN_STOP,
	PAN_LEFT,
	PAN_LEFT_STOP,
	PAN_RIGHT,
	PAN_RIGHT_STOP
};



@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	[swipeUpRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
	UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	[swipeDownRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
	UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	[swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
	[swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	
	[[self view] addGestureRecognizer:swipeUpRecognizer];
	[[self view] addGestureRecognizer:swipeDownRecognizer];
	[[self view] addGestureRecognizer:swipeLeftRecognizer];
	[[self view] addGestureRecognizer:swipeRightRecognizer];
	[[self view] addGestureRecognizer:pinchRecognizer];
	[[self view] addGestureRecognizer:tapRecognizer];

	[self play];
}


#pragma mark - Play

- (void)play
{
	NSString *urlAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"internetAddress"];
	if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"useLocalAddress"] )
	{
		urlAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"localAddress"];
	}
	NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	imageView.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/videostream.cgi?user=%@&pwd=%@", urlAddress, userName, password]];
	[imageView play];
}


#pragma mark - PreferenceViewControllerDelegate

- (void)preferenceViewControllerDone:(PreferenceViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:controller.internetAddress.text forKey:@"internetAddress"];
	[[NSUserDefaults standardUserDefaults] setObject:controller.localAddress.text forKey:@"localAddress"];
	[[NSUserDefaults standardUserDefaults] setObject:controller.userName.text forKey:@"userName"];
	[[NSUserDefaults standardUserDefaults] setObject:controller.password.text forKey:@"password"];
	[[NSUserDefaults standardUserDefaults] setBool:controller.localSet.on forKey:@"useLocalAddress"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self play];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ( [segue.identifier isEqualToString:@"Preferences"] )
	{
		PreferenceViewController *preferenceViewController = segue.destinationViewController;
		preferenceViewController.delegate = self;
	}
	[imageView stop];
}


#pragma mark - Gestures

- (void)handleTap:(UIPinchGestureRecognizer *)gestureRecognizer
{
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	frame.origin.x = 0;
	frame.origin.y = 0;
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	if ( orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight )
	{
		float tmp = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = tmp;
	}
	imageView.frame = frame;
}


- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
	{
		imageView.transform = CGAffineTransformScale([imageView transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];		
    }
}


- (void)handleSwipe:(UIGestureRecognizer *)gestureRecognizer
{
	UISwipeGestureRecognizer *mSwipeUpRecognizer = (UISwipeGestureRecognizer *)gestureRecognizer;

	if ( mSwipeUpRecognizer.direction & UISwipeGestureRecognizerDirectionUp )
	{
		[self performSelectorInBackground:@selector(turnCamera:) withObject:[NSNumber numberWithInt:TILT_DOWN]];
	}
	else if ( mSwipeUpRecognizer.direction & UISwipeGestureRecognizerDirectionDown )
	{
		[self performSelectorInBackground:@selector(turnCamera:) withObject:[NSNumber numberWithInt:TILT_UP]];
	}
	else if ( mSwipeUpRecognizer.direction & UISwipeGestureRecognizerDirectionLeft )
	{
		[self performSelectorInBackground:@selector(turnCamera:) withObject:[NSNumber numberWithInt:PAN_RIGHT]];
	}
	else if ( mSwipeUpRecognizer.direction & UISwipeGestureRecognizerDirectionRight )
	{
		[self performSelectorInBackground:@selector(turnCamera:) withObject:[NSNumber numberWithInt:PAN_LEFT]];
	}
}


- (void)turnCamera:(NSNumber *)direction
{
	int dir = [direction intValue];
	NSString *urlAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"internetAddress"];
	if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"useLocalAddress"] )
	{
		urlAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"localAddress"];
	}
	[self requestToURL:[NSString stringWithFormat:@"%@/decoder_control.cgi?command=%d", urlAddress, dir]];
	[NSThread sleepForTimeInterval:.1];
	[self requestToURL:[NSString stringWithFormat:@"%@/decoder_control.cgi?command=%d", urlAddress, dir + 1]];
}


- (void)requestToURL:(NSString *)urlStr
{
	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	NSError *myError = nil;
	
	// create a plaintext string in the format username:password
	NSString *loginString = [NSString stringWithFormat:@"%@:%@", userName, password];
	
	// employ the Base64 encoding above to encode the authentication tokens
	NSString *encodedLoginData = [Base64 encode:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
	
	// create the contents of the header
	NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", encodedLoginData];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
														   cachePolicy: NSURLRequestReloadIgnoringCacheData
													   timeoutInterval: 3];
	
	// add the header to the request.  Here's the $$$!!!
	[request addValue:authHeader forHTTPHeaderField:@"Authorization"];
	
	// perform the reqeust
	NSURLResponse *response;
	[NSURLConnection sendSynchronousRequest:request returningResponse: &response error: &myError];
}
	
@end
