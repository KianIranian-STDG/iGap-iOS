//
//  MC_HeadTitle.m
//  maincore
//
//  Created by Amir Soleimani on 8/6/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_HeadTitle.h"
#import "core_utils.h"
#import "UIFont+IRANSansMobile.h"

@implementation MC_HeadTitle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTextAlignment:NSTextAlignmentRight];
        [self setFont:[UIFont openIRANSansBoldFontOfSize:14]];
        [self setEdgeInsets:UIEdgeInsetsMake(3, 10, 0, 10)];
        [self setTextColor:Rgb2UIColor(58, 58, 58)];
    }
    return self;
}

@end
