//
//  OSLabel.h
//  timeline
//
//  Created by Amir Soleimani on 6/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+IRANSansMobile.h"

@interface MC_OSLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets edgeInsets;
- (void)setRTL;

@end
