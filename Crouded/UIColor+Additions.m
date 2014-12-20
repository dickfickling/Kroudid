//
//  UIColor+Additions.m
//  Crouded
//
//  Created by Scott Sirowy on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "UIColor+Additions.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0f \
green:       ((rgbValue & 0x00FF00) >>  8)/255.0f \
blue:        ((rgbValue & 0x0000FF) >>  0)/255.0f \
alpha:       1.0]

@implementation UIColor (Additions)

+ (UIColor*)crowdedBlueColor
{
    return UIColorFromRGB(0x576E91);
}

+ (UIColor*)crowdedRedColor {
    return UIColorFromRGB(0x576E91);
}

@end
