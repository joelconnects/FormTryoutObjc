//
//  UIColor+Extensions.m
//  TextFieldNonsense
//
//  Created by Joel Bell on 3/29/16.
//  Copyright © 2016 Joel Bell. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor *)defaultAppleGray {
    return [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
}
+ (UIColor *)defaultAppleBlue {
    return [UIColor colorWithRed:0/255.0 green:120.0/255.0 blue:251.0/255.0 alpha:1.0];
}

+ (UIColor *)placeholderPurple {
    return [UIColor colorWithRed:223.0/255.0 green:207.0/255.0 blue:231.0/255.0 alpha:0.7];
}

+ (UIColor *)borderPurple {
    return [UIColor colorWithRed:255.0/255.0 green:211.0/255.0 blue:255.0/255.0 alpha:0.7];
}

+ (UIColor *)deepPinkPurple {
    return [UIColor colorWithRed:111.0/255.0 green:0.0/255.0 blue:111.0/255.0 alpha:1.0];
}

+ (UIColor *)shadowPurple {
    return [UIColor colorWithRed:80.0/255.0 green:0.0/255.0 blue:80.0/255.0 alpha:1.0];
}



@end
