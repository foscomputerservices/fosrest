//
//  FOSRelationshipFault+FOS_Internal.m
//  FOSRest
//
//  Created by David Hunt on 4/19/13.
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

#import "FOSRelationshipFault+FOS_Internal.h"

@implementation FOSRelationshipFault (FOS_Internal)

+ (NSPredicate *)predicateForEntity:(NSEntityDescription *)entity
                             withId:(FOSJsonId)jsonId
               forRelationshipNamed:(NSString *)relName {

    NSParameterAssert(entity != nil);
    NSParameterAssert(jsonId != nil);

    NSPredicate *result = nil;
    if (relName.length > 0) {
        result = [NSPredicate predicateWithFormat:@"jsonId == %@ && managedObjectClassName == %@ && relationshipName == %@",
                  jsonId, entity.name, relName];
    }
    else {
        result = [NSPredicate predicateWithFormat:@"jsonId == %@ && managedObjectClassName == %@",
                  jsonId, entity.name];
    }

    return result;
}

+ (NSPredicate *)predicateForInstance:(FOSCachedManagedObject *)cmo
               forRelationshipNamed:(NSString *)relName {

    NSParameterAssert(cmo != nil);
    NSParameterAssert(cmo.jsonIdValue != nil);

    NSString *jsonId = (NSString *)cmo.jsonIdValue;

    NSPredicate *result = [self predicateForEntity:cmo.entity
                                            withId:jsonId
                              forRelationshipNamed:relName];

    return result;
}

@end
