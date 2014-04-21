//
//  FOSParseFileService.m
//  FOSFoundation
//
//  Created by David Hunt on 2/11/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSParseFileService.h"
#import "FOSWebServiceRequest+FOS_Internal.h"

@interface NSString(FOSFileService)

- (NSString *)operation;
- (NSArray *)operationArgs;
- (NSDictionary *)operationFields;

@end

@interface FOSWebServiceRequest(FOSFileService)

- (NSString *)fsEndPoint;

@end

@implementation FOSParseFileService {
    FOSRESTConfig *_restConfig;
    NSMutableDictionary *_classJSON;
}

#pragma mark - FOSProcessServiceRequest

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig {

    if ((self = [super init]) != nil) {
        _restConfig = restConfig;
    }

    return self;
}

- (void)queueRequest:(FOSWebServiceRequest *)request {

    @autoreleasepool {
        id<NSObject> jsonResult = nil;

        switch (request.requestMethod) {
            case FOSRequestMethodGET:
                jsonResult = [self _jsonForGETRequest:request];
                break;

            case FOSRequestMethodPOST:
            case FOSRequestMethodPUT:
                jsonResult = [self _jsonForPOST_PUTRequest:request];
                break;

            case FOSRequestMethodDELETE:
                @throw [NSException exceptionWithName:@"FOSInternal"
                                               reason:@"Deleted not supported"
                                             userInfo:nil];
        }

        [request setJsonResult:jsonResult];
    }
}

#pragma mark - Private Methods

- (id<NSObject>)_jsonForGETRequest:(FOSWebServiceRequest *)request {
    NSString *endPoint = request.fsEndPoint;
    NSArray *args = endPoint.operationArgs;
    NSDictionary *fields = endPoint.operationFields;
    id<NSObject> matchedObjects = nil;
    NSString *operation = endPoint.operation;
    BOOL singletonResult = YES;

    if ([operation isEqualToString:@"classes"]) {
        NSPredicate *pred = nil;

        switch (args.count) {
                // All class entries
            case 1:
                // Do we need to filter the class entries
                pred = [self _predicateForRequest:request];
                singletonResult = NO;
                break;

                // Single class entry via id
            case 2:
                pred = [NSPredicate predicateWithFormat:@"%K == %@", @"objectId", args[2]];
                break;
                
            default:
                @throw [NSException exceptionWithName:@"FOSInternal"
                                               reason:@"Unknown GET request"
                                             userInfo:nil];
        }

        NSArray *classEntries = [self _jsonForClass:args[0]];

        if (pred == nil) {
            matchedObjects = classEntries;
        }
        else {
            matchedObjects = [classEntries filteredArrayUsingPredicate:pred];
        }
    }
    else if ([operation isEqualToString:@"login"]) {
        matchedObjects = [self _jsonForLoginRequest:request];
    }
    else if ([operation isEqualToString:@"users"]) {
        NSString *userObjectId = args[0];

        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"objectId", userObjectId];
        NSArray *users = [[self _jsonForClass:@"_User"] filteredArrayUsingPredicate:pred];

        matchedObjects = users[0];
    }
    else {
        @throw [NSException exceptionWithName:@"FOSInternal"
                                       reason:@"Unknown GET request"
                                     userInfo:nil];
    }

    id<NSObject> result = nil;

    // Match the cardinality of the request
    if (singletonResult) {
        if (matchedObjects == nil) {
            matchedObjects = @{ };
        }

        result = matchedObjects;
    }
    else {
        if (matchedObjects == nil) {
            matchedObjects = @[];
        }

        // Let's see if they wanted a count intead of the full set
        if ([fields[@"count"] isEqualToString:@"1"]) {
            result = @{
                @"results" : @[ ],
                @"count" : @([(NSArray *)matchedObjects count])
            };
        }
        else {
            result = @{ @"results" : matchedObjects };
        }
    }

    return result;
}

- (id<NSObject>)_jsonForPOST_PUTRequest:(FOSWebServiceRequest *)request {
    id<NSObject> result = nil;

    if (
        ([request.fsEndPoint rangeOfString:@"1/events"].location != NSNotFound)
    ) {
        result = @{};
    }
    else if (
        ([request.fsEndPoint rangeOfString:@"1/classes/UserDeviceInfo"].location != NSNotFound)
    ){
        // Just a dummy objectId
        result = @{ @"objectId" : @"wVzlu6c4U3" };
    }
    else {
        @throw [NSException exceptionWithName:@"FOSInternal"
                                       reason:@"Unknown POST_PUT request"
                                     userInfo:nil];
    }

    return result;
}

