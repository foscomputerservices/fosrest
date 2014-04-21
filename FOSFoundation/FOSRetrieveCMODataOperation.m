//
//  FOSRetrieveCMODataOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSRetrieveCMODataOperation.h"
#import "FOSWebServiceRequest+FOS_Internal.h"

@implementation FOSRetrieveCMODataOperation {
    NSError *_error;
}

@synthesize entity = _entity;
@synthesize jsonId = _jsonId;

#pragma mark - Class Methods

+ (instancetype)retrieveDataOperationForEntity:(NSEntityDescription *)entity
                                   withRequest:(NSURLRequest *)request
                                 andURLBinding:(FOSURLBinding *)urlBinding {
    NSParameterAssert(entity != nil);
    NSParameterAssert(request != nil);
    NSParameterAssert(urlBinding != nil);

    return [[self alloc] initWithEntity:entity withRequest:request andURLBinding:urlBinding];
}

#pragma mark - Intialization Methods

- (id)initWithEntity:(NSEntityDescription *)entity
         withRequest:(NSURLRequest *)request
       andURLBinding:(FOSURLBinding *)urlBinding {
    NSParameterAssert(entity != nil);
    NSParameterAssert(request != nil);
    NSParameterAssert(urlBinding != nil);

    if ((self = [super initWithURLRequest:request andURLBinding:urlBinding]) != nil) {
        _entity = entity;
    }

    return self;
}

#pragma mark - FOSRetrieveCMODataOperationProtocol Methods

- (void)setJsonResult:(NSDictionary *)jsonResult {
    id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;
    FOSURLBinding *urlBinding = [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                                     forRelationship:nil
                                                       forEntity:self.entity];

    NSError *localError = nil;
    FOSJsonId jsonId = [urlBinding.cmoBinding jsonIdFromJSON:jsonResult
                                                   forEntity:self.entity
                                                       error:&localError];

    if (localError == nil) {
        [self willChangeValueForKey:@"jsonId"];

        _jsonId = jsonId;

        [self didChangeValueForKey:@"jsonId"];

        [super setJsonResult:jsonResult];
    }
    else {
        _error = localError;
    }
}

#pragma mark - Method Overrides

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return result;
}

@end
