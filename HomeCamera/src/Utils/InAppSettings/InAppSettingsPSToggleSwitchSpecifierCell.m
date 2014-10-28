//
//  PSToggleSwitchSpecifier.m
//  InAppSettingsTestApp
//
//  Created by David Keegan on 11/21/09.
//  Copyright 2009 InScopeApps{+}. All rights reserved.
//

#import "InAppSettingsPSToggleSwitchSpecifierCell.h"
#import "InAppSettingsConstants.h"

@implementation InAppSettingsPSToggleSwitchSpecifierCell

//    The value associated with the preference when the toggle switch 
//    is in the ON position. The value type for this key can be any 
//    scalar type, including Boolean, String, Number, Date, or Data. 
//    If this key is not present, the default value type is a Boolean.

- (BOOL)getBool{
    id value = [self.setting getValue];
    id trueValue = [self.setting valueForKey:@"TrueValue"];
    id falseValue = [self.setting valueForKey:@"FalseValue"];
    
    if([value isEqual:trueValue]){
        return YES;
    }
    
    if([value isEqual:falseValue]){
        return NO;
    }
    
    //if there is no true or false values the value has to be a bool
    return [value boolValue];
}

- (void)setBool:(BOOL)newValue{
    id value = [NSNumber numberWithBool:newValue];
    if(newValue){
        id trueValue = [self.setting valueForKey:@"TrueValue"];
        if(trueValue){
            value = trueValue;
        }
    }
    else{
        id falseValue = [self.setting valueForKey:@"FalseValue"];
        if(falseValue){
            value = falseValue;
        }
    }
    [self.setting setValue:value];
}

- (void)switchAction{
    [self setBool:[self.valueSwitch isOn]];
}

- (void)setUIValues{
    [super setUIValues];
    
    [self setTitle];
    self.valueSwitch.on = [self getBool];
}

- (void)layoutSubviews{
	[super layoutSubviews];

    CGRect valueSwitchFrame = self.valueSwitch.frame;
    valueSwitchFrame.origin.y = CGRectGetMidY(self.contentView.bounds)-CGRectGetMidY(self.valueSwitch.bounds);
    valueSwitchFrame.origin.x = CGRectGetWidth(self.contentView.bounds)-CGRectGetWidth(valueSwitchFrame)-InAppSettingsCellPadding;
    self.valueSwitch.frame = CGRectIntegral(valueSwitchFrame);
}

- (void)setupCell{
    [super setupCell];
    
    //create the switch
    self.valueSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.valueSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.valueSwitch];
}

@end
