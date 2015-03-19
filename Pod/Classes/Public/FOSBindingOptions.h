//
//  FOSBindingOptions.h
//  Pods
//
//  Created by David Hunt on 3/18/15.
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

/*!
 * @enum FOSBindingOptions
 *
 * @constant FOSBindingOptionOneToOneRelationship
 *
 *   Allowed only for FOSLifecyclePhaseRetrieveServerRecordRelationship and indicates that the
 *   relationship is a one-to-one relationship.
 *
 * @constant FOSBindingOptionOneToManyRelationship
 *
 *   Allowed only for FOSLifecyclePhaseRetrieveServerRecordRelationship and indicates that the
 *   relationship is a one-to-many relationship.
 *
 * @constant FOSBindingOptionOrderedRelationship
 *
 *   Allowed only for FOSLifecyclePhaseRetrieveServerRecordRelationship and indicates that the
 *   relationship is an ordered relationship.
 */
typedef NS_OPTIONS(NSUInteger, FOSBindingOptions) {
    FOSBindingOptionsNone = 0,
    FOSBindingOptionsOneToOneRelationship = (1 << 0),
    FOSBindingOptionsOneToManyRelationship = (1 << 1),
    // TODO :  FOSBindingOptionsManyToManyRelationship = (1 << 2),
    FOSBindingOptionsUnorderedRelationship = (1 << 3),
    FOSBindingOptionsOrderedRelationship = (1 << 4)
};