- (id<NSObject>)_jsonForLoginRequest:(FOSWebServiceRequest *)request {
    id<NSObject> result = nil;

    NSDictionary *fields = request.fsEndPoint.operationFields;
    NSString *username = fields[@"username"];
    NSArray *users = [self _jsonForClass:@"_User"];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", @"username", username];

    result = [users filteredArrayUsingPredicate:pred][0];

    return result;
}

- (NSArray *)_jsonForClass:(NSString *)className {
    NSArray *result = _classJSON[className];

    if (result == nil) {
        if (_classJSON == nil) {
            _classJSON = [NSMutableDictionary dictionaryWithCapacity:100];
        }

        NSURL *classFileURL = [self _fileURLForClass:className];
        if (classFileURL != nil) {
            NSInputStream *stream = [NSInputStream inputStreamWithURL:classFileURL];
            [stream open];

            {
                NSError *error = nil;
                id<NSObject> json = [NSJSONSerialization JSONObjectWithStream:stream
                                                                      options:0
                                                                        error:&error];
                if (error != nil) {
                    @throw [NSException exceptionWithName:@"FOSInternal"
                                                   reason:@"Unable to read JSON file"
                                                 userInfo:nil];
                }

                if (![json isKindOfClass:[NSDictionary class]] ||
                    (((NSDictionary *)json)[@"results"] == nil) ||
                    (![((NSDictionary *)json)[@"results"] isKindOfClass:[NSArray class]])) {
                    @throw [NSException exceptionWithName:@"FOSInternal"
                                                   reason:@"Unknow JSON format"
                                                 userInfo:nil];
                }

                // Strip off the outside dictionary
                _classJSON[className] = ((NSDictionary  *)json)[@"results"];
                result = _classJSON[className];
            }

            [stream close];
        }
        else {
            result = @[];
        }
    }

    return result;
}

- (NSURL *)_fileURLForClass:(NSString *)className {
    NSBundle *mainBundle = [NSBundle mainBundle];

    NSURL *result = [mainBundle URLForResource:className withExtension:@"json"];

    return result;
}

- (NSPredicate *)_predicateForRequest:(FOSWebServiceRequest *)request {
    NSPredicate *result = nil;

    // where={"user" : { "__type" : "Pointer", "className" : "_User", "objectId" : "wVzlu6c4Ua" }
    NSString *whereClause = request.fsEndPoint.operationFields[@"where"];
    if (whereClause != nil) {
        NSData *data = [whereClause dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error = nil;
        NSDictionary *whereJson = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:0
                                                                    error:&error];
        if (error != nil || ![whereJson isKindOfClass:[NSDictionary class]]) {
            @throw [NSException exceptionWithName:@"FOSInternal"
                                           reason:@"Error decoding whereClause JSON"
                                         userInfo:nil];
        }

        result = [self _predicateForWhereJSON:whereJson withScopeKey:nil];
    }

    return result;
}

