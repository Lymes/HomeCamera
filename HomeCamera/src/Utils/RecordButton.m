//
//  RecordButton.m
//  homecamera
//
//  Created by Marco Oliva on 30/10/14.
//  Copyright (c) 2014 Leonid Mesentsev. All rights reserved.
//

#import "RecordButton.h"


@interface RecordButton ()

@property CAShapeLayer *circleShape;

@end


@implementation RecordButton


- (void)awakeFromNib
{
    self.layer.cornerRadius = self.frame.size.height / 2;
}


- (BOOL)isAnimating
{
    return self.layer.animationKeys.count > 0;
}


- (void)animate:(BOOL)flag
{
    if ( flag )
    {
        UIColor *stroke = [UIColor colorWithWhite:0.8 alpha:0.8];

        CGRect pathFrame = CGRectMake( -CGRectGetMidX( self.bounds ), -CGRectGetMidY( self.bounds ), self.bounds.size.width, self.bounds.size.height );
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];

        // accounts for left/right offset and contentOffset of scroll view
        CGPoint shapePosition = [self convertPoint:self.center fromView:nil];

        if ( !self.circleShape )
        {
            self.circleShape = [CAShapeLayer layer];
            self.circleShape.path = path.CGPath;
            self.circleShape.position = shapePosition;
            self.circleShape.fillColor = [UIColor clearColor].CGColor;
            self.circleShape.opacity = 0;
            self.circleShape.strokeColor = stroke.CGColor;
            self.circleShape.lineWidth = 3;

            [self.layer addSublayer:self.circleShape];
        }

        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale( 2.5, 2.5, 1 )];

        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @1;
        alphaAnimation.toValue = @0;

        CAAnimationGroup *animation = [CAAnimationGroup animation];
        animation.animations = @[scaleAnimation, alphaAnimation];
        animation.duration = 0.9f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.repeatCount = NSIntegerMax;
        [self.circleShape addAnimation:animation forKey:nil];

        self.alpha = 1;
    }

    else
    {
        [self.circleShape removeAllAnimations];
    }
}


@end
