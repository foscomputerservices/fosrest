//
//  FOSURLBinding.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSURLBinding.h"
#import "FOSConcatExpression.h"
#import "FOSRESTServiceAdapter.h"

@implementation FOSURLBinding

#pragma mark - Class Methods

+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                               cmoBinder:(FOSCMOBinding *)cmoBinder
                        andEntityMatcher:(FOSItemMatcher *)entityMatcher {
    NSParameterAssert(endPoint != nil);
    NSParameterAssert(cmoBinder != nil);
    NSParameterAssert(entityMatcher != nil);

    FOSURLBinding *result = [[self alloc] init];
    result.lifecyclePhase = lifecyclePhase;
    result.endPointURLExpression = endPoint;
    result.cmoBinding = cmoBinder;
    result.entityMatcher = entityMatcher;

    return result;
}

+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                     cmoBindingReference:(FOSSharedBindingReference *)bindingReference
                        andEntityMatcher:(FOSItemMatcher *)entityMatcher {
    NSParameterAssert(endPoint != nil);
    NSParameterAssert(bindingReference != nil);
    NSParameterAssert(entityMatcher != nil);

    FOSURLBinding *result = [[self alloc] init];
    result.lifecyclePhase = lifecyclePhase;
    result.endPointURLExpression = endPoint;
    result.sharedBindingReference = bindingReference;
    result.entityMatcher = entityMatcher;

    return result;
}

+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                           requestFormat:(FOSRequestFormat)requestFormat
                        andEntityMatcher:(FOSItemMatcher *)entityMatcher {
    NSParameterAssert(endPoint != nil);
    NSParameterAssert(entityMatcher != nil);
    NSParameterAssert(requestFormat == FOSRequestFormatNoData);

    FOSURLBinding *result = [[self alloc] init];
    result.lifecyclePhase = lifecyclePhase;
    result.endPointURLExpression = endPoint;
    result.requestFormat = requestFormat;
    result.entityMatcher = entityMatcher;

    return result;
}

+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                           requestFormat:(FOSRequestFormat)requestFormat
                      andJSONExpressions:(NSArray *)jsonExpressions {
    NSParameterAssert(endPoint != nil);

    FOSURLBinding *result = [[self alloc] init];
    result.lifecyclePhase = lifecyclePhase;
    result.endPointURLExpression = endPoint;
    result.requestFormat = requestFormat;
    result.jsonBindingExpressions = jsonExpressions;

    return result;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        self.lifecycleStyle = [FOSItemMatcher matcherMatchingAllItems];
    }

    return self;
}

#pragma mark - Property Overrides

- (NSURL *)baseURL {
    NSURL *result = _baseURL;

    if (self.baseURLExpr != nil) {
        NSError *error = nil;
        NSString *baseURLStr = [self.baseURLExpr evaluateWithContext:nil error:&error];
        if (baseURLStr.length > 0 && error == nil) {
            result = [NSURL URLWithString:baseURLStr];
        }
    }

    return result;
}

#pragma mark - Public Methods

- (NSURLRequest *)urlRequestForCMO:(FOSCachedManagedObject *)cmo error:(NSError **)error {
    NSParameterAssert(cmo != nil);
    NSMutableURLRequest *result = nil;

    if (error != nil) { *error = nil; }

    // Ensure that the cmo is managed by this request
    if ([self _matchEntity:cmo.entity error:error]) {

        NSError *localError = nil;

        NSURL *url = [self _urlForCMO:cmo withContext:nil error:&localError];

        if (localError == nil) {
            // Assign URL
            result = [NSMutableURLRequest requestWithURL:url];

            // Assign request method
            result.HTTPMethod = self._httpMethod;

            // Assign headers
            result.allHTTPHeaderFields = self._mergedHeaderFields;

            // Assign timeout
            result.timeoutInterval = self._timeoutInterval;

            // Assign the body
            result.HTTPBody = [self _httpBodyForCMO:cmo error:&localError];
        }

        if (localError != nil) {
            if (error != nil) {
                *error = localError;
            }

            result = nil;
        }
    }

    return result;
}

