//
//  PSToggleSwitchSpecifier.m
//  InAppSettingsTestApp
//
//  Created by David Keegan on 11/21/09.
//  Copyright 2009 InScopeApps{+}. All rights reserved.
//

#import "InAppSettingsPSTextFieldSpecifierCell.h"
#import "InAppSettingsConstants.h"

@implementation InAppSettingsPSTextFieldSpecifierCell

#pragma mark helper methods

- (BOOL)isSecure{
    NSNumber *isSecure = [self.setting valueForKey:@"IsSecure"];
    if(!isSecure){
        return NO;
    }
    return [isSecure boolValue];
}

- (UIKeyboardType)getKeyboardType{
    NSString *keyboardType = [self.setting valueForKey:@"KeyboardType"];
    if([keyboardType isEqualToString:@"NumbersAndPunctuation"]){
        return UIKeyboardTypeNumbersAndPunctuation;
    }
    else if([keyboardType isEqualToString:@"NumberPad"]){
        return UIKeyboardTypeNumberPad;
    }
    else if([keyboardType isEqualToString:@"URL"]){
        return UIKeyboardTypeURL;
    }    
    else if([keyboardType isEqualToString:@"EmailAddress"]){
        return UIKeyboardTypeEmailAddress;
    } 
    
    return UIKeyboardTypeAlphabet;
}

- (UITextAutocapitalizationType)getAutocapitalizationType{
    NSString *autocapitalizationType = [self.setting valueForKey:@"AutocapitalizationType"];
    if([autocapitalizationType isEqualToString:@"Words"]){
        return UITextAutocapitalizationTypeWords;
    }
    else if([autocapitalizationType isEqualToString:@"Sentences"]){
        return UITextAutocapitalizationTypeSentences;
    }
    else if([autocapitalizationType isEqualToString:@"AllCharacters"]){
        return UITextAutocapitalizationTypeAllCharacters;
    }
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)getAutocorrectionType{
    NSString *autocorrectionType = [self.setting valueForKey:@"AutocorrectionType"];
    if([autocorrectionType isEqualToString:@"Yes"]){
        return UITextAutocorrectionTypeYes;
    }
    else if([autocorrectionType isEqualToString:@"No"]){
        return UITextAutocorrectionTypeNo;
    }
    return UITextAutocorrectionTypeDefault;
}

- (void)textChangeAction{
    [self.setting setValue:self.textField.text];
}

#pragma mark cell controlls

- (void)setValueDelegate:(id)delegate{
    self.textField.delegate = delegate;
    [super setValueDelegate:delegate];
}

- (void)setUIValues{
    [super setUIValues];
    
    [self setTitle];
    
    CGRect textFieldFrame = self.textField.frame;
//iOS7: Updating sizeWithFont (depreciated) to sizeWithAttributes
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:
                        @{NSFontAttributeName:[UIFont systemFontOfSize:InAppSettingsFontSize]}];
#else
    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
#endif

    textFieldFrame.origin.x = (CGFloat)round(titleSize.width+InAppSettingsTotalTablePadding);
    if(textFieldFrame.origin.x < InAppSettingsCellTextFieldMinX){
        textFieldFrame.origin.x = InAppSettingsCellTextFieldMinX;
    }
    textFieldFrame.origin.y = (CGFloat)round(CGRectGetMidY(self.contentView.bounds)-(titleSize.height*0.5f));
    textFieldFrame.size.width = (CGFloat)round((CGRectGetWidth(self.bounds)-(InAppSettingsTotalTablePadding+InAppSettingsCellPadding))-textFieldFrame.origin.x);
    textFieldFrame.size.height = titleSize.height;
    self.textField.frame = textFieldFrame;
    self.textField.text = [self.setting getValue];
    
    //keyboard traits
    self.textField.secureTextEntry = [self isSecure];
    self.textField.keyboardType = [self getKeyboardType];
    self.textField.autocapitalizationType = [self getAutocapitalizationType];
    self.textField.autocorrectionType = [self getAutocorrectionType];
    
    //these are set here so they are set per cell
    self.valueInput = self.textField;
}

- (void)setupCell{
    [super setupCell];
    
    //create text field
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.textColor = InAppSettingsBlue;
    self.textField.adjustsFontSizeToFitWidth = YES;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //THIS IS NOT THE BEHAVIOR OF THE SETTINGS APP
    //but we need a way to dismiss the keyboard
    self.textField.returnKeyType = UIReturnKeyDone;
    
    [self.textField addTarget:self action:@selector(textChangeAction) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.textField];
}


@end
