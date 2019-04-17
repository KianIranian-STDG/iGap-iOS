//
//  OSLabel.m
//  timeline
//
//  Created by Amir Soleimani on 6/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_OSLabel.h"

@implementation MC_OSLabel {
    BOOL isRTL;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (void)setRTL {
    isRTL = (isRTL) ? false : true;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    //--
    if (isRTL) {
        if ([self.text length] >= 1) {
            if (![[self.text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"\u200F"]) {
                NSString *Text = [@"\u200F" stringByAppendingString:self.text];
                self.text = Text;
            }
        }

    }
}

@end
