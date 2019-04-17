//
//  PD_textfield_cell.m
//  payment-coupon
//
//  Created by Amir Soleimani on 8/22/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_emptyborder_cell.h"
#import "core_utils.h"
#import "MC_sourceimage.h"

@implementation MC_emptyborder_cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setOpaque:NO];
        self.focusStyle = UITableViewCellFocusStyleCustom;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsZero;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //--
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, Rgb2UIColor(230, 230, 230).CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, self.frame.size.height);
    CGContextAddLineToPoint(context, self.frame.size.width-10, self.frame.size.height);
    CGContextDrawPath(context, kCGPathStroke);
    
    if (_TopArrow) {
        float ArrowSize = 5;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, Rgb2UIColor(230, 230, 230).CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, 10, (self.frame.size.height/2)+ArrowSize);
        CGContextAddLineToPoint(context, 20,  (self.frame.size.height/2)-ArrowSize);
        CGContextAddLineToPoint(context, 30, (self.frame.size.height/2)+ArrowSize);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)layoutSubviews {
    float W = 0;
    if (_TopArrow) {
        W = 20;
    }
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UITextField class]])
            [v setFrame:CGRectMake(10+W, 0, (self.frame.size.width-20)-W, self.frame.size.height-1)];
        else if ([v.superclass isSubclassOfClass:[UIButton class]])
            [v setFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)];
        else if (![v isKindOfClass:[MC_sourceimage class]]) {
            [v setFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)];
            [v.layer setCornerRadius:5];
        }
    }
    [self setNeedsDisplay];
}


@end
