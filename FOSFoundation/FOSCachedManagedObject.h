//
//  FOSCachedManagedObject.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSManagedObject.h"
#import "FOSCacheManager.h"
#import "FOSRelationshipFault.h"
#import "FOSWebServiceRequest.h"

@class FOSRetrieveCMOOperation;
@class FOSSendServerRecordOperation;
@class FOSRESTConfig;

typedef id<NSObject,NSCopying> FOSJsonId;

@interface FOSCachedManagedObject : FOSManagedObject {
@protected
    BOOL reentrancyBit;
}

#pragma mark - DB properties

// NOTE: If any properties are added, add them to the skip list
//       in NSAttributeDescription's +isCMOProperty: impl.
@property (nonatomic, strong) NSDate *updatedWithServerAt;
@property (nonatomic) BOOL markedClean;
@property (nonatomic) BOOL hasRelationshipFaults;
@property (nonatomic) BOOL hasModifiedProperties;
@property (nonatomic) BOOL isFaultObject;
@property (nonatomic) BOOL isLocalOnly;
@property (nonatomic, retain) NSData * originalJsonData;

#pragma mark - Public Properties

@property (nonatomic, readonly) BOOL isDirty;
@property (nonatomic, readonly) BOOL hasLocalOnlyParent;
@property (nonatomic, readonly) NSSet *faultedRelationships;
@property (nonatomic, readonly) BOOL isSubTreeDirty;
@property (nonatomic, readonly) FOSRESTConfig *restConfig;

/*!
 * @property isUploadable
 *
 * Determins if it is allowable to upload the receiver
 * to the web service.
 *
 * It combines the receiver's isLocalOnly and isReadOnly
 * properties.
 */
@property (nonatomic, readonly) BOOL isUploadable;

/*!
 * @property skipServerDelete
 *
 * Mark the receiver as not to be deleted from the server.
 *
 * @discussion
 *
 * This is generally used when we have recognized that the server had
 * deleted an object and it needs to be removed from the local store.
 *
 * Obviously since the object is no longer on the server, we don't need
 * to attempt to remove it from there.
 *
 * Note that this status *is* stored in the database.
 */
@property (nonatomic, assign) BOOL skipServerDelete;

/*!
 * @property owner
 *
 * Returns the owner of the receiver assuming that the following are true:
 *
 *  1) The receiver has a relationship where relationship.isOwnershipRelationship == YES
 *  2) The ownership relationship is a to-One relation from the receiver to the owner.
 */
@property (nonatomic, readonly) FOSCachedManagedObject *owner;

/*!
 * @property skipServerDeleteTree
 *
 * Checks the entire parent tree of the receiver to determine if
 * the receiver should be skipped.  See skipServerDelete.
 */
@property (nonatomic, readonly) BOOL skipServerDeleteTree;

#pragma mark - Class methods

+ (BOOL)idIsInDatabase:(FOSJsonId)jsonId;

/*!
 * @method fetchWithId:
 *
 * Retrieves an instance of the receiver's class from
 * the database using jsonId as for the key.
 *
 * @param jsonId  The unique identifier of the instance
 *     to retrieve.
 */
+ (instancetype)fetchWithId:(FOSJsonId)jsonId;

+ (NSSet *)fetchWithIds:(id<NSFastEnumeration>)jsonIds;

/*!
 * @method fetchWithId:forJsonRelation:
 *
 * Retrieves instances of the receiver's class from
 * the database using objectId as for the key.
 *
 * @param jsonRelId  The unique identifier of the instance
 *     to retrieve.
 */
+ (NSSet *)fetchWithRelId:(FOSJsonId)jsonRelId forJsonRelation:(NSString *)jsonRelation;

/*!
 * @method fetchAllEntities
 */
+ (NSArray *)fetchAllEntities;

/*!
 * @method fetchWithPredicate:
 */
+ (NSArray *)fetchWithPredicate:(NSPredicate *)pred;

/*!
 * @method fetchWithPredicate:withSortDescriptors:
 */
+ (NSArray *)fetchWithPredicate:(NSPredicate *)pred
            withSortDescriptors:(NSArray *)sortDescriptors;

/*!
 * @method countOfEntities
 *
 * Returns the number of instances of the receiver in the database.
 */
+ (NSUInteger)countOfEntities;

/*!
 * @method countOfEntitiesWithPredicate
 *
 * Returns the number of instances of the receiver in the database that
 * match the given predicate.
 */
+ (NSUInteger)countOfEntitiesWithPredicate:(NSPredicate *)pred;

