//
//  FOSDeletedObject+FOS_Internal.m
//  FOSREST
//
//  Created by David Hunt on 9/17/13.
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

#import "FOSDeletedObject+FOS_Internal.h"
#import "FOSREST_Internal.h"

@implementation FOSDeletedObject (FOS_Internal)

+ (BOOL)existsDeletedObjectWithId:(FOSJsonId)jsonId andType:(Class)type {
    NSParameterAssert(jsonId != nil);
    NSParameterAssert(type != nil);

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"deletedJsonId = %@ && deletedEntityName == %@",
                         jsonId, [NSEntityDescription entityNameForClass:type]];

    NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;

    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"FOSDeletedObject"];
    fetchReq.predicate = pred;

    NSError *error = nil;
    NSUInteger matchCount = [moc countForFetchRequest:fetchReq error:&error];
    if (matchCount == NSNotFound) {
        NSException *e = [NSException exceptionWithName:@"FOSDeletedObjectError"
                                                 reason:error.description
                                               userInfo:@{ @"error" : error }];
        @throw e;
    }

    return matchCount > 0;
}

@end
