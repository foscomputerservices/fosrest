//
//  FOSStaticTableSearchOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 5/21/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSStaticTableSearchOperation.h"

@implementation FOSStaticTableSearchOperation {
    NSError *_error;
}

#pragma mark - Overrides

- (Class)managedClass {
    NSAssert(_staticTableClass != NULL, @"staticTableClass must be assigned!");

    return _staticTableClass;
}

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return result;
}

- (NSSet *)dependentSearchOperations {
    NSAssert(self.staticTableClass != NULL, @"staticTableClass must be assigned!");

    NSError *localError = nil;
    NSMutableSet *result = [NSMutableSet setWithCapacity:1];
    NSEntityDescription *entity = [self.staticTableClass entityDescription];
    __block FOSStaticTableSearchOperation *blockSelf = self;

    FOSWebServiceRequest *countRequest = [self _countRequestForEntity:entity
                                                                error:&localError];
    if (countRequest != nil) {
        // We need all of the dependencies ahead of time, so cannot create an re-queue later.
        // Instead we'll cancel this request if we don't need it.
        FOSWebServiceRequest *dataRequest = [blockSelf _dataRequestForEntity:entity
                                                                       error:&localError];
        if (localError == nil) {
            FOSBackgroundOperation *procCount = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
                if (!cancelled && (error == nil)) {

                    // Compare the counts to see if there's any work to do
                    NSNumber *serverCount = (NSNumber *)countRequest.jsonResult;
                    NSAssert([serverCount isKindOfClass:[NSNumber class]],
                             @"Expected NSNumber, got %@.",
                             NSStringFromClass(blockSelf->_staticTableClass));

                    NSUInteger existingCount = [blockSelf->_staticTableClass count];

                    // If the server count and the local count are equal, then no need to proceed.
                    if (serverCount.unsignedIntegerValue == existingCount) {
                        [dataRequest cancel];
                    }
                }
            }];

            [procCount addDependency:countRequest];
            [dataRequest addDependency:procCount];

            // Process the pulled results
            FOSOperation *procOp = [self processSearchResults:dataRequest];

            [result addObject:procOp];
        }
    }

    if (localError != nil) {
        _error = localError;
        result = nil;
    }
    
    return result;
}

#pragma mark - Private Methods

// TODO : These two methods (and others) seem to indicate the need for a wrapper
//        API somewhere.
- (FOSWebServiceRequest *)_countRequestForEntity:(NSEntityDescription *)entity
                                           error:(NSError **)error {
    NSParameterAssert(entity != nil);
    NSParameterAssert(error != nil);

    FOSWebServiceRequest *result = nil;

    // 1st retrieve a count of records from the server to see if that count matches ours
    FOSURLBinding *urlCountBinding =
        [self.restAdapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecordCount
                                       forLifecycleStyle:nil
                                      forRelationship:nil
                                        forEntity:entity];
    NSURLRequest *urlCountRequest = [urlCountBinding urlRequestServerRecordOfType:entity
                                                                     withDSLQuery:nil
                                                                            error:error];

    if (*error == nil) {
        result = [FOSWebServiceRequest requestWithURLRequest:urlCountRequest
                                               forURLBinding:urlCountBinding];
    }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

- (FOSWebServiceRequest *)_dataRequestForEntity:(NSEntityDescription *)entity
                                          error:(NSError **)error {
    NSParameterAssert(entity != nil);
    NSParameterAssert(error != nil);

    FOSWebServiceRequest *result = nil;

    FOSURLBinding *urlDataBinding =
        [self.restAdapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecords
                                       forLifecycleStyle:nil
                                      forRelationship:nil
                                        forEntity:entity];

    NSURLRequest *urlDataRequest = [urlDataBinding urlRequestServerRecordOfType:entity
                                                                   withDSLQuery:nil
                                                                          error:error];

    if (*error == nil) {
        result = [FOSWebServiceRequest requestWithURLRequest:urlDataRequest
                                               forURLBinding:urlDataBinding];
    }

    if (*error != nil) {
        result = nil;
    }

    return result;
}

@end
