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

- (NSString *)dslQuery {
    NSParameterAssert(self.uid != nil);
    NSParameterAssert(self.testType == nil || self.testType.length > 0);

    // DSLQQUERY = where={"user" : {"__type" : "Pointer", "className" : "_User", "objectId" : "EcpQ2bE3fx"}}
    NSString *result = nil;

    if (self.uid != nil) {
        result = [NSString stringWithFormat:@"{ \"user\" : {\"__type\" : \"Pointer\", \"className\" : \"_User\", \"objectId\" : \"%@\"}%@ }", self.uid,
                    self.testType == nil
                    ? @"" :
                    [NSString stringWithFormat:@", \"testType\" : \"%@\"", self.testType]];
    }

    return result;
}

@end
