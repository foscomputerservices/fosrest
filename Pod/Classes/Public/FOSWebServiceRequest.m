//
//  FOSWebServiceRequest.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSWebServiceRequest+FOS_Internal.h>
#import "FOSFoundation_Internal.h"

@implementation FOSWebServiceRequest {
    NSURLRequest *_urlRequest;
}

#pragma mark - Property Overrides

- (NSString *)httpMethod {
    return [[self class] httpMethodStringForRequestMethod:self.requestMethod];
}

- (id<NSObject>)jsonResult {
    return _jsonResult;
}

- (id<NSObject>)originalJsonResult {
    return _originalJsonResult;
}

- (void)setServiceRequestProcessor:(id<FOSProcessServiceRequest>)serviceRequestProcessor {
    _serviceRequestProcessor = serviceRequestProcessor;

    [self willChangeValueForKey:@"isReady"];
    _requestState = FOSWSRequestStateReady;
    [self didChangeValueForKey:@"isReady"];
}

- (NSURL *)url {
    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];

    // Build up the full URL
    BOOL isGet = _requestMethod == FOSRequestMethodGET;
    BOOL hasFragments = _uriFragments.count > 0;
    BOOL fragmentIsString =
        hasFragments &&
        [_uriFragments.lastObject isKindOfClass:[NSString class]] &&
        ((NSString *)_uriFragments.lastObject).length > 0;
    BOOL fragmentIsQueryString =
        fragmentIsString &&
        ([((NSString *)_uriFragments.lastObject) characterAtIndex:0] == (unichar)'?' ||
         [((NSString *)_uriFragments.lastObject) characterAtIndex:0] == (unichar)'/');
    BOOL fragmentIsQueryParameter =
        isGet || fragmentIsQueryString;

    NSMutableString *endPointAndQuery = [NSMutableString stringWithCapacity:128];
    [endPointAndQuery appendString:_endPoint];
    if (fragmentIsQueryParameter) {
        NSUInteger i = 0, count = _uriFragments.count;
        for (id<NSObject> nextFragment in _uriFragments) {
            NSString *uriFragment = nil;

            if ([nextFragment isKindOfClass:[NSString class]]) {
                uriFragment = (NSString *)nextFragment;
            }
            else if ([nextFragment isKindOfClass:[NSDictionary class]] ||
                     [nextFragment isKindOfClass:[NSArray class]]) {

                if ([nextFragment isKindOfClass:[NSArray class]] &&
                    ![nextFragment isKindOfClass:[NSData class]]) {

                    NSError *jsonError = nil;
                    NSData *serializedJSON =
                    [NSJSONSerialization dataWithJSONObject:nextFragment
                                                    options:0
                                                      error:&jsonError];
                    NSAssert(jsonError == nil, @"Error received encoding JSON data???");

                    uriFragment = [NSString stringWithUTF8String:serializedJSON.bytes];
                }
            }
            else {
                NSAssert(@"Do not know how to handle uriFragment of type %@.",
                         [[nextFragment class] description]);
            }

            if (uriFragment.length > 0) {
                if ([uriFragment characterAtIndex:0] != '?') {
                    [endPointAndQuery appendString:@"/"];
                }

                [endPointAndQuery appendString:uriFragment];
            }
            else if (i < count - 1) {
                [endPointAndQuery appendString:@"/"];
            }
        }

        i++;
    }

    NSString *localBaseURL = _baseURL.length > 0 ? [_baseURL copy] : @"";
    NSString *localEndPointAndQuery = [endPointAndQuery copy];
    NSArray *localFragments = [_uriFragments copy];

    // Allow for app to override this URL
    if ([restConfig.restServiceAdapter respondsToSelector:@selector(swizzleURL:endPoint:andFragments:)]) {
        [restConfig.restServiceAdapter swizzleURL:&localBaseURL
                                         endPoint:&localEndPointAndQuery
                                     andFragments:&localFragments];
    }

    NSString *requestURLString = localBaseURL;
    if (localEndPointAndQuery.length > 0) {
        BOOL baseEndsWithSlash =
        ([localEndPointAndQuery characterAtIndex:localEndPointAndQuery.length-1] == (unichar)'/');

        requestURLString = [localBaseURL stringByAppendingFormat:@"%@%@",
                            baseEndsWithSlash ? @"" : @"/",
                            localEndPointAndQuery];
    }

    // Encode the URL
    NSString *encodedRequestURLString = [requestURLString
                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *result = [NSURL URLWithString:encodedRequestURLString];

    return result;
}

- (NSURLRequest *)urlRequest {
    NSURLRequest *result = _urlRequest;

    if (result == nil) {
        result = [self _composeURLRequest];
    }

    return result;
}

