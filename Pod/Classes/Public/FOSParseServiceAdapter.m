//
//  FOSParseRESTAdapter.m
//  FOSREST
//
//  Created by David Hunt on 3/14/14.
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

#import <FOSParseServiceAdapter.h>
#import "FOSREST_Internal.h"

// TODO : Standardize
extern NSString *FOSWebServiceErrorStatusCode;
extern NSString *FOSWebServiceErrorBase;
extern NSString *FOSWebServiceErrorJSON;
extern NSString *FOSWebServiceServerErrorCode;
extern NSString *FOSWebServiceServerErrorMessage;

@implementation FOSParseServiceAdapter {
    NSString *_applicationId;
    NSString *_restAPIKey;
    id<FOSAnalytics> _analyticsManager;
}

#pragma mark - Class Methods

+ (instancetype)adapterWithApplicationId:(NSString *)applicationid
                           andRESTAPIKey:(NSString *)restAPIKey {
    return [[self alloc] initWithApplicationId:applicationid andRESTAPIKey:restAPIKey];
}

#pragma mark - Initialization

- (id)initWithApplicationId:(NSString *)applicationId andRESTAPIKey:(NSString *)restAPIKey {
    NSParameterAssert(applicationId != nil);
    NSParameterAssert(restAPIKey != nil);

    // Find the adaptermap file
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *adapterMapURL = [bundle URLForResource:@"FOSParse" withExtension:@"adaptermap"
                                     subdirectory:nil];

    NSError *localError = nil;
    if ((self = [super initFromBindingFile:adapterMapURL error:&localError]) != nil) {
        _applicationId = applicationId;
        _restAPIKey = restAPIKey;
    }
    else {
        NSException *e = [NSException exceptionWithName:localError.domain
                                                 reason:localError.description
                                               userInfo:localError.userInfo];
        @throw e;
    }

    return self;
}

#pragma mark - FOSRESTServiceAdapter Protocol Methods

- (id)valueForExpressionVariable:(NSString *)varName matched:(BOOL *)matched error:(NSError **)error {
    NSParameterAssert(varName!= nil);
    NSParameterAssert(varName.length > 0);
    NSParameterAssert(matched != nil);

    id result = nil;
    *matched = NO;

    if ([varName isEqualToString:@"PARSE_APPLICATION_ID"]) {
        result = _applicationId;
        *matched = YES;
    }
    else if ([varName isEqualToString:@"PARSE_REST_API_ID"]) {
        result = _restAPIKey;
        *matched = YES;
    }
    else if ([varName isEqualToString:@"PARSE_RECORD_LIMIT"]) {
        // Default to the maximum allowed by parse
        // https://parse.com/docs/rest#queries-constraints
        result = @"1000";
        *matched = YES;
    }
    else if ([varName isEqualToString:@"PARSE_RECORD_SKIP"]) {
        // Default to the maximum allowed by parse
        // https://parse.com/docs/rest#queries-constraints
        result = @"0";
        *matched = YES;
    }
    else if ([varName isEqualToString:@"PARSE_RESTRICT_FIELDS"]) {
        // Default to all fields
        result = @"";
        *matched = YES;
    }
    else if ([varName isEqualToString:@"PARSE_WHERE_CLAUSE"]) {
        // We default it to blank if they didn't specific it in the context
        result = @"";
        *matched = YES;
    }
    else {
        result = [super valueForExpressionVariable:varName matched:matched error:error];
    }

    return result;
}

- (NSUInteger)maxBatchCount {
    return 20;
}

- (BOOL)requestCanBeBatched:(FOSWebServiceRequest *)webServiceRequest {
    BOOL result = NO; // TODO : Restore support for batching  -- YES;

    // Process the getRequests..parse doesn't have a batch for those
    // Grrr... "1/users' not supported in batch operations"
    if (webServiceRequest.requestMethod == FOSRequestMethodGET ||
        ([webServiceRequest.endPoint rangeOfString:@"1/users"].location != NSNotFound) ||
        ([webServiceRequest.endPoint rangeOfString:@"1/events"].location != NSNotFound) ||
        ([webServiceRequest.endPoint rangeOfString:@"1/requestPasswordReset"].location != NSNotFound)) {
        result = NO;
    }

    return result;
}

