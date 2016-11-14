//
//  FOSPropertyBinding.m
//  FOSRest
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

#import <FOSPropertyBinding.h>
#import "FOSREST_Internal.h"

@implementation FOSPropertyBinding

+ (void)setValue:(id)value ofJson:(NSMutableDictionary *)json forKeyPath:(NSString *)jsonKeyPath {
    NSArray *keyFields = [jsonKeyPath componentsSeparatedByString:@"."];
    NSMutableDictionary *innerDict = json;

    // Handle nested dictionaries
    NSUInteger keyCount = 1;
    for (NSString *innerKey in keyFields) {
        if (keyCount++ == keyFields.count) {
            innerDict[innerKey] = (value == nil ? [NSNull null] : value);
        }
        else {
            NSMutableDictionary *nextInnerDict = innerDict[innerKey];
            if (nextInnerDict == nil) {
                nextInnerDict = [NSMutableDictionary dictionaryWithCapacity:5];
                innerDict[innerKey] = nextInnerDict;
            }

            innerDict = nextInnerDict;
        }
    }
}

+ (id)encodeCMOValueToJSON:(id)cmoValue
                    ofType:(NSAttributeDescription *)attrDesc
        withServiceAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                      error:(NSError **)error {
    NSParameterAssert(attrDesc != nil);
    NSParameterAssert([attrDesc isKindOfClass:[NSAttributeDescription class]]);

    id result = cmoValue;

    if ([serviceAdapter respondsToSelector:@selector(encodeCMOValueToJSON:ofType:error:)]) {
        result = [serviceAdapter encodeCMOValueToJSON:cmoValue ofType:attrDesc error:error];
    }

    return result;
}

+ (id)decodeJSONValueToCMO:(id)jsonValue
                     ofType:(NSAttributeDescription *)attrDesc
        withServiceAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                      error:(NSError **)error {
    NSParameterAssert(attrDesc != nil);
    NSParameterAssert([attrDesc isKindOfClass:[NSAttributeDescription class]]);

    id result = jsonValue;

    if ([serviceAdapter respondsToSelector:@selector(decodeJSONValueToCMOValue:ofType:error:)]) {
        result = [serviceAdapter decodeJSONValueToCMOValue:jsonValue ofType:attrDesc error:error];
    }

    return result;
}

+ (BOOL)shouldUpdateValueForCMO:(FOSCachedManagedObject *)cmo
                      toNewValue:(id)newValue
                      forKeyPath:(NSString *)keyPath
                     andProperty:(NSPropertyDescription *)propDesc {
    NSParameterAssert(cmo != nil);
    NSParameterAssert(keyPath != nil);
    NSParameterAssert(propDesc != nil);

    BOOL result = YES;

    // Check if this would override a locally updated value
    // NOTE: The order of the && is important as hasModifiedProperties is
    //       MUCH easier to check than hasBeenUploadedToServer.
    if (cmo.hasModifiedProperties && cmo.hasBeenUploadedToServer) {
        for (FOSModifiedProperty *modProd in cmo.propertiesModifiedSinceLastUpload) {
            if ([modProd.propertyName isEqualToString:propDesc.name]) {
                result = NO;
                break;
            }
        }
    }

    // TODO : Check if it's the same as the current value
    
    return result;
}

@end
