//
//  FOSManagedObject+FOS_Internal.m
//  FOSREST
//
//  Created by David Hunt on 1/5/13.
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

#import "FOSManagedObject+FOS_Internal.h"
#import "FOSREST_Internal.h"

@implementation FOSManagedObject (FOS_Internal)

+ (NSEntityDescription *)entityDescriptionInManagedObjectContext:(NSManagedObjectContext *)moc {

    NSEntityDescription *result = [NSEntityDescription insertNewObjectForEntityForName:[NSEntityDescription entityNameForClass:self]
                                                                inManagedObjectContext:moc];
    if (result != nil) {
        result.managedObjectClassName = NSStringFromClass(self);
        result.properties = [self _properties];

        result.abstract = YES;
    }

    return result;
}

#pragma mark - Private Methods

+ (NSArray *)_properties {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:5];

    // Property: createdAt
    NSAttributeDescription *createdAt = [[NSAttributeDescription alloc] init];
    createdAt.indexed = NO;
    createdAt.name = @"createdAt";
    createdAt.optional = YES;
    createdAt.attributeType = NSDateAttributeType;
    [result addObject:createdAt];

    // Property: lastModifiedAT
    NSAttributeDescription *lastModifiedAt = [[NSAttributeDescription alloc] init];
    lastModifiedAt.indexed = NO;
    lastModifiedAt.name = @"lastModifiedAt";
    lastModifiedAt.optional = YES;
    lastModifiedAt.attributeType = NSDateAttributeType;
    [result addObject:lastModifiedAt];

    // Property: updatedWithServerAt
    NSAttributeDescription *updatedWithServerAt = [[NSAttributeDescription alloc] init];
    updatedWithServerAt.indexed = NO;
    updatedWithServerAt.name = @"updatedWithServerAt";
    updatedWithServerAt.optional = YES;
    updatedWithServerAt.attributeType = NSDateAttributeType;
    [result addObject:updatedWithServerAt];

    return result;
}

@end
