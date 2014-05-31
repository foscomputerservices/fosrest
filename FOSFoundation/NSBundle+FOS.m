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
    static NSBundle* __fosFrameworkBundle = nil;
    static dispatch_once_t __fosDispatchOnceBundle;
    dispatch_once(&__fosDispatchOnceBundle, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[FOSRESTConfig class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"FOSFoundation.bundle"];
        __fosFrameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return __fosFrameworkBundle;
}

+ (NSManagedObjectModel *)fosManagedObjectModel {
    // FOSFoundation
    NSBundle *fosBundle = [NSBundle fosFrameworkBundle];
    NSURL *modelURL = [fosBundle URLForResource:@"FOSFoundation" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return model;
}

@end
