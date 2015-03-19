//
//  FOSWebService.m
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
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

#import <FOSWebService_Internal.h>
#import "FOSWebServiceRequest+FOS_Internal.h"

const NSTimeInterval kFOSQueueingDelay = 0.26f;

@implementation FOSWebService {
    __weak FOSRESTConfig *_restConfig;
    NSInteger _nextRequestId;
    NSMutableArray *_queuedRequests;
    FOSOperationQueue *_timerQueue;
}

#pragma mark - FOSProcessServiceRequest Protocol Methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(restConfig.defaultTimeout > 0.0);

    if ((self = [super init]) != nil) {
        _restConfig = restConfig;
        _queuedRequests = [NSMutableArray arrayWithCapacity:300];
        _timerQueue = [FOSOperationQueue queueWithRestConfig:restConfig];
        _timerQueue.maxConcurrentOperationCount = 1;
        _timerQueue.name = @"Web Service Batch Queue";
    }

    return self;
}

- (id)init {
    NSException *e = [NSException exceptionWithName:@"FOSWebServiceInit"
                                             reason:@"FOSWebService::initWithCacheConfig must be called, not init."
                                           userInfo:nil];

    @throw e;
}

- (void)queueRequest:(FOSWebServiceRequest *)request {
    @synchronized(_queuedRequests) {
        BOOL batchedRequestsSupported =
            [_restConfig.restServiceAdapter respondsToSelector:@selector(maxBatchCount)];

        [_queuedRequests addObject:request];

        if (batchedRequestsSupported) {
            __block FOSWebService *blockSelf = self;

            [_timerQueue cancelAllOperations];

            FOSSleepOperation *nextSleepOp =
                [FOSSleepOperation sleepOperationWithSleepInterval:kFOSQueueingDelay];

            FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                if (!cancelled && error == nil) {
                    [blockSelf _processRequestQueue];
                }
            }];

            [bgOp addDependency:nextSleepOp];

            [_timerQueue addOperation:nextSleepOp];
            [_timerQueue addOperation:bgOp];
        }
        else {
            [self _processRequestQueue];
        }
    }
}

#pragma mark - Private Methods

- (void)_sendShortCircuitableRequest:(FOSWebServiceRequest *)request synchronous:(BOOL)synchronous {
    BOOL sendRequest = YES;

    // Allow the request's willProcessHandler to short-circuit the request
    // and direct the result right back to an existing NSManagedObjectID.
    if (request.willProcessHandler != nil) {
        NSManagedObjectID *objectID = request.willProcessHandler();

        if (objectID != nil) {
            [request setOriginalJsonResult:objectID postProcessor:nil];
            sendRequest = NO;
        }
    }

    if (sendRequest) {
        [self _sendRequest:request synchronous:synchronous];
    }
}

- (void)_processRequestQueue {
    NSArray *queuedRequests = nil;

    @synchronized(_queuedRequests) {
        // Retrieve queued requests
        queuedRequests = [_queuedRequests copy];
        [_queuedRequests removeAllObjects];
    }

    BOOL isConnectedToInternet = (_restConfig.networkStatus != FOSNetworkStatusNotReachable);
    NSUInteger maxBatchCount = [_restConfig.restServiceAdapter respondsToSelector:@selector(maxBatchCount)]
        ? _restConfig.restServiceAdapter.maxBatchCount
        : 0;

    NSMutableArray *updateRequests = [NSMutableArray arrayWithCapacity:queuedRequests.count];
    for (FOSWebServiceRequest *nextRequest in queuedRequests) {

        // If we're not connected to the internet, no need to send the request.
        if (isConnectedToInternet) {
            if (maxBatchCount > 0 &&
                [_restConfig.restServiceAdapter requestCanBeBatched:nextRequest]) {
                [updateRequests addObject:nextRequest];
            }
            else {
                [self _sendShortCircuitableRequest:nextRequest synchronous:YES];
            }
        }
        else {
            [nextRequest cancel];
        }
    }

    while (updateRequests.count > 0) {
        NSUInteger batchCount = updateRequests.count < maxBatchCount
            ? updateRequests.count
            : maxBatchCount;

        // Get the next batch of requests
        NSRange range = NSMakeRange(0, batchCount);
        NSArray *requests = [updateRequests subarrayWithRange:range];
        [updateRequests removeObjectsInRange:range];

        // Combine the requests into a single batch request
        FOSWebServiceRequest *batchRequest =
            [_restConfig.restServiceAdapter generateBatchRequestForRequests:requests];

        // This request really never gets queued, it's just a container
        [self _sendShortCircuitableRequest:batchRequest synchronous:YES];

        // Process the server's result
        [_restConfig.restServiceAdapter processResultsOfBatchRequest:batchRequest
                                                         forRequests:requests];
    }
}

