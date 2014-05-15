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
    NSParameterAssert(lifecyclePhase != FOSLifecyclePhaseCreateServerRecord &&
                      lifecyclePhase != FOSLifecyclePhaseUpdateServerRecord &&
                      requestFormat == FOSRequestFormatNoData);

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

        NSURL *baseURL = self._baseURL;
        NSError *localError = nil;
        NSMutableString *endPointURLStr =
            [[self _endPointURLStrForCMO:cmo error:&localError] mutableCopy];

        if (endPointURLStr.length > 0 && localError == nil) {
            baseURL = [baseURL URLByAppendingPathComponent:endPointURLStr];

            // Assign URL
            result = [NSMutableURLRequest requestWithURL:baseURL];

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
                                         error:(NSError **)error {
    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);

    if (error != nil) { *error = nil; }

    NSDictionary *context = @{ @"CMOID" : jsonId, @"ENTITY" : entity };
    
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
                                                             error:(NSError **)error {
    NSParameterAssert(relDesc != nil);

    if (error != nil) { *error = nil; }

    NSDictionary *context = @{ @"ENTITY" : destEntity, @"RELDESC": relDesc, @"OWNERID" :ownerId };

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
            NSString *msg = [NSString stringWithFormat:@"The provided CMO is of type %@, which doesn't match any entity descriptions bound to this URLBinding.", entity.name];

            *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        }

        result = NO;
    }

    return result;
}

- (id<FOSRESTServiceAdapter>)_adapter {
    id<FOSRESTServiceAdapter> result = [FOSRESTConfig sharedInstance].restServiceAdapter;

    return result;
}

- (NSURL *)_baseURL {
    NSURL *result = self.baseURL;

    if (result == nil) {

        result = self._adapter.defaultBaseURL;
    }

    return result;
}

- (NSString *)_endPointURLStrForCMO:(FOSCachedManagedObject *)cmo error:(NSError **)error {
    NSParameterAssert(error != nil);

    NSDictionary *context = @{ @"CMO" : cmo };
    NSMutableString *result = nil;

    id exprValue = [self.endPointURLExpression evaluateWithContext:context error:error];
    if (![exprValue isKindOfClass:[NSString class]]) {
        NSString *msg = [NSString stringWithFormat:@"endPointURLExpression yieled an instance of type %@, expected and NSString", NSStringFromClass([exprValue class])];

        *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }
    else {
        result = [(NSString *)exprValue mutableCopy];
    }

    // See if we need to encode the data into the URL too
    if (self.requestFormat == FOSRequestFormatWebform &&
        self.requestMethod == FOSRequestMethodGET) {

        NSDictionary *json = [self _jsonBodyForCMO:cmo error:error];
        if (json != nil && json.count > 0 && *error == nil) {
            NSString *webformEncoding = [self _webformEncodeJSON:json error:error];

            if ([result rangeOfString:@"?"].location == NSNotFound) {
                [result appendString:@"?"];
            }
            else {
                [result appendString:@"&"];
            }

            [result appendString:webformEncoding];
        }
    }

    return result;
}

