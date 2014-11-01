//
//  PSToggleSwitchSpecifier.m
//  InAppSettingsTestApp
//
//  Created by David Keegan on 11/21/09.
//  Copyright 2009 InScopeApps{+}. All rights reserved.
//

#import "InAppSettingsPSSliderSpecifierCell.h"
#import "InAppSettingsConstants.h"

@implementation InAppSettingsPSSliderSpecifierCell

- (NSString *)resolutionIndependentImagePath:(NSString *)path{
    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f){
        NSString *extension  = [path pathExtension];
        if([extension length] == 0){
            extension = @"png";
        }
        NSString *path2x = [[path stringByDeletingLastPathComponent]
                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@",
                                                            [[path lastPathComponent] stringByDeletingPathExtension],
                                                            extension]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path2x]){
            return path2x;
        }
    }

    NSString *extension  = [path pathExtension];
    if([extension length] == 0){
        return [NSString stringWithFormat:@"%@.png", path];
    }

    return path;
}

#pragma mark -

- (void)slideAction{
    [self.setting setValue:[NSNumber numberWithFloat:[self.valueSlider value]]];
}

- (void)setUIValues{
    [super setUIValues];

    //get the abolute path to the images
    NSString *minImagePath = [self resolutionIndependentImagePath:[InAppSettingsBundlePath stringByAppendingPathComponent:[self.setting valueForKey:@"MinimumValueImage"]]];
    NSString *maxImagePath = [self resolutionIndependentImagePath:[InAppSettingsBundlePath stringByAppendingPathComponent:[self.setting valueForKey:@"MaximumValueImage"]] ];
    
    //setup the slider
    self.valueSlider.minimumValue = [[self.setting valueForKey:InAppSettingsSpecifierMinimumValue] floatValue];
    self.valueSlider.maximumValue = [[self.setting valueForKey:InAppSettingsSpecifierMaximumValue] floatValue];
    self.valueSlider.minimumValueImage = [UIImage imageWithContentsOfFile:minImagePath];
    self.valueSlider.maximumValueImage = [UIImage imageWithContentsOfFile:maxImagePath];
    CGRect valueSliderFrame = self.valueSlider.frame;
    valueSliderFrame.origin.x = InAppSettingsCellPadding;
    valueSliderFrame.size.width = CGRectGetWidth(self.contentView.bounds)-InAppSettingsCellPadding*2;
    valueSliderFrame.origin.y = (CGFloat)round(CGRectGetMidY(self.contentView.bounds)-round(valueSliderFrame.size.height*0.5));
    self.valueSlider.frame = valueSliderFrame;
    
    self.valueSlider.value = [[self.setting getValue] floatValue];
}

- (void)setupCell{
    [super setupCell];
    
    //create the slider
    self.valueSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];  //Fix required for iOS7    
    self.valueSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.valueSlider addTarget:self action:@selector(slideAction) forControlEvents:UIControlEventTouchUpInside+UIControlEventTouchUpOutside];
    [self.contentView addSubview:self.valueSlider];
}


@end
