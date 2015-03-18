//
//  UIColorRGBValueTransformer.m
//  FOSREST
//
//  Created by David Hunt on 3/17/14.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>
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
