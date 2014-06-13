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
 * @method encodeCMOValueToJSON:ofType:withServiceAdapter:error:
 */
+ (id)encodeCMOValueToJSON:(id)cmoValue
                    ofType:(NSAttributeDescription *)attrDesc
        withServiceAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                     error:(NSError **)error;

/*!
 @method decodeJSONValueToCMO:ofType:withServiceAdapter:error:
 */
+ (id)decodeJSONValueToCMO:(id)jsonValue
                    ofType:(NSAttributeDescription *)attrDesc
        withServiceAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                     error:(NSError **)error;

/*!
 @method shouldUpdateValueForCMO:toNewValue:forKeyPath:andProperty:
 */
+ (BOOL)shouldUpdateValueForCMO:(FOSCachedManagedObject *)cmo
                     toNewValue:(id)newValue
                     forKeyPath:(NSString *)keyPath
                    andProperty:(NSPropertyDescription *)propDesc;
@end
