//
//  core_validation.m
//  maincore
//
//  Created by Amir Soleimani on 7/15/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "core_validation.h"

@implementation core_validation

+ (BOOL)checkmobile:(NSString*)Mobile {
    BOOL Error = false;
    if ([Mobile length] == 11)
        if ([[Mobile substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"09"])
            Error = true;
    return Error;
}

@end