- (NSURLRequest *)urlRequestServerRecordOfType:(NSEntityDescription *)entity
                                    withJsonId:(FOSJsonId)jsonId
                                  withDSLQuery:(NSString *)dslQuery
                                         error:(NSError **)error {
    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);

    if (error != nil) { *error = nil; }

    NSDictionary *context = @{ @"CMOID" : jsonId, @"ENTITY" : entity };
    if (dslQuery != nil) {
        context = [context mutableCopy];
        ((NSMutableDictionary *)context)[@"DSLQUERY"] = dslQuery;
    }

    NSError *localError = nil;
    NSURLRequest *result = [self _urlRequestForEntity:entity withContext:context error:&localError];
    
    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }
        
        result = nil;
    }
    
    return result;
}

- (NSURLRequest *)urlRequestServerRecordOfType:(NSEntityDescription *)entity
                                  withDSLQuery:(NSString *)dslQuery
                                         error:(NSError **)error {
    NSParameterAssert(entity != nil);
    
    if (error != nil) { *error = nil; }
    
    NSMutableDictionary *context = [NSMutableDictionary dictionaryWithCapacity:2];
    context[@"ENTITY"] = entity;
    if (dslQuery != nil) {
        context[@"DSLQUERY"] = dslQuery;
    }
    
    NSError *localError = nil;
    NSURLRequest *result = [self _urlRequestForEntity:entity withContext:context error:&localError];
    
    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }
        
        result = nil;
    }
    
    return result;
}

- (NSURLRequest *)urlRequestServerRecordsOfRelationship:(NSRelationshipDescription *)relDesc
                                   forDestinationEntity:(NSEntityDescription *)destEntity
                                            withOwnerId:(FOSJsonId)ownerId
                                           withDSLQuery:(NSString *)dslQuery
                                                  error:(NSError **)error {
    NSParameterAssert(relDesc != nil);

    if (error != nil) { *error = nil; }

    NSMutableDictionary *context = [@{ @"ENTITY" : destEntity, @"RELDESC": relDesc } mutableCopy];
    if (relDesc.isToMany) {
        context[@"OWNERID"] = ownerId;
    }
    else {
        context[@"CMOID"] = ownerId;
    }

    if (dslQuery != nil) {
        context = [context mutableCopy];
        ((NSMutableDictionary *)context)[@"DSLQUERY"] = dslQuery;
    }

    NSError *localError = nil;
    NSURLRequest *result = [self _urlRequestForRelationship:relDesc
                                                withContext:context
                                                      error:&localError];

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }

    return result;
}

- (NSURLRequest *)urlRequestForServerCommandWithContext:(NSDictionary *)context
                                                  error:(NSError **)error {
    NSParameterAssert(context != nil);

    if (error != nil) { *error = nil; }

    NSError *localError = nil;
    NSURLRequest *result = [self _urlRequestForEntity:nil
                                          withContext:context
                                                error:&localError];

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }
    
    return result;
}


