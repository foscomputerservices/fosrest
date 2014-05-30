//
//  FOSBindingParser.m
//  FOSFoundation
//
//  Created by David Hunt on 3/14/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSAdapterBindingParser.h"
#import "Bison.h"

// externed from FOSBinding.ym
FOSAdapterBinding *parsedAdapterBinding;
id parsedBinding;

@implementation FOSAdapterBindingParser

+ (FOSAdapterBinding *)parseAdapterBinding:(NSString *)binding error:(NSError **)error {
    NSError *localError = nil;
    if (error != nil) { *error = nil; }

    FOSAdapterBinding *result = [self _parse:binding error:&localError];

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

    if (error != nil) { *error = nil; }

    // Reset global var to bison parser
    parsedAdapterBinding = nil;
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
                if (error != nil) {
                    *error = parser_error;
                }

                result = NO;
            }
        }
        @catch (NSException* exception) {
            NSString *msg = exception.description;

            *error = [NSError errorWithMessage:msg];
        }
    }

    if (*error == nil) {
        if (parsedAdapterBinding != nil) {
            result = parsedAdapterBinding;
        }
        else if (parsedBinding != nil) {
            result = parsedBinding;
        }
    }

    // Reset global var to bison parser
    parsedAdapterBinding = nil;

    return result;
}

@end
