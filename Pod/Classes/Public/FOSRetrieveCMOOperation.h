//
//  FOSRetrieveCMOOperation.h
//  FOSREST
//
//  Created by David Hunt on 12/31/12.
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

#import <fosrest/FOSOperation.h>
#import <fosrest/FOSCachedManagedObject.h>
#import <fosrest/FOSURLBinding.h>

@protocol FOSRetrieveCMODataOperationProtocol;

@interface FOSRetrieveCMOOperation : FOSOperation

#pragma mark - Properties

@property (nonatomic, readonly) NSEntityDescription *entity;
@property (nonatomic, readonly) FOSJsonId jsonId;
@property (nonatomic, readonly) id<NSObject> json;
@property (nonatomic, readonly) NSManagedObjectID *managedObjectID;
@property (nonatomic, readonly) FOSCachedManagedObject *managedObject;
@property (nonatomic, readonly) BOOL isTopLevelFetch;
@property (nonatomic, assign) BOOL allowFastTrack;
@property (nonatomic, strong) NSString *dslQuery;
@property (nonatomic, assign) BOOL mergeResults;

#pragma mark - Class Methods

+ (instancetype)retrieveCMOUsingDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchOp
                            forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
                            forLifecycleStyle:(NSString *)lifecycleStyle;

+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                              withId:(FOSJsonId)jsonId;

+ (instancetype)retrieveCMOForEntity:(NSEntityDescription *)entity
                            withJson:(NSDictionary *)json
                        withBindings:(NSMutableDictionary *)bindings;

+ (NSMutableDictionary *)primeBindingsForEntity:(NSEntityDescription *)entity
                                    withJsonIDs:(NSArray *)jsonIds;

+ (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                              withJsonId:(FOSJsonId)jsonId
                            fromBindings:(NSMutableDictionary *)bindings;

- (FOSCachedManagedObject *)cmoForEntity:(NSEntityDescription *)entity
                                withJson:(id<NSObject>)json
                            fromBindings:(NSMutableDictionary *)bindings;

#pragma mark - Initialization Methods

- (id)initAsTopLevelFetch:(BOOL)isTopLevelFetch
        forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
        forLifecycleStyle:(NSString *)lifecycleStyle
                   entity:(NSEntityDescription *)entity
           ofRelationship:(NSRelationshipDescription *)relDesc
             withBindings:(NSMutableDictionary *)bindings;

- (id)initWithDataOperation:(FOSOperation<FOSRetrieveCMODataOperationProtocol> *)fetchOp
            isTopLevelFetch:(BOOL)isTopLevelFetch
          forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
          forLifecycleStyle:(NSString *)lifecycleStyle
               withBindings:(NSMutableDictionary *)bindings;

- (id)initForEntity:(NSEntityDescription *)entity
     ofRelationship:(NSRelationshipDescription *)relDesc
             withId:(FOSJsonId)jsonId
    isTopLevelFetch:(BOOL)isTopLevelFetch
  forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
  forLifecycleStyle:(NSString *)lifecycleStyle
       withBindings:(NSMutableDictionary *)bindings;

- (id)initForEntity:(NSEntityDescription *)entity
     ofRelationship:(NSRelationshipDescription *)relDesc
           withJson:(NSDictionary *)json
    isTopLevelFetch:(BOOL)isTopLevelFetch
  forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
  forLifecycleStyle:(NSString *)lifecycleStyle
       withBindings:(NSMutableDictionary *)bindings;

#pragma mark - Binding Methods

- (void)finishBinding;
- (void)finishOrdering;
- (NSError *)finishValidation;
- (void)finishCleanup:(BOOL)forceDestroy;

@end
