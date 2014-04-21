//
//  FOSRetrieveCMODataOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 1/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@protocol FOSRetrieveCMODataOperationProtocol <NSObject>

@required

@property (nonatomic, readonly) NSEntityDescription *entity;
@property (nonatomic, readonly) FOSJsonId jsonId;
@property (nonatomic, readonly) NSDictionary *jsonResult;

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
#pragma mark - Intialization Methods

- (id)initWithEntity:(NSEntityDescription *)entity
         withRequest:(NSURLRequest *)request
       andURLBinding:(FOSURLBinding *)urlBinding;

@end