- (NSString *)_endPointURLStrWithContext:(NSDictionary *)context
                                error:(NSError **)error {
    NSParameterAssert(error != nil);

    NSMutableString *result = nil;

    id exprValue = [self.endPointURLExpression evaluateWithContext:context error:error];
    if (![exprValue isKindOfClass:[NSString class]]) {
        NSString *msg = [NSString stringWithFormat:@"endPointURLExpression yieled an instance of type %@, expected an NSString", NSStringFromClass([exprValue class])];

        *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
    }
    else {
        result = [(NSString *)exprValue mutableCopy];
    }
    
    // Add any parameters that were provided
    BOOL paramsAdded = NO;
    for (id<FOSExpression> paramExpr in self.endPointParameters) {
        id paramExprVal = [paramExpr evaluateWithContext:context error:error];
        
        if (paramExprVal && *error == nil) {
            if (![paramExprVal isKindOfClass:[NSString class]]) {
                NSString *msg = [NSString stringWithFormat:@"endPointParameters yieled an instance of type %@, expected an NSString", NSStringFromClass([paramExprVal class])];
                
                *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
                break;
            }
            
            NSString *paramSep = paramsAdded ? @"&" : @"?";
            NSString *paramStr = (NSString *)paramExprVal;
            
            if (paramStr.length > 0) {
                
                // Escape the user-provided string!
                NSString *escapedParamStr =
                    [paramStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [result appendString:paramSep];
                [result appendString:escapedParamStr];
                
                paramsAdded = YES;
            }
        }
        else if (*error != nil) {
            break;
        }
    }

    if (*error != nil) {
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
        
        NSURL *baseURL = self._baseURL;
        
        NSString *endPointURLStr = [self _endPointURLStrWithContext:context error:error];
        
        if (endPointURLStr.length > 0 && *error == nil) {
            baseURL = [NSURL URLWithString:endPointURLStr relativeToURL:baseURL];
            
            // Assign URL
            result = [NSMutableURLRequest requestWithURL:baseURL];
            
            // Assign request method
            result.HTTPMethod = self._httpMethod;
            
            // Assign headers
            result.allHTTPHeaderFields = self._mergedHeaderFields;
            
            // Assign timeout
            result.timeoutInterval = self._timeoutInterval;
            
            // Assign the body
            if (self.requestFormat == FOSRequestFormatJSON) {
                // TODO : This is really hacked up and needs to be straightend out with
                //        a top-level expression.
                NSMutableDictionary *json = [NSMutableDictionary dictionary];

                for (NSArray *keyValueArray in self.jsonBindingExpressions) {
                    id<FOSExpression> keyExpr = keyValueArray[0];
                    id<FOSExpression> valueExpr = keyValueArray[1];

                    id key = [keyExpr evaluateWithContext:context
                                                    error:error];
                    if (*error == nil) {
                        id value = [valueExpr evaluateWithContext:context
                                                            error:error];
                        if (*error == nil) {
                            json[key] = value;
                        }
                    }

                    if (*error != nil) {
                        break;
                    }
                }

                if (*error == nil) {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                                       options:0 error:error];
                    if (*error == nil) {
                        result.HTTPBody = jsonData;
                    }
                }
            }
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
    NSEntityDescription *entity = relDesc.entity;
    if ([self _matchEntity:entity error:error] &&
        [self.relationshipMatcher itemIsIncluded:relDesc.name context:context]) {

        NSURL *baseURL = self._baseURL;

        NSString *endPointURLStr = [self _endPointURLStrWithContext:context error:error];

        if (endPointURLStr.length > 0 && *error == nil) {
            baseURL = [NSURL URLWithString:endPointURLStr relativeToURL:baseURL];

            // Assign URL
            result = [NSMutableURLRequest requestWithURL:baseURL];

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
    NSMutableDictionary *result = [[self._adapter headerFields] mutableCopy];
    NSDictionary *localHeaders = self.headerFields;

    // Set the content type
    NSString *contentType = self._contentType;
    if (contentType != nil) {
        result[@"Content-Type"] = contentType;
    }

    // Add any local entries
    if (localHeaders != nil) {
        [result addEntriesFromDictionary:localHeaders];
    }

    return result;
}

- (NSTimeInterval)_timeoutInterval {
    NSTimeInterval result = self.timeoutInterval;

    if (result == 0.0f) {
        result = self._adapter.defaultTimeout;
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

    NSData *result = nil;

    // There's only a body if the request format is going to be JSON or if it's
    // webform and we're not using GET to send the request.
    if (self.requestFormat == FOSRequestFormatJSON ||
        (self.requestFormat == FOSRequestFormatWebform &&
         self.requestMethod != FOSRequestMethodGET)) {
        NSDictionary *json = [self _jsonBodyForCMO:cmo error:error];

        if (json != nil && *error == nil) {
            if (self.requestFormat == FOSRequestFormatJSON) {
                result = [NSJSONSerialization dataWithJSONObject:json options:0 error:error];
            }

            // web-form
            else {
                NSString *webformEncodeing = [self _webformEncodeJSON:json error:error];

                // Is this the correct encoding???
                result = [webformEncodeing dataUsingEncoding:NSUTF8StringEncoding];
            }
        }
    }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

- (NSDictionary *)_jsonBodyForCMO:(FOSCachedManagedObject *)cmo error:(NSError **)error {
    NSParameterAssert(error != nil);

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    // These are the only 2 lifecycle phases that we send json.
    // TODO : Consider whether this logic needs to be in the adapter
    if (self.lifecyclePhase == FOSLifecyclePhaseCreateServerRecord ||
        self.lifecyclePhase == FOSLifecyclePhaseUpdateServerRecord) {
        if (![self.cmoBinding updateJson:result
                                fromCMO:cmo
                      forLifecyclePhase:self.lifecyclePhase
                                  error:error]) {
            result = nil;
        }
    }

    return result;
}

- (NSString *)_webformEncodeJSON:(NSDictionary *)json error:(NSError **)error {
    NSParameterAssert(error != nil);
    *error = nil;

    NSMutableString *result = [NSMutableString stringWithCapacity:256];

    for (NSString *key in json.allKeys) {
        id<NSObject> value = json[key];

        if (![value isKindOfClass:[NSArray class]] && ![value isKindOfClass:[NSDictionary class]]) {
            if (result.length > 0) {
                [result appendString:@"&"];
            }
            [result appendString:key];
            [result appendString:@"="];
            [result appendString:value.description];
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Unable to create a webform encoding of JSON with nested containers."];

            *error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        }
    }

    return result;
}

@end