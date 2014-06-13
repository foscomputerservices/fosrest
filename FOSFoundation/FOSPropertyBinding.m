//
//  FOSPropertyBinding.m
//  FOSFoundation
//
//  Created by David Hunt on 4/12/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSPropertyBinding.h"

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
    if (cmo.hasBeenUploadedToServer && cmo.hasModifiedProperties) {
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
