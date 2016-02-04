//
//  FOSRestServiceAdapter.h
//  FOSRest
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

@import Foundation;
@import CoreData;
#import "FOSLifecyclePhase.h"

@protocol FOSAnalytics;
@protocol FOSTwoWayRecordBinding;

@class FOSNetworkStatusMonitor;
@class FOSURLBinding;
@class FOSWebServiceRequest;

/*
 * @protocol FOSRESTServiceAdapter
 *
 * The FOSRESTServiceAdapter protocol provides a mechanism to adapt certain
 * behaviors of the FOS Foundation REST service to a specific REST
 * implementation.
 */
@protocol FOSRESTServiceAdapter <NSObject>

@required

@property (nonatomic, readonly) NSTimeInterval defaultTimeout;
@property (nonatomic, readonly) FOSNetworkStatusMonitor *networkStatusMonitor;

/*!
 * @method defaultBaseURL:
 *
 * Returns the defaultBaseURL for the web service.
 */
- (NSURL *)defaultBaseURL;

/*!
 * @method setupCoreDatabaseForcingRemoval:error:
 *
 * Open a connection to the CoreData database.
 *
 * @param forceDBRemoval Indicates that the exsiting database file should be deleted and a new
 *                       one created.
 *
 * @param error Returns the error status for the operation. A nil value may be provided.
 */
- (NSPersistentStoreCoordinator *)setupDatabaseForcingRemoval:(BOOL)forceDBRemoval error:(NSError **)error;

/*!
 * @method urlBindingForLifecyclePhase:forRelationship:forEntity:
 *
 * Returns the matching relationship for the given parameters.
 *
 * @relDesc Must be specified if lifeCyclePhase == FOSLifecyclePhaseRetrieveServerRecordRelationship,
 *          otherwise its value is ignored.
 */
- (FOSURLBinding *)urlBindingForLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
                             forLifecycleStyle:(NSString *)lifecycleStyle
                               forRelationship:(NSRelationshipDescription *)relDesc
                                     forEntity:(NSEntityDescription *)entity;

- (BOOL)processWebServiceResponse:(NSHTTPURLResponse *)httpResponse
                     responseData:(NSData *)responseData
                    forURLBinding:(FOSURLBinding *)urlBinding
                       jsonResult:(id<NSObject> *)jsonResult
                            error:(NSError **)error;

@optional

@property (nonatomic, readonly)id<FOSAnalytics> analyticsManager;

/*!
 * @method headerFields
 *
 * Returns a dictionary of key/value paris to add to requests made to the server.
 * For example:
 *
 * @{
 *     @"X-Parse-Application-Id" : @"<your parse app id>",
 *     @"X-Parse-REST-API-Key" : @"<your parse API key>",
 *  };
 */
- (NSDictionary *)headerFields;

/*!
 * @method maxBatchCount
 *
 * Returns the maximum number of requests that can be batched together.
 *
 * @discussion
 *
 * If the receiver implements this property AND returns a value > 0, then
 * the receiver *must* implement requestCanBeBatched:, generateBatchRequestForRequests:
 * and processResultsOfBatchRequest:forRequests:.
 */
@property (nonatomic, readonly)NSUInteger maxBatchCount;

/*!
 * @method requestCanBeBatched:
 *
 * Some service providers provide the ability to batch (combine) multiple
 * requests into a single request to save on chatter.
 *
 * Simply return YES if the provided request can be batched with other requests.
 */
- (BOOL)requestCanBeBatched:(FOSWebServiceRequest *)webServiceRequest;

/*!
 * @method generateBatchRequestForRequests:
 *
 * Combines the provided requests into a single request that can be sent
 * to the REST service for processing.
 */
- (FOSWebServiceRequest *)generateBatchRequestForRequests:(NSArray *)requests;

/*!
 * @method processResultsOfBatchRequest:forRequests:
 *
 * Once the response has been received from the server, this method is called
 * to update the requests with the result from the batchRequest.
 */
- (void)processResultsOfBatchRequest:(FOSWebServiceRequest *)batchRequest
                         forRequests:(NSArray *)requests;

/*!
 * @method encodeCMOValuetoJSON:ofType:forServiceAdapter:error:
 *
 * Provides a mechanism for the encoding of non-standard object types into
 * standard JSON types.
 *
 * For example NSColor could be encoded into an NSData or NSString instance.
 *
 * @discussion
 *
 * If this method is implemented, @link decodeJSONValueToCMOValue @/link should also
 * be implemented.
 */
- (id<NSObject>)encodeCMOValueToJSON:(id)cmoValue
                              ofType:(NSAttributeDescription *)attrDesc
                               error:(NSError **)error;

