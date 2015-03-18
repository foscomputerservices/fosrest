//
//  FOSCMOBindingTests.m
//  FOSREST
//
//  Created by David Hunt on 3/18/14.
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

@interface FOSCMOBindingTests : XCTestCase

@end

@implementation FOSCMOBindingTests

SETUP_TEARDOWN_NOLOGIN

- (void)testSimpleCMOToJSONBinding {
    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *objectId = @"__objectId";
    NSString *name = @"a name";
    cmo.objectId = objectId;
    cmo.name = name;

    FOSAttributeBinding *binding1 = [[FOSAttributeBinding alloc] init];
    binding1.jsonKeyExpression = [FOSConstantExpression constantExpressionWithValue:@"jsonId"];
    binding1.cmoKeyPathExpression = [FOSConstantExpression constantExpressionWithValue:@"objectId"];
    FOSConstantExpression *expr = [FOSConstantExpression constantExpressionWithValue:@"objectId"];
    binding1.attributeMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    FOSAttributeBinding *binding2 = [[FOSAttributeBinding alloc] init];
    binding2.jsonKeyExpression = [FOSConstantExpression constantExpressionWithValue:@"name"];
    binding2.cmoKeyPathExpression = [FOSConstantExpression constantExpressionWithValue:@"name"];
    expr = [FOSConstantExpression constantExpressionWithValue:@"name"];
    binding2.attributeMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    FOSCMOBinding *cmoBinding = [[FOSCMOBinding alloc] init];
    cmoBinding.entityMatcher = [FOSItemMatcher matcherMatchingAllItems];
    cmoBinding.attributeBindings = [NSSet setWithObjects:binding1, binding2, nil];

    NSDictionary *expectedResults = @{
                                      @"jsonId" : objectId,
                                      @"name" : name
                                      };

    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    NSError *error = nil;

    XCTAssertTrue([cmoBinding updateJson:json
                                 fromCMO:cmo
                       forLifecyclePhase:FOSLifecyclePhaseCreateServerRecord
                                   error:&error], @"Bad result");
    XCTAssertTrue([json isEqual:expectedResults], @"Bad results");
}

@end
