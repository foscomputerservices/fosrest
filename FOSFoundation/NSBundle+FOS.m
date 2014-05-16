//
//  NSBundle+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 5/15/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "NSBundle+FOS.h"

@implementation NSBundle (FOS)

// Load the framework bundle.
+ (NSBundle *)fosFrameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[FOSRESTConfig class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"FOSFoundation.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

@end
