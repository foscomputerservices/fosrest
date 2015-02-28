//
//  FOSParseCachedManagedObject+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 1/2/13.
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

#import "FOSParseCachedManagedObject+FOS_Internal.h"

@implementation FOSParseCachedManagedObject (FOS_Internal)

// TODO : Move to bindings
+ (NSString *)jsonOrderProp {
    return @"createdAt";
}

#pragma mark - Overrides

+ (id)objectForAttribute:(NSAttributeDescription *)attrDesc forJsonValue:(id)jsonValue {
    id jsonVal = [jsonValue isKindOfClass:[NSNull class]] ? nil : jsonValue;
    id result = nil;

    if (jsonVal != nil && attrDesc.attributeType == NSTransformableAttributeType) {

        NSAssert([jsonVal isKindOfClass:[NSDictionary class]], @"Expected a dictionary!");

        NSValueTransformer *transformer =
            [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

        Class xFormClass = [[transformer class] transformedValueClass];

        if (![xFormClass isSubclassOfClass:[NSData class]] &&
            ![xFormClass isSubclassOfClass:[NSString class]]) {
            NSString *msg = NSLocalizedString(@"The NSValueTransformer '%@' must transform to/from an NSData or NSString instance (found %@) on attribute '%@' of entity '%@'.", @"FOSBad_Transformer");

            [NSException raise:@"FOSBad_Transformer" format:msg,
             NSStringFromClass([transformer class]),
             NSStringFromClass([[transformer class] transformedValueClass]),
             attrDesc.name, attrDesc.entity.name];
        }

        if ([xFormClass isSubclassOfClass:[NSData class]]) {
            NSDictionary *dataDict = (NSDictionary *)jsonVal;
            NSAssert([dataDict[@"__type"] isEqualToString:@"Bytes"], @"Incorrect binary dictionary format.");
            NSAssert(dataDict[@"base64"] != nil, @"Incorrect binary dictionary format.");
            
            NSString *base64ByteString = dataDict[@"base64"];

            NSData *data = [NSData dataFromBase64String:base64ByteString];

            result = [transformer reverseTransformedValue:data];
        }
        else {
            result = [transformer reverseTransformedValue:jsonVal];
        }
    }
    else if (jsonVal != nil && attrDesc.attributeType == NSDateAttributeType) {
        NSAssert([jsonVal isKindOfClass:[NSDictionary class]], @"Expected a dictionary!");

        NSDictionary *dateDict = (NSDictionary *)jsonVal;
        NSAssert([dateDict[@"__type"] isEqualToString:@"Date"], @"Incorrect date dictionary format.");

        NSString *formattedDate = dateDict[@"iso"];

        NSDateFormatter *formatter = [[self class] _fromServerDateFormatter];

       result = [formatter dateFromString:formattedDate];
    }
    else {
        result = [super objectForAttribute:attrDesc forJsonValue:jsonVal];
    }

    return result;
}

+ (id)jsonValueForObject:(id)objValue forAttribute:(NSAttributeDescription *)attrDesc {
    id result = objValue;

    if (objValue != nil && attrDesc.attributeType == NSTransformableAttributeType) {

        NSValueTransformer *transformer =
            [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

        Class xFormClass = [[transformer class] transformedValueClass];

        if (![xFormClass isSubclassOfClass:[NSData class]] &&
            ![xFormClass isSubclassOfClass:[NSString class]]) {
            NSString *msg = NSLocalizedString(@"The NSValueTransformer '%@' must transform to/from an NSData or NSString instance (found %@) on attribute '%@' of entity '%@'.", @"FOSBad_Transformer");

            [NSException raise:@"FOSBad_Transformer" format:msg,
             NSStringFromClass([transformer class]),
             NSStringFromClass([[transformer class] transformedValueClass]),
             attrDesc.name, attrDesc.entity.name];
        }

        if ([xFormClass isSubclassOfClass:[NSData class]]) {
            NSData *data = [transformer transformedValue:objValue];

            NSString *base64ByteString = [data base64EncodedString];

            result = @{ @"__type" : @"Bytes", @"base64" : base64ByteString };
        }
        else {
            result = [transformer transformedValue:objValue];
        }
    }
    else if (objValue != nil && [result isKindOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)objValue;

        result = [self parseJsonValueForDate:date];
    }
    else {
        result = [super jsonValueForObject:objValue forAttribute:attrDesc];
    }

    return result;
}

#pragma mark - Public Class Methods

+ (id<NSObject>)parseJsonValueForDate:(NSDate *)date {
    NSDateFormatter *formatter = [[self class] _toServerDateFormatter];
    
    NSString *formattedDate = [formatter stringFromDate:date];
    
    NSDictionary *result = @{ @"__type" : @"Date", @"iso" : formattedDate };

    return result;
}

#pragma mark - Validation

#ifdef needed
// This code is ***incredibly expensive***
- (BOOL)validateObjectId:(id *)objId error:(NSError * __autoreleasing *)error {
    BOOL result = YES;

    if (*objId != nil) {
        // There should not be another object with this id in the database
        FOSJsonId jsonId = (FOSJsonId)*objId;

        id other = [[self class] fetchWithId:jsonId];
        result = (other == nil || (other == self));
    }

    if (!result && error) {
        NSString *msg = NSLocalizedString(@"Encountered duplicate objectId %@ for entity '%@': %@", @"");
        FOSLogDebug(msg, (NSString *)*objId, self.entity.name, self.description);

        msg = [NSString stringWithFormat:msg, (NSString *)*objId, self.entity.name, self.description];

        *error = [NSError errorWithMessage:msg];

    }

    return result;
}
#endif

#pragma mark - Private methods

+ (NSString *)_parseDateFormat {
    return @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'";
}

+ (NSDateFormatter *)_toServerDateFormatter {
    static NSDateFormatter *serverFormatter = nil;

    // Cache the instance according to Apple's documentation.
    // (see https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html)
    if (serverFormatter == nil) {
        serverFormatter = [[NSDateFormatter alloc] init];
        serverFormatter.dateFormat = [self _parseDateFormat];
        serverFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }

    return serverFormatter;
}

+ (NSDateFormatter *)_fromServerDateFormatter {
    static NSDateFormatter *localFormatter = nil;

    // Cache the instance according to Apple's documentation.
    // (see https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html)
    if (localFormatter == nil) {
        localFormatter = [[NSDateFormatter alloc] init];
        localFormatter.dateFormat = [self _parseDateFormat];
        localFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }

    return localFormatter;
}

@end