- (id<NSObject>)wrapJSON:(id<NSObject>)json context:(NSDictionary *)context error:(NSError **)error {

    if (error != nil) { *error = nil; }
    id<NSObject> result = json;

    NSError *localError = nil;

    if (self.jsonWrapperKey != nil && json != nil) {
        NSString *jsonKey = [self.jsonWrapperKey evaluateWithContext:context error:&localError];

        if (localError == nil && jsonKey.length > 0) {
            result = @{ jsonKey : json };
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

- (id<NSObject>)unwrapJSON:(id<NSObject>)json
                   context:(NSDictionary *)context
                     error:(NSError **)error {

    if (error != nil) { *error = nil; }
    id<NSObject> result = json;

    NSError *localError = nil;

    if (self.jsonWrapperKey != nil && json != nil) {
        NSString *jsonKey = [self.jsonWrapperKey evaluateWithContext:context error:&localError];

        if (jsonKey != nil && localError == nil) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSString *msgFmt = @"The json provided to JSON_WRAPPER_KEY was of type %@, an NSDictionary was expected for ULR_BINDING %@.";
                NSString *msg = [NSString stringWithFormat:msgFmt,
                                 NSStringFromClass([json class]),
                                 self.entityMatcher.description];

                localError = [NSError errorWithMessage:msg forAtom:self];
            }
            else {
                NSDictionary *jsonDict = (NSDictionary *)json;

                result = jsonDict[jsonKey];

                if (result == nil) {
                    NSString *msgFmt = @"Unwrapping the JSON %@ using JSON_WRAPPER_KEY %@ lead to an empty result.";
                    NSString *msg = [NSString stringWithFormat:msgFmt, [jsonDict description], jsonKey];

                    localError = [NSError errorWithMessage:msg forAtom:self];
                }
            }
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

- (id<NSObject>)unwrapBulkJSON:(id<NSObject>)json
                       context:(NSDictionary *)context
                         error:(NSError *__autoreleasing *)error {
    return [self _unwrapJSON:json
               keyExpression:self.bulkWrapperKey
                     context:context
                       error:error];
}

#pragma mark - Debug Information

+ (NSString *)stringForLifecycle:(FOSLifecyclePhase)lifecyclePhase {
    switch (lifecyclePhase) {
        case FOSLifecyclePhaseLogin:
            return @"LOGIN";
        case FOSLifecyclePhaseLogout:
            return @"LOGOUT";
        case FOSLifecyclePhasePasswordReset:
            return @"PASSWORD_RESET";
        case FOSLifecyclePhaseCreateServerRecord:
            return @"CREATE";
        case FOSLifecyclePhaseUpdateServerRecord:
            return @"UPDATE";
        case FOSLifecyclePhaseDestroyServerRecord:
            return @"DESTORY";
        case FOSLifecyclePhaseRetrieveServerRecord:
            return @"RETRIEVE_SERVER_RECORD";
        case FOSLifecyclePhaseRetrieveServerRecords:
            return @"RETRIEVE_SERVER_RECORDS";
        case FOSLifecyclePhaseRetrieveServerRecordCount:
            return @"RETRIEVE_SERVER_RECORD_COUNT";
        case FOSLifecyclePhaseRetrieveServerRecordRelationship:
            return @"RETRIEVE_RELATIONSHIP";
    }
}

#pragma mark - Overrides

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];

    NSString *phase = nil;
    switch (self.lifecyclePhase) {
        case FOSLifecyclePhaseLogin:
            phase = @"LOGIN";
            break;
        case FOSLifecyclePhaseLogout:
            phase = @"LOGOUT";
            break;
        case FOSLifecyclePhasePasswordReset:
            phase = @"PASSWORD-RESET";
            break;
        case FOSLifecyclePhaseCreateServerRecord:
            phase = @"CREATE";
            break;
        case FOSLifecyclePhaseUpdateServerRecord:
            phase = @"UPDATE";
            break;
        case FOSLifecyclePhaseDestroyServerRecord:
            phase = @"DESTROY";
            break;
        case FOSLifecyclePhaseRetrieveServerRecord:
            phase = @"RETRIEVE-SERVER-RECORD";
            break;
        case FOSLifecyclePhaseRetrieveServerRecords:
            phase = @"RETRIEVE-SERVER-RECORDS";
            break;
        case FOSLifecyclePhaseRetrieveServerRecordCount:
            phase = @"COUNT";
            break;
        case FOSLifecyclePhaseRetrieveServerRecordRelationship:
            phase = @"RETRIEVE-REL";
    }
    [result appendString:phase];

    [result appendString:@" - ("];
    if (self.bindingOptions == FOSBindingOptionsNone) {
        [result appendString:@"NONE"];
    }
    else {
        if (self.bindingOptions & FOSBindingOptionsOneToOneRelationship) {
            [result appendString:@"TO-ONE, "];
        }
        if (self.bindingOptions & FOSBindingOptionsOneToManyRelationship) {
            [result appendString:@"TO-MANY, "];
        }
        if (self.bindingOptions & FOSBindingOptionsOrderedRelationship) {
            [result appendString:@"ORDERED, "];
        }
        if (self.bindingOptions & FOSBindingOptionsUnorderedRelationship) {
            [result appendString:@"UNORDERED, "];
        }
    }
    [result appendString:@")"];

    NSString *reqMethod = [FOSWebServiceRequest httpMethodStringForRequestMethod:self.requestMethod];
    [result appendFormat:@" - %@", reqMethod];

    NSString *reqFormat = nil;
    switch (self.requestFormat) {
        case FOSRequestFormatJSON:
            reqFormat = @"JSON";
            break;
        case FOSRequestFormatNoData:
            reqFormat = @"NO-DATA";
            break;
        case FOSRequestFormatWebform:
            reqFormat = @"WEBFORM";
            break;
    }
    [result appendFormat:@" - %@", reqFormat];

    NSString *entityMatch = self.entityMatcher.description;
    [result appendFormat:@" (%@)", entityMatch];

    [result appendFormat:@" - %@", self.baseURL.absoluteString];

    return result;
}

#pragma mark - Private Methods

- (BOOL)_matchEntity:(NSEntityDescription *)entity error:(NSError **)error {
    BOOL result = YES;

    NSDictionary *context = @{ @"ENTITY" : entity };

    if (![self.entityMatcher itemIsIncluded:entity.name context:context]) {
        if (error) {
            NSString *msgFmt = @"The provided CMO is of type %@, which doesn't match any entity descriptions bound to this URLBinding.";
            NSString *msg = [NSString stringWithFormat:msgFmt, entity.name];

            *error = [NSError errorWithMessage:msg forAtom:self];
        }

        result = NO;
    }

    return result;
}

- (NSURL *)_baseURL {
    NSURL *result = self.baseURL;

    if (result == nil) {
        result = self.serviceAdapter.defaultBaseURL;
    }

    return result;
}

- (NSURL *)_urlForCMO:(FOSCachedManagedObject *)cmo
          withContext:(NSDictionary *)context
                error:(NSError **)error {
    NSParameterAssert(error != nil);

    NSURL *result = self._baseURL;
    NSError *localError = nil;
    NSMutableDictionary *localContext = context == nil
        ? [NSMutableDictionary dictionary]
        : [context mutableCopy];

    if (cmo != nil) {
        localContext[@"CMO"] = cmo;
        localContext[@"ENTITY"] = cmo.entity;

        if (cmo.jsonIdValue != nil) {
            localContext[@"CMOID"] = cmo.jsonIdValue;
        }
    }

    // Retrieve the base END_POINT
    NSString *endPoint = [self _endPointStrForCMO:cmo withContext:localContext error:&localError];
    if (localError == nil) {
        result = [result URLByAppendingPathComponent:endPoint];
    }

    // Retrieve the query portion
    NSString *endPointQuery = [self _endPointQueryForCMO:cmo
                                             withContext:localContext
                                                   error:&localError];
    if (endPointQuery.length > 0) {
        NSString *baseURLStr = result.absoluteString;
        NSString *fullURLStr = [NSString stringWithFormat:@"%@?%@",
                                baseURLStr, endPointQuery];

        result = [NSURL URLWithString:fullURLStr];
    }

    if (localError != nil) {
        *error = localError;
        result = nil;
    }

    return result;
}

- (NSString *)_endPointQueryForCMO:(FOSCachedManagedObject *)cmo
                       withContext:(NSDictionary *)context
                             error:(NSError **)error {
    NSParameterAssert(cmo != nil || context != nil);
    NSParameterAssert(error != nil);

    NSError *localError = nil;
    NSMutableString *result = nil;

    // Add any END_POINT_PARAMETERS
    NSDictionary *endPointJson = [self _evaluateEndPointParametersWithContext:context error:&localError];
    if (endPointJson != nil) {
        NSAssert(localError == nil, @"Error assigned???");

        if (endPointJson != nil && endPointJson.count > 0 && localError == nil) {
            NSString *webformEncoding = [self _webformEncodeJSON:endPointJson error:error];

            if (result == nil) {
                result = [NSMutableString string];
            }
            else {
                [result appendString:@"&"];
            }

            [result appendString:webformEncoding];
        }
    }

    // See if we need to encode the data into the URL too
    if (localError == nil &&
        cmo != nil &&
        self.requestFormat == FOSRequestFormatWebform &&
        self.requestMethod == FOSRequestMethodGET) {

        NSDictionary *json = [self _jsonBodyForCMO:cmo error:error];
        if (json != nil && json.count > 0 && localError == nil) {
            NSString *webformEncoding = [self _webformEncodeJSON:json error:error];

            if (result == nil) {
                result = [NSMutableString string];
            }
            else {
                [result appendString:@"&"];
            }

            [result appendString:webformEncoding];
        }
    }
    
    if (localError != nil) {
        *error = localError;
        result = nil;
    }

    return result;
}

- (NSDictionary *)_evaluateEndPointParametersWithContext:(NSDictionary *)context error:(NSError **)error  {
    NSParameterAssert(error != nil);

    NSMutableDictionary *result = nil;

    // Add any parameters that were provided
    NSError *localError;
    NSUInteger entryNum = 0;
    for (NSArray *paramTuple in self.endPointParameters) {
        if (![paramTuple isKindOfClass:[NSArray class]]) {
            NSString *msgFmt = @"END_POINT_PARAMETERS expression yielded a result of type %@, expected NSArray.";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             NSStringFromClass([paramTuple class])];

            localError = [NSError errorWithMessage:msg forAtom:self];
        }

        NSString *msgFmt = @"The %@ hand expression of END_POINT_PARAMETERS entry #%lu yieled a type of %@, expected NSString";

        // Evaluate the LHS expression
        id lhsResult = nil;

        if (localError == nil) {
            id<FOSExpression,FOSCompiledAtomInfo> lhsExpr = paramTuple[0];
            lhsResult = [lhsExpr evaluateWithContext:context error:&localError];
            if (localError == nil) {
                if (![lhsResult isKindOfClass:[NSString class]]) {
                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                     @"left",
                                     (unsigned long)entryNum,
                                     NSStringFromClass([lhsResult class])];

                    localError = [NSError errorWithMessage:msg forAtom:lhsExpr];
                }
            }
        }

        // Evaluate the RHS expression
        id rhsResult = nil;
        if (localError == nil) {
            id<FOSExpression,FOSCompiledAtomInfo> rhsExpr = paramTuple[1];
            rhsResult = [rhsExpr evaluateWithContext:context error:&localError];

            if (localError == nil) {
                if (![rhsResult isKindOfClass:[NSString class]]) {
                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                     @"right",
                                     (unsigned long)entryNum,
                                     NSStringFromClass([rhsResult class])];

                    localError = [NSError errorWithMessage:msg forAtom:rhsExpr];
                }
            }
        }

        // Save off the expression results
        if (localError == nil) {
            if (rhsResult != nil &&
                (![rhsResult isKindOfClass:[NSString class]] ||
                 ((NSString *)rhsResult).length > 0)) {

                if (result == nil) {
                    result = [NSMutableDictionary dictionary];
                }

                result[lhsResult] = rhsResult;
            }
        }
        else {
            break;
        }

        entryNum++;
    }
    
    if (localError != nil) {
        *error = localError;
        result = nil;
    }
    
    return result;
}