- (void)_sendRequest:(FOSWebServiceRequest *)webServiceRequest
         synchronous:(BOOL)synchronous {

    NSURLRequest *urlRequest = webServiceRequest.urlRequest;

    NSInteger currentRequestId = _nextRequestId;
    _nextRequestId += 1;

    NSString *requestMethod = urlRequest.HTTPMethod;
    NSString *requestURLString = urlRequest.URL.absoluteString;

    NSString *requestDebugData = nil;
    if (urlRequest.HTTPBody != nil) {
        NSString *contentType = urlRequest.allHTTPHeaderFields[@"Content-Type"];
        NSRange jsonTypeRange = [contentType rangeOfString:@"application/json"];
        NSRange webformTypeRange = [contentType rangeOfString:@"application/x-www-form-urlencoded"];

        if (jsonTypeRange.location != NSNotFound) {
            id<NSObject> json = [NSJSONSerialization JSONObjectWithData:urlRequest.HTTPBody
                                                                options:0
                                                                  error:nil];

            requestDebugData = json.description;
        }
        else if (webformTypeRange.location != NSNotFound) {
            requestDebugData = [[NSString alloc] initWithData:urlRequest.HTTPBody
                                                     encoding:NSUTF8StringEncoding];
        }
    }

    if (synchronous) {
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                                         error:&error];

        FOSLogDebug(@"FOSWebService (%li) Sync: %@ - %@",
                    (long)currentRequestId, requestMethod,
                    [requestURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        if (urlRequest.allHTTPHeaderFields.count > 0) {
            FOSLogPedantic(@"\nHTTP-Headers: %@",
                             urlRequest.allHTTPHeaderFields.description);
        }
        if (requestDebugData != nil) {
            FOSLogPedantic(@"\nHTTP-Data: %@",
                   [requestDebugData stringByRemovingPercentEncoding]);
        }
        
        [self _completionHandlerForRequest:webServiceRequest
                            withURLRequest:urlRequest
                                  response:response
                              responseData:data
                             responseError:error];
    }
    else {
        FOSOperationQueue *queue = (FOSOperationQueue *)[FOSOperationQueue currentQueue];
        NSAssert(queue != nil, @"No current queue???");
        NSAssert([queue isKindOfClass:[FOSOperationQueue class]],
                 @"Expected FOSOperationQueue, got %@.",
                 NSStringFromClass([queue class]));

        FOSLogDebug(@"FOSWebService (%li) Async: %@ - %@", (long)currentRequestId, requestMethod, requestURLString);

        __block FOSWebService *blockSelf = self;

        // Capture the request Id
        NSInteger requestId = _nextRequestId;
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

            FOSLogDebug(@"   FOSWebService (%li) response...", (long)requestId);

            [blockSelf _completionHandlerForRequest:webServiceRequest
                                     withURLRequest:urlRequest
                                           response:response
                                       responseData:data
                                      responseError:error];
        }];
    }
}

- (void)_completionHandlerForRequest:(FOSWebServiceRequest *)webServiceRequest
                      withURLRequest:(NSURLRequest *)request
                            response:(NSURLResponse *)response
                        responseData:(NSData *)data
                       responseError:(NSError *)error {

    id<NSObject> jsonResult = nil;
    NSError *localError = error;

    // We made an HTTP request, we expect an NSHTTPURLResponse
    if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        id<FOSRESTServiceAdapter> adapter = _restConfig.restServiceAdapter;

        // Allow the client to watch this
        if ([adapter respondsToSelector:@selector(request:receivedResponse:andError:)]) {
            [adapter request:request receivedResponse:httpResponse andError:localError];
        }

        [adapter processWebServiceResponse:httpResponse
                              responseData:data
                             forURLBinding:webServiceRequest.urlBinding
                                jsonResult:&jsonResult
                                     error:&localError];
    }
    else if (response != nil) {
        NSString *errorMsg = [NSString stringWithFormat:@"Received a reponse of type %@, expected NSHTTPURLResponse.",
                              [[response class] description]];

        localError = [NSError errorWithMessage:errorMsg];
    }
    else {
        if (localError == nil) {
            NSString *msg = @"Received a nil NSURLResponse and no NSError.";

            localError = [NSError errorWithMessage:msg];
        }
    }

    // Handle the result of the processing
    if (localError == nil) {
        FOSLogDebug(@"    FOSWebService Success!!!");

        [webServiceRequest setOriginalJsonResult:jsonResult postProcessor:nil];
    }
    else {
        FOSLogError(@"    FOSWebService ERROR -- Message: %@", localError.description);

        [webServiceRequest setError:localError];
    }

    if (FOSGetLogLevel() >= FOSLogLevelPedantic) {
        NSString *json = @"<no data>";

        if (jsonResult != nil) {
            // Let's format this is JSON format as opposed to [NSObjet description] format.
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResult options:0 error:nil];

            json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        FOSLogPedantic(@"\nJSON: %@", json);
    }
}

@end