- (NSPredicate *)_predicateForWhereJSON:(NSDictionary *)whereJson
                           withScopeKey:(NSString *)scopeKey {
    NSPredicate *result = nil;

    NSMutableArray *preds = [NSMutableArray arrayWithCapacity:10];

    for (NSString *key in whereJson.allKeys) {
        NSDictionary *valueJson = whereJson[key];
        BOOL valueIsDictionary = [valueJson isKindOfClass:[NSDictionary class]];
        BOOL valueIsPointer = valueIsDictionary && valueJson[@"objectId"];
        BOOL valueIsNumber = [valueJson isKindOfClass:[NSNumber class]];
//        BOOL valueIsSubQuery = !valueIsPointer && !valueIsNumber;

        NSString *predKey = [NSString stringWithFormat:@"%@%@%@",
                             scopeKey == nil ? @"" : [NSString stringWithFormat:@"%@.", scopeKey],
                             key,
                             valueIsPointer ? @".objectId" : @""];

        NSPredicate *pred = nil;

        if (valueIsNumber) {
            pred = [NSPredicate predicateWithFormat:@"%K == %@",
                    predKey, valueJson];
        }
        else if (valueIsDictionary) {
            // Pointer match
            if (valueIsPointer) {
                NSString *value = valueJson[@"objectId"];

                if (![value isKindOfClass:[NSString class]]) {
                    @throw [NSException exceptionWithName:@"FOSInternal"
                                                   reason:@"Unknown query pointer format"
                                                 userInfo:nil];
                }

                pred = [NSPredicate predicateWithFormat:@"%K == %@",
                        predKey, value];
            }

            // $inQuery/$notInQuery match
            else if (valueJson[@"$inQuery"] != nil || valueJson[@"$notInQuery"] != nil) {
                BOOL inQuery = (valueJson[@"$inQuery"] != nil);

                NSDictionary *subQuery = inQuery
                    ? valueJson[@"$inQuery"]
                    : valueJson[@"$notInQuery"];

                NSDictionary *subWhereJson = subQuery[@"where"];
                pred = [self _predicateForWhereJSON:subWhereJson
                                       withScopeKey:predKey];

                if (!inQuery) {
                    pred = [NSCompoundPredicate notPredicateWithSubpredicate:pred];
                }
            }

            // $in/$nin match
            else if (valueJson[@"$in"] != nil || valueJson[@"$nin"] != nil) {
                BOOL isIn = (valueJson[@"$in"] != nil);
                NSArray *valueArray = isIn
                    ? valueJson[@"$in"]
                    : valueJson[@"$nin"];

                pred = [NSPredicate predicateWithFormat:@"%K IN %@",
                        predKey, valueArray];

                if (!isIn) {
                    pred = [NSCompoundPredicate notPredicateWithSubpredicate:pred];
                }
            }
            else {
                @throw [NSException exceptionWithName:@"FOSInternal"
                                               reason:@"Unknown predicate value query"
                                             userInfo:nil];
            }

        }

        [preds addObject:pred];
    }

    if (preds.count > 1) {
        result = [NSCompoundPredicate andPredicateWithSubpredicates:preds];
    }
    else {
        result = preds.lastObject;
    }

    return  result;
}

@end

@implementation NSString (FOSFileService)

- (NSString *)operation {
    NSString *result = nil;

    // "1/operation/operationArg1/operationArg2/.../?operationField1_Key=operationField1_value&..."
    NSArray *comps = [self._lhs componentsSeparatedByString:@"/"];

    if (comps.count >= 2) {
        result = comps[1];
    }
    else {
        @throw [NSException exceptionWithName:@"FOSInternal"
                                       reason:@"Unknown operation"
                                     userInfo:nil];
    }

    return result;
}

- (NSArray *)operationArgs {
    NSArray *result = nil;

    // "1/operation/operationArg1/operationArg2/.../?operationField1_Key=operationField1_value&..."
    NSArray *comps = [self._lhs componentsSeparatedByString:@"/"];

    // Skip '1' & 'operation'
    if (comps.count >= 2) {
        result = [comps subarrayWithRange:NSMakeRange(2, comps.count - 2)];
    }

    return result;
}

- (NSDictionary *)operationFields {
    NSDictionary *result = nil;

    // "1/operation/operationArg1/operationArg2/.../?operationField1_Key=operationField1_value&..."
    NSArray *comps = [self._rhs componentsSeparatedByString:@"&"];

    if (comps.count > 0) {
        NSMutableDictionary *fields = [NSMutableDictionary dictionaryWithCapacity:comps.count];
        for (NSString *nextComp in comps) {
            NSArray *fieldComps = [nextComp componentsSeparatedByString:@"="];

            [fields setObject:fieldComps[1] forKey:fieldComps[0]];
        }

        result = fields;
    }

    return result;
}

#pragma mark - Private Methods

- (NSString *)_lhs {
    NSString *result = self;

    NSRange qmarkRange = [self rangeOfString:@"?"];
    if (qmarkRange.location != NSNotFound) {
        result = [self substringToIndex:qmarkRange.location];
    }

    return result;
}

- (NSString *)_rhs {
    NSString *result = nil;

    NSRange qmarkRange = [self rangeOfString:@"?"];
    if (qmarkRange.location != NSNotFound) {
        result = [self substringFromIndex:qmarkRange.location + 1];
    }

    return result;
}

@end

@implementation FOSWebServiceRequest(FOSFileService)

- (NSString *)fsEndPoint {
    NSURL *requestURL = self.url;
    NSString *path = [requestURL.path substringFromIndex:1];
    NSString *query = requestURL.query;
    NSString *result = [[NSString stringWithFormat:@"%@%@%@",
                           path,
                           query.length > 0 ? @"?" : @"",
                           query.length > 0 ? query : @""] stringByRemovingPercentEncoding];

    return result;
}

@end
