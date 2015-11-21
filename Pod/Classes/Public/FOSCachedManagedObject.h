//
//  FOSCachedManagedObject.h
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

#import "FOSManagedObject.h"
#import "FOSHandlers.h"
#import "FOSJsonId.h"

@class FOSRetrieveCMOOperation;
@class FOSSendServerRecordOperation;
@class FOSRESTConfig;
@class FOSSearchOperation;
@class FOSOperation;

@interface FOSCachedManagedObject : FOSManagedObject {
@protected
    BOOL reentrancyBit;
}

#pragma mark - DB properties

// NOTE: If any properties are added, add them to the skip list
//       in NSAttributeDescription's +isFOSAttribute: impl.
@property (nonatomic, strong) NSDate * _Nullable updatedWithServerAt;
@property (nonatomic) BOOL markedClean;
@property (nonatomic) BOOL hasRelationshipFaults;
@property (nonatomic) BOOL hasModifiedProperties;
@property (nonatomic) BOOL isFaultObject;
@property (nonatomic) BOOL isLocalOnly;
@property (nonatomic) BOOL isSendOnly;
@property (nonatomic, strong) NSData * _Nullable originalJsonData;

#pragma mark - Public Properties

@property (nonatomic, readonly) BOOL isDirty;
@property (nonatomic, readonly) BOOL hasLocalOnlyParent;
@property (nonatomic, readonly) NSSet * _Nullable faultedRelationships;
@property (nonatomic, readonly) BOOL isSubTreeDirty;
@property (nonatomic, readonly) FOSRESTConfig * _Nonnull restConfig;

/*!
 * @property isUploadable
 *
 * Determines if it is allowable to upload the receiver
 * to the web service.
 *
 * It combines the receiver's isLocalOnly and isReadOnly
 * properties.
 */
@property (nonatomic, readonly) BOOL isUploadable;

/*!
 * @property prepareForSendOperation
 *
 * Allows the CMO to perform work before the receiver
 * is delivered to the server.
 *
 * Subclasses should make their operation dependant on
 * the super class's result, if not nil.
 */
@property (nonatomic, readonly) FOSOperation * _Nonnull prepareForSendOperation;

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
@property (nonatomic, readonly) FOSCachedManagedObject * _Nullable owner;

#pragma mark - Class methods

+ (BOOL)idIsInDatabase:(FOSJsonId _Nonnull)jsonId;

// See: http://fosmain.foscomputerservices.com:8080/browse/FF-12
+ (BOOL)canHaveDuplicateJsonIds;

/*!
 * @method fetchWithId:
 *
 * Retrieves an instance of the receiver's class from
 * the database using jsonId as for the key.
 *
 * @param jsonId  The unique identifier of the instance
 *     to retrieve.
 */
+ (instancetype _Nullable)fetchWithId:(FOSJsonId _Nonnull)jsonId;

+ (instancetype _Nullable)fetchWithId:(FOSJsonId _Nonnull)jsonId
               inManagedObjectContext:(NSManagedObjectContext * _Nonnull)moc;

+ (NSSet * _Nonnull)fetchWithIds:(id<NSFastEnumeration> _Nonnull)jsonIds;

/*!
 * @method fetchWithId:forJsonRelation:
 *
 * Retrieves instances of the receiver's class from
 * the database using objectId as for the key.
 *
 * @param jsonRelId  The unique identifier of the instance
 *     to retrieve.
 */
+ (NSSet * _Nonnull)fetchWithRelId:(FOSJsonId _Nonnull)jsonRelId forJsonRelation:(NSString * _Nonnull)jsonRelation;

/*!
 * @method fetchAll
 */
+ (NSArray * _Nullable)fetchAll;

/*!
 * @method fetchWithPredicate:
 */
+ (NSArray * _Nullable)fetchWithPredicate:(NSPredicate * _Nullable)pred;

/*!
 * @method fetchWithPredicate:withSortDescriptors:
 */
+ (NSArray * _Nullable)fetchWithPredicate:(NSPredicate * _Nullable)pred
            withSortDescriptors:(NSArray * _Nullable)sortDescriptors;

/*!
 * @method count
 *
 * Returns the number of instances of the receiver's type in the database.
 */
+ (NSUInteger)count;

/*!
 * @method countWithPredicate
 *
 * Returns the number of instances of the receiver's type in the database that
 * match the given predicate.
 */
+ (NSUInteger)countWithPredicate:(NSPredicate * _Nullable)pred;

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
+ (FOSRetrieveCMOOperation * _Nonnull)retrieveCMOForJsonId:(FOSJsonId _Nonnull)jsonId;

/*!
 * @method retrieveCMOsWithDSLQuery:
 *
 * This method corresponds to the FOSLifecyclePhaseRetrieveServerRecords
 * @link FOSLifecyclePhase @/link.
 */
+ (FOSSearchOperation * _Nonnull)retrieveCMOsWithDSLQuery:(NSString * _Nullable)dslQuery;

/*!
 * @method sendServerRecordWithLifecycleStyle:
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
 * depending on the receiver's @link hasBeenUploadedToServer @/link
 * status.
 */
