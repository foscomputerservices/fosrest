//
//  FOSAttributeBindingTests.m
//  FOSREST
//
//  Created by David Hunt on 3/17/14.
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

#import <XCTest/XCTest.h>
#import "FOSRESTTests.h"
#import "TestCreate.h"

@interface FOSAttributeBindingTests : XCTestCase

@end

@implementation FOSAttributeBindingTests

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Test Property Settings

- (void)testSimpleCMOToJSON {
    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *cmoKeyPath = @"objectId";
    id<FOSExpression> cmoKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:cmoKeyPath];
    NSPropertyDescription *cmoPropDesc = cmo.entity.propertiesByName[@"objectId"];

    NSAssert(cmoPropDesc != nil, @"Broken test!");

    NSString *originalJsonId = @"originalJsonId";
    cmo.jsonIdValue = originalJsonId;

    NSString *jsonKeyPath = @"jsonId";
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    id<FOSExpression> jsonKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:jsonKeyPath];

    FOSAttributeBinding *propBinding = [[FOSAttributeBinding alloc] init];
    propBinding.jsonKeyExpression = jsonKeyPathExpr;
    propBinding.cmoKeyPathExpression = cmoKeyPathExpr;
    propBinding.attributeMatcher = [FOSItemMatcher matcherMatchingAllItems];

    NSString *expectedResult = originalJsonId;

    NSError *error = nil;
    XCTAssertTrue([propBinding updateJSON:json fromCMO:cmo forProperty:cmoPropDesc forLifecyclePhase:FOSLifecyclePhaseCreateServerRecord error:&error],
                  @"Bad result");
    XCTAssertTrue([json[jsonKeyPath] isEqualToString:expectedResult], @"Bad result");
}

- (void)testSimpleJSONToCMO {
    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *cmoKeyPath = @"objectId";
    id<FOSExpression> cmoKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:cmoKeyPath];
    NSPropertyDescription *cmoPropDesc = cmo.entity.propertiesByName[@"objectId"];

    NSAssert(cmoPropDesc != nil, @"Broken test!");

    NSString *originalJsonId = @"originalJsonId";

    NSString *jsonKeyPath = @"jsonId";
    NSDictionary *json = @{ jsonKeyPath : originalJsonId };
    id<FOSExpression> jsonKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:jsonKeyPath];

    FOSAttributeBinding *propBinding = [[FOSAttributeBinding alloc] init];
    propBinding.cmoKeyPathExpression = cmoKeyPathExpr;
    propBinding.jsonKeyExpression = jsonKeyPathExpr;
    propBinding.attributeMatcher = [FOSItemMatcher matcherMatchingAllItems];

    NSString *expectedResult = originalJsonId;

    NSError *error = nil;
    XCTAssertTrue([propBinding updateCMO:cmo fromJSON:json forProperty:cmoPropDesc error:&error],
                  @"Bad result");
    XCTAssertTrue([[cmo valueForKeyPath:cmoKeyPath] isEqualToString:expectedResult], @"Bad result");
}

@end
