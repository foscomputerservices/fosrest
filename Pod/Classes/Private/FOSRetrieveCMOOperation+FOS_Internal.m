//
//  FOSRetrieveCMOOperation+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 4/15/13.
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

#import "FOSRetrieveCMOOperation+FOS_Internal.h"
#import "FOSRESTConfig.h"

extern NSMutableDictionary *_outstandingFEORequests;

@implementation FOSRetrieveCMOOperation (FOS_Internal)

+ (instancetype)fetchRelatedManagedObjectUsingDataOperation:(FOSRetrieveCMODataOperation *)fetchOp
                                             ofRelationship:(NSRelationshipDescription *)relDesc
                                               withBindings:(NSMutableDictionary *)bindings {
    NSParameterAssert(fetchOp != nil);
    NSParameterAssert(bindings != nil);

    return [[self alloc] initWithDataOperation:fetchOp
                               isTopLevelFetch:NO
                             forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                             forLifecycleStyle:nil
                                  withBindings:bindings];
}

+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                    ofRelationship:(NSRelationshipDescription *)relDesc
                                            withId:(FOSJsonId)jsonId
                                      withBindings:(NSMutableDictionary *)bindings {

    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(bindings != nil);

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                   ofRelationship:relDesc
                                                           withId:jsonId
                                                  isTopLevelFetch:NO
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                                forLifecycleStyle:nil
                                                     withBindings:bindings];

    return result;
}

+ (instancetype)fetchRelatedManagedObjectForEntity:(NSEntityDescription *)entity
                                    ofRelationship:(NSRelationshipDescription *)relDesc
                                          withJson:(id<NSObject>)json
                                      withBindings:(NSMutableDictionary *)bindings {

    NSParameterAssert(entity != nil);
    NSParameterAssert(json != nil);
    NSParameterAssert(bindings != nil);

    FOSRetrieveCMOOperation *result = [[self alloc] initForEntity:entity
                                                   ofRelationship:relDesc
                                                         withJson:(NSDictionary *)json
                                                  isTopLevelFetch:NO
                                                forLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordRelationship
                                                forLifecycleStyle:nil
                                                     withBindings:bindings];

    return result;
}

@end
