//
//  FOSPropertyBinding.h
//  FOSFoundation
//
//  Created by David Hunt on 4/12/14.
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
#import <FOSFoundation/FOSCompiledAtom.h>

@class FOSCachedManagedObject;

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
