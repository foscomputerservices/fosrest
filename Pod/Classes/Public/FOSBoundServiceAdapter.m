//
//  FOSBoundServiceAdapter.m
//  FOSRest
//
//  Created by David Hunt on 3/21/14.
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

#import <FOSBoundServiceAdapter.h>
#import "FOSREST_Internal.h"

@implementation FOSBoundServiceAdapter {
    FOSAdapterBinding *_bindings;
    FOSNetworkStatusMonitor *_networkStatusMonitor;
    NSURL *_baseURL;
    NSArray *__serverDateFormatters;
}

#pragma mark - Class Methods

+ (instancetype)serviceAdapterWithBinding:(FOSAdapterBinding *)binding {
    return [[self alloc] initWithBinding:binding];
}

+ (instancetype)serviceAdapterFromBindingDescription:(NSString *)description
                                          error:(NSError *__autoreleasing *)error {
    return [[self alloc] initFromBindingDescription:description
                                              error:error];
}

+ (instancetype)serviceAdapterFromBindingFile:(NSURL *)url error:(NSError **)error {
    return [[self alloc] initFromBindingFile:url error:error];
}

+ (NSArray *)serverDateFormats {
    NSString *msg = [NSString stringWithFormat:@"Concrete subclasses of FOSBoundServiceAdapter must override and implement %@.", NSStringFromSelector(_cmd)];

    @throw [NSException exceptionWithName:@"FOSREST_MustOverride"
                                   reason:msg userInfo:nil];
}

#pragma mark - Initialization Methods

- (id)initWithBinding:(FOSAdapterBinding *)binding {
    NSParameterAssert(binding != nil);

    if ((self = [super init]) != nil) {
        _bindings = binding;
    }

    return self;
}

- (id)initFromBindingDescription:(NSString *)description error:(NSError **)error {
    NSParameterAssert(description != nil);
    if (error != nil) { *error = nil; }

    NSError *localError = nil;
    FOSAdapterBinding *adapterBinding =
        [FOSAdapterBinding parseAdapterBindingDescription:description
                                               forAdapter:self
                                                    error:&localError];

    if (adapterBinding && localError == nil) {
        self = [self initWithBinding:adapterBinding];
    }
    else {
        if (error != nil) {
            *error = localError;
        }

        self = nil;
    }

    return self;
}

- (id)initFromBindingFile:(NSURL *)url error:(NSError **)error {
    NSParameterAssert(url != nil);
    if (error != nil) { *error = nil; }

    NSError *localError = nil;
    FOSAdapterBinding *bindings = [FOSAdapterBinding parseAdapterBindings:url
                                                               forAdapter:self
                                                                    error:&localError];

    if (bindings && localError == nil) {
        self = [self initWithBinding:bindings];
    }
    else {
        if (error != nil) {
            *error = localError;
        }

        self = nil;
    }

    return self;
}

#pragma mark - Required FOSRESTServiceAdapter Protocol Methods

- (NSTimeInterval)defaultTimeout {
    NSNumber *timeout = [self _unwrapAdapterField:@"timeout_interval"];
    return (NSTimeInterval)[timeout unsignedIntegerValue];
}

- (FOSNetworkStatusMonitor *)networkStatusMonitor {
    if (_networkStatusMonitor == nil) {
        NSURL *baseURL = self.defaultBaseURL;
        NSString *hostname = baseURL.host;

        _networkStatusMonitor = [FOSNetworkStatusMonitor statusMonitorWithHostName:hostname];
    }

    return _networkStatusMonitor;
}

- (NSURL *)defaultBaseURL {
    if (_baseURL == nil) {
        _baseURL = [NSURL URLWithString:[self _unwrapAdapterField:@"base_url"]];
    }

    return _baseURL;
}

- (NSPersistentStoreCoordinator *)setupDatabaseForcingRemoval:(BOOL)forceDBRemoval error:(NSError **)error {
    NSString *msgFmt = @"The %@ method must be overridden by subclasses of FOSBoundServicesAdapter.  Do not call FOSBoundServicesAdapter's implementation.";
    NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromSelector(_cmd)];

    NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];
    @throw e;

}

