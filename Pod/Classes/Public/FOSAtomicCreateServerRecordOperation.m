//
//  FOSAtomicCreateServerRecordOperation.m
//  FOSRest
//
//  Created by David Hunt on 10/3/13.
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

#import <FOSAtomicCreateServerRecordOperation.h>
#import "FOSREST_Internal.h"

@implementation FOSAtomicCreateServerRecordOperation {
    FOSWebServiceRequest *_webRequest;
}

#pragma mark - Properties

// We must synthesize as they're declared in a protocol and won't auto synthesize.
@synthesize entity = _entity;
@synthesize jsonId = _jsonId;
@synthesize jsonResult = _jsonResult;
@synthesize originalJsonResult = _originalJsonResult;

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
        _originalJsonResult = _jsonResult;
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

- (NSString *)dslQuery {
    return nil;
}

- (BOOL)mergeResults {
    return NO;
}

#pragma mark - Method Overrides

- (void)main {
    [super main];

    if (!self.isCancelled && self.error == nil) {

#ifndef NS_BLOCK_ASSERTIONS
        Class objectType = NSClassFromString(_entity.managedObjectClassName);

        NSParameterAssert([objectType isSubclassOfClass:[FOSCachedManagedObject class]]);
#endif

        id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
        FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseCreateServerRecord
                                                          forLifecycleStyle:nil
                                                         forRelationship:nil
                                                               forEntity:self.entity];
        id<FOSTwoWayRecordBinding> recordBinding = urlBinding.cmoBinding;

        NSError *localError = nil;

        _jsonId = [recordBinding jsonIdFromJSON:_webRequest.jsonResult
                                      forEntity:self.entity
                                          error:&localError];

        if (_jsonId == nil) {
            NSString *msg = NSLocalizedString(@"Did not receive a unique id from the web service afer creating entity '%@'.", @"FOSMissing_WebServiceId");

            _error = [NSError errorWithMessage:msg];
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
        FOSLogError(@"Create failed for entity '%@': %@", _entity.name,
              _webRequest.error.description);
    }
    else {
        FOSLogInfo(@"Create for entity '%@' **CANCELLED**.", _entity.name);
    }
}

@end
