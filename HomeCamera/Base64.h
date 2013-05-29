//
//  Base64.h
//  HomeCamera
//
//  Created by Leonid Mesentsev on 5/29/13.
//  Copyright (c) 2013 Leonid Mesentsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject

+ (NSString *)encode:(NSData *)plainText;

@end
