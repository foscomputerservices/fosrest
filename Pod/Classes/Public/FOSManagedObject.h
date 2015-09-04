//
//  FOSManagedObject.h
//  FOSRest
//
//  Created by David Hunt on 9/27/11.
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

@import Foundation;
@import CoreData;

@interface FOSManagedObject : NSManagedObject<NSCopying>

#pragma mark - Public Properties

// NOTE: If any properties are added, add them to the skip list
//       in NSAttributeDescription's +isFOSAttribute: impl.
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *lastModifiedAt;
@property (nonatomic, readonly) BOOL willSaveHasRecursed;

/*!
 * @property isReadOnly
 *
 * Determines if it is allowable to modify the receiver.
 *
 * It combines the receiver's isLocalOnly property, the
 * receiver's entity.jsonIsStaticTableEntity property along
 * with allowing subclasses to add their own logic.
 *
 * @discussion
 *
 * Subclasses that override this property should consult
 * [super isReadOnly] first and then add their own
 * logic if YES is returned.
 */
@property (nonatomic, readonly) BOOL isReadOnly;

#pragma mark - Initialization Methods

- (instancetype)initInsertingIntoManagedObjectContext:(NSManagedObjectContext *)moc;

@end
