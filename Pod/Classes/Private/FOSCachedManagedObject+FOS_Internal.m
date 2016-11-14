//
//  FOSCachedManagedObject+FOS_Internal.m
//  FOSRest
//
//  Created by David Hunt on 12/29/12.
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

#import "FOSCachedManagedObject+FOS_Internal.h"
#import "FOSRESTConfig.h"
#import "FOSREST_Internal.h"

@implementation FOSCachedManagedObject(FOS_Internal)

#pragma mark - Class Methods

+ (NSString *)entityName {
    return [[self entityDescription] name];
}

+ (NSEntityDescription *)entityDescription {
    NSString *entityClass = NSStringFromClass([self class]);
    NSEntityDescription  *result = [[FOSRESTConfig sharedInstance].databaseManager entityDescriptForClassName:entityClass];

    NSAssert(result != nil, @"Unable to find an entity description for entity: %@",
             entityClass);

    return result;
}

- (id)initSkippingReadOnlyCheckAndInsertingIntoMOC:(NSManagedObjectContext *)moc {
    return [super initInsertingIntoManagedObjectContext:moc];
}

@end
