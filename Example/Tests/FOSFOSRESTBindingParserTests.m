//
//  FOSFOSRESTBindingParserTests.m
//  FOSREST
//
//  Created by David Hunt on 3/14/14.
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
#import "FOSRest.h"
#import "FOSAdapterBindingParser.h"

@interface FOSFOSRESTBindingParserTests : XCTestCase

@end

@implementation FOSFOSRESTBindingParserTests

#pragma mark - HEADER_FIELDS

- (void)testHeaderFields_Single {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"HEADER_FIELDS :: { 'x-foo' : 'bar' };\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testHeaderFields_List {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"HEADER_FIELDS :: { 'x-foo' : 'bar'}, {'x-grotz' : 'zap' };\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - Test REQUEST_METHOD

- (void)testRequestMethod_GET {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"REQUEST_METHOD :: GET;\n"
    ;

    NSError *error = nil;
    id result = [parser parseBinding:str error:&error];
    XCTAssertNotNil(result, @"Bad result");
    XCTAssertTrue([result isKindOfClass:[NSNumber class]], @"Bad Type");
    XCTAssertEqual([result unsignedIntegerValue], FOSRequestMethodGET, @"Bad value");
    XCTAssertNil(error, @"Bad error");
}

- (void)testRequestMethod_POST {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"REQUEST_METHOD :: POST;\n"
    ;

    NSError *error = nil;
    id result = [parser parseBinding:str error:&error];
    XCTAssertNotNil(result, @"Bad result");
    XCTAssertTrue([result isKindOfClass:[NSNumber class]], @"Bad Type");
    XCTAssertEqual([result unsignedIntegerValue], FOSRequestMethodPOST, @"Bad value");
    XCTAssertNil(error, @"Bad error");
}

- (void)testRequestMethod_PUT {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"REQUEST_METHOD :: PUT;\n"
    ;

    NSError *error = nil;
    id result = [parser parseBinding:str error:&error];
    XCTAssertNotNil(result, @"Bad result");
    XCTAssertTrue([result isKindOfClass:[NSNumber class]], @"Bad Type");
    XCTAssertEqual([result unsignedIntegerValue], FOSRequestMethodPUT, @"Bad value");
    XCTAssertNil(error, @"Bad error");
}

- (void)testRequestMethod_DELETE {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"REQUEST_METHOD :: DELETE;\n"
    ;

    NSError *error = nil;
    id result = [parser parseBinding:str error:&error];
    XCTAssertNotNil(result, @"Bad result");
    XCTAssertTrue([result isKindOfClass:[NSNumber class]], @"Bad Type");
    XCTAssertEqual([result unsignedIntegerValue], FOSRequestMethodDELETE, @"Bad value");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - Test END_POINT

- (void)testEndPoint_STRING_LITERAL {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: '1/TestCreate';\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testEndPoint_IDENTIFIER {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: $FOO;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testEndPoint_INTEGER_LITERAL {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: 25;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - Property Binding

- (void)testPropertyBinding {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"ATTRIBUTE_BINDINGS :: { 'jsonKey' : 'cmoPropName' } ATTRIBUTES :: ALL ;"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testIdPropertyBinding {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"ATTRIBUTE_BINDINGS :: ID_ATTRIBUTE { 'jsonKey' : 'cmoPropName' } ATTRIBUTES :: ALL ;"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - CMO_BINDING

- (void)testCMOBinding_SINGLE {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"CMO_BINDING ::\n"
        @"ATTRIBUTE_BINDINGS :: { 'key' : 'value' } ATTRIBUTES :: ALL ;\n"
        @"ENTITIES :: ( 'Foo' );"
    @";"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - TIMEOUT_INTERVAL

- (void)testTimeoutInterval {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"TIMEOUT_INTERVAL :: 25;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - REQUEST_FORMAT

- (void)testRequestFormat_JSON {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"REQUEST_FORMAT :: JSON;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testRequestFormat_WEBFORM {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"REQUEST_FORMAT :: WEBFORM;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testRequestFormat_NODATA {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"REQUEST_FORMAT :: NO_DATA;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - Test ENTITIES

- (void)testEntitiesList_SINGLE {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"ENTITIES :: ( 'TestCreate' );\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testEntitiesList_MULTIPLE {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"ENTITIES :: ( 'TestCreate', 'AnotherEntity' );\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testEntitiesList_ALL {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"ENTITIES :: ALL;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testEntitiesList_ALL_EXCEPT {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"ENTITIES :: ALL_EXCEPT ( 'Foo', 'Bar' );\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - Test Expression

- (void)testExpression_STRING_LITERAL {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: 'literal string';\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testExpression_INTEGER_LITERAL {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: 25;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testExpression_IDENTIFIER {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: $FOO;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testExpression_BINARY_EXPRESSION {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: $FOO.method;\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testExpression_CONCAT_EXPRESSION {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: ( 'foo' + 'bar' );\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

- (void)testExpression_Nested_CONCAT_EXPRESSION {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"END_POINT :: ( 'foo' + ('bar' + 'zap' ) );\n"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - Test url_binding

- (void)testURLBinding_Simplest {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"URL_BINDINGS :: URL_BINDING ::\n"
        @"LIFECYCLE :: CREATE ;\n"
        @"END_POINT :: 'http://foo.bar' ;\n"
        @"CMO_BINDING :: $$DUMMY_CMO_BINDING ;\n"
        @"ENTITIES :: ALL ;\n"
    @";"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

#pragma mark - Test url_binding_list

- (void)testURLBindingList_Double {

    FOSAdapterBindingParser *parser = [[FOSAdapterBindingParser alloc] init];

    NSString *str =
    @"URL_BINDINGS ::\n"
        @"URL_BINDING ::\n"
            @"LIFECYCLE :: CREATE ;\n"
            @"END_POINT :: 'http://foo.bar';\n"
            @"CMO_BINDING :: $$DUMMY_CMO_BINDING ;\n"
            @"ENTITIES :: ( 'user' ); \n"
        @"URL_BINDING ::\n"
            @"LIFECYCLE :: CREATE ;\n"
            @"END_POINT :: 'http://foo.bar' ;\n"
            @"CMO_BINDING :: $$DUMMY_CMO_BINDING ;\n"
            @"ENTITIES :: ALL_EXCEPT ( 'user' );\n"
    @";"
    ;

    NSError *error = nil;
    XCTAssertNotNil([parser parseBinding:str error:&error], @"Bad result");
    XCTAssertNil(error, @"Bad error");
}

@end
