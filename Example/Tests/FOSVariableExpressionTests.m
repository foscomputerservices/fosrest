//
//  FOSVariableExpressionTests.m
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FOSFoundation/FOSVariableExpression.h>
#import <FOSFoundation/FOSDatabaseManager.h>
#import <FOSFoundation/NSEntityDescription+FOS.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"

@interface FOSVariableExpressionTests : XCTestCase

@end

@implementation FOSVariableExpressionTests

SETUP_TEARDOWN_NOLOGIN

- (void)testVariable_CMO {
    TestCreate *cmo = [[TestCreate alloc] init];

    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"CMO"];
    NSDictionary *context = @{ @"CMO" : cmo };
    id expectedResult = cmo;

    NSError *error = nil;
    XCTAssertTrue([[expr evaluateWithContext:context error:&error] isEqual:expectedResult],
                  @"Bad result");
    XCTAssertNil(error, @"error not nil?");
}

- (void)testVariable_BadCMO {
    NSNumber *cmo = @(42);

    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"CMO"];
    NSDictionary *context = @{ @"CMO" : cmo };

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:context error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error nil?");
}

- (void)testVariable_CMOID {
    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *jsonIdValue = @"__test123__";
    cmo.jsonIdValue = jsonIdValue;

    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"CMOID"];
    NSDictionary *context = @{ @"CMO" : cmo };
    id expectedResult = jsonIdValue;

    NSError *error = nil;
    XCTAssertTrue([[expr evaluateWithContext:context error:&error] isEqual:expectedResult],
                  @"Bad result");
    XCTAssertNil(error, @"error not nil?");
}

- (void)testVariable_OWNERID {
    NSString *userIdValue = @"__user123";
    User *testUser = [[User alloc] init];
    testUser.jsonIdValue = userIdValue;

    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *jsonIdValue = @"__test123__";
    cmo.jsonIdValue = jsonIdValue;
    cmo.user = testUser;

    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"OWNERID"];
    NSDictionary *context = @{ @"CMO" : cmo };
    id expectedResult = userIdValue;

    NSError *error = nil;
    XCTAssertTrue([[expr evaluateWithContext:context error:&error] isEqual:expectedResult],
                  @"Bad result");
    XCTAssertNil(error, @"error not nil?");
}

- (void)testVariable_ATTRDESC {
    NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"TestCreate" inManagedObjectContext:moc];
    NSPropertyDescription *propDesc = [entityDesc properties].firstObject;

    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"ATTRDESC"];
    NSDictionary *context = @{ @"ATTRDESC" : propDesc };
    id expectedResult = propDesc;

    NSError *error = nil;
    XCTAssertTrue([[expr evaluateWithContext:context error:&error] isEqual:expectedResult],
                  @"Bad result");
    XCTAssertNil(error, @"error not nil?");
}

- (void)testVariable_BadATTRDESC {
    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"ATTRDESC"];
    NSDictionary *context = @{ @"ATTRDESC" : @(42) };

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:context error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error not nil?");
}

- (void)testVariable_MissingATTRDESC {
    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"ATTRDESC"];
    NSDictionary *context = @{ };

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:context error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error not nil?");
}

- (void)testVariable_RELDESC {
    NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"TestCreate" inManagedObjectContext:moc];
    NSPropertyDescription *relDesc = entityDesc.cmoRelationships.anyObject;

    NSAssert(relDesc != nil, @"Test is broken!");

    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"RELDESC"];

    NSDictionary *context = @{ @"RELDESC" : relDesc };
    id expectedResult = relDesc;

    NSError *error = nil;
    XCTAssertTrue([[expr evaluateWithContext:context error:&error] isEqual:expectedResult],
                  @"Bad result");
    XCTAssertNil(error, @"error not nil?");
}

- (void)testVariable_BadRELDESC {
    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"RELDESC"];
    NSDictionary *context = @{ @"ATTRDESC" : @(42) };

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:context error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error not nil?");
}

- (void)testVariable_MissingRELDESC {
    id<FOSExpression> expr = [FOSVariableExpression variableExpressionWithIdentifier:@"RELDESC"];
    NSDictionary *context = @{ };

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:context error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error not nil?");
}

- (void)testVariable_UnknownVar_WithContext {
    FOSVariableExpression *expr =
        [FOSVariableExpression variableExpressionWithIdentifier:@"--Unknown Var--"];
    NSDictionary *context = @{ };

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:context error:&error], @"Expected nil result");
    XCTAssertNotNil(error, @"error not nil?");
}

- (void)testVariable_UnknownVar_WithoutContext {
    FOSVariableExpression *expr =
        [FOSVariableExpression variableExpressionWithIdentifier:@"--Unknown Var--"];

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:nil error:&error], @"Expected nil result");
    XCTAssertNotNil(error, @"error not nil?");
}

@end
