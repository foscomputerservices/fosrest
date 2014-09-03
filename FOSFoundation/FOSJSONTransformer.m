//
//  FOSJSONTransformer.m
//  FOSFoundation
//
//  Created by David Hunt on 7/21/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSJSONTransformer.h"

@implementation FOSJSONTransformer

// The type returned from transformedValue:; must be NSData as that what
// is stored in the CoreData table.
+ (Class)transformedValueClass {
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

// Transform from (localValue) JSON to transformedValueClass (for CoreData)
- (id)transformedValue:(id)jsonValue {
    NSData *result = nil;

    if (jsonValue != nil) {
        result = [NSJSONSerialization dataWithJSONObject:jsonValue options:0 error:nil];
    }

    return result;
}

// Transform from transformedValueClass (from CoreData) to (localValue) JSON
- (id)reverseTransformedValue:(id)coreDataValue {
    id<NSObject> result = nil;

    if (coreDataValue != nil) {
        id<NSObject> json = nil;

        // From CoreData
        if ([coreDataValue isKindOfClass:[NSData class]]) {
            json = [NSJSONSerialization JSONObjectWithData:coreDataValue
                                                   options:0
                                                     error:nil];
        }

        else {
            NSString *msgFmt = @"Unable to transform type '%@' into JSON";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             NSStringFromClass([coreDataValue class])];

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

// Transform from (localValue) JSON to NSString to send to Web Service
- (NSString *)webServiceValueFromLocalValue:(id)jsonValue error:(NSError **)error {
    NSString *result = nil;
    NSError *localError = nil;

    if (error != nil) { *error = nil; }

    if (jsonValue != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonValue
                                                           options:0
                                                             error:&localError];

        if (jsonData != nil && localError == nil) {
            result = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
        }
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }

    return result;
}

// Transform from Web Service (JSON String) to NSObject-based json
- (id)localValueFromWebServiceValue:(NSString *)webServiceValue
                              error:(NSError **)error {
    id result = nil;
    NSError *localError = nil;

    if (error != nil) { *error = nil; }

    if (webServiceValue != nil) {
        NSData *jsonData = [webServiceValue dataUsingEncoding:NSUTF8StringEncoding];

        result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                 options:0
                                                   error:&localError];
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }

    return  result;
}

@end
