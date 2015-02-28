//
//  FOSJSONTransformer.m
//  FOSFoundation
//
//  Created by David Hunt on 7/21/14.
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

#import <FOSJSONTransformer.h>

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
