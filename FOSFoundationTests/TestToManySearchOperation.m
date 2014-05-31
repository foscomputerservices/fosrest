//
//  TestToManySearchOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "TestToManySearchOperation.h"
#import "TestToMany+VBM.h"

@implementation TestToManySearchOperation
- (Class)managedClass {
    return [TestToMany class];
}

- (NSSet *)dependentSearchOperations {
    NSParameterAssert(self.uid != nil);
    NSParameterAssert(self.testType == nil || self.testType.length > 0);

    NSMutableSet *result = [NSMutableSet setWithCapacity:2];
    NSEntityDescription *entity = [self.managedClass entityDescription];
    NSError *localError = nil;

    // DSLQQUERY = where={"user" : {"__type" : "Pointer", "className" : "_User", "objectId" : "EcpQ2bE3fx"}}
    NSString *dslQuery = nil;

    if (self.uid != nil) {
        dslQuery = [NSString stringWithFormat:@"where={ \"user\" : {\"__type\" : \"Pointer\", \"className\" : \"_User\", \"objectId\" : \"%@\"}%@ }", self.uid,
                    self.testType == nil
                    ? @"" :
                    [NSString stringWithFormat:@", \"testType\" : \"%@\"", self.testType]];
    }

    FOSURLBinding *urlBinding =
        [self.restAdapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecords
                                    forLifecycleStyle:nil
                                      forRelationship:nil
                                            forEntity:entity];
    NSURLRequest *urlRequest = [urlBinding urlRequestServerRecordOfType:entity
                                                           withDSLQuery:dslQuery
                                                                  error:&localError];
    if (localError == nil) {
        FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                      forURLBinding:urlBinding];

        FOSOperation *procOp = [self processSearchResults:request];

        [result addObject:procOp];
    }

    return result;
}

@end
