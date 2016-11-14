//
//  FOSDatabaseManager+FOS_Internal.h
//  FOSRest
//
//  Created by David Hunt on 10/2/14.
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

#import <FOSDatabaseManager.h>

@interface FOSDatabaseManager (FOS_Internal)

/*!
 * @property mainThreadMOC
 *
 * Returns the MOC for the main thread.
 *
 * NOTE: Calling this method is not locked and may return null.  However, an implementation
 *       detail is that the main thread MOC is held for the lifetime of the receiver, or
 *       until resetDatabase is called, which should only be done for testing.
 */
- (NSManagedObjectContext * _Nullable)mainThreadMOC;

/*!
 * @method entityDescriptForClassName:
 *
 * Looks up the entity description by matching managedObjectClassName as opposed to name.
 */
- (NSEntityDescription * _Nullable)entityDescriptForClassName:(NSString *)className;

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
