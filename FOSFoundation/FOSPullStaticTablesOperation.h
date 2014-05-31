//
//  FOSPullStaticTablesOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 4/23/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

@interface FOSPullStaticTablesOperation : FOSOperation

#pragma mark - Initialization Methods

- (id)initResettingProcessedTables:(BOOL)resetTables;

#pragma mark - Public Methods

- (void)commitProcessedTables;
- (void)rollbackProcessedTables;

@end
