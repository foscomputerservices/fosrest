//
//  FOSSendToManyRelationshipOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
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

#import <FOSSendToManyRelationshipOperation.h>
#import "FOSFoundation_Internal.h"

@implementation FOSSendToManyRelationshipOperation

#pragma mark - Initialization Methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc
    parentSentIDs:(NSSet *)parentSentIDs {
    if ((self = [super initWithCMO:cmo forRelationship:relDesc parentSentIDs:parentSentIDs]) != nil) {

        id<NSFastEnumeration> relatedCMOs = [cmo primitiveValueForKey:relDesc.name];
        if (relatedCMOs != nil) {

            for (FOSCachedManagedObject *relatedCMO in relatedCMOs) {

                if (![parentSentIDs containsObject:relatedCMO.objectID] &&
                    !relatedCMO.isLocalOnly) {
                    FOSSendServerRecordOperation *sendOp =
                        [relatedCMO sendServerRecordWithLifecycleStyle:nil parentSentIDs:parentSentIDs];

                    [self addDependency:sendOp];
                }
            }
        }
    }

    return self;
}

@end
