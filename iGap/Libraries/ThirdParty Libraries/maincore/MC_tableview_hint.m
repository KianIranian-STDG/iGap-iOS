//
//  TL_hint_noresult.m
//  timeline
//
//  Created by Amir Soleimani on 7/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_tableview_hint.h"
#import "core_utils.h"
#import "MC_OSLabel.h"
#import "UIFont+IRANSansMobile.h"

@implementation MC_tableview_hint

- (id)initWithText:(NSString*)Text {
    float SW = [core_utils getScreenWidth];
    if (self = [super initWithFrame:CGRectMake(0, 0, SW, 1)]) {
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
        //--
        float IPd = 10;
        float BodyHeight = 0;
        //--
        MC_OSLabel *Title = [[MC_OSLabel alloc] initWithFrame:CGRectMake(IPd, BodyHeight, self.frame.size.width-(IPd*2), 100)];
        [Title setFont:[UIFont openIRANSansLightFontOfSize:14]];
        [Title setTextAlignment:NSTextAlignmentCenter];
        [Title setText:Text];
        [self addSubview:Title];
        BodyHeight+=Title.frame.size.height;
        //--
        CGRect superFrame = self.frame;
        superFrame.size.height = BodyHeight;
        [self setFrame:superFrame];
    }
    return self;
}

@end