- (FOSSendServerRecordOperation * _Nonnull)sendServerRecordWithLifecycleStyle:(NSString * _Nullable)lifecycleStyle;

- (FOSSendServerRecordOperation * _Nonnull)sendServerRecordWithLifecycleStyle:(NSString * _Nullable)lifecycleStyle parentSentIDs:(NSSet * _Nullable)parentSentIDs;

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
+ (FOSRetrieveCMOOperation * _Nonnull)createAndRetrieveServerRecordWithJSON:(id<NSObject> _Nonnull)json;

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
@property (nonatomic, strong) FOSJsonId _Nullable jsonIdValue;

#pragma mark - Public methods

/*!
 * @method markClean
 *
 * Marks the receiver clean with respect to the REST service.  Any outstanding
 * indications that local changes were made to the receiver are erased
 * (e.g. propertiesModifiedSinceLastUpload will be empty).
 */
- (void)markClean;

/*!
 * @method originalJson
 *
 * The original json from which the receiver was created.
 */
- (id<NSObject> _Nullable)originalJson;

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
 * Returns the set of properties that have changed since the last time
 * that @link markClean @/link was called.
 */
- (NSSet * _Nullable)propertiesModifiedSinceLastUpload;

/*! @methodgroup Refresh */
#pragma mark - Refresh methods

/*!
 * @method refresh
 *
 * Refreshes the receiver and it's 'forcePull' relationships with the REST server.
 */
- (void)refreshWithHandler:(FOSBackgroundRequest _Nullable)handler;

/*!
 * @method refreshRelationshipNamed:dslQuery:mergeResults:handler:
 *
 * @param relName The name of the CMOs relationship to refresh
 *
 * @param dslQuery A 'Domain Specific Query' that will be bound to the $DSLQUERY
 *                 variable when the URL_BINDING is bound to a URL.
 *
 * Refreshes the receiver's named relationship with the REST server.
 *
 * @discussion
 *
 * This method calls efreshRelationshipNamed:dslQuery:mergeResults:handler: with
 * mergeResults = NO; that is, results will be synchronized.
 */
- (void)refreshRelationshipNamed:(NSString * _Nonnull)relName
                        dslQuery:(NSString * _Nullable)dslQuery
                         handler:(FOSBackgroundRequest _Nullable)handler;

/*!
 * @method refreshRelationshipNamed:dslQuery:mergeResults:handler:
 *
 * @param relName The name of the CMOs relationship to refresh
 *
 * @param dslQuery A 'Domain Specific Query' that will be bound to the $DSLQUERY
 *                 variable when the URL_BINDING is bound to a URL.
 *
 * @param mergeResults YES will inhibit the synchronization of the server results with
 *                     the existing results.  This allows the relationship to be
 *                     incrementally add to as opposed to synchronized.
 *
 * Refreshes the receiver's named relationship with the REST server.
 */
- (void)refreshRelationshipNamed:(NSString * _Nonnull)relName
                        dslQuery:(NSString * _Nullable)dslQuery
                    mergeResults:(BOOL)mergeResults
                         handler:(FOSBackgroundRequest _Nullable)handler;

/*!
 * @method refreshRelationshipNamed:handler:
 *
 * Refreshes the receiver's named relationships with the REST server.
 */
- (void)refreshAllRelationshipsNamed:(id<NSFastEnumeration> _Nonnull)relNames
                             handler:(FOSBackgroundRequest _Nullable)handler;

/*!
 * @method refreshAllRelationships:
 *
 * Refreshes the receiver's managed relationships with the REST server.
 */
- (void)refreshAllRelationships:(FOSBackgroundRequest _Nullable)handler;

#pragma mark - Associated Caches

/*!
 * @method associateValue:toPropertyNamed:
 *
 * The associated value mechanism allows values to be stored related to
 * another property.  Tha  value will be retained as long as the related property
 * doesn't change.  If a change is observed for that property,
 * the related value will be dropped.
 */
- (void)associateValue:(id _Nonnull)value toPropertyNamed:(NSString * _Nonnull)propName;

/*!
 * @method associatedValueForProperty:
 */
- (id _Nullable)associatedValueForProperty:(NSString * _Nonnull)propName;

/*!
 * @method resetAssociatedValues
 *
 * Causes the receiver to drop all property-associated values.
 *
 * @discussion
 *
 * Generally this method is only called internally by the FOSCacheManager.
 */
- (void)resetAssociatedValues;

/*!
 * @property skipNextReset
 *
 * Allows for skipping the next round of associated value resets for this instance.
 *
 * @discussion
 *
 * When a CMO is updated and its values are sent to the server, the local instance
 * is updated with the values that come back from the server.  However, those
 * values are probably simply what was sent to the server and there's no reason
 * to clear the associated value caches.
 */
@property (nonatomic) BOOL skipNextReset;

#pragma mark - Override Points

+ (id _Nullable)objectForAttribute:(NSAttributeDescription * _Nonnull)attrDesc forJsonValue:(id _Nonnull)jsonValue;
+ (id _Nullable)jsonValueForObject:(id _Nonnull)objValue forAttribute:(NSAttributeDescription * _Nonnull)attrDesc;

@end
