//
//  NSBundle+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 5/15/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <NSBundle+FOS.h>
#import "FOSRESTConfig+FOS_Internal.h"

@implementation NSBundle (FOS)

// Load the framework bundle.
+ (NSBundle *)fosFrameworkBundle {
    return [NSBundle bundleForClass:[FOSRESTConfig class]];
}

+ (NSManagedObjectModel *)fosManagedObjectModel {
    // FOSFoundation
    NSBundle *fosBundle = [NSBundle fosFrameworkBundle];
    NSURL *modelURL = [fosBundle URLForResource:@"FOSFoundation" withExtension:@"momd"];

    if (modelURL == nil) {
        NSException *e = [NSException exceptionWithName:@"FOSMissingModel" reason:@"Unable to locate the compiled Core Data model: FOSFoundation.momd" userInfo:nil];

        @throw e;
    }

    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return model;
}

@end
