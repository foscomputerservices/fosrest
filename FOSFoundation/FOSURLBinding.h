//
//  FOSURLBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FOSCompiledAtom.h"
#import "FOSCachedManagedObject.h"
#import "FOSWebServiceRequest.h"

@class FOSConcatExpression;
@class FOSCMOBinding;
@class FOSSharedBindingReference;
@class FOSItemMatcher;
@protocol FOSExpression;

typedef NS_OPTIONS(NSUInteger, FOSLifecycleDirection) {
    FOSLifecycleDirectionUpdate   = 0x00008000,
    FOSLifecycleDirectionRetrieve = 0x80000000,
};

/*!
 * @enum FOSLifecyclePhase
 *
 * @constant FOSLifecyclePhaseLogin Logs a user in to the REST Service (Adapter binding: LOGIN).
 *
 * @constant FOSLifecyclePhaseLogout Logs a user out of the REST Service (Adapter binding: LOGOUT).
 *
 * @constant FOSLifecyclePhasePasswordReset Resets the password for a user
 *           (Adapter binding: PASSWORD_RESET).
 *
 * @constant FOSLifecyclePhaseCreateServerRecord Create a record on the REST Service
 *           (Adapter binding: CREATE).
 *
 * @constant FOSLifecyclePhaseUpdateServerRecord Update a record on the REST Service
 *           (Adapter binding: UPDATE).
 *
 * @constant FOSLifecyclePhaseDestroyServerRecord Destroy a record on the REST Service
 *           (Adapter binding: DESTROY).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecord Retrieves information from the
 *           REST Service and creates or updates a CMO  (Adapter binding: RETRIEVE_SERVER_RECORD).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecords Retrieves information from the
 *           REST Service and creates or updates one or more CMOs
 *           (Adapter binding: RETRIEVE_SERVER_RECORDS).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecordCount Retrieves the count of
 *           records from the REST Service  (Adapter binding: RETRIEVE_SERVER_RECORD_COUNT).
 *
 * @constant FOSLifecyclePhaseRetrieveServerRecordRelationship Retrieves information from
 *           the REST service and creates or updates a relationship of a CMO
 *           (Adapter binding: RETRIEVE_RELATIONSHIP).
 */
typedef NS_ENUM(NSUInteger, FOSLifecyclePhase) {
    FOSLifecyclePhaseLogin                            = 0x01 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseLogout                           = 0x02,
    FOSLifecyclePhasePasswordReset                    = 0x03,
    FOSLifecyclePhaseCreateServerRecord               = 0x04 | FOSLifecycleDirectionUpdate,
    FOSLifecyclePhaseUpdateServerRecord               = 0x05 | FOSLifecycleDirectionUpdate,
    FOSLifecyclePhaseDestroyServerRecord              = 0x06 | FOSLifecycleDirectionUpdate,
    FOSLifecyclePhaseRetrieveServerRecord             = 0x07 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseRetrieveServerRecords            = 0x08 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseRetrieveServerRecordCount        = 0x09 | FOSLifecycleDirectionRetrieve,
    FOSLifecyclePhaseRetrieveServerRecordRelationship = 0x0A | FOSLifecycleDirectionRetrieve
};

/*!
 * @enum FOSBindingOptions
 *
 * @constant FOSBindingOptionOneToOneRelationship
 * 
 *   Allowed only for FOSLifecyclePhaseRetrieveServerRecordRelationship and indicates that the
 *   relationship is a one-to-one relationship.
 *
 * @constant FOSBindingOptionOneToManyRelationship
 *
 *   Allowed only for FOSLifecyclePhaseRetrieveServerRecordRelationship and indicates that the
 *   relationship is a one-to-many relationship.
 *
 * @constant FOSBindingOptionOrderedRelationship
 *
 *   Allowed only for FOSLifecyclePhaseRetrieveServerRecordRelationship and indicates that the
 *   relationship is an ordered relationship.
 */
typedef NS_OPTIONS(NSUInteger, FOSBindingOptions) {
    FOSBindingOptionsNone = 0,
    FOSBindingOptionsOneToOneRelationship = (1 << 0),
    FOSBindingOptionsOneToManyRelationship = (1 << 1),
// TODO :  FOSBindingOptionsManyToManyRelationship = (1 << 2),
    FOSBindingOptionsUnorderedRelationship = (1 << 3),
    FOSBindingOptionsOrderedRelationship = (1 << 4)
};

/*!
 * @enum FOSRESTRequestFormat
 *
 * @constant FOSRequestFormatJSON  (Adapter binding: 'JSON') The data will be transmitted as JSON
 *           in the body of the message with a body type of 'application/json'.  This is the
 *           default for FOSRequestMethodPOST, FOSRequestMethodGET and FOSRequestMethodDELETE.
 *
 * @constant FOSRequestFormatWebform (Adapter binding: 'WEBFORM') The data will be transmited
 *           as parameters. For FOSRequestMethodGET they are embedded in the URL; for all
 *           other request types, they are embedded in the body with a content type
 *           of 'application/x-www-form-urlencoded'.
 *
 * @constant FOSRequestFormatNoData (Adapter binding: 'NO_DATA') No object data will be
 *           transmitted in the request.
 */
typedef NS_ENUM(NSUInteger, FOSRequestFormat) {
    FOSRequestFormatJSON = 0,
    FOSRequestFormatWebform = 1,
    FOSRequestFormatNoData = 2
};

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
 * Describes to which lifecycle the reciever applies.
 *
 * Setting this property is required.
 */
