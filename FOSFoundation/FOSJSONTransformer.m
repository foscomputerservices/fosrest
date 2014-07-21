//
//  FOSJSONTransformer.m
//  FOSFoundation
//
//  Created by David Hunt on 7/21/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSJSONTransformer.h"

@implementation FOSJSONTransformer

+ (Class)transformedValueClass {
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

// Transform from WebService value to local value
- (id)transformedValue:(id<NSObject>)localValue {
    NSData *result = nil;

    if (localValue != nil) {
        result = [NSJSONSerialization dataWithJSONObject:localValue options:0 error:nil];
    }

    return result;
}

// Transform from local value to WebService value
- (id)reverseTransformedValue:(id)webServiceValue {
    id<NSObject> result = nil;

    if (webServiceValue != nil) {
        id<NSObject> json = nil;

        // From CoreData
        if ([webServiceValue isKindOfClass:[NSData class]]) {
            json = [NSJSONSerialization JSONObjectWithData:webServiceValue
                                                   options:0
                                                     error:nil];
        }

        // From WebService
        else if ([webServiceValue isKindOfClass:[NSDictionary class]] ||
                 [webServiceValue isKindOfClass:[NSArray class]] ||
                 [webServiceValue isKindOfClass:[NSNumber class]] ||
                 [webServiceValue isKindOfClass:[NSString class]]) {
            json = (id<NSObject>)webServiceValue;
        }
        else {
            NSString *msgFmt = @"Unable to transform type '%@' into JSON";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             NSStringFromClass([webServiceValue class])];

            NSException *e = [NSException exceptionWithName:@"FOSFoundation"
                                                     reason:msg
                                                   userInfo:nil];
            @throw e;
        }

        if (json != nil) {
            result = json;
        }
    }
    
    return result;
}

@end
