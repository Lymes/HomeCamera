//
//  DismissSegue.m
//  homecamera
//
//  Created by Leonid Mesentsev on 29/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "DismissSegue.h"


@implementation DismissSegue


- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;

    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
