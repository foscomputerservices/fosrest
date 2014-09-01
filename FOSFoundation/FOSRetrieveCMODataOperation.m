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
    FOSJsonId _jsonId;
}

@synthesize entity = _entity;

#pragma mark - Class Methods

+ (instancetype)retrieveDataOperationForEntity:(NSEntityDescription *)entity
                                   withRequest:(NSURLRequest *)request
                                 andURLBinding:(FOSURLBinding *)urlBinding {
    NSParameterAssert(entity != nil);
    NSParameterAssert(request != nil);
    NSParameterAssert(urlBinding != nil);

    return [[self alloc] initWithEntity:entity withRequest:request andURLBinding:urlBinding];
}

#pragma mark - Initialization Methods

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

#pragma mark - Property Overrides
- (FOSJsonId)jsonId {
    if (_jsonId == nil && self.jsonResult != nil) {
        id<FOSRESTServiceAdapter> adapter = self.restConfig.restServiceAdapter;

        // http://fosmain.foscomputerservices.com:8080/browse/FF-8
        FOSURLBinding *urlBinding =
            [adapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecord
                                  forLifecycleStyle:nil
                                 forRelationship:nil
                                       forEntity:self.entity];

        FOSJsonId jsonId = nil;
        NSError *localError = nil;

        NSDictionary *context = @{ @"ENTITY" : self.entity };

        id<NSObject> unwrappedJson = [urlBinding unwrapJSON:self.jsonResult
                                                    context:context
                                                      error:&localError];
        if (localError == nil) {
            jsonId = [urlBinding.cmoBinding jsonIdFromJSON:unwrappedJson
                                                       forEntity:self.entity
                                                           error:&localError];
        }

        if (localError == nil) {
            _jsonId = jsonId;

        }
        else {
            [self willChangeValueForKey:@"error"];
            _error = localError;
            [self didChangeValueForKey:@"error"];
        }
    }

    return _jsonId;
}

- (NSString *)dslQuery {
    return nil;
}

- (BOOL)mergeResults {
    return NO;
}

#pragma mark - Method Overrides

- (void)setOriginalJsonResult:(id<NSObject>)jsonResult
                postProcessor:(FOSRequestPostProcessor)postProcessor {
    [self willChangeValueForKey:@"jsonId"];

    [super setOriginalJsonResult:jsonResult postProcessor:postProcessor];

    [self didChangeValueForKey:@"jsonId"];
}

@end
