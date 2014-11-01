//
//  InAppSettingsTableCell.m
//  InAppSettingsTestApp
//
//  Created by David Keegan on 11/21/09.
//  Copyright 2009 InScopeApps{+}. All rights reserved.
//

#import "InAppSettingsTableCell.h"
#import "InAppSettingsConstants.h"

@implementation InAppSettingsTableCell

@synthesize setting;
@synthesize titleLabel, valueLabel;
@synthesize valueInput;
@synthesize canSelectCell;

#pragma mark Cell lables

- (void)setTitle{
    self.titleLabel.text = [self.setting localizedTitle];
}

- (void)setDetail{
    [self setDetail:[self.setting getValue]];
}

- (void)setDetail:(NSString *)detail{
    //the detail is not localized
    self.valueLabel.text = detail;
}

- (void)setDisclosure:(BOOL)disclosure{
    if(disclosure){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setCanSelectCell:(BOOL)value{
    if(value){
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }else{
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    canSelectCell = value;
}

- (void)layoutSubviews{
	[super layoutSubviews];

//    self.contentView.backgroundColor = [UIColor blueColor];

    // title view
//iOS7: Updating sizeWithFont (depreciated) to sizeWithAttributes
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        CGSize titleSize = [self.titleLabel.text sizeWithAttributes:
                             @{NSFontAttributeName:[UIFont systemFontOfSize:InAppSettingsFontSize]}];
#else
        CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
#endif

    CGFloat maxTitleWidth = InAppSettingsCellTitleMaxWidth;
    if([self.setting isType:InAppSettingsPSToggleSwitchSpecifier]){
        maxTitleWidth = InAppSettingsCellTitleMaxWidth-(InAppSettingsCellToggleSwitchWidth+InAppSettingsCellPadding);
    }
    if(titleSize.width > maxTitleWidth){
        titleSize.width = maxTitleWidth;
    }

    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.size = titleSize;
    titleFrame.origin.x = InAppSettingsCellPadding;
    titleFrame.origin.y = (CGFloat)round(CGRectGetMidY(self.contentView.bounds)-(titleSize.height*0.5f));
    self.titleLabel.frame = titleFrame;

    // detail view
    CGRect valueFrame = self.valueLabel.frame;
    //iOS7: Updating sizeWithFont (depreciated) to sizeWithAttributes
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    CGSize valueSize = [self.valueLabel.text sizeWithAttributes:
                        @{NSFontAttributeName:[UIFont systemFontOfSize:InAppSettingsFontSize]}];
#else
    CGSize valueSize = [self.valueLabel.text sizeWithFont:self.valueLabel.font];
#endif

    CGFloat titleRightSide = CGRectGetWidth(self.titleLabel.bounds)+InAppSettingsTablePadding;
    CGFloat valueMaxWidth = CGRectGetWidth(self.contentView.bounds)-(titleRightSide+InAppSettingsTablePadding+InAppSettingsCellPadding*3);
    if(valueSize.width > valueMaxWidth){
        valueSize.width = valueMaxWidth;
    }

    if(!InAppSettingsUseNewMultiValueLocation && [self.setting isType:InAppSettingsPSMultiValueSpecifier] && [[self.setting localizedTitle] length] == 0){
        valueFrame.origin.x = InAppSettingsCellPadding;
    }else{
        valueFrame.origin.x = CGRectGetWidth(self.contentView.bounds)-valueSize.width-InAppSettingsCellPadding;
        if(titleRightSide >= valueFrame.origin.x){
            valueFrame.origin.x = titleRightSide;
        }
    }
    valueFrame.origin.y = (CGFloat)round(CGRectGetMidY(self.contentView.bounds)-(valueSize.height*0.5f));
    valueFrame.size.width = CGRectGetWidth(self.contentView.bounds)-valueFrame.origin.x-InAppSettingsCellPadding;

    //if the width is less then 0 just hide the label
    if(valueFrame.size.width <= 0){
        self.valueLabel.hidden = YES;
    }else{
        self.valueLabel.hidden = NO;
    }
    valueFrame.size.height = valueSize.height;
    self.valueLabel.frame = valueFrame;
}

#pragma mark -

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    //the docs say UITableViewCellStyleValue1 is used for settings, 
    //but it doesn't look 100% the same so we will just draw our own UILabels
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self != nil){
        self.canSelectCell = NO;
    }
    
    return self;
}

#pragma mark implement in cell

- (void)setUIValues{
    //implement this per cell type
}

- (void)setValueDelegate:(id)delegate{
    //implement in cell
}

- (void)setupCell{
    //setup title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.titleLabel.font = InAppSettingsNormalFont;                 //changed from Bold to Normal for iOS7
    } else {
        self.titleLabel.font = InAppSettingsBoldFont;
    }
    self.titleLabel.highlightedTextColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
//    self.titleLabel.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:self.titleLabel];
    
    //setup value label
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.valueLabel.font = InAppSettingsNormalFont;
    self.valueLabel.textColor = InAppSettingsBlue;
    self.valueLabel.highlightedTextColor = [UIColor whiteColor];
    self.valueLabel.backgroundColor = [UIColor clearColor];
//    self.valueLabel.backgroundColor = [UIColor redColor];    
    self.valueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:self.valueLabel];
}

@end
