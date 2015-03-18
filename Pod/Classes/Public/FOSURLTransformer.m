//
//  FOSURLTransformer.m
//  FOSREST
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

            NSException *e = [NSException exceptionWithName:@"FOSREST"
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
