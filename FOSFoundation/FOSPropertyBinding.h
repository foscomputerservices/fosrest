//
//  FOSPropertyBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 4/12/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @class FOSPropertyBinding
 *
 * An abstract class that provides a few shared methods for its subtypes.
 */
@interface FOSPropertyBinding : FOSCompiledAtom

/*!
 * @methodgroup Class Methods
 */

/*!
 * @method setValue:ofJson:forKeyPath:
 */
+ (void)setValue:(id)value ofJson:(NSMutableDictionary *)json forKeyPath:(NSString *)jsonKeyPath;

/*!
 * @method encodeCMOValueToJSON:ofType:error:
 */
+ (id)encodeCMOValueToJSON:(id)cmoValue
                    ofType:(NSAttributeDescription *)attrDesc
                     error:(NSError **)error;

/*!
 @method decodeJSONValueToCMO:ofType:error:
 */
+ (id)decodeJSONValueToCMO:(id)jsonValue
                    ofType:(NSAttributeDescription *)attrDesc
                     error:(NSError **)error;

/*!
 @method shouldUpdatevalueForCMO:toNewValue:forKeyPath:andProperty:
 */
+ (BOOL)shouldUpdateValueForCMO:(FOSCachedManagedObject *)cmo
                     toNewValue:(id)newValue
                     forKeyPath:(NSString *)keyPath
                    andProperty:(NSPropertyDescription *)propDesc;
@end
