//
//  FOSRetrieveCMODataOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

@protocol FOSRetrieveCMODataOperationProtocol <NSObject>

@required

@property (nonatomic, readonly) NSEntityDescription *entity;
@property (nonatomic, readonly) FOSJsonId jsonId;
@property (nonatomic, readonly) id<NSObject> jsonResult;
@property (nonatomic, readonly) id<NSObject> originalJsonResult;

@optional

@property (nonatomic, readonly) FOSItemMatcher *relationshipsToPull;

@end

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