- (NSString *)_endPointStrForCMO:(FOSCachedManagedObject *)cmo
                            withContext:(NSDictionary *)context
                                  error:(NSError **)error {
    if (error != nil) { *error = nil; }

    NSError *localError = nil;
    NSString *result = nil;

    id exprValue = [self.endPointURLExpression evaluateWithContext:context error:&localError];
    if (localError == nil) {
        if (![exprValue isKindOfClass:[NSString class]]) {
            NSString *msgFmt = @"END_POINT expression yielded a value of type %@, expected an NSString for URL_BINDING %@";
            NSString *msg = [NSString stringWithFormat:msgFmt,
                             NSStringFromClass([exprValue class]),
                             self.entityMatcher.description];

            localError = [NSError errorWithMessage:msg forAtom:self];
        }
        else {
            result = (NSString *)exprValue;
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

- (NSURLRequest *)_urlRequestForEntity:(NSEntityDescription *)entity
                           withContext:(NSDictionary *)context
                                 error:(NSError **)error {
    NSParameterAssert(context != nil);
    NSParameterAssert(error != nil);
    
    // Ensure that the cmo is managed by this request
    NSMutableURLRequest *result= nil;
    if ((entity == nil) || [self _matchEntity:entity error:error]) {
        
        NSURL *url = [self _urlForCMO:nil withContext:context error:error];
        
        if (*error == nil) {
            // Assign URL
            result = [NSMutableURLRequest requestWithURL:url];
            
            // Assign request method
            result.HTTPMethod = self._httpMethod;
            
            // Assign headers
            result.allHTTPHeaderFields = self._mergedHeaderFields;
            
            // Assign timeout
            result.timeoutInterval = self._timeoutInterval;
            
            // Assign the body
            result.HTTPBody = [self _httpBodyForCommandWithContext:context error:error];
        }
        
        if (*error != nil) {
            result = nil;
        }
    }
    
    return result;
}

- (NSURLRequest *)_urlRequestForRelationship:(NSRelationshipDescription *)relDesc
                                 withContext:(NSDictionary *)context
                                       error:(NSError **)error {
    NSParameterAssert(relDesc != nil);
    NSParameterAssert(context != nil);
    NSParameterAssert(error != nil);

    // Ensure that the cmo is managed by this request
    NSMutableURLRequest *result= nil;
    NSEntityDescription *entity = relDesc.destinationEntity;
    if ([self _matchEntity:entity error:error] &&
        [self.relationshipMatcher itemIsIncluded:relDesc.name context:context]) {

        NSURL *url = [self _urlForCMO:nil withContext:context error:error];

        if (*error == nil) {
            // Assign URL
            result = [NSMutableURLRequest requestWithURL:url];

            // Assign request method
            result.HTTPMethod = self._httpMethod;

            // Assign headers
            result.allHTTPHeaderFields = self._mergedHeaderFields;

            // Assign timeout
            result.timeoutInterval = self._timeoutInterval;

            // Assign the body
            NSAssert(self.requestFormat == FOSRequestFormatNoData, @"Need to generate a body???");
        }

        if (*error != nil) {
            result = nil;
        }
    }
    return result;
}

- (NSString *)_httpMethod {
    return [FOSWebServiceRequest httpMethodStringForRequestMethod:self.requestMethod];
}

- (NSDictionary *)_mergedHeaderFields {
    NSMutableDictionary *result = [[self.serviceAdapter headerFields] mutableCopy];
    NSDictionary *localHeaders = self.headerFields;

    // Set the content type
    NSString *contentType = self._contentType;
    if (contentType != nil) {
        result[@"Content-Type"] = contentType;
    }
    result[@"Accept"] = @"application/json";

    // Add any local entries
    if (localHeaders != nil) {
        [result addEntriesFromDictionary:localHeaders];
    }

    return result;
}

- (NSTimeInterval)_timeoutInterval {
    NSTimeInterval result = self.timeoutInterval;

    if (result == 0.0f) {
        result = self.serviceAdapter.defaultTimeout;
    }

    return result;
}

- (NSString *)_contentType {
    NSString *result = nil;

    // TODO : Someday we'll have to figure out how to deal with other charsets, but
    //        UTF-8 should work for quite a while.
    switch (self.requestFormat) {
        case FOSRequestFormatJSON:
            result = @"application/json; charset=UTF-8";
            break;

        case FOSRequestFormatWebform:
            result = @"application/x-www-form-urlencoded; charset=UTF-8";
            break;

        default:
        case FOSRequestFormatNoData:
            break;
    }

    return result;
}

- (NSData *)_httpBodyForCMO:(FOSCachedManagedObject *)cmo error:(NSError **)error {
    NSParameterAssert(error != nil);

    NSError *localError = nil;
    NSData *result = nil;

    NSDictionary *json = [self _jsonBodyForCMO:cmo error:&localError];

    if (localError == nil) {
        NSDictionary *context = @{ @"CMO" : cmo };

        result = [self _httpBodyForJSON:json context:context error:&localError];
    }

    if (localError != nil) {
        if (error != nil) { *error = localError; }

        result = nil;
    }

    return result;
}

- (NSDictionary *)_jsonBodyForCMO:(FOSCachedManagedObject *)cmo error:(NSError **)error {
    NSParameterAssert(cmo != nil);
    NSParameterAssert(error != nil);

    NSMutableDictionary *result = nil;
    NSError *localError = nil;

    result = [NSMutableDictionary dictionary];

    // These are the only 2 lifecycle phases that we send json.
    // TODO : Consider whether this logic needs to be in the adapter
    if (self.lifecyclePhase == FOSLifecyclePhaseCreateServerRecord ||
        self.lifecyclePhase == FOSLifecyclePhaseUpdateServerRecord) {
        if (![self.cmoBinding updateJson:result
                                fromCMO:cmo
                      forLifecyclePhase:self.lifecyclePhase
                                  error:&localError]) {
            result = nil;
        }
    }

    if (localError == nil) {
        NSDictionary *context = @{ @"CMO" : cmo , @"ENTITY" : cmo.entity };
        if (cmo.jsonIdValue != nil) {
            context = [context mutableCopy];
            ((NSMutableDictionary *)context)[@"CMOID"] = cmo.jsonIdValue;
        }

        NSDictionary *jsonBody = [self _jsonBodyWithContext:context error:&localError];
        if (localError == nil && jsonBody.count > 0) {
            [result addEntriesFromDictionary:jsonBody];
        }
    }

    if (localError != nil) {
        if (error != nil) { *error = localError; }

        result = nil;
    }

    return result;
}

- (NSData *)_httpBodyForCommandWithContext:(NSDictionary *)context error:(NSError **)error {
    NSParameterAssert(error != nil);

    NSDictionary *json = [self _jsonBodyWithContext:context error:error];
    NSData *result = [self _httpBodyForJSON:json context:context error:error];

    return result;
}

- (NSData *)_httpBodyForJSON:(id<NSObject>)json
                     context:(NSDictionary *)context
                       error:(NSError **)error {
    NSParameterAssert(error != nil);

    NSData *result = nil;

    // There's only a body if the request format is going to be JSON or if it's
    // webform and we're not using GET to send the request.
    if (self.requestFormat == FOSRequestFormatJSON ||
        (self.requestFormat == FOSRequestFormatWebform &&
         self.requestMethod != FOSRequestMethodGET)) {

            if (json != nil && *error == nil) {

                // See if it needs to be wrapped
                json = [self wrapJSON:json context:context error:error];

                if (*error == nil) {
                    result = [self _htmlBodyForJSON:json error:error];
                }
            }
        }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

- (NSDictionary *)_jsonBodyWithContext:(NSDictionary *)context error:(NSError **)error {
    NSParameterAssert(error != nil);

    *error = nil;
    NSDictionary *result = nil;

    // TODO : This is really hacked up and needs to be straightend out with
    //        a top-level expression.
    NSMutableDictionary *json = [NSMutableDictionary dictionary];

    for (NSArray *keyValueArray in self.jsonBindingExpressions) {
        id<FOSExpression> keyExpr = keyValueArray[0];
        id<FOSExpression> valueExpr = keyValueArray[1];

        id key = [keyExpr evaluateWithContext:context error:error];
        if (*error == nil) {
            id value = [valueExpr evaluateWithContext:context error:error];
            if (*error == nil) {
                json[key] = value ? value : [NSNull null];
            }
        }

        if (*error != nil) {
            break;
        }
    }

    if (*error == nil) {
        result = json;
    }
    else {
        result = nil;
    }

    return result;
}

- (NSData *)_htmlBodyForJSON:(id<NSObject>)json error:(NSError **)error {
    NSParameterAssert(json != nil);
    NSParameterAssert(error != nil);

    *error = nil;
    NSData *result = nil;

    if (self.requestFormat == FOSRequestFormatJSON) {
        result = [NSJSONSerialization dataWithJSONObject:json options:0 error:error];
    }

    // web-form
    else {
        NSString *webformEncoding = [self _webformEncodeJSON:json error:error];

        // Is this the correct encoding???
        result = [webformEncoding dataUsingEncoding:NSUTF8StringEncoding];
    }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

- (NSString *)_webformEncodeJSON:(id<NSObject>)json error:(NSError **)error {
    NSParameterAssert(error != nil);
    *error = nil;

    NSMutableString *result = [NSMutableString stringWithCapacity:256];

    // TODO : Support other types
    NSParameterAssert([json isKindOfClass:[NSDictionary class]]);

    for (NSString *key in ((NSDictionary *)json).allKeys) {
        id<NSObject> value = json[key];

        if (result.length > 0) {
            [result appendString:@"&"];
        }

        [result appendString:key];
        [result appendString:@"="];

        NSString *valueStr = nil;
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:error];

            NSString *jsonStr = [[NSString alloc] initWithData:jsonData
                                                      encoding:NSUTF8StringEncoding];

            valueStr = jsonStr;
        }
        else {
            valueStr = value.description;
        }

        NSString *escapedValueStr =
            [valueStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [result appendString:escapedValueStr];
    }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

- (id<NSObject>)_unwrapJSON:(id<NSObject>)json
              keyExpression:(id<FOSExpression>)keyExpr
                    context:(NSDictionary *)context
                      error:(NSError **)error {

    if (error != nil) { *error = nil; }
    id<NSObject> result = json;

    NSError *localError = nil;

    if (keyExpr != nil && json != nil) {
        NSString *jsonKey = [keyExpr evaluateWithContext:context error:&localError];

        if (jsonKey != nil && localError == nil) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSString *msgFmt = @"The json provided to xxx_WRAPPER_KEY %@ was of type %@, an NSDictionary was expected for ULR_BINDING %@.";
                NSString *msg = [NSString stringWithFormat:msgFmt,
                                 jsonKey,
                                 NSStringFromClass([json class]),
                                 self.entityMatcher.description];

                localError = [NSError errorWithMessage:msg forAtom:self];
            }
            else {
                NSDictionary *jsonDict = (NSDictionary *)json;

                result = jsonDict[jsonKey];
            }
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

@end
