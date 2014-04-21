//
//  FOSSharedBindingReference.m
//  FOSFoundation
//
//  Created by David Hunt on 3/22/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSSharedBindingReference.h"

@implementation FOSSharedBindingReference

#pragma mark - Class Methods

+ (instancetype)referenceWithBindingType:(NSString *)bindingType
                           andIdentifier:(NSString *)identifier {
    FOSSharedBindingReference *result = [[FOSSharedBindingReference alloc] init];
    result.bindingType = bindingType;
    result.identifier = identifier;

    return result;
}

@end
