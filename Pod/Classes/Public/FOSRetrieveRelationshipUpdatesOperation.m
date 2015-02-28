//
//  FOSRetrieveRelationshipUpdatesOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 6/3/14.
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

#import <FOSRetrieveRelationshipUpdatesOperation.h>
#import "FOSFoundation_Internal.h"

@interface _FOSCMODataOpPackage : FOSOperation<FOSRetrieveCMODataOperationProtocol>

+ (instancetype)packageFor:(FOSCachedManagedObject *)cmo
                  dslQuery:(NSString *)dslQuery
              mergeResults:(BOOL)mergeResults
                  matching:(FOSItemMatcher *)relationshipNameMatcher;

@end

@implementation _FOSCMODataOpPackage

@synthesize entity = _entity;
@synthesize jsonId = _jsonId;
@synthesize dslQuery = _dslQuery;
@synthesize mergeResults = _mergeResults;
@synthesize jsonResult = _jsonResult;
@synthesize originalJsonResult = _originalJsonResult;
@synthesize relationshipsToPull = _relationshipsToPull;

+ (instancetype)packageFor:(FOSCachedManagedObject *)cmo
                  dslQuery:(NSString *)dslQuery
              mergeResults:(BOOL)mergeResults
                  matching:(FOSItemMatcher *)relationshipNameMatcher {
    return [[self alloc] initForCMO:cmo
                           dslQuery:dslQuery
                       mergeResults:mergeResults
                   forRelationships:relationshipNameMatcher];
}

- (id)initForCMO:(FOSCachedManagedObject *)cmo
        dslQuery:(NSString *)dslQuery
    mergeResults:(BOOL)mergeResults
forRelationships:(FOSItemMatcher *)relationshipNameMatcher {
    NSParameterAssert(cmo != nil);
    NSParameterAssert(relationshipNameMatcher != nil);

    if ((self = [super init])) {
        _entity = cmo.entity;
        _jsonId = cmo.jsonIdValue;
        _jsonResult = cmo.originalJson;
        _dslQuery = dslQuery;
        _mergeResults = mergeResults;
        _relationshipsToPull = relationshipNameMatcher;
    }

    return self;
}

@end

@implementation FOSRetrieveRelationshipUpdatesOperation

#pragma mark - Class Methods

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo
                                         dslQuery:(NSString *)dslQuery
                                     mergeResults:(BOOL)mergeResults {
    return [[self alloc] initForCMO:cmo dslQuery:dslQuery mergeResults:mergeResults];
}

+ (instancetype)retrieveRealtionshipUpdatesForCMO:(FOSCachedManagedObject *)cmo
                                         dslQuery:(NSString *)dslQuery
                                     mergeResults:(BOOL)mergeResults
                                         matching:(FOSItemMatcher *)relationshipNameMatcher {
    return [[self alloc] initForCMO:cmo dslQuery:dslQuery
                       mergeResults:mergeResults
                   forRelationships:relationshipNameMatcher];
}

#pragma mark - Initialization Methods

- (id)initForCMO:(FOSCachedManagedObject *)cmo
        dslQuery:(NSString *)dslQuery
    mergeResults:(BOOL)mergeResults {
    return [self initForCMO:cmo
                   dslQuery:dslQuery
               mergeResults:mergeResults
           forRelationships:[FOSItemMatcher matcherMatchingAllItems]];
}

- (id)initForCMO:(FOSCachedManagedObject *)cmo
        dslQuery:(NSString *)dslQuery
    mergeResults:(BOOL)mergeResults
forRelationships:(FOSItemMatcher *)relationshipNameMatcher {

    NSParameterAssert(cmo != nil);
    NSParameterAssert(relationshipNameMatcher != nil);

    if ((self = [super init]) != nil) {
        _FOSCMODataOpPackage *dataOpPackage = [_FOSCMODataOpPackage packageFor:cmo
                                                                      dslQuery:dslQuery
                                                                  mergeResults:mergeResults
                                                                      matching:relationshipNameMatcher];

        FOSRetrieveCMOOperation *retrieveCMO =
            [FOSRetrieveCMOOperation retrieveCMOUsingDataOperation:dataOpPackage
                                                 forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                 forLifecycleStyle:self.lifecycleStyle];
        retrieveCMO.dslQuery = dslQuery;
        retrieveCMO.mergeResults = mergeResults;

        [self addDependency:retrieveCMO];
    }

    return self;
}

@end
