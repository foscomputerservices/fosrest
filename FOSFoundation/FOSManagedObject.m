//
//  FOSManagedObject.m
//
//  Created by David Hunt on 9/27/11.
//  Copyright 2011 FOS Computer Services. All rights reserved.
//

#import "FOSManagedObject.h"
#import "FOSRESTConfig.h"
#import "NSDate+FOS.h"
#import "FOSDatabaseManager.h"

@implementation FOSManagedObject {
    BOOL _insideWillSave;
}

#pragma mark - Properties

@dynamic createdAt;
@dynamic lastModifiedAt;

#pragma mark - Property Overrides

- (BOOL)willSaveHasRecursed {
    return _insideWillSave;
}

- (BOOL)isReadOnly {
    BOOL result =
        (self.entity.jsonIsStaticTableEntity &&
         ![FOSRESTConfig sharedInstance].allowStaticTableModifications);

    return result;
}

#pragma mark - Initialization methods

- (id)init {
    NSManagedObjectContext *ctxt = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;
    NSAssert(ctxt != nil, @"No context???");

    NSString *entityName = NSStringFromClass([self class]);
    NSEntityDescription *desc = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:ctxt];

    if (desc == nil) {
        NSString *msg = NSLocalizedString(@"Entity %@ is missing from the managed object model", @"");

        [NSException raise:@"FOSMissing_EntityInModel" format:msg, entityName];
    }

    self = [self initWithEntity:desc insertIntoManagedObjectContext:ctxt];

    return self;
}

#pragma mark - NSCopying methods

- (id)copyWithZone:(NSZone *)zone {
    FOSManagedObject *result = [[[self class] allocWithZone:zone] init];

    return result;
}

#pragma mark - Overrides

- (void)willSave {

    // Avoid infinite recursion
    if (!_insideWillSave) {
        _insideWillSave = YES;

        if (!self.isReadOnly) {
            // We'll store all dates in the DB as utc
            NSDate *utcNow = [NSDate utcDate];
            BOOL changes = self.hasChanges;
            
            if (changes) {
                [self setValue:utcNow forKey:@"lastModifiedAt"];
            }
            
            // If we don't already have a createdAt value, then we're
            // brand spankin' new!
            if (![self primitiveValueForKey:@"createdAt"]) {
                [self setValue:utcNow forKey:@"createdAt"];
            }
        }
    }

    [super willSave];
}

- (void)didSave {
    [super didSave];

    // We're done saving
    _insideWillSave = NO;
}

@end
