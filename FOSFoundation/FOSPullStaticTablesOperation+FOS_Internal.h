//
//  FOSPullStaticTablesOperation+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 12/27/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSPullStaticTablesOperation.h"

@interface FOSPullStaticTablesOperation ()

#pragma mark - Testing Only!

+ (void)_initStaticTablesList:(BOOL)resetTables managedObjectContext:(NSManagedObjectContext *)moc;

@end