#pragma mark - NSOperation Overrides
- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isReady {
    @synchronized(self) {
        BOOL result = [super isReady] && _requestState == FOSWSRequestStateReady;

        return result;
    }
}

- (BOOL)isCancelled {
    BOOL result = [super isCancelled];

    return result;
}

- (BOOL)isExecuting {
    @synchronized(self) {
        BOOL result = _requestState == FOSWSRequestStateExecuting && !self.isCancelled;

        return result;
    }
}

- (BOOL)isFinished {
    @synchronized(self) {
        BOOL result =
            _requestState == FOSWSRequestStateFinished ||
            self.isCancelled;
        
        return result;
    }
}

- (void)cancel {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    [super cancel];

    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)start {
    @synchronized(self) {
        NSAssert(self.serviceRequestProcessor != nil,
                 @"FOSCacheManager should have assigned serviceRequestProcessor by now!");

        [self willChangeValueForKey:@"isExecuting"];
        _requestState = FOSWSRequestStateExecuting;
        [self didChangeValueForKey:@"isExecuting"];

        // Do it!
        [self main];
    }
}

- (void)main {
    [super main];

    // Asynchronously queue ourself for processing.
    // FOSWebService will then call back on either setOriginalJsonResult: or setError:
    // in FOSWebServiceRequest+FOS_Internal, which will cause things to progres
    // from there.

    [_serviceRequestProcessor queueRequest:self];
}

#pragma mark - Class methods
+ (BOOL)isValidLoggedOutEndpoint:(NSString *)endPoint {
    NSSet *validOfflineEndPoints = [FOSRESTConfig sharedInstance].validOfflineEndPoints;
    BOOL found = NO;

    // TODO : Probably should include FOSRequestMethod in the comparison
    for (NSString *nextEP in validOfflineEndPoints) {
        if ([endPoint rangeOfString:nextEP].location != NSNotFound) {
            found = YES;
            break;
        }
    }
    
    return found;
}

#pragma mark - Init methods
+ (instancetype)requestWithRequestType:(FOSRequestMethod)requestType endPoint:(NSString *)endPoint {
    FOSWebServiceRequest *result = [[self alloc] initWithRequestType:requestType
                                                             baseURL:nil
                                                            endPoint:endPoint
                                                        uriFragments:nil];

    return result;
}

+ (instancetype)requestWithRequestType:(FOSRequestMethod)requestType
                              endPoint:(NSString *)endPoint
                          uriFragments:(NSArray *)uriFragments {

    FOSWebServiceRequest *result = [[self alloc] initWithRequestType:requestType
                                                             baseURL:nil
                                                            endPoint:endPoint
                                                        uriFragments:uriFragments];

    return result;
}

+ (instancetype)requestWithRequestType:(FOSRequestMethod)requestType
                               baseURL:(NSString *)baseURL
                              endPoint:(NSString *)endPoint
                          uriFragments:(NSArray *)uriFragments {
    
    FOSWebServiceRequest *result = [[self alloc] initWithRequestType:requestType
                                                             baseURL:baseURL
                                                            endPoint:endPoint
                                                        uriFragments:uriFragments];

    return result;
}

+ (instancetype)requestWithURLRequest:(NSURLRequest *)urlRequest
                        forURLBinding:(FOSURLBinding *)urlBinding {
    NSParameterAssert(urlRequest != nil);
    NSParameterAssert(urlBinding != nil);

    return [[self alloc] initWithURLRequest:urlRequest andURLBinding:urlBinding];
}

+ (NSString *)httpMethodStringForRequestMethod:(FOSRequestMethod)requestMethod {
    NSString *result = nil;
    
    switch (requestMethod) {
        case FOSRequestMethodPOST:
            result = @"POST";
            break;
            
        case FOSRequestMethodPUT:
            result = @"PUT";
            break;
            
        case FOSRequestMethodDELETE:
            result = @"DELETE";
            break;
            
        default:
        case FOSRequestMethodGET:
            result = @"GET";
            break;
    }
    
    return result;
}

#pragma mark - Initialization Methods

- (id)initWithRequestType:(FOSRequestMethod)requestType
                  baseURL:(NSString *)baseURL
                 endPoint:(NSString *)endPoint
             uriFragments:(NSArray *)uriFragments {
    NSParameterAssert(endPoint != nil);
    NSParameterAssert([endPoint rangeOfString:@"<null>"].location == NSNotFound);

    if ((self = [super init]) != nil) {
        _requestMethod = requestType;
        _baseURL = baseURL;
        _endPoint = endPoint;
        _uriFragments = uriFragments;
    }
    
    return self;
}

- (id)initWithURLRequest:(NSURLRequest *)urlRequest andURLBinding:(FOSURLBinding *)urlBinding {
    NSParameterAssert(urlRequest != nil);
    NSParameterAssert(urlBinding != nil);

    if ((self = [super init]) != nil) {
        _urlRequest = urlRequest;
        _urlBinding = urlBinding;
    }

    return self;
}

- (NSString *)description {
    NSString *result = nil;

    if (_urlBinding == nil) {
        NSString *requestTypeStr = nil;
        switch (_requestMethod) {
            case FOSRequestMethodGET:
                requestTypeStr = @"FOSRequestMethodGET";
                break;
                
            case FOSRequestMethodPUT:
                requestTypeStr = @"FOSRequestMethodPUT";
                break;
                
            case FOSRequestMethodPOST:
                requestTypeStr = @"FOSRequestMethodPOST";
                break;
                
            case FOSRequestMethodDELETE:
                requestTypeStr = @"FOSRequestMethodDELETE";
                break;
        }
        
        NSMutableString *uriFragments = [NSMutableString string];
        
        for (id<NSObject> nextFragment in _uriFragments) {
            if (uriFragments.length > 0) {
                [uriFragments appendString:@", "];
            }

            [uriFragments appendString:[nextFragment description]];
        }
        
        result = [NSString stringWithFormat:@"{ super = { %@ }, baseURL = %@, requestType = %@, endPoint = %@, uriFragments = { %@ } }", [super description], _baseURL, requestTypeStr, _endPoint, uriFragments];
    }
    else {
        result = _urlBinding.description;
    }
    
    return result;
}

#pragma mark - FOSOperation Overrides

- (BOOL)isPullOperation {
    return (self.requestMethod == FOSRequestMethodGET);
}

#pragma mark - Private Methods

// TODO : In theory, this entire mechanism should go away and be replaced with simply
//        NSURLRequest instances generated by the service provider.
- (NSURLRequest *)_composeURLRequest {

    FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];
    FOSRequestMethod requestType = self.requestMethod;
    NSString *endPoint = self.endPoint;
    NSArray *uriFragments = self.uriFragments;
    NSString *baseURL = self.baseURL.length > 1
        ? self.baseURL
        : restConfig.restServiceAdapter.defaultBaseURL.absoluteString;

    NSParameterAssert(baseURL != nil);
    NSParameterAssert(endPoint!= nil);
    NSParameterAssert(endPoint.length > 0);
    NSParameterAssert([endPoint characterAtIndex:0] != (unichar)'/');

    // Set up a dictionary for any potential errors.  As pieces are accumulated
    // they will be added to this dictionary so that we will have full disclosure
    // of what was going on sent to the error handlers and loggers.
    //
    // It's true that this puts a slight burden on the majority of requests that
    // succeed, but for tracking down problems it's worth the slight overhead on
    // each call.
    NSMutableDictionary *errorUserInfo = [NSMutableDictionary dictionaryWithCapacity:15];
    errorUserInfo[@"requestType"] = @(requestType);
    errorUserInfo[@"baseURL"] = baseURL;
    if (uriFragments != nil) {
        errorUserInfo[@"uriFragments"] = uriFragments;
    }

    // Build up the full URL
    BOOL isGet = requestType == FOSRequestMethodGET;
    BOOL hasFragments = uriFragments.count > 0;
    BOOL fragmentIsString =
        hasFragments &&
        [uriFragments.lastObject isKindOfClass:[NSString class]] &&
        ((NSString *)uriFragments.lastObject).length > 0;
    BOOL fragmentIsQueryString =
        fragmentIsString &&
        ([((NSString *)uriFragments.lastObject) characterAtIndex:0] == (unichar)'?' ||
         [((NSString *)uriFragments.lastObject) characterAtIndex:0] == (unichar)'/');
    BOOL fragmentIsQueryParameter =
        isGet || fragmentIsQueryString;

    NSMutableString *endPointAndQuery = [NSMutableString stringWithCapacity:128];
    [endPointAndQuery appendString:endPoint];
    if (fragmentIsQueryParameter) {
        NSUInteger i = 0, count = uriFragments.count;
        for (id<NSObject> nextFragment in uriFragments) {
            NSString *uriFragment = nil;

            if ([nextFragment isKindOfClass:[NSString class]]) {
                uriFragment = (NSString *)nextFragment;
            }
            else if ([nextFragment isKindOfClass:[NSDictionary class]] ||
                     [nextFragment isKindOfClass:[NSArray class]]) {

                if ([nextFragment isKindOfClass:[NSArray class]] &&
                    ![nextFragment isKindOfClass:[NSData class]]) {

                    NSError *jsonError = nil;
                    NSData *serializedJSON =
                    [NSJSONSerialization dataWithJSONObject:nextFragment
                                                    options:0
                                                      error:&jsonError];
                    NSAssert(jsonError == nil, @"Error received encoding JSON data???");

                    uriFragment = [NSString stringWithUTF8String:serializedJSON.bytes];
                }
            }
            else {
                NSAssert(@"Do not know how to handle uriFragment of type %@.",
                         [[nextFragment class] description]);
            }

            if (uriFragment.length > 0) {
                if ([uriFragment characterAtIndex:0] != '?') {
                    [endPointAndQuery appendString:@"/"];
                }

                [endPointAndQuery appendString:uriFragment];
            }
            else if (i < count - 1) {
                [endPointAndQuery appendString:@"/"];
            }
        }

        i++;
    }

    NSString *localBaseURL = [baseURL copy];
    NSString *localEndPointAndQuery = [endPointAndQuery copy];
    NSArray *localFragments = [uriFragments copy];

    NSString *requestURLString = localBaseURL;
    if (localEndPointAndQuery.length > 0) {
        BOOL baseEndsWithSlash =
        ([localEndPointAndQuery characterAtIndex:localEndPointAndQuery.length-1] == (unichar)'/');

        requestURLString = [localBaseURL stringByAppendingFormat:@"%@%@",
                            baseEndsWithSlash ? @"" : @"/",
                            localEndPointAndQuery];
    }
    errorUserInfo[@"requestURLString"] = requestURLString;

    // Encode the URL
    NSString *encodedRequestURLString = [requestURLString
                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    errorUserInfo[@"encodedRequestURLString"] = encodedRequestURLString;

    NSURL *requestURL = [NSURL URLWithString:encodedRequestURLString];

    if (requestURL == nil) {

        NSString *msg = [NSString stringWithFormat:@"Unable to convert base url and fragments (%@) into a URL.", requestURLString];

        NSException *e = [NSException exceptionWithName:@"FOSBADWebServiceRequest"
                                                 reason:msg
                                               userInfo:errorUserInfo];

        @throw e;
    }

    else {
        // Build the request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
        [request setTimeoutInterval:restConfig.defaultTimeout];

        // We want a JSON response
        [request addValue:@"application/json" forHTTPHeaderField:@"accept"];

        // Add authentication keys
        for (NSString *nextKey in restConfig.headerFields) {
            NSString *nextValue = restConfig.headerFields[nextKey];

            NSParameterAssert([nextKey isKindOfClass:[NSString class]]);
            NSParameterAssert([nextKey isKindOfClass:[NSString class]]);

            [request addValue:nextValue forHTTPHeaderField:nextKey];
        }

        // Do we have any data to attach?
        if (!fragmentIsQueryParameter && localFragments.count > 0) {
            for (id<NSObject> nextFragment in localFragments) {
                NSData *uriFragment = nil;

                if ([nextFragment isKindOfClass:[NSString class]]) {
                    // Set content type
                    [request addValue:@"application/x-www-form-urlencoded"
                   forHTTPHeaderField:@"content-type"];

                    uriFragment =
                    [(NSString *)nextFragment dataUsingEncoding:NSUTF8StringEncoding];
                }
                else if ([nextFragment isKindOfClass:[NSDictionary class]] ||
                         [nextFragment isKindOfClass:[NSArray class]]) {
                    // Set content type
                    [request addValue:@"application/json" forHTTPHeaderField:@"content-type"];

                    NSError *jsonError = nil;
                    NSData *serializedJSON = [NSJSONSerialization dataWithJSONObject:nextFragment
                                                                             options:0
                                                                               error:&jsonError];
                    NSAssert(jsonError == nil, @"Error received encoding JSON data???");

                    uriFragment = serializedJSON;
                }
                else if ([nextFragment isKindOfClass:[NSData class]]) {
                    NSAssert(localFragments.count == 2, @"There must be 2 fragments for binary data.  1) the data, 2) NSDictionary of header fields");
                    NSData *data = (NSData *)nextFragment;
                    NSDictionary *fields = localFragments.lastObject;

                    for (NSString *nextKey in fields.allKeys) {
                        NSAssert([nextKey isKindOfClass:[NSString class]],
                                 @"Bad header key, expected an NSString");

                        NSString *nextValue = fields[nextKey];
                        NSAssert([nextValue isKindOfClass:[NSString class]],
                                 @"Bad header value, expected an NSString");

                        [request addValue:nextValue forHTTPHeaderField:nextKey];
                    }

                    // Set content length
                    NSString *contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
                    [request addValue:contentLength forHTTPHeaderField:@"Content-Length"];

                    request.HTTPBody = data;

                    // We're done with these fragments
                    break;
                }
                else {
                    NSAssert(@"Do not know how to handle uriFragment of type %@.",
                             [[nextFragment class] description]);
                }

                [request setHTTPBody:uriFragment];
            }
        }

        [request setHTTPMethod:self.httpMethod];

        return request;
    }
}

@end
