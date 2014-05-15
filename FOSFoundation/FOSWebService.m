//
//  FOSWebService.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSWebService_Internal.h"
#import "FOSWebServiceRequest+FOS_Internal.h"

const NSTimeInterval kDefaultTimeout = 20.0f; // 20 seconds
const NSTimeInterval kQueueingDelay = 0.26f;

@implementation FOSWebService {
    __weak FOSRESTConfig *_restConfig;
    NSInteger _nextRequestId;
    NSMutableArray *_queuedRequests;
    FOSOperationQueue *_timerQueue;
}

#pragma mark - FSOProcessServiceRequest Protocol Methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(restConfig.defaultTimeout > 0.0);

    if ((self = [super init]) != nil) {
        _restConfig = restConfig;
        _queuedRequests = [NSMutableArray arrayWithCapacity:300];
        _timerQueue = [[FOSOperationQueue alloc] init];
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
        [_queuedRequests addObject:request];

        [_timerQueue cancelAllOperations];

        __block FOSWebService *blockSelf = self;

        FOSSleepOperation *nextSleepOp = [FOSSleepOperation sleepOperationWithSleepInterval:kQueueingDelay];

        FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
            if (!cancelled && error == nil) {
                [blockSelf _processRequestQueue];
            }
        }];

        [bgOp addDependency:nextSleepOp];

        [_timerQueue addOperation:nextSleepOp];
        [_timerQueue addOperation:bgOp];
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
            request.jsonResult = objectID;
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

    if (synchronous) {
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                                         error:&error];

        NSLog(@"FOSWebService (%li) Sync: %@ - %@",
              (long)currentRequestId, requestMethod,
              [requestURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        
        [self _completionHandlerForRequest:webServiceRequest
                            withURLRequest:urlRequest
                                  response:response
                              responseData:data
                             responseError:error];
    }
    else {
        FOSOperationQueue *queue = [FOSOperationQueue currentQueue];
        NSAssert(queue != nil, @"No current queue???");
        NSAssert([queue isKindOfClass:[FOSOperationQueue class]],
                 @"Expected FOSOperationQueue, got %@.",
                 NSStringFromClass([queue class]));

        NSLog(@"FOSWebService (%li) Async: %@ - %@", (long)currentRequestId, requestMethod, requestURLString);

        __block FOSWebService *blockSelf = self;

        // Capture the request Id
        NSInteger requestId = _nextRequestId;
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

            NSLog(@"   FOSWebService (%li) response...", (long)requestId);

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

        localError = [NSError errorWithDomain:@"FOSFoundation"
                                      message:errorMsg
                                  andUserInfo:nil];
    }
    else {
        if (localError == nil) {
            NSString *errorMsg = @"Received a null NSURLResponse.  See userInfo for more information.";

            if (localError == nil) {
                errorMsg = @"Received a nil NSURLResponse and no NSError.";
            }

            localError = [NSError errorWithDomain:@"FOSFoundation"
                                          message:errorMsg
                                      andUserInfo:nil];
        }
    }

    // Handle the result of the processing
    if (localError == nil) {
        NSLog(@"    FOSWebService Success!!!");

        [webServiceRequest setJsonResult:jsonResult];
    }
    else {
        NSLog(@"    FOSWebService Response ERROR: %@", localError.description);

        [webServiceRequest setError:localError];
    }
}

@end