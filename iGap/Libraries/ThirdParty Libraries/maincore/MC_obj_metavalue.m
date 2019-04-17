//
//  MC_obj_metavalue.m
//  maincore
//
//  Created by Amir Soleimani on 8/1/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_obj_metavalue.h"

@implementation MC_obj_metavalue

@synthesize Meta = _Meta;
@synthesize Value = _Value;

- (id)initWithMeta:(NSString*)Meta value:(NSString*)Value {
    if ((self = [super init])) {
        self.Meta = Meta;
        self.Value = Value;
    }
    return self;
}

@end
