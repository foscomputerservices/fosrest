//
//  WidgetSearchOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "WidgetSearchOperation.h"
#import "Widget.h"

@implementation WidgetSearchOperation {
    NSError *_error;
}

- (Class)managedClass {
    return [Widget class];
}

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return result;
}

- (NSSet *)dependentSearchOperations {
    NSParameterAssert(self.name != nil ||
                      self.uid != nil);

    NSMutableSet *result = [NSMutableSet setWithCapacity:2];
    NSEntityDescription *entity = [self.managedClass entityDescription];
    NSError *localError = nil;

    // DSLQUERY = {"user" : {"__type" : "Pointer", "className" : "_User", "objectId" : "EcpQ2bE3fx"}}
    NSMutableString *dslQuery = [NSMutableString stringWithString:@"{"];
    if (self.uid != nil) {
        [dslQuery appendFormat:@"{ \"user\" : {\"__type\" : \"Pointer\", \"className\" : \"_User\", \"objectId\" : \"%@\"} }", self.uid];
    }
    else {
        [dslQuery appendFormat:@"%@\"name\" : \"%@\"",
         self.uid == nil ? @"" : @", ",
         self.name];
    }

    [dslQuery appendString:@"}"];

    FOSURLBinding *urlBinding = [self.restAdapter
                                 urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecords
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
