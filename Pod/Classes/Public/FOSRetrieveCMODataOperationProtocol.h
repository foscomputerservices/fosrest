//
//  FOSRetrieveCMODataOperationProtocol.h
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

@import CoreData;
#import "FOSJsonId.h"

@class FOSItemMatcher;

@protocol FOSRetrieveCMODataOperationProtocol <NSObject>

@required

@property (nonatomic, readonly) NSEntityDescription *entity;
@property (nonatomic, readonly) FOSJsonId jsonId;
@property (nonatomic, readonly) id<NSObject> jsonResult;
@property (nonatomic, readonly) BOOL mergeResults;
@property (nonatomic, readonly) id<NSObject> originalJsonResult;
@property (nonatomic, readonly) NSString *dslQuery;

@optional

@property (nonatomic, readonly) FOSItemMatcher *relationshipsToPull;

@end
