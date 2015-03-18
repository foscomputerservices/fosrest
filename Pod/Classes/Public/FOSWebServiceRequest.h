//
//  FOSWebServiceRequest.h
//  FOSREST
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

#import <FOSRest/FOSOperation.h>

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
    FOSWSRequestStateReady = 1,
    FOSWSRequestStateExecuting = 2,
    FOSWSRequestStateFinished = 3
};

@interface FOSWebServiceRequest : FOSOperation {
    @protected
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
