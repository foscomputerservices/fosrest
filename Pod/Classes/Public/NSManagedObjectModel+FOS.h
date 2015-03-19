//
//  NSManagedObjectModel+FOS.h
//  FOSRest
//
//  Created by David Hunt on 4/20/14.
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

@import CoreData;

/*!
 * @category NSManagedObjectModel
 *
 */
@interface NSManagedObjectModel (FOS)

/*!
 * @method modelByMergingModelsButIgnoringPlaceholders:
 *
 * Merges models together by replacing any entities that have
 * a userInfo key of 'placeholder' with the corresponding
 * entity in another model that does not have that key.
 *
 * @discussion
 *
 * Original Idea:  http://chanson.livejournal.com/187540.html
 *
 * Chris's original code didn't handle inheritance (There
 * have since been a few comments to help fix this problem, but I
 * was not able to get those to work either as they seemed to skip
 * the inheritance model of the placeholder entities across
 * multiple models).
 *
 * This implementation fully supports inheritance and placeholder
 * entites in multiple models.
 */
+ (NSManagedObjectModel *)modelByMergingModels:(NSArray *)models
                           ignoringPlaceholder:(NSString *)placeholder;

@end
