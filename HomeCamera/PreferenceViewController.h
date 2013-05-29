//
//  PreferenceViewController.h
//  HomeCamera
//
//  Created by Leonid Mesentsev on 5/29/13.
//  Copyright (c) 2013 Leonid Mesentsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PreferenceViewController;

@protocol PreferenceViewControllerDelegate

- (void)preferenceViewControllerDone:(PreferenceViewController *)controller;

@end


@interface PreferenceViewController : UITableViewController
	
@property (nonatomic, weak) id  delegate;
@property (strong, nonatomic) IBOutlet UISwitch *localSet;
@property (strong, nonatomic) IBOutlet UITextField *internetAddress;
@property (strong, nonatomic) IBOutlet UITextField *localAddress;
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITableViewCell *doneButtonView;

- (IBAction)done:(id)sender;

@end
