//
//  FOSURLTransformer.m
//  FOSFoundation
//
//  Created by David Hunt on 7/21/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSURLTransformer.h>

@implementation FOSURLTransformer
+ (Class)transformedValueClass {
    return [NSURL class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

// Transform from local value to WebService value
- (id)transformedValue:(NSURL *)localValue {
    NSData *result = nil;

    if (localValue != nil) {
        result = [localValue.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
    }

    return result;
}

// Transform from WebService value to local value
- (id)reverseTransformedValue:(id)webServiceValue {
    NSURL *result = nil;

    if (webServiceValue != nil) {
        NSString *absoluteString = nil;

        // From CoreData
        if ([webServiceValue isKindOfClass:[NSData class]]) {
            absoluteString = [[NSString alloc] initWithData:(NSData *)webServiceValue
                                                   encoding:NSUTF8StringEncoding];
        }

        // From WebService
        else if ([webServiceValue isKindOfClass:[NSString class]]) {
            absoluteString = (NSString *)webServiceValue;
        }
        else {
            NSString *msgFmt = @"Unable to transform type '%@' into NSURL";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             NSStringFromClass([webServiceValue class])];

            NSException *e = [NSException exceptionWithName:@"FOSFoundation"
                                                     reason:msg
                                                   userInfo:nil];
            @throw e;
        }

        if (absoluteString != nil) {
            result = [NSURL URLWithString:absoluteString];
        }
    }
    
    return result;
}

@end