@property (nonatomic, assign) FOSLifecyclePhase lifecyclePhase;

/*!
 * @property lifecycleStyle
 *
 * Allows for multiple @link FOSURLBinding @/link
 * specificiations for a single @link FOSLifeCyclePhase @/link.
 *
 * For example, there might be multiple mechanisms for authenticating
 * (FOSLifecyclePhaseLogin) wil the REST service.  Each authentication
 * mechanism would need a different @link FOSURLBinding @/link specification.
 *
 * @discussion
 *
 * Setting this property is optional.  The default matcher is
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
 * @discussion
 *
 * If this property is no specified, FOSRequestMethodGET will be used.
 */
@property (nonatomic, assign) FOSRequestMethod requestMethod;

/*!
 * @property requestFormat
 *
 * The format into which the data should be delivered to the REST server.
 *
 * Setting this property is optional.  The default falue is @link FOSRequestFormatJSON @/link.
 */
@property (nonatomic, assign) FOSRequestFormat requestFormat;

/*!
 * @property timeoutInterval
 *
 * The timeout value, in seconds, for the request.
 *
 * Setting this property is optional.
 *
 * @discussion
 *
 * Setting this property overrides the setting provided by @link FOSRESTServicesAdapter/defaultTimeout @/link.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/*!
 * @property headerFields
 *
 * A set of header key/value pairs that can extend/override what is provided by
 * @link FOSRESTServiceAdaper/requestHeaders @/link.
 *
 * Setting this property is optional.
 *
 * @discussion
 *
 * If this property is not set, @link FOSRESTServicesAdapter/headerFields @/link will be used.
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
 * @discussion
 *
 * Setting this property overrides the setting provided by the @link FOSRESTServiceAdapter @/link.
 */
@property (nonatomic, strong) NSURL *baseURL;

/*!
 * @property baseURLExpr
 *
 * An expression that yields a string that can be converted into an NSURL.
 *
 * Setting this property is optional.
 *
 * @discuassion
 *
 * If this property is set, it overrides any value set by baseURL.  However, if the evaluation
 * of baseURLExpr yields an error, baseURL will be returned.
 */
@property (nonatomic, strong) id<FOSExpression> baseURLExpr;

/*!
 * @property endPointURLExpression
 *
 * An expression that yields a URL fragment that is applied to baseURL.  This URL is the URL
 * that is used to communicate with the REST Service.
 *
 * For eaxample, '1/classes/MyClass' or '1/classes/$ENTITY.name'.
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
 * @discussion
 *
 * For example, given the end point '1/MyClass' you might have additional parameters
 * such as 'limit=1000' and 'skip=20' for a resulting end point of '1/MyClass?limit=1000&skip=20'.
 */
@property (nonatomic, strong) NSArray *endPointParameters;

/*!
 * @property jsonWrapperKey
 *
 * The key that server expects objects to be wrapped under.  If the object is
 * not under any key, this value should be nil.
 *
 * @discussion
 *
 * This key is also used to look into parent-supplied results to see if parent
 * server queries might have provided the child's information.
 *
 * Setting this property is optional.
 */
@property (nonatomic, strong) id<FOSExpression> jsonWrapperKey;

/*!
 * @property cmoBinding
 *
 * A binding that provides for two-way binding between the web services's JSON packets and
 * the adapter's CMO instances.
 *
 * Setting this property or sharedBindingReference is required unless
 *   requestFormat == FOSRequestFormatNoData &&
 *   lifecyclePhase != FOSLifecyclePhaseCreateServerRecord &&
 *   lifecyclePhase != FOSLifecyclePhaseUpdateServerRecord.
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
 *   requestFormat == FOSRequestFormatNoData &&
 *   lifecyclePhase != FOSLifecyclePhaseCreateServerRecord &&
 *   lifecyclePhase != FOSLifecyclePhaseUpdateServerRecord.
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
 * @method urlRequestServerRecordOfType:withJsonId:error:
 *
 * Creates an NSURLRequest that will retrieve the given server record.
 */
- (NSURLRequest *)urlRequestServerRecordOfType:(NSEntityDescription *)entity
                                    withJsonId:(FOSJsonId)jsonId
                                         error:(NSError **)error;

/*!
 * @method urlRequestServerRecordsOfType:withDSLQuery:error:
 *
 * Creates an NSURLRequest that will retrieve a set of server records that match the
 * given dslQuery.
 *
 * @discussion
 *
 * @link dslQuery @/link Is a 'Domain Specific Query', which is simply a string
 * that is added as a parameter to the requet url.  The query is specific to the
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
 * If the recevier's jsonWrapperKey is nil, then json is returned unaltered.
 */
- (id<NSObject>)wrapJSON:(id<NSObject>)json context:(NSDictionary *)context error:(NSError **)error;

/*!
 * @method unwrapJSON:context:error:
 *
 * If the receiver's jsonWrapperKey is specified, it will be evaluated against the
 * provided context and the resulting string will be used against (NSDictionary *)json
 * to return the inner wrapped json.
 *
 * If the recevier's jsonWrapperKey is nil, then json is returned unaltered.
 */
- (id<NSObject>)unwrapJSON:(id<NSObject>)json context:(NSDictionary *)context error:(NSError **)error;

/*!
 * @methodgroup Debug Information
 */

/*!
 * @method stringforLifecycle:
 */
+ (NSString *)stringForLifecycle:(FOSLifecyclePhase)lifecyclePhase;

@end
