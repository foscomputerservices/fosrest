//
//  TestToMany.h
//  FOSREST
//
//  Created by David Hunt on 12/2/13.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <fosrest/FOSParseCachedManagedObject.h>

@class TestToManyDestMax, TestToManyDestMin, User;

@interface TestToMany : FOSParseCachedManagedObject

@property (nonatomic, retain) NSString * testType;
@property (nonatomic, retain) NSSet *toManyMax;
@property (nonatomic, retain) NSSet *toManyMin;
@property (nonatomic, retain) User *user;
@end

@interface TestToMany (CoreDataGeneratedAccessors)

- (void)addToManyMaxObject:(TestToManyDestMax *)value;
- (void)removeToManyMaxObject:(TestToManyDestMax *)value;
- (void)addToManyMax:(NSSet *)values;
- (void)removeToManyMax:(NSSet *)values;

- (void)addToManyMinObject:(TestToManyDestMin *)value;
- (void)removeToManyMinObject:(TestToManyDestMin *)value;
- (void)addToManyMin:(NSSet *)values;
- (void)removeToManyMin:(NSSet *)values;

@end