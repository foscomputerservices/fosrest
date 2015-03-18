//
//  FOSAdapterBindingParser.m
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

#import <FOSAdapterBindingParser.h>
#import "Bison.h"
#import "FOSREST_Internal.h"

// externed from FOSBinding.ym
extern id<FOSRESTServiceAdapter> parsedServiceAdapter;
extern id parsedBinding;

@implementation FOSAdapterBindingParser

+ (FOSAdapterBinding *)parseAdapterBinding:(NSString *)binding
                                forAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                                     error:(NSError **)error {
    NSParameterAssert(binding != nil);
    NSParameterAssert(serviceAdapter != nil);

    NSError *localError = nil;
    if (error != nil) { *error = nil; }

    // Hand off adapter to bind into AST
    parsedServiceAdapter = serviceAdapter;

    FOSAdapterBinding *result = [self _parse:binding error:&localError];

    // We're done with it now, so let it go
    parsedServiceAdapter = nil;

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }
        result = nil;
    }

    return result;
}

#ifdef DEBUG
- (id)parseBinding:(NSString *)str error:(NSError **)error {
    NSError *localError = nil;
    if (error != nil) { *error = nil; }

    id result = [[self class] _parse:str error:&localError];

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }
        result = nil;
    }

    return result;
}
#endif


#pragma mark - Private Methods

NSError *parser_error = nil;

+ (FOSAdapterBinding *)_parse:(NSString *)input error:(NSError **)error {
    NSParameterAssert(error != nil);
    FOSAdapterBinding *result = nil;

    *error = nil;

    // Reset global var to bison parser
    parsedBinding = nil;

    @synchronized(self) {

        const char *inputStr = [input cStringUsingEncoding:NSASCIIStringEncoding];
        size_t strLen = strlen(inputStr);

        // Need writble & double \0
        NSMutableData *dataBuf = [NSMutableData dataWithCapacity:strLen + 1];
        [dataBuf appendBytes:inputStr length:strLen];
        char *null = "\0";
        [dataBuf appendBytes:null length:1];

        @try {
            YY_BUFFER_STATE buf;
            buf = yy_scan_string(dataBuf.bytes);

            yyreset_state();
            yypush_buffer_state(buf);

            parser_error = nil;

            yyparse();

            yy_delete_buffer(buf);

            if (parser_error != nil) {
                *error = parser_error;

                result = nil;
            }
        }
        @catch (NSException* exception) {
            NSString *msg = exception.description;

            *error = [NSError errorWithMessage:msg];
        }
    }

    if (*error == nil) {
        result = [FOSAdapterBindingParser capturedParsedAdapterBinding];
        if (result == nil && parsedBinding != nil) {
            result = parsedBinding;
        }
    }

    return result;
}

@end