/*!
 * @method decodeJSONValueToCMOValue:ofType:forServiceAdapter:error:
 *
 * Provides a mechanism for the decodeing of standard JSON types into
 * non-standard object types.
 *
 * For example an NSData or NSString could be decoded into an NSColor instance.
 *
 * @discussion
 *
 * If this method is implemented, @link encodeCMOValueToJSON @/link should also
 * be implemented.
 */
- (id)decodeJSONValueToCMOValue:(id<NSObject>)jsonValue
                         ofType:(NSAttributeDescription *)attrDesc
                          error:(NSError **)error;


/*!
 * @method valueForExpressionVariable:error:
 *
 * Provides for the binding of adapter specific variables.
 * See @link FOSBindingExpression @/link.
 *
 * @discussion
 *
 * This method is declared as @optional, however if there are
 * any adapter specific variables, this method must be implemented.
 */
- (id)valueForExpressionVariable:(NSString *)varName matched:(BOOL *)matched error:(NSError **)error;

/*
 * @method subtypeFromBase:givenJSON:
 *
 * Provide a mechanism for determing which subtype of a base entity type should be used
 * given the provided JSON.
 *
 * @discussion
 *
 * Often in SQL-based backends single-table inheritance will be used. In this case,
 * a standard design pattern is to have a column in the data describe the subtype
 * of a basedtype to instantiate for that row.
 *
 * A service adapter can implement this method to provide a mapping from the given JSON
 * data to the appropriate subtype to be instantiated.
 */
- (NSEntityDescription *)subtypeFromBase:(NSEntityDescription *)baseType givenJSON:(id)json;

/*!
 * @method swizzleURL:endPoint:andFragments:
 *
 * If this callback is provided, it will be called with each
 * URI before the uri is used in a server request.
 *
 * This provides the client application to modify the URI
 * before it is used.  Thus, if the standard patterns that
 * the toolkit uses are not sufficient, an easily matched
 * token can be placed in the pattern and it can be matched
 * and replaced via this method.
 *
 * It is critical to note that the thread on which this
 * invocation is made is not defined.
 *
 * @discussion
 *
 * For example, parse.com's user model contains a user id
 * which is separate from the email.  When we create an
 * account for parse.com, we might want to specify that
 * both the user id and the email are the same upon
 * account creation.  However, the template for
 * account creation only takes two substitution points:
 *
 *   * Allowed: 1/users?newUser={"username" : "%@", "password" : "%@"}
 *   * Desired: 1/users?newUser={"username" : "%@", "password" : "%@", "email" : "%@"}
 *
 * To achieve the desired effect, specify the createAccountEndPoint as
 * a pattern that can easily matched and then substitute your
 * desired url.  For example, in you data model, on the userSubType (e.g. MyUser : FOSUser)
 * you specified the following mapping:
 *
 *    jsonPOSTEndPoint = ___CREATE_USER___/"%@"/"%@"
 *
 * Then your code can search for @"___CREATE_USER___" in the URL and,
 * if found can create a new url substituting the provided information.
 *
 * cacheConfig.urlSwizzler = ^(NSString **baseUrl, NSString **endPoint, NSArray **fragments) {
 *     NSRange range = [*endPoint rangeOfString:@"___CREATE_USER___"];
 *
 *     if (range.location != NSNotFound) {
 *
 *         NSString *remainingStr = [urlStr substringFromIndex:range.location];
 *
 *         // Pull out the email & password
 *         NSArray *pieces = [remainingStr componentsSeparatedByString:@"/"];
 *
 *         NSAssert(pieces.count == 3, @"Something's wrong!");
 *         NSAssert([pieces[0] isEqualToString:@"___CREATE_USER___"], @"Something's wrong!");
 *
 *         NSString *email = pieces[1];
 *         NSString *password = pieces[2];
 *         NSString *pattern = @"user?newUser={\"username\":%@,\"password\":%@,\"email\":%@}";
 *
 *         NSString *newUrlStr = [NSString stringWithFormat:pattern, email, password, email];
 *
 *         *endPoint = newUrlStr;
 *     }
 *
 *     return result;
 * };
 *
 * Once the string is matched, it can be split to find the substituted
 * pieces and then an updated URL can be manufactured.
 *
 * Note that the provided string must be able to be encoded into a URL.
 */
- (void)swizzleURL:(NSString **)baseURL
          endPoint:(NSString **)endPoint
      andFragments:(NSArray **)fragments;

/*!
 * @property request:receivedResponse:andError
 *
 * After each web service invocation, this callback will be called with the details
 * of the response received.
 *
 * It is critical to note that the thread on which this
 * invocation is made is not defined.
 *
 * @discussion
 *
 * An example usage of this functionality would be to store off information
 * received when a login completed.  Possibly a token was passed in the
 * information that might be needed at a later point, for example.
 */
- (void)request:(NSURLRequest *)request receivedResponse:(NSHTTPURLResponse *)response
       andError:(NSError *)error;

@end
