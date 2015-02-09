//
//  NSBundle+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 5/15/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface NSBundle (FOS)

+ (NSBundle *)fosFrameworkBundle;
+ (NSManagedObjectModel *)fosManagedObjectModel;

@end