- (FOSURLBinding *)urlBindingForLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
                             forLifecycleStyle:(NSString *)lifecycleStyle
                               forRelationship:(NSRelationshipDescription *)relDesc
                                 forEntity:(NSEntityDescription *)entity {
    NSParameterAssert(entity != nil);
    NSParameterAssert(lifecyclePhase != FOSLifecyclePhaseRetrieveServerRecordRelationship ||
                      relDesc != nil);

    FOSURLBinding *urlBinding = [_bindings urlBindingForLifecyclePhase:lifecyclePhase
                                                        forLifecycleStyle:lifecycleStyle
                                                       forRelationship:relDesc
                                                             forEntity:entity];

    return urlBinding;
}

- (BOOL)processWebServiceResponse:(NSHTTPURLResponse *)httpResponse
                     responseData:(NSData *)responseData
                    forURLBinding:(FOSURLBinding *)urlBinding
                       jsonResult:(id<NSObject> *)jsonResult
                            error:(NSError **)error {
    NSParameterAssert(httpResponse != nil);
    NSParameterAssert(jsonResult != nil);

    if (error != nil) { *error = nil; }
    *jsonResult = nil;

    BOOL result = YES;
    NSError *localError = nil;

    // Without more info, about all we can do is pull out the JSON, if there was one
    if (httpResponse.statusCode == 200) {
        if (responseData != nil && responseData.length > 0) {
            *jsonResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                          options:0
                                                            error:&localError];
        }
    }
    else {
        NSString *msg = @"Bad server response";

        if (responseData != nil &&
            [httpResponse.MIMEType isEqualToString:@"application/json"]) {

            NSError *localError = nil;

            *jsonResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                          options:0
                                                            error:&localError];
        }

        localError = [NSError errorWithDomain:@"FOSREST"
                                    errorCode:httpResponse.statusCode
                                   andMessage:msg];
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = NO;
    }

    return result;
}

#pragma mark - Optional FOSRESTServiceAdapter Protocol Methods

- (NSDictionary *)headerFields {
    // Note: We cannot save the result to a member variable as the contents might
    //       change over time. For example, when the user logs in there might be
    //       a new key added to the header fields to identify/authenticate the
    //       request.
    return [self _unwrapAdapterField:@"header_fields"];
}

- (id<NSObject>)encodeCMOValueToJSON:(id)cmoValue
                              ofType:(NSAttributeDescription *)attrDesc
                               error:(NSError **)error {
    NSParameterAssert(attrDesc != nil);

    if (error != nil) { *error = nil; }

    id result = cmoValue;
    NSError *localError = nil;

    if (cmoValue == nil || [cmoValue isKindOfClass:[NSNull class]]) {
        result = [NSNull null];
    }
    else {
        if (attrDesc.attributeType == NSTransformableAttributeType) {

            NSValueTransformer *transformer =
                [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

            if (transformer == nil) {
                NSString *msgFmt = NSLocalizedString(@"Unable to locate an NSValueTransformer of type '%@' as specified by the NSAttributeDescription '%@' of Entity '%@'.", "");
                NSString *msg = [NSString stringWithFormat:msgFmt, attrDesc.valueTransformerName,
                                 attrDesc.name, attrDesc.entity.name];

                localError = [NSError errorWithMessage:msg];
            }

            if ([[transformer class] conformsToProtocol:@protocol(FOSValueTransformer)]) {
                id<FOSValueTransformer> fosTransformer = (id<FOSValueTransformer>)transformer;

                result = [fosTransformer webServiceValueFromLocalValue:cmoValue
                                                                 error:&localError];
            }
            else {
                NSString *msgFmt = NSLocalizedString(@"The NSValueTransformer '%@' on attribute '%@' of entity '%@' must implement the FOSValueTransformer protocol.", @"FOSBad_Transformer");

                NSString *msg = [NSString stringWithFormat:msgFmt,
                                 NSStringFromClass([transformer class]),
                                 attrDesc.name, attrDesc.entity.name];

                localError = [NSError errorWithMessage:msg];
            }
        }
        else if ([result isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)cmoValue;

            result = [self _jsonDateForDate:date forAttribute:attrDesc error:error];
        }
        else {
            result = [FOSCachedManagedObject jsonValueForObject:cmoValue forAttribute:attrDesc];
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

- (id)decodeJSONValueToCMOValue:(id<NSObject>)jsonValue
                         ofType:(NSAttributeDescription *)attrDesc
                          error:(NSError **)error {
    NSParameterAssert(attrDesc != nil);

    if (error != nil) { *error = nil; }

    id result = jsonValue;
    NSError *localError = nil;

    if ([jsonValue isKindOfClass:[NSNull class]]) {
        result = nil;
    }
    else if (jsonValue != nil) {
        if (attrDesc.attributeType == NSTransformableAttributeType) {
            NSValueTransformer *transformer =
                [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

            if ([[transformer class] conformsToProtocol:@protocol(FOSValueTransformer)]) {
                id<FOSValueTransformer> fosTransformer = (id<FOSValueTransformer>)transformer;

                result = [fosTransformer localValueFromWebServiceValue:(NSString *)jsonValue
                                                                 error:&localError];
            }
            else {
                NSString *msgFmt = NSLocalizedString(@"The NSValueTransformer '%@' on attribute '%@' of entity '%@' must implement the FOSValueTransformer protocol.", @"FOSBad_Transformer");

                NSString *msg = [NSString stringWithFormat:msgFmt,
                                 NSStringFromClass([transformer class]),
                                 attrDesc.name, attrDesc.entity.name];

                localError = [NSError errorWithMessage:msg];
            }
        }
        else if (attrDesc.attributeType == NSDateAttributeType) {
            NSDate *date = [self _dateForJsonDate:jsonValue forAttribute:attrDesc error:&localError];

            result = date;
        }
        else if ([result isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)jsonValue;

            result = [data base64EncodedString];
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

- (id)valueForExpressionVariable:(NSString *)varName matched:(BOOL *)matched error:(NSError **)error {
    NSParameterAssert(varName != nil);
    NSParameterAssert(varName.length > 0);
    NSParameterAssert(matched != nil);

    *matched = NO;
    id result = nil;
    if (error != nil) { *error = nil; }

    if ([varName isEqualToString:@"LOGGED_IN_USER"]) {
        result = [FOSRESTConfig sharedInstance].loginManager.loggedInUser;
        *matched = YES;
    }
    else if ([varName isEqualToString:@"USER_ENTITY"]) {
        result = [NSEntityDescription entityNameForClass:[FOSRESTConfig sharedInstance].userSubType];
    }
    else if ([varName isEqualToString:@"DSLQUERY"]) {
        result = @"";
    }

    return result;
}

- (BOOL)processWebServiceResponse:(NSHTTPURLResponse *)httpResponse
              json:(id) jsonResult
            responseData:(NSData *)data
                userInfo:(NSMutableDictionary *)errorUserInfo
                   error:(NSError **)error {
    NSString *msg = [NSString stringWithFormat:@"Concrete subclasses of FOSBoundServiceAdapter must override and implement %@.", NSStringFromSelector(_cmd)];

    @throw [NSException exceptionWithName:@"FOSREST_MustOverride"
                                   reason:msg userInfo:nil];
}

#pragma mark - Private Methods

- (id)_unwrapAdapterField:(NSString *)fieldName {
    id result = nil;

    id adapterField = _bindings.adapterFields[fieldName];

    NSError *localError = nil;
    if ([adapterField isKindOfClass:[NSArray class]]) {

        NSArray *array = (NSArray *)adapterField;
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:array.count];
        result = resultDict;

        for (NSArray *keyValuePair in array) {
            id<FOSExpression> keyExpr = keyValuePair[0];
            id<FOSExpression> valExpr = keyValuePair[1];

            id key = [keyExpr evaluateWithContext:nil error:&localError];
            if (key != nil && localError == nil) {
                id value = [valExpr evaluateWithContext:nil error:&localError];
                if (value != nil && localError == nil) {
                    resultDict[key] = value;
                }
            }

            if (localError != nil) {
                break;
            }
        }
    }
    else {
        id<FOSExpression> valExpr = (id<FOSExpression>)adapterField;

        id value = [valExpr evaluateWithContext:nil error:&localError];
        if (value != nil && localError == nil) {
            result = value;
        }
    }

    if (localError != nil) {
        // TODO : Add line/col info http://fosmain.foscomputerservices.com:8080/browse/FF-3
        NSString *msgFmt = @"Error (%d:%d): %@ for adapter";
        NSString *msg = [NSString stringWithFormat:msgFmt,
                         0, 0, localError.description];

        NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];
        @throw e;
    }
    
    return result;
}

- (NSInteger)_formatIndexForAttribute:(NSAttributeDescription *)attrDesc error:(NSError **)error {
    NSInteger result = -1;
    NSError *localError = nil;
    if (error != nil) { *error = nil; }

    // We only need a dateFormatIndex if more than one format is available
    if ([[self class] serverDateFormats].count > 1) {
        NSString *indexStr = attrDesc.userInfo[@"dateFormatIndex"];
        if (indexStr == nil) {
            NSString *msgFmt = @"Attribute '%@' of Entity '%@' requires 'dateFormatIndex' to be specified in the userInfo to indicate which date formatter to use.";

            NSString *msg = [NSString stringWithFormat:msgFmt, attrDesc.name, attrDesc.entity.name];

            NSDictionary *userInfo = @{ @"serverDateFormats" : [[self class] serverDateFormats] };
            localError = [NSError errorWithDomain:@"FOSBoundServicAdapter"
                                          message:msg andUserInfo:userInfo];
        }
        else {
            NSInteger indexNum = indexStr.integerValue;
            NSInteger formatCount = (NSInteger)[[self class] serverDateFormats].count;

            if (indexNum >= 0 && indexNum < formatCount) {
                result = indexNum;
            }
            else {
                NSString *msgFmt = @"Attribute '%@' of Entity '%@' specified an invalid index of %@.  Only indicies between 0 and %ul are allowed.";
                NSString *msg = [NSString stringWithFormat:msgFmt, attrDesc.name, attrDesc.entity.name,
                                 indexStr, formatCount - 1];

                NSDictionary *userInfo = @{ @"serverDateFormats" : [[self class] serverDateFormats] };
                localError = [NSError errorWithDomain:@"FOSBoundServicAdapter"
                                              message:msg andUserInfo:userInfo];
            }
        }
    }
    else {
        result = 0;
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = -1;
    }

    return result;
}

- (NSDateFormatter *)_dateFormatterForAttribute:(NSAttributeDescription *)attrDesc error:(NSError **)error {
    NSDateFormatter *result = nil;

    NSInteger formatterIndex = [self _formatIndexForAttribute:attrDesc error:error];
    if (formatterIndex >= 0) {
        result = [self _serverDateFormatters][(NSUInteger)formatterIndex];
    }

    return result;
}

- (id<NSObject>)_jsonDateForDate:(NSDate *)date forAttribute:(NSAttributeDescription *)attrDesc error:(NSError **)error {
    NSString *result = nil;
    NSDateFormatter *formatter = [self _dateFormatterForAttribute:attrDesc error:error];

    if (formatter != nil) {
       result = [formatter stringFromDate:date];
    }

    return result;
}

- (NSDate *)_dateForJsonDate:(id<NSObject>)jsonDate forAttribute:(NSAttributeDescription *)attrDesc error:(NSError **)error {
    NSDate *result = nil;
    NSError *localError = nil;

    if (jsonDate != nil) {
        if ([jsonDate isKindOfClass:[NSString class]]) {

            NSDateFormatter *formatter = [self _dateFormatterForAttribute:attrDesc error:error];
            if (formatter != nil) {
                result = [formatter dateFromString:(NSString *)jsonDate];
            }
        }
        else {
            NSString *msgFmt = @"Adapter received a jsonDate of type %@, expected NSString.";
            NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromClass([jsonDate class])];

            localError = [NSError errorWithMessage:msg];
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

- (NSArray *)_serverDateFormatters {

    // Cache the instance according to Apple's documentation.
    // (see https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html)
    if (__serverDateFormatters == nil) {

        NSArray *formatStrings = [[self class] serverDateFormats];
        NSMutableArray *formatters = [NSMutableArray arrayWithCapacity:formatStrings.count];

        for (NSString *formatString in formatStrings) {

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = formatString;
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

            [formatters addObject:dateFormatter];
        }

        __serverDateFormatters = formatters;
    }

    return __serverDateFormatters;
}

@end
