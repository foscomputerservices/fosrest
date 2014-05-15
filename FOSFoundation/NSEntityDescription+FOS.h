//
//  NSEntityDescription+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef BOOL (^FOSAttributeHandler)(NSAttributeDescription *relDesc);
typedef BOOL (^FOSRelationshipHandler)(NSRelationshipDescription *relDesc);

@class FOSRetrieveCMOOperation;

/*!
 * @category NSEntityDescription (FOS)
 *
 * This category provides access to key-value pairs
 * provided in the NSEntityDescription's userInfo
 * NSDictionary.  The names of the properties in this
 * interface correspond directly to key names that
 * are to be provided in the userInfo dictionary.
 *
 * The receiver's superEntity chain is searched for
 * matches if a match is not found in the receiver's
 * userInfo dictionary.
 *
 * Normally these values are set in the database
 * model modified using Xcode's database modeling
 * tools.
 *
 * These properties work together to bi-directionally
 * bind managed entities to JSON objects.
 *
 * Each of the samples below is based on the User entity
 * in the sample data model provided in
 * FOSFoundationTests/Test Data Model/RESTTests.xcdatamodeld.
 */
@interface NSEntityDescription (FOS)

/*!
 * @methodgroup  Extended class methods
 */
#pragma mark - Class Methods

/*!
 * @method insertNewObjectForEntityForName:inManagedObjectContext:withJSON:
 *
 * This is a server-based implementation of the corresponding method
 * insertNewObjectForEntityForName:inManagedObjectContext:.
 *
 * 
 */
+ (FOSRetrieveCMOOperation *)insertNewCMOForEntityForName:(NSString *)entityName
                                      inManagedObjectContext:(NSManagedObjectContext *)moc
                                                    withJSON:(id<NSObject>)json;

/*!
 * @methodgroup  Optional Data Model Properties
 */
#pragma mark - Optional Data Model Properties

/*!
 * @property jsonAllowFault
 *
 * @return
 *
 * YES if it is acceptable to use faulting for instances
 * of the receiver's type, NO if concrete instances are
 * always required.
 *
 * @discussion
 *
 * If 'jsonAllowFault' is not specified on the entity, then
 * faulting is disallowed.
 *
 * Faulting is very similar to CoreData's faulting model
 * in that, it allows for stub instances to be allowed in
 * the object graph instead of requiring the entire tree
 * to be brought over the wire.
 *
 * If at all possible faults should be allowed to reduce the
 * network burden.  Faults will then be optimally handled by
 * the system.
 */
@property (nonatomic, readonly) BOOL jsonAllowFault;

/*!
 * @property jsonCanValueMatch
 *
 * Attempts to match downloaded JSON data with local
 * entity data in the case that the jsonIdValue in the
 * JSON packet doesn't match any entity in the database.
 *
 * This can help to alleviate data duplication issues.
 *
 * @return
 *
 * YES if it is acceptable to use value matching to find
 * instances that match during synchronization.
 *
 * @discussion
 *
 * By default this value is NO. It should only be turned
 * on for values that have sufficient data to ensure
 * non-ambiguous comparisons.
 */
@property (nonatomic, readonly) BOOL jsonCanValueMatch;

/*!
 * @property jsonAbstractRelationshipMaps
 *
 * A string containing maps between properties on parent abstract entity
 * relationships and the concrete entity type that is used by this entity.
 *
 * The format of this string is:  <property>:<entity name>[,<property>:<entity name>, ...]
 *
 * @discussion
 *
 * On entities that have relationships to abstract entities, at some time the final
 * concrete entity type is required.  When pushing an instance for the relationship,
 * the entity can be determined from that instance.  However, if the relationship
 * is severed (e.g. assigned to nil), then the entity type cannot be determined.
 *
 * In this case, some statement of the entity type must be specified.
 */
@property (nonatomic, readonly) NSString *jsonAbstractRelationshipMaps;

/*!
 * @methodgroup  Inferred Properties
 */
#pragma mark - Inferred Properties

@property (nonatomic, readonly) BOOL hasOwner;

@property (nonatomic, readonly) BOOL hasUserDefinedProperties;

#pragma mark - Custom Enumeration Methods

- (void)enumerateAttributes:(FOSAttributeHandler)handler;
- (void)enumerateOnlyOwned:(BOOL)onlyOwned relationships:(FOSRelationshipHandler)handler;
- (void)enumerateOnlyNotOwned:(BOOL)onlyOwned relationships:(FOSRelationshipHandler)handler;

@end