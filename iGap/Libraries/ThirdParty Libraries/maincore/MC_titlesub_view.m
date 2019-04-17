//
//  MC_titlesub_view.m
//  maincore
//
//  Created by Amir Soleimani on 8/6/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_titlesub_view.h"
#import "MC_OSLabel.h"
#import "UIFont+IRANSansMobile.h"

@implementation MC_titlesub_view


- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 200, 44)];
    if (self) {
        [self setOpaque:NO];
        
        //--Title
        self.Title = [[MC_OSLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 25)];
        [self.Title setTextAlignment:NSTextAlignmentCenter];
        [self.Title setAdjustsFontSizeToFitWidth:TRUE];
        [self.Title setFont:[UIFont openIRANSansLightFontOfSize:16]];
        [self.Title setEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        [self addSubview:self.Title];
        
        //--SubTitle
        self.SubTitle = [[MC_OSLabel alloc] initWithFrame:CGRectMake(0, self.Title.frame.size.height, self.frame.size.width ,19)];
        [self.SubTitle setTextAlignment:NSTextAlignmentCenter];
        [self.SubTitle setAdjustsFontSizeToFitWidth:TRUE];
        [self.SubTitle setFont:[UIFont openIRANSansLightFontOfSize:11]];
        [self.SubTitle setEdgeInsets:UIEdgeInsetsMake(-3, 0, 0, 0)];
        [self addSubview:self.SubTitle];
        
    }
    return self;
}

- (void)setTitleText:(NSString*)Text {
    [self.Title setText:Text];
}

- (void)setSubTitleText:(NSString*)Text {
    [self.SubTitle setText:Text];
}

@end
