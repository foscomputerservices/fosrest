//
//  NSEntityDescription+FOS.h
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

@import CoreData;

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
 * "FOSREST_Internal.h"Tests/Test Data Model/RESTTests.xcdatamodeld.
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
 * @return YES if it is acceptable to use faulting for instances
 * of the receiver's type, NO if concrete instances are
 * always required.
 *
 * @discussion If 'jsonAllowFault' is not specified on the entity, then
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
 * @return YES if it is acceptable to use value matching to find
 * instances that match during synchronization.
 *
 * @discussion By default this value is NO. It should only be turned
 * on for values that have sufficient data to ensure
 * non-ambiguous comparisons.
 */
@property (nonatomic, readonly) BOOL jsonCanValueMatch;

/*!
 * @property jsonIgnoreAsStaticTableEntity
 *
 * Specifying 'YES' overrides any automatic matching of the receiver
 * as a static table entity and thus treats entities of the recvier's
 * type as normal FOSCachedManagedObject entities.
 *
 * @discussion If this property is not provided in the entity's UserInfo specification,
 * the framework automatically determines the appropriate value by whether
 * the entity has any owning relationships to or from it.  If no relationships
 * are found, then it is assumed to be a static entity.
 */
@property (nonatomic, readonly) BOOL jsonIgnoreAsStaticTableEntity;

/*!
 * @property jsonUseAbstract
 *
 * Tells the infrastructure to communicate with REST service using the REST API
 * of the abstract entity as opposed to each of the subtypes.
 *
 * @discussion For entities that are declared as abstract we need to know how the concrete
 * entities align with the webservice API.  Sometimes there is a separate end point
 * for each subtype and other times there's a shared end point for all subtypes
 * (like SQL single-table inheritance).
 *
 * Specifying 'YES' will cause all REST communication to be completed
 * through the end point associaited with the abstract entity.  In this case,
 * the FOSRESTServiceAdapter implementation should implement the subtypeFromBase:givenJSON:
 * method to disambiguate the final entity type to instantiate.
 *
 * Specifying 'NO' (the default) will cause all REST communication to be
 * completed through each of the leaf types of the entity.  Thus a call will be made
 * to the REST service for each leaf (concrete) type.
 */
@property (nonatomic, readonly) BOOL jsonUseAbstract;

/*!
 * @methodgroup Computed Attribute and Relationship properties
 */

/*!
 * @property cmoAttributes
 *
 * The set of properties that are of type NSAttributeDescription and
 * !relDesc.isFOSProperty.
 */
@property (nonatomic, readonly) NSSet<NSAttributeDescription *> *cmoAttributes;

/*!
 * @property cmoRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship.
 */
@property (nonatomic, readonly) NSSet<NSRelationshipDescription *> *cmoRelationships;

/*!
 * @property cmoToOneRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && !relDesc.isToMany.
 */
@property (nonatomic, readonly) NSSet<NSRelationshipDescription *> *cmoToOneRelationships;

/*!
 * @property cmoToManyRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && relDesc.isToMany.
 */
@property (nonatomic, readonly) NSSet<NSRelationshipDescription *> *cmoToManyRelationships;

/*!
 * @property cmoOwnedRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && relDesc.isOwnershipRelationship.
 */
@property (nonatomic, readonly) NSSet<NSRelationshipDescription *> *cmoOwnedRelationships;

/*!
 * @property cmoOwnedToManyRelationships
 *
 * The set of properties that are of type NSRelationshipDescription and
 * !relDesc.isFOSRelationship && relDesc.isOwnershipRelationship && relDesc.isToMany.
 */
@property (nonatomic, readonly) NSSet<NSRelationshipDescription *> *cmoOwnedToManyRelationships;

/*!
 * @methodgroup  Inferred Properties
 */
#pragma mark - Inferred Properties

@property (nonatomic, readonly) BOOL hasOwner;

@property (nonatomic, readonly) BOOL hasUserDefinedProperties;

/*!
 * @methodgroup Localization Properties
 */

/*!
 * @property localizedName
 *
 * Returns the localized name for the receiver in the
 * localizationDictionary associated with the recever's NSManagedObjectModel.
 */
@property (nonatomic, readonly) NSString *localizedName;

@end
