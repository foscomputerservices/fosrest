//
//  FOSURLBinding.h
//  FOSRest
//
//  Created by David Hunt on 3/17/14.
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
#import "FOSCompiledAtom.h"
#import "FOSBindingOptions.h"
#import "FOSJsonId.h"
#import "FOSLifecycleDirection.h"
#import "FOSLifecyclePhase.h"
#import "FOSRequestFormat.h"
#import "FOSRequestMethod.h"
#import "FOSHandlers.h"

@class FOSCachedManagedObject;
@class FOSConcatExpression;
@class FOSCMOBinding;
@class FOSSharedBindingReference;
@class FOSItemMatcher;
@protocol FOSExpression;

/*!
 * @class FOSURLBinding
 *
 * Describes how to generate a NSURLRequest for a given lifecycle phase of
 * a given NSEntityDescription.
 */
@interface FOSURLBinding : FOSCompiledAtom

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method bindingForLifeCyclePhase:endPoint:cmoBinder:andEntityMatcher:
 */
+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                               cmoBinder:(FOSCMOBinding *)cmoBinder
                        andEntityMatcher:(FOSItemMatcher *)entityMatcher;

/*!
 * @method bindingForLifeCyclePhase:endPoint:cmoBinder:andEntityMatcher:
 */
+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                     cmoBindingReference:(FOSSharedBindingReference *)bindingReference
                        andEntityMatcher:(FOSItemMatcher *)entityMatcher;

+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                           requestFormat:(FOSRequestFormat)requestFormat
                        andEntityMatcher:(FOSItemMatcher *)entityMatcher;

+ (instancetype)bindingForLifeCyclePhase:(FOSLifecyclePhase)lifecyclePhase
                                endPoint:(id<FOSExpression>)endPoint
                           requestFormat:(FOSRequestFormat)requestFormat
                      andJSONExpressions:(NSArray *)jsonExpressions;

/*!
 * @group Properties
 */
#pragma mark - Properties

/*!
 * @property lifecyclePhase
 *
 * Describes to which lifecycle the reliever applies.
 *
 * Setting this property is required.
 */
@property (nonatomic, assign) FOSLifecyclePhase lifecyclePhase;

/*!
 * @property lifecycleStyle
 *
 * Allows for multiple @link FOSURLBinding @/link
 * specifications for a single @link FOSLifeCyclePhase @/link.
 *
 * For example, there might be multiple mechanisms for authenticating
 * (FOSLifecyclePhaseLogin) wil the REST service.  Each authentication
 * mechanism would need a different @link FOSURLBinding @/link specification.
 *
 * @discussion Setting this property is optional.  The default matcher is
 * [FOSItemMatcher matcherMatchingAllItems];
 */
@property (nonatomic, strong) FOSItemMatcher *lifecycleStyle;

/*!
 * @property bindingOptions
 *
 * Describes any binding options that match for the lifecycle.
 *
 * Setting this property is optional.
 */
@property (nonatomic, assign) FOSBindingOptions bindingOptions;

/*!
 * @property requestMethod
 *
 * The @link FOSRequestMethod @/link that corresponds to the receiver.
 *
 * Setting this property is optional.
 *
 * @discussion If this property is no specified, FOSRequestMethodGET will be used.
 */
@property (nonatomic, assign) FOSRequestMethod requestMethod;

/*!
 * @property requestFormat
 *
 * The format into which the data should be delivered to the REST server.
 *
 * Setting this property is optional.  The default failure is @link FOSRequestFormatJSON @/link.
 */
@property (nonatomic, assign) FOSRequestFormat requestFormat;

/*!
 * @property timeoutInterval
 *
 * The timeout value, in seconds, for the request.
 *
 * Setting this property is optional.
 *
 * @discussion Setting this property overrides the setting provided by @link FOSRESTServicesAdapter/defaultTimeout @/link.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/*!
 * @property headerFields
 *
 * A set of header key/value pairs that can extend/override what is provided by
 * @link FOSRESTServiceAdapter/requestHeaders @/link.
 *
 * Setting this property is optional.
 *
 * @discussion If this property is not set, @link FOSRESTServicesAdapter/headerFields @/link will be used.
 * If this property is set, the dictionary from @link FOSRESTServicesAdapter/headerFields @/link
 * will be added to by the settings provided by this property.  The values provided by
 * this property will override any provided by the adapter.
 */
@property (nonatomic, strong) NSDictionary *headerFields;

/*!
 * @property baseURL
 *
 * The base portion of the URL to communicate with the REST service;
 * for example 'https://api.parse.com'.
 *
 * Setting this property is optional.
 *
 * @discussion Setting this property overrides the setting provided by the @link FOSRESTServiceAdapter @/link.
 */
@property (nonatomic, strong) NSURL *baseURL;

/*!
 * @property baseURLExpr
 *
 * An expression that yields a string that can be converted into an NSURL.
 *
 * Setting this property is optional.
 *
 * @discussion If this property is set, it overrides any value set by baseURL.  However, if the evaluation
 * of baseURLExpr yields an error, baseURL will be returned.
 */
@property (nonatomic, strong) id<FOSExpression> baseURLExpr;

/*!
 * @property endPointURLExpression
 *
 * An expression that yields a URL fragment that is applied to baseURL.  This URL is the URL
 * that is used to communicate with the REST Service.
 *
 * For example, '1/classes/MyClass' or '1/classes/$ENTITY.name'.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) id<FOSExpression> endPointURLExpression;

/*!
 * @property endPointParameters
 *
 * Additional parameters to add to the end point.
 *
 * Setting this property is optional.
 *
 * @discussion For example, given the end point '1/MyClass' you might have additional parameters
 * such as 'limit=1000' and 'skip=20' for a resulting end point of '1/MyClass?limit=1000&skip=20'.
 */
@property (nonatomic, strong) NSArray *endPointParameters;

/*!
 * @property jsonWrapperKey
 *
 * The key that server expects objects to be wrapped under.  If the object is
 * not under any key, this value should be nil.
 *
 * @discussion This key is also used to look into parent-supplied results to see if parent
 * server queries might have provided the child's information.
 *
 * Setting this property is optional.
 */
@property (nonatomic, strong) id<FOSExpression> jsonWrapperKey;

/*!
 * @property bulkWrapperKey
 *
 * The key under which to look in the top-level expression's originalJson to
 * find JSON packets for data that matches the URLBinding.
 *
 * @discussion As an optimization, the server can package up data components related to
 * data in a top-level query.  For example, consider pulling a user record
 * from the server.  Almost certainly that record will have relationships to
 * other data that will need to be pulled.  Such additional relationships will
 * require subsequent GET calls from the server to obtain the JSON for those
 * related entities (i.e. the user's clients).
 *
 * However, this mechanism allows the server to send those related JSON packages
 * along with the top-level user request under keys that siblings to the user
 * data.  These sibling keys should be specified in the bulkWrapperKey on the
 * URLBinding for the related entity (e.g. client's URL Binding).
 *
 * An example JSON result as described here might look as follows:
 *
 * {
 *   "user" : { "name" : "Fred", ... },
 *   "clients" : [ { "clientName" : "Barney", ... } , { "clientName" : "Client2", ...} ... ]
 * }
 *
 * In this case, "clients" should be specified as the bulkWrapperKey.
 *
 * Setting this property is optional.
 */
@property (nonatomic, strong) id<FOSExpression> bulkWrapperKey;

/*!
 * @property cmoBinding
 *
 * A binding that provides for two-way binding between the web services's JSON packets and
 * the adapter's CMO instances.
 *
 * Setting this property or sharedBindingReference is required unless
 *   requestFormat == FOSRequestFormatNoData.
 */
@property (nonatomic, strong) FOSCMOBinding *cmoBinding;

/*!
 * @property jsonBindingExpressions
 *
 * A binding that provides for one-way binding between a context and a web service's
 * JSON packet.
 *
 * TODO : This expression just doesn't feel right.  It should be a single id<FOSExpression>,
 *        but at this time we don't have a good construct in the adapter grammar.
 */
@property (nonatomic, strong) NSArray *jsonBindingExpressions;

/*!
 * @property sharedBindingReference
 *
 * A late-bound reference that will be used to resolve the receiver's cmoBinding or
 * jsonBindingExpression.
 *
 * Setting this property or cmoBinder is required unless
 *   requestFormat == FOSRequestFormatNoData.
 */
@property (nonatomic, strong) FOSSharedBindingReference *sharedBindingReference;

/*!
 * @property relationshipMatcher
 *
 * A matcher that matches the relationship names that can be two-way bound by the receiver.
 *
 * Setting this property is required for
 * lifecyclePhase == FOSLifecyclePhaseRetrieveServerRecordRelationship.
 */
@property (nonatomic, strong) FOSItemMatcher *relationshipMatcher;

/*!
 * @property entityMatcher
 *
 * A matcher that matches the entity names that can be two-way bound by the receiver.
 *
 * Setting this property is required.
 */
@property (nonatomic, strong) FOSItemMatcher *entityMatcher;

/*!
 * @group Methods
 */
#pragma mark - Methods

/*!
 * @method urlRequestForCMO:error:
 *
 * Creates a NSMutableURLRequest that is fully bound with the receiver's information.
 */
- (NSURLRequest *)urlRequestForCMO:(FOSCachedManagedObject *)cmo error:(NSError **)error;

/*!
 * @method urlRequestServerRecordOfType:withJsonId:withDSLQuery:error:
 *
 * Creates an NSURLRequest that will retrieve the given server record.
 *
 * @discussion dslQuery Is a 'Domain Specific Query', which is simply a string
 * that is added as a parameter to the request url.  The query is specific to the
 * REST Service.
 */
- (NSURLRequest *)urlRequestServerRecordOfType:(NSEntityDescription *)entity
                                    withJsonId:(FOSJsonId)jsonId
                                  withDSLQuery:(NSString *)dslQuery
                                         error:(NSError **)error;

/*!
 * @method urlRequestServerRecordsOfType:withDSLQuery:error:
 *
 * Creates an NSURLRequest that will retrieve a set of server records that match the
 * given dslQuery.
 *
 * @discussion dslQuery Is a 'Domain Specific Query', which is simply a string
 * that is added as a parameter to the request url.  The query is specific to the
 * REST Service.
 */
- (NSURLRequest *)urlRequestServerRecordOfType:(NSEntityDescription *)entity
                                  withDSLQuery:(NSString *)dslQuery
                                         error:(NSError **)error;

/*!
 * @method - urlRequestServerRecordsOfRelationship:forDestinationEntity:withOwnerId:error:
 *
 * Creates an NSURLRequest that will retrieve a set of server records that match the
 * relationship owned by the given @link ownerId @/link.
 */
- (NSURLRequest *)urlRequestServerRecordsOfRelationship:(NSRelationshipDescription *)relDesc
                                   forDestinationEntity:(NSEntityDescription *)destEntity
                                            withOwnerId:(FOSJsonId)ownerId
                                           withDSLQuery:(NSString *)dslQuery
                                                  error:(NSError **)error;

/*!
 * @method urlRequestForContext:error:
 *
 * Creates an NSURLRequest that will execute a server command.
 */
- (NSURLRequest *)urlRequestForServerCommandWithContext:(NSDictionary *)context
                                                  error:(NSError **)error;

/*!
 * @method wrapJSON:context:error:
 *
 * If the receiver's jsonWrapperKey is specified, it will be evaluated against the
 * provided context and the resulting string will be used to wrap json in an
 * NSDictionary under the specified key.
 *
 * If the receiver's jsonWrapperKey is nil, then json is returned unaltered.
 */
- (id<NSObject>)wrapJSON:(id<NSObject>)json context:(NSDictionary *)context error:(NSError **)error;

/*!
 * @method unwrapJSON:context:error:
 *
 * If the receiver's jsonWrapperKey is specified, it will be evaluated against the
 * provided context and the resulting string will be used against (NSDictionary *)json
 * to return the inner wrapped json.
 *
 * If the receiver's jsonWrapperKey is nil, then json is returned unaltered.
 */
- (id<NSObject>)unwrapJSON:(id<NSObject>)json context:(NSDictionary *)context error:(NSError **)error;

/*!
 * @method unwrapBulkJSON:context:error:
 *
 * If the receiver's bulkWrapperKey is specified, it will be evaluated against the
 * provided context and the resulting string will be used against (NSDictionary *)json
 * to return the inner wrapped json.
 *
 * If the receiver's jsonWrapperKey is nil, then json is returned unaltered.
 */
- (id<NSObject>)unwrapBulkJSON:(id<NSObject>)json context:(NSDictionary *)context error:(NSError **)error;

/*!
 * @methodgroup Debug Information
 */

/*!
 * @method stringForLifecycle:
 */
+ (NSString *)stringForLifecycle:(FOSLifecyclePhase)lifecyclePhase;

@end
