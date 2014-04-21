//
//  UIColorRGBValueTransformer.m
//  VB-MAPP
//
//  Created by Gabelmann Fredrick on 2/5/12.
//  Copyright (c) 2012 Reticent Media, Inc. All rights reserved.
//

#import "UIColorRGBValueTransformer.h"

@implementation UIColorRGBValueTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (value == nil)
        return nil;

#if defined(TARGET_OS_IPHONE) || defined(TARGET_IPHONE_SIMULATOR)
    UIColor *color = value;
#else
    NSColor *color = value;
#endif

    const CGFloat *components = CGColorGetComponents(color.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f",
                               components[0], components[1], components[2], components[3]];
    
    return [colorAsString dataUsingEncoding:NSUTF8StringEncoding];
}


- (id)reverseTransformedValue:(id)value
{
    if (value == nil)
        return nil;
    
    NSString *colorAsString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    NSArray *components = [colorAsString componentsSeparatedByString:@","];
    CGFloat r = [components[0] floatValue];
    CGFloat g = [components[1] floatValue];
    CGFloat b = [components[2] floatValue];
    CGFloat a = [components[3] floatValue];

#if defined(TARGET_OS_IPHONE) || defined(TARGET_IPHONE_SIMULATOR)
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
#else
    return [NSColor colorWithDeviceRed:r green:g blue:b alpha:a];
#endif

}

@end