/*!
 * @method updateNotificationName
 *
 * Returns the name that identifies that changes have been
 * made to the database entities of this type.
 */
+ (NSString *)updateNotificationName;

/*!
 * @methodgroup FOSLifecyclePhase Methods
 */
#pragma mark - FOSLifecyclePhase Methods

/*!
 * @method retrieveCMOForJsonId:
 *
 * @discussion
 *
 * This method corresponds to the FOSLifecyclePhaseRetrieveServerRecord
 * @link FOSLifecyclePhase @/link.
 */
+ (FOSRetrieveCMOOperation *)retrieveCMOForJsonId:(FOSJsonId)jsonId;

/*!
 * @method sendServerRecord
 *
 * Updates the corresponding server record's fields with the
 * the values of the properties returned by
 * @link propertiesModifiedSinceLastUpload @/link.
 *
 * @discussion
 *
 * This method corresponds to both the
 * FOSLifecyclePhaseCreateServerRecord and the
 * FOSLifecyclePhaseUpdateServerRecord @link FOSLifecyclePhase @/link,
 * depending on the receiver's @link hasBeenUploadedToSErver @/link
 * status.
 */
- (FOSSendServerRecordOperation *)sendServerRecord;

/*!
 * @method createAndRetrieveServerRecordWithJSON:
 *
 * Creates an instance of the receiver on the server and then
 * pulls the resulting instance into the database from the server.
 *
 * @discussion
 *
 * This helper method corresponds to the FOSLifecyclePhaseCreateServerRecord
 * AND FOSLifecyclePhaseRetrieveServerRecord @link FOSLifecyclePhase @/link s.
 *
 * This method has more overhead than simply creating a Core Data
 * instance and saving it, but ensures that the server record
 * is created before creating the local CMO instance in Core Data.
 *
 * NOTE: This method will be removed as a better infrastructure
 *       for creating atomic instances needs to be put in place by
 *       utilizing separate NSManagedObjectContexts.
 */
+ (FOSRetrieveCMOOperation *)createAndRetrieveServerRecordWithJSON:(id<NSObject>)json;

/*!
 * @group Public Properties
 */
#pragma mark - Public properties

/*!
 * @property jsonIdValue
 *
 * Returns the receiver's id value to use to identify itself
 * in JSON objects.
 *
 * @discussion
 *
 * The implementation of this property uses the adapter map's ID_ATTRIBUTE
 * mapping.  Thus, this property must not be used to specify the adapter map's
 * ID_ATTRIBUTE.
 */
@property (nonatomic, strong) FOSJsonId jsonIdValue;

/*!
 * @property updateNotificationName
 *
 * Returns a string that can be used to register for update notifications
 * related to the receiver.
 *
 * @discussion
 *
 * This name is based on the jsonIdValue, and thus will be invalidated
 * if jsonIdValue changes.  It is an error to call this method if
 * jsonIdValue == nil.
 */
@property (nonatomic, readonly) NSString *updateNotificationName;

#pragma mark - Public methods

- (void)markClean;

/*!
 * @method originalJson
 *
 * The original json that was received at the last updateWithJSONDictionary:
 * call.
 */
- (NSDictionary *)originalJson;

/*!
 * @method hasBeenUploadedToServer
 *
 * Indicates whether the receiver has ever been uploaded
 * to the server.
 *
 * @discussion
 *
 * The base implementation of this method uses the
 * @link updatedWithServerAt @/link property to determine this
 * status.
 */
- (BOOL)hasBeenUploadedToServer;

/*!
 * @method propertiesModifiedSinceLastUpload
 *
 * Returns the set of properties that have chagned since the last time
 * that @link markClean @/link was called.
 */
- (NSSet *)propertiesModifiedSinceLastUpload;

/*!
 */
- (NSString *)updateNotificationNameForToManyRelationship:(SEL)toManySelector;

#pragma mark - Override Points

+ (id)objectForAttribute:(NSAttributeDescription *)attrDesc forJsonValue:(id)jsonValue;
+ (id)jsonValueForObject:(id)objValue forAttribute:(NSAttributeDescription *)attrDesc;

@end

@interface FOSCachedManagedObject (CoreDataGeneratedAccessors)

- (void)addFaultedRelationshipsObject:(FOSRelationshipFault *)value;
- (void)removeFaultedRelationshipsObject:(FOSRelationshipFault *)value;
- (void)addFaultedRelationships:(NSSet *)values;
- (void)removeFaultedRelationships:(NSSet *)values;

@end
