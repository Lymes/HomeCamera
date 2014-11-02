//
//  ThemeManager.m
//  homecamera
//
//  Created by Leonid Mesentsev on 01/11/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "ThemeManager.h"

@implementation ThemeManager

+ (void)load
{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITableView appearance] setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:.9f]];
}

@end
