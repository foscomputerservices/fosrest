//
//  FOSManagedObject+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSManagedObject.h"

@interface FOSManagedObject (FOS_Internal)

+ (NSEntityDescription *)entityDescriptionInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