- (FOSWebServiceRequest *)generateBatchRequestForRequests:(NSArray *)requests {
    NSMutableArray *requestFragments = [NSMutableArray arrayWithCapacity:requests.count];
    for (FOSWebServiceRequest *nextRequest in requests) {
        [requestFragments addObject:[self _jsonBatchFragmentFromRequest:nextRequest]];
    }

    NSDictionary *requestFrag = @{ @"requests" : requestFragments };

    FOSWebServiceRequest *result =
        [FOSWebServiceRequest requestWithRequestType:FOSRequestMethodPOST
                                            endPoint:@"1/batch"
                                        uriFragments:@[ requestFrag ]];

    FOSLogDebug(@"FOSWebService: BATCH REQUEST - %@", requestFrag);

    return result;
}

- (void)processResultsOfBatchRequest:(FOSWebServiceRequest *)batchRequest
                         forRequests:(NSArray *)requests {

    // https://parse.com/docs/rest#objects-batch
    NSError *batchRequestError = batchRequest.error;
    id<NSObject> responseJson = batchRequest.jsonResult;
    NSAssert(batchRequestError != nil || [responseJson isKindOfClass:[NSArray class]],
             @"Expected to receive an error or an array.");

    NSArray *responseArray = (NSArray *)responseJson;
    NSAssert(batchRequestError != nil || responseArray.count == requests.count,
             @"Received a different # of responses than requests!");

    for (NSUInteger i = 0; i < requests.count; i++) {
        FOSWebServiceRequest *nextRequest = requests[i];
        NSDictionary *nextResponse = batchRequestError == nil ? responseArray[i] : nil;

        id<NSObject> jsonSuccess = batchRequestError == nil ? nextResponse[@"success"] : nil;

        if (jsonSuccess != nil) {
            [nextRequest setOriginalJsonResult:jsonSuccess postProcessor:nil];
        }
        else {
            NSError *error = nil;

            if (batchRequestError != nil) {
                error = batchRequestError;
            }
            else {
//                [self processWebServiceResponse:nil
//                            json:nextResponse
//                          responseData:nil
//                              userInfo:[NSMutableDictionary dictionary]
//                                 error:&error];
            }

            NSAssert(error != nil, @"No success or error???");

            [nextRequest setError:error];
        }
    }
}

- (id<FOSAnalytics>)analyticsManager {
    if (_analyticsManager == nil) {
        _analyticsManager = [[FOSParseAnalyticsManager alloc] init];
    }

    return _analyticsManager;
}

