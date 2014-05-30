//
//  FOSCompiledAtom.m
//  FOSFoundation
//
//  Created by David Hunt on 5/30/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSCompiledAtom.h"

@implementation FOSCompiledAtom

// Protocol Properties
@synthesize atomStartLineNum = _atomStartLineNum;
@synthesize atomStartColNum = _atomStartColNum;
@synthesize atomName = _atomName;


- (NSString *)atomDescription {
    return [NSString stringWithFormat:@"(%li:%li) - %@",
            (long)self.atomStartLineNum,
            (long)self.atomStartColNum,
            self.atomName];
}

@end
