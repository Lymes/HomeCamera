//
//  PSToggleSwitchSpecifier.m
//  InAppSettingsTestApp
//
//  Created by David Keegan on 11/21/09.
//  Copyright 2009 InScopeApps{+}. All rights reserved.
//

#import "InAppSettingsPSMultiValueSpecifierCell.h"
#import "InAppSettingsConstants.h"

@implementation InAppSettingsPSMultiValueSpecifierCell

- (NSString *)getValueTitle{
    NSArray *titles = [self.setting valueForKey:InAppSettingsSpecifierTitles];
    NSArray *values = [self.setting valueForKey:InAppSettingsSpecifierValues];
    NSInteger valueIndex = [values indexOfObject:[self.setting getValue]];
    if((valueIndex >= 0) && (valueIndex < (NSInteger)[titles count])){
        return InAppSettingsLocalize([titles objectAtIndex:valueIndex], self.setting.stringsTable); 
    }
    return nil;
}

- (void)setUIValues{
    [super setUIValues];
    
    [self setTitle];
    [self setDetail:[self getValueTitle]];

    if([[self.setting valueForKey:InAppSettingsSpecifierInAppMultiType] isEqualToString:@"fonts"]){
        NSString *cellValue = [self.setting getValue];
        if([cellValue isEqualToString:@"system"]){
            self.valueLabel.font = [UIFont systemFontOfSize:InAppSettingsFontSize];
        }else{
            self.valueLabel.font = [UIFont fontWithName:cellValue size:InAppSettingsFontSize];
        }
    }
}

- (void)setupCell{
    [super setupCell];
    
    [self setDisclosure:YES];
    self.canSelectCell = YES;
}

@end
