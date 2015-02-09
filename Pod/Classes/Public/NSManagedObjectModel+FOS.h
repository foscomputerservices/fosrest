//
//  NSManagedObjectModel+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 4/20/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

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
