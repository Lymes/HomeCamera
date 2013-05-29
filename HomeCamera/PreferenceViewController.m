//
//  PreferenceViewController.m
//  HomeCamera
//
//  Created by Leonid Mesentsev on 5/29/13.
//  Copyright (c) 2013 Leonid Mesentsev. All rights reserved.
//

#import "PreferenceViewController.h"
#import <QuartzCore/QuartzCore.h>


@implementation PreferenceViewController

@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Remove border
	self.doneButtonView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	
	// Creation of the Toolbar and setting of Tine Color
	UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 300, 44)];
	toolbar.tintColor  = [UIColor colorWithRed:0.2156 green:0.4313 blue:0.9137 alpha:1.0];
	// Creation of Bar Button Item
	UIBarButtonItem *item = [UIBarButtonItem new];
	item.width = 290;
	//Bar Button Style setting
	item.title = @"Готово";
	item.style = UIBarButtonItemStylePlain;
	// Attaching the Action method through selector
	item.action = @selector(done:);
	//Style of toolbar
	
	toolbar.items = [NSArray arrayWithObject:item];
	toolbar.layer.masksToBounds = YES;
	toolbar.layer.cornerRadius  = 15.0;
	toolbar.layer.borderWidth   = 2.0;
	toolbar.layer.borderColor   = [[UIColor colorWithRed:0.2156 green:0.4313 blue:0.9137 alpha:1.0] CGColor];
	// Adding to the View
	[self.doneButtonView.contentView addSubview:toolbar];
	item    = nil;
	toolbar = nil;
	
	self.internetAddress.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"internetAddress"];
	self.localAddress.text    = [[NSUserDefaults standardUserDefaults] stringForKey:@"localAddress"];
	self.userName.text        = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
	self.password.text        = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	self.localSet.on          = [[NSUserDefaults standardUserDefaults] boolForKey:@"useLocalAddress"];
}



- (IBAction)done:(id)sender
{
	[self.delegate preferenceViewControllerDone:self];
	//[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
