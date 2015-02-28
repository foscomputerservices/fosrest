//
//  FOSRetrieveCMODataOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
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

#import <FOSRetrieveCMODataOperation.h>
#import "FOSFoundation_Internal.h"

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
