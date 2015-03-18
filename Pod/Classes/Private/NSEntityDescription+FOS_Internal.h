//
//  NSEntityDescription+FOS_Internal.h
//  FOSREST
//
//  Created by David Hunt on 12/28/12.
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

#import <CoreData/CoreData.h>
#import "FOSCacheManager.h"
#import "FOSWebServiceRequest.h"
#import "FOSRetrieveCMOOperation.h"

@class FOSUser;

@interface NSEntityDescription (FOS_Internal)

#pragma mark - Public Properties
@property (nonatomic, readonly) BOOL isFOSEntity;

/*!
 * @property leafEntities
 *
 *
 */
@property (nonatomic, readonly) NSSet *leafEntities;
@property (nonatomic, readonly) NSSet *flattenedRelationships;
@property (nonatomic, readonly) BOOL hasMultipleOwnerRelationships;
@property (nonatomic, readonly) NSSet *ownerRelationships;
@property (nonatomic, readonly) NSSet *flattenedOwnershipRelationships;
@property (nonatomic, readonly) BOOL isStaticTableEntity;

#pragma mark - Public Class Methods

/*!
 * @method
 *
 * Converts a class name into an entity name that will bind to NSEntityDescription.
 *
 * @discussion
 *
 * This method should *always* be used, never expect that NSStringFromClass() is
 * a substitute for retrieving the entity name.
 */
+ (NSString *)entityNameForClass:(Class)class;

#pragma mark - Public Methods

- (BOOL)isFOSEntityWithRestConfig:(FOSRESTConfig *)restConfig;
- (BOOL)isStaticTableEntityWithRestConfig:(FOSRESTConfig *)restConfig;

@end
