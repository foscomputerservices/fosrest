//
//  FOSAtomicCreateServerRecordOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 10/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSAtomicCreateServerRecordOperation.h"

@implementation FOSAtomicCreateServerRecordOperation {
    FOSWebServiceRequest *_webRequest;
    NSError *_error;
}

#pragma mark - Properties

// We must synthesize as they're declared in a protocol and won't auto synthesize.
@synthesize entity = _entity;
@synthesize jsonId = _jsonId;
@synthesize jsonResult = _jsonResult;

#pragma mark - Class Methods

+ (instancetype)operationForEntity:(NSEntityDescription *)entity
                          withJSON:(id<NSObject>)json {

    FOSAtomicCreateServerRecordOperation *result = [[self alloc] initForEntity:entity
                                                          withJSON:json];

    return result;
}

#pragma mark - Initialization Methods

- (id)initForEntity:(NSEntityDescription *)entity
           withJSON:(id<NSObject>)json {

    NSParameterAssert(entity != nil);
    NSParameterAssert(json != nil);

    if ((self = [super init]) != nil) {

        _entity = entity;
        _jsonResult = (NSDictionary *)json;
//        _webRequest = [entity jsonCreateRequestForJSON:json];
        NSAssert(NO, @"Broken!!! Hopefully atomic create will be obsolted!");

        if (_webRequest == nil) {
            NSString *msg = NSLocalizedString(@"Missing 'jsonCreateEndPoint' specification on entity '%@'.",
                                              @"FOSMissing_jsonCreateEndPoint");

            [NSException raise:@"FOSMissing_jsonCreateEndPoint" format:msg, _entity.name];
        }

        [self addDependency:_webRequest];
    }

    return self;
}

#pragma mark - FOSRetrieveCMODataOperationProtocol Methods

- (NSEntityDescription *)entity {
    return _entity;
}

- (FOSJsonId)jsonId {
    return _jsonId;
}

#pragma mark - Method Overrides

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return result;
}

- (void)main {
    [super main];

    if (!self.isCancelled && self.error == nil) {

#ifndef NS_BLOCK_ASSERTIONS
        Class objectType = NSClassFromString(_entity.managedObjectClassName);

        NSParameterAssert([objectType isSubclassOfClass:[FOSCachedManagedObject class]]);
#endif

        id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
        FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseCreateServerRecord
                                                         forRelationship:nil
                                                               forEntity:self.entity];
        id<FOSTwoWayRecordBinding> recordBinding = urlBinding.cmoBinding;

        NSError *localError = nil;

        _jsonId = [recordBinding jsonIdFromJSON:_webRequest.jsonResult
                                      forEntity:self.entity
                                          error:&localError];

        if (_jsonId == nil) {
            NSString *msg = NSLocalizedString(@"Did not receive a unique id from the web service afer creating entity '%@'.", @"FOSMissing_WebServiceId");

            _error = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
        }
        else if (localError != nil) {
            _error = localError;
        }

#ifdef DEBUG
        else {
            // There shouldn't already be an entity with this id
            FOSCachedManagedObject *otherCMO = [objectType fetchWithId:_jsonId];
            NSAssert(otherCMO == nil || [otherCMO.objectID isEqual:_jsonId],
                     @"Duplicate %@ instance with id %@!!!",
                     [objectType description], (NSString *)_jsonId);
        }
#endif
    }
    else if (self.error != nil) {
        NSLog(@"Create failed for entity '%@': %@", _entity.name,
              _webRequest.error.description);
    }
    else {
        NSLog(@"Create for entity '%@' **CANCELLED**.", _entity.name);
    }
}

@end
