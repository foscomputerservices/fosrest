//
//  FOSWebServiceRequest+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/30/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSWebServiceRequest.h"

@interface FOSWebServiceRequest (FOS_Internal)

- (void)setError:(NSError *)error;
- (void)setJsonResult:(id<NSObject>)jsonResult;

@end
