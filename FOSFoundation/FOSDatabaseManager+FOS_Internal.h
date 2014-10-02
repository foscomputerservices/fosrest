//
//  FOSDatabaseManager+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 10/2/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

@interface FOSDatabaseManager (FOS_Internal)

/*!
 * @method resetDatabase
 *
 * Completely resets the database and the connection to it by the following
 * steps:
 *
 *   1) Closes the existing connection
 *   2) Deletes the existing database
 *   3) Creates a new database
 *   4) Opens a new connection to the new database
 */
- (void)resetDatabase;

@end