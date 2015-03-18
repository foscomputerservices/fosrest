//
//  FOSSendRelationshipOperation.m
//  FOSREST
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

#import <FOSSendRelationshipOperation.h>
#import "FOSREST_Internal.h"

@implementation FOSSendRelationshipOperation {
    NSManagedObjectID *_cmoID;
}

#pragma mark - Class Methods

+ (instancetype)operationForCMO:(FOSCachedManagedObject *)cmo
                forRelationship:(NSRelationshipDescription *)relDesc
                  parentSentIDs:(NSSet *)parentSentIDs {

    return [[self alloc] initWithCMO:cmo forRelationship:relDesc parentSentIDs:parentSentIDs];
}

#pragma mark - Property Overides

- (FOSCachedManagedObject *)cmo {
    return (FOSCachedManagedObject *)[self.managedObjectContext objectWithID:_cmoID];
}

#pragma mark - Initialization methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
  forRelationship:(NSRelationshipDescription *)relDesc
    parentSentIDs:(NSSet *)parentSentIDs {
    if ((self = [super init]) != nil) {
        _cmoID = cmo.objectID;
        _relDesc = relDesc;
        _parentSentIDs = parentSentIDs;
    }
    
    return self;
}

@end
