//
//  FOSAtomicCreateServerRecordOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 10/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>
#import <FOSFoundation/FOSRetrieveCMODataOperation.h>

@interface FOSAtomicCreateServerRecordOperation : FOSOperation<FOSRetrieveCMODataOperationProtocol>

#pragma mark - Class Methods

+ (instancetype)operationForEntity:(NSEntityDescription *)entity withJSON:(id<NSObject>)json;

#pragma mark - Initialization Methods

- (id)initForEntity:(NSEntityDescription *)entity
           withJSON:(id<NSObject>)json;

@end
