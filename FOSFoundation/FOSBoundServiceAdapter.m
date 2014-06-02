//
//  FOSBoundServiceAdapter.m
//  FOSFoundation
//
//  Created by David Hunt on 3/21/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSBoundServiceAdapter.h"
#import "FOSAdapterBinding.h"

@implementation FOSBoundServiceAdapter {
    FOSAdapterBinding *_bindings;
    FOSNetworkStatusMonitor *_networkStatusMonitor;
    NSURL *_baseURL;
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
    FOSAdapterBinding *bindings = [FOSAdapterBinding parseAdapterBindings:url error:&localError];

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
        if (responseData != nil) {
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

        localError = [NSError errorWithDomain:@"FOSFoundation"
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

    if (cmoValue == nil || [cmoValue isKindOfClass:[NSNull class]]) {
        result = [NSNull null];
    }
    else {
        if (attrDesc.attributeType == NSTransformableAttributeType) {

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
                NSData *data = [transformer transformedValue:cmoValue];

                NSString *base64ByteString = [data base64EncodedString];

                result = @{ @"__type" : @"Bytes", @"base64" : base64ByteString };
            }
            else {
                result = [transformer transformedValue:cmoValue];
            }
        }
        else if ([result isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)cmoValue;

            result = [self _parseJsonValueForDate:date];
        }
        else {
            result = [FOSCachedManagedObject jsonValueForObject:cmoValue forAttribute:attrDesc];
        }
    }
    
    return result;
}

- (id)decodeJSONValueToCMOValue:(id<NSObject>)jsonValue
                         ofType:(NSAttributeDescription *)attrDesc
                          error:(NSError **)error {
    NSParameterAssert(attrDesc != nil);

    if (error != nil) { *error = nil; }

    id result = jsonValue;

    if ([jsonValue isKindOfClass:[NSNull class]]) {
        result = nil;
    }
    else if (jsonValue != nil) {
        if (attrDesc.attributeType == NSTransformableAttributeType) {
            NSValueTransformer *transformer =
                [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

            result = [transformer reverseTransformedValue:jsonValue];
        }
        else if ([result isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)jsonValue;

            result = @(date.timeIntervalSince1970);
        }
        else if ([result isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)jsonValue;

            result = [data base64EncodedString];
        }
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
        result = NSStringFromClass([FOSRESTConfig sharedInstance].userSubType);
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

    @throw [NSException exceptionWithName:@"FOSFoundation_MustOverride"
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

        NSException *e = [NSException exceptionWithName:@"FOSFoundation" reason:msg userInfo:nil];
        @throw e;
    }
    
    return result;
}

- (id<NSObject>)_parseJsonValueForDate:(NSDate *)date {
    NSDateFormatter *formatter = [[self class] _toServerDateFormatter];

    NSString *formattedDate = [formatter stringFromDate:date];

    NSDictionary *result = @{ @"__type" : @"Date", @"iso" : formattedDate };

    return result;
}

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
