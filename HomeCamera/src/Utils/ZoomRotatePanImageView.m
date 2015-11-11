//
//  ZoomRotatePanImageView.m
//
//
//  Created by bennythemink on 20/07/12.
//  Copyright (c) 2012 bennythemink. All rights reserved.
//

#import "ZoomRotatePanImageView.h"

@interface ZoomRotatePanImageView ()
- (void)setUpGestures;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recogniser;
- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recogniser;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recogniser;
- (IBAction)handleTap:(UITapGestureRecognizer *)recogniser;
@end

@implementation ZoomRotatePanImageView

#pragma mark - Initialisation Overrides

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if ( self )
    {
        [self setUpGestures];
    }
    return self;
}


- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if ( self )
    {
        [self setUpGestures];
    }
    return self;
}


- (id)init
{
    self = [super init];
    if ( self )
    {
        [self setUpGestures];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        [self setUpGestures];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self setUpGestures];
    }
    return self;
}


#pragma mark - Utility Methods

- (void)setUpGestures
{

    [self setUserInteractionEnabled:TRUE];
    _pinchRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    _rotateRecogniser = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    _panRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panRecogniser.minimumNumberOfTouches = 2;
    
    _tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapRecogniser.numberOfTapsRequired = 2;

    [_pinchRecogniser setDelegate:self];
    [_rotateRecogniser setDelegate:self];
    [_panRecogniser setDelegate:self];
    [_tapRecogniser setDelegate:self];

    [self addGestureRecognizer:_pinchRecogniser];
    [self addGestureRecognizer:_rotateRecogniser];
    [self addGestureRecognizer:_panRecogniser];
    [self addGestureRecognizer:_tapRecogniser];

    // set the aspect ratio mode
    [self setContentMode:UIViewContentModeScaleAspectFit];
}


- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recogniser
{
    recogniser.view.transform = CGAffineTransformScale( recogniser.view.transform, recogniser.scale, recogniser.scale );
    recogniser.scale = 1;
}


- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recogniser
{
    recogniser.view.transform = CGAffineTransformRotate( recogniser.view.transform, recogniser.rotation );
    recogniser.rotation = 0;
}


- (IBAction)handleTap:(UITapGestureRecognizer *)recogniser
{
    [self resetWithAnimation:TRUE];
}


- (IBAction)handlePan:(UIPanGestureRecognizer *)recogniser
{

    if ( recogniser.state == UIGestureRecognizerStateBegan || recogniser.state == UIGestureRecognizerStateChanged )
    {
        CGPoint translation = [recogniser translationInView:self];
        // CGPoint translatedCenter = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        // [self setCenter:translatedCenter];
        recogniser.view.transform = CGAffineTransformTranslate( recogniser.view.transform, translation.x, translation.y );
        [recogniser setTranslation:CGPointZero inView:self];
    }
}


- (void)reset
{
    self.transform = CGAffineTransformIdentity;
    self.center = self.superview.center;
}


- (void)resetWithAnimation:(BOOL)animation
{

    if ( !animation )
    {
        [self reset];
    }
    else
    {
        [UIView animateWithDuration:.25 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.center = self.superview.center;
        }];
    }
}


#pragma mark - UIGestureRecognizer Delegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}


@end
