//
//  FOSWebServiceRequest.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSOperation.h"

@class FOSCachedManagedObject;
@class FOSWebService;
@class FOSURLBinding;
@protocol FOSProcessServiceRequest;

typedef NS_ENUM(NSUInteger, FOSRequestMethod) {
    FOSRequestMethodPOST = 1,
    FOSRequestMethodPUT = 2,
    FOSRequestMethodGET = 3,
    FOSRequestMethodDELETE = 4
};

typedef NSManagedObjectID *(^FOSWebServiceWillProcessHandler)();

typedef NS_ENUM(NSUInteger, FOSWSRequestState) {
    FOSWSRequestStateNotStarted = 0,
    FOSWSRequestStateExecuting = 1,
    FOSWSRequestStateFinished = 2,
    FOSWSRequestStateCancelled = 3
};

@interface FOSWebServiceRequest : FOSOperation {
    @protected
        NSError *_error;
        id<NSObject> _jsonResult;
        id<NSObject> _originalJsonResult;
        FOSWSRequestState _requestState;
}

#pragma mark - Properties

@property (nonatomic, readonly) FOSRequestMethod requestMethod;
@property (nonatomic, readonly) NSString *httpMethod;

/*!
 * @property baseURL
 *
 * Allows the default baseURL used by FOSWebService to be overridden.
 */
@property (nonatomic, readonly) NSString *baseURL;
@property (nonatomic, readonly) NSString *endPoint;
@property (nonatomic, readonly) NSArray *uriFragments;
@property (nonatomic, strong) FOSWebServiceWillProcessHandler willProcessHandler;
@property (nonatomic, readonly) NSURL *url;

/*!
 * @property jsonResult
 *
 * The result of executing the request against the server.
 *
 * @discussion
 *
 * This result is 'unwrapped' automatically by the urlBinding if a urlBinding
 * was specified.
 */
@property (nonatomic, readonly) id<NSObject> jsonResult;

/*!
 * @property originalJsonResult
 *
 * The result of executing the request against the server.
 *
 * @discussion
 *
 * This result is the original 'wrapped' version received from the server.
 */
@property (nonatomic, readonly) id<NSObject> originalJsonResult;

@property (nonatomic, readonly) NSURLRequest *urlRequest;
@property (nonatomic, readonly) FOSURLBinding *urlBinding;

// This is managed internally by FOSCacheManager.
@property (nonatomic, strong) id<FOSProcessServiceRequest> serviceRequestProcessor;

#pragma mark - Class methods

+ (BOOL)isValidLoggedOutEndpoint:(NSString *)endPoint;

+ (instancetype)requestWithRequestType:(FOSRequestMethod)requestType endPoint:(NSString *)endPoint;

+ (instancetype)requestWithRequestType:(FOSRequestMethod)requestType
                              endPoint:(NSString *)endPoint
                          uriFragments:(NSArray *)uriFragments;

+ (instancetype)requestWithRequestType:(FOSRequestMethod)requestType
                  baseURL:(NSString *)baseURL
                 endPoint:(NSString *)endPoint
             uriFragments:(NSArray *)uriFragments;

+ (instancetype)requestWithURLRequest:(NSURLRequest *)urlRequest
                        forURLBinding:(FOSURLBinding *)urlBinding;

+ (NSString *)httpMethodStringForRequestMethod:(FOSRequestMethod)requestMethod;

#pragma mark - Initialization Methods

- (id)initWithRequestType:(FOSRequestMethod)requestType
                  baseURL:(NSString *)baseURL
                 endPoint:(NSString *)endPoint
             uriFragments:(NSArray *)uriFragments;

- (id)initWithURLRequest:(NSURLRequest *)urlRequest andURLBinding:(FOSURLBinding *)urlBinding;

@end
