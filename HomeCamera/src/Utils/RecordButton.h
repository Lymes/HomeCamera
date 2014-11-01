//
//  RecordButton.h
//  homecamera
//
//  Created by Marco Oliva on 30/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordButton : UIButton

- (BOOL)isAnimating;
- (void)animate:(BOOL)flag;

@end
