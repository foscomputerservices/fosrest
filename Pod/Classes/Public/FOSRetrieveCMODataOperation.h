//
//  FOSRetrieveCMODataOperation.h
//  FOSREST
//
//  Created by David Hunt on 1/1/13.
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

#import <FOSREST/FOSCachedManagedObject.h>

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

#import <FOSREST/FOSWebServiceRequest.h>

@interface FOSRetrieveCMODataOperation : FOSWebServiceRequest<FOSRetrieveCMODataOperationProtocol>

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

+ (instancetype)retrieveDataOperationForEntity:(NSEntityDescription *)entity
                                   withRequest:(NSURLRequest *)request
                                 andURLBinding:(FOSURLBinding *)urlBinding;

/*!
 * @methodgroup Initialization Methods
 */
#pragma mark - Initialization Methods

- (id)initWithEntity:(NSEntityDescription *)entity
         withRequest:(NSURLRequest *)request
       andURLBinding:(FOSURLBinding *)urlBinding;

@end