- (BOOL)processWebServiceResponse:(NSHTTPURLResponse *)httpResponse
                     responseData:(NSData *)responseData
                    forURLBinding:(FOSURLBinding *)urlBinding
                       jsonResult:(id<NSObject> *)jsonResult
                            error:(NSError **)error {
    NSParameterAssert(httpResponse != nil);
    NSParameterAssert(jsonResult != nil);
    NSParameterAssert(error != nil);

    *jsonResult = nil;
    *error = nil;

    BOOL result = YES;

    if (urlBinding == nil) {
        result = [super processWebServiceResponse:httpResponse
                                     responseData:responseData
                                    forURLBinding:urlBinding
                                       jsonResult:jsonResult
                                            error:error];
    }
    else {
        // Parse the responseData, if provided
        id<NSObject> jsonData = nil;
        if (responseData != nil) {
            jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        }

        switch (urlBinding.lifecyclePhase) {
            case FOSLifecyclePhaseCreateServerRecord:
                result = [self _processCreateResponse:httpResponse
                                             jsonData:jsonData
                                           jsonResult:jsonResult
                                                error:error];
                break;

            case FOSLifecyclePhasePasswordReset:
            case FOSLifecyclePhaseRetrieveServerRecord:
                result = [self _processSingletonQueryResponse:httpResponse
                                                     jsonData:jsonData
                                                   jsonResult:jsonResult
                                                        error:error];
                break;

            case FOSLifecyclePhaseRetrieveServerRecordCount:
                result = [self _processCountQueryResponse:httpResponse
                                                 jsonData:jsonData
                                               jsonResult:jsonResult
                                                    error:error];
                break;

            case FOSLifecyclePhaseLogout:
            case FOSLifecyclePhaseRetrieveServerRecords:
            case FOSLifecyclePhaseRetrieveServerRecordRelationship:
                result = [self _processQueryResponse:httpResponse
                                            jsonData:jsonData
                                          jsonResult:jsonResult
                                               error:error];
                break;

            case FOSLifecyclePhaseLogin:
            case FOSLifecyclePhaseUpdateServerRecord:
                result = [self _processUpdateResponse:httpResponse
                                             jsonData:jsonData
                                           jsonResult:jsonResult
                                                error:error];
                break;

            case FOSLifecyclePhaseDestroyServerRecord:
                result = [self _processDestroyResponse:httpResponse
                                              jsonData:jsonData
                                            jsonResult:jsonResult
                                                 error:error];
                break;
        }
    }

    return result;
}

- (id<NSObject>)encodeCMOValueToJSON:(id)cmoValue
                              ofType:(NSAttributeDescription *)attrDesc
                               error:(NSError **)error {
    NSParameterAssert(attrDesc != nil);
    if (error != nil) { *error = nil; }

    id result = cmoValue;
    NSError *localError = nil;

    if (cmoValue != nil && attrDesc.attributeType == NSTransformableAttributeType) {

        NSValueTransformer *transformer =
            [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

        Class xFormClass = [[transformer class] transformedValueClass];

        if (![xFormClass isSubclassOfClass:[NSData class]] &&
            ![xFormClass isSubclassOfClass:[NSString class]]) {
            NSString *msgFmt = @"The NSValueTransformer '%@' must transform to/from an NSData or NSString instance (found %@) on attribute '%@' of entity '%@'.";
            NSString *msg = [NSString stringWithFormat:msgFmt,  NSStringFromClass([transformer class]),
                             NSStringFromClass([[transformer class] transformedValueClass]),
                             attrDesc.name, attrDesc.entity.name];

            localError = [NSError errorWithMessage:msg];
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
    else if (cmoValue != nil && [result isKindOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)cmoValue;

        result = [[self class] _parseJsonValueForDate:date];
    }
    else {
        result = [super encodeCMOValueToJSON:cmoValue ofType:attrDesc error:error];
    }

    if (localError != nil && error != nil) {
        *error = localError;
    }
    
    return result;
}

- (id)decodeJSONValueToCMOValue:(id<NSObject>)jsonValue
                         ofType:(NSAttributeDescription *)attrDesc
                          error:(NSError **)error {
    NSParameterAssert(attrDesc != nil);
    if (error != nil) { *error = nil; }

    NSError *localError = nil;

    id jsonVal = [jsonValue isKindOfClass:[NSNull class]] ? nil : jsonValue;
    id result = nil;

    if (jsonVal != nil && attrDesc.attributeType == NSTransformableAttributeType) {

        NSAssert([jsonVal isKindOfClass:[NSDictionary class]], @"Expected a dictionary!");

        NSValueTransformer *transformer =
            [NSValueTransformer valueTransformerForName:attrDesc.valueTransformerName];

        Class xFormClass = [[transformer class] transformedValueClass];

        if (![xFormClass isSubclassOfClass:[NSData class]] &&
            ![xFormClass isSubclassOfClass:[NSString class]]) {
            NSString *msgFmt = @"The NSValueTransformer '%@' must transform to/from an NSData or NSString instance (found %@) on attribute '%@' of entity '%@'.";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             NSStringFromClass([transformer class]),
                             NSStringFromClass([[transformer class] transformedValueClass]),
                             attrDesc.name, attrDesc.entity.name];

            localError = [NSError errorWithMessage:msg];
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
        result = [super decodeJSONValueToCMOValue:jsonValue ofType:attrDesc error:&localError];
    }

    if (localError != nil) {
        if (error != nil) { *error = localError; }

        result = nil;
    }
    
    return result;

}

#pragma mark - Private Methods

- (BOOL)_processCreateResponse:(NSHTTPURLResponse *)httpResponse
                      jsonData:(id<NSObject>)jsonData
                    jsonResult:(id<NSObject> *)jsonResult
                         error:(NSError **)error {
    NSParameterAssert(jsonResult != nil);
    NSParameterAssert(error != nil);

    BOOL result = YES;

    // https://parse.com/docs/rest#objects-creating
    if (httpResponse.statusCode == 201) {
        NSAssert([jsonData isKindOfClass:[NSDictionary class]], @"Not an NSDictionary???");
        *jsonResult = (NSDictionary *)jsonData;
    }
    else {
        result = NO;

        [self _extractParseError:httpResponse error:error jsonData:jsonData];
    }

    return result;
}

- (BOOL)_processDestroyResponse:(NSHTTPURLResponse *)httpResponse
                       jsonData:(id <NSObject>)jsonData
                     jsonResult:(id <NSObject> *)jsonResult
                          error:(NSError **)error {
    NSParameterAssert(jsonResult != nil);
    NSParameterAssert(error != nil);

    BOOL result = YES;

    // https://parse.com/docs/rest#objects-deleting
    if (httpResponse.statusCode != 200) {
        result = NO;

        [self _extractParseError:httpResponse error:error jsonData:jsonData];
    }

    return result;
}

- (BOOL)_processSingletonQueryResponse:(NSHTTPURLResponse *)httpResponse
                              jsonData:(id<NSObject>)jsonData
                            jsonResult:(id<NSObject> *)jsonResult
                                 error:(NSError **)error {
    NSParameterAssert(jsonResult != nil);
    NSParameterAssert(error != nil);

    BOOL result = YES;

    // https://parse.com/docs/rest#objects-retrieving
    if (httpResponse.statusCode == 200) {
        NSAssert([jsonData isKindOfClass:[NSDictionary class]], @"Not an NSDictionary???");
        *jsonResult = (NSDictionary *)jsonData;
    }
    else {
        result = NO;

        [self _extractParseError:httpResponse error:error jsonData:jsonData];
    }
    
    return result;
}

- (BOOL)_processCountQueryResponse:(NSHTTPURLResponse *)httpResponse
                          jsonData:(id<NSObject>)jsonData
                        jsonResult:(id<NSObject> *)jsonResult
                             error:(NSError **)error {
    NSParameterAssert(jsonResult != nil);
    NSParameterAssert(error != nil);

    BOOL result = YES;

    // https://parse.com/docs/rest#objects-retrieving
    if (httpResponse.statusCode == 200) {
        NSAssert([jsonData isKindOfClass:[NSDictionary class]], @"Not an NSDictionary???");
        
        if (![jsonData isKindOfClass:[NSDictionary class]]) {
            NSString *msgFmt = @"Received a value of type %@, expected NSDictionary.";
            NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromClass([jsonData class])];
            NSDictionary *userInfo = @{ @"URL" : httpResponse.URL  };
            
            *error = [NSError errorWithDomain:@"FOSREST"
                                    errorCode:0
                                      message:msg
                                  andUserInfo:userInfo];
        }
        else {
            *jsonResult = ((NSDictionary *)jsonData)[@"count"];

            if (![*jsonResult isKindOfClass:[NSNumber class]]) {
                NSString *msgFmt = @"Received a value of type %@, expected NSNumber.";
                NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromClass([*jsonResult class])];
                NSDictionary *userInfo = @{ @"URL" : httpResponse.URL  };
                
                *error = [NSError errorWithDomain:@"FOSREST"
                                        errorCode:0
                                          message:msg
                                      andUserInfo:userInfo];

            }
        }
    }
    else {
        [self _extractParseError:httpResponse error:error jsonData:jsonData];
    }

    if (*error != nil) {
        *jsonResult = nil;
        result = NO;
    }

    return result;
}

- (BOOL)_processQueryResponse:(NSHTTPURLResponse *)httpResponse
                     jsonData:(id<NSObject>)jsonData
                   jsonResult:(id<NSObject> *)jsonResult
                        error:(NSError **)error {
    NSParameterAssert(jsonResult != nil);
    NSParameterAssert(error != nil);

    BOOL result = YES;

    // https://parse.com/docs/rest#queries-basic
    if (httpResponse.statusCode == 200) {
        NSAssert([jsonData isKindOfClass:[NSDictionary class]], @"Not an NSDictionary???");
        NSDictionary *json = (NSDictionary *)jsonData;

        *jsonResult = json[@"results"];
        NSAssert([*jsonResult isKindOfClass:[NSArray class]], @"Not an NSArray???");
    }
    else {
        result = NO;

        [self _extractParseError:httpResponse error:error jsonData:jsonData];
    }

    return result;
}

- (BOOL)_processUpdateResponse:(NSHTTPURLResponse *)httpResponse
                      jsonData:(id<NSObject>)jsonData
                    jsonResult:(id<NSObject> *)jsonResult
                         error:(NSError **)error {
    NSParameterAssert(jsonResult != nil);

    BOOL result = YES;

    // https://parse.com/docs/rest#objects-updating
    if (httpResponse.statusCode == 200) {
        NSAssert([jsonData isKindOfClass:[NSDictionary class]], @"Not an NSDictionary???");
        *jsonResult = (NSDictionary *)jsonData;
    }
    else {
        result = NO;

        [self _extractParseError:httpResponse error:error jsonData:jsonData];
    }

    return result;
}

- (BOOL)_extractParseError:(NSHTTPURLResponse *)httpResponse
                     error:(NSError **)error
                  jsonData:(id)jsonData {

    BOOL result = true;
    NSError *localError = nil;

    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        NSString *errorStr = ((NSDictionary *)jsonData)[@"error"];

        localError = [NSError errorWithDomain:@"FOSParseError"
                                    errorCode:httpResponse.statusCode
                                   andMessage:errorStr];
    }
    else {
        NSString *msg = @"Unknown error received from server";

        // Let's see if we can find a header status field
        NSString *headerStatus = httpResponse.allHeaderFields[@"Status"];
        if (headerStatus.length > 0) {
            msg = headerStatus;
        }

        localError = [NSError errorWithDomain:@"FOSParseError"
                                    errorCode:httpResponse.statusCode
                                   andMessage:msg];
    }

    if (localError != nil) {
        if (error != nil) { *error = localError; }
        result = false;
    }

    return result;
}

- (id<NSObject>)_jsonBatchFragmentFromRequest:(FOSWebServiceRequest *)request {

    NSDictionary *result = nil;

    NSString *parseEP = [@"/" stringByAppendingString:request.endPoint];

    if (request.uriFragments.count == 0) {
        result = @{
                   @"method" : request.httpMethod,
                   @"path" : parseEP
        };
    }
    else {
        id<NSObject> body = request.uriFragments.count == 1
            ? request.uriFragments.lastObject
            : request.uriFragments;

        result = @{
                   @"method" : request.httpMethod,
                   @"path" : parseEP,
                   @"body" : body
        };
    }
    
    return result;
}

+ (id<NSObject>)_parseJsonValueForDate:(NSDate *)date {
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
