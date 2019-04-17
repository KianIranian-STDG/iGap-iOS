//
//  obj_cell.m
//  timeline
//
//  Created by Amir Soleimani on 6/18/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_obj_cell.h"

@implementation MC_obj_cell

@synthesize Height = _Height;
@synthesize View = _View;

- (id)initWithHeight:(float)Height view:(id)View {
    if ((self = [super init])) {
        self.Height = Height;
        self.View = View;
    }
    return self;
}

@end
