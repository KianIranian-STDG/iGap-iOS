//
//  MC_options_cell.m
//  raad
//
//  Created by Amir Soleimani on 9/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_options_cell.h"
#import "core_utils.h"

@implementation MC_options_cell {
    float Padding;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self Config];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self Config];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self Config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self Config];
    }
    return self;
}

- (void)Config {
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor whiteColor]];
    self.focusStyle = UITableViewCellFocusStyleCustom;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorInset = UIEdgeInsetsZero;
    Padding = 10;
    //--
    self.Title = [[MC_OSLabel alloc] init];
    [self.Title setFont:[UIFont openIRANSansFontOfSize:13]];
    [self.Title setTextAlignment:NSTextAlignmentRight];
    [self.Title setTextColor:[UIColor blackColor]];
    [self addSubview:self.Title];
}

- (void)setIsRed:(BOOL)isRed {
    _isRed = isRed;
    if (_isRed)
        [self.Title setTextColor:Rgb2UIColor(220, 80, 80)];
    else
        [self.Title setTextColor:[UIColor blackColor]];
}

- (void)layoutSubviews {
    [self.Title setFrame:CGRectMake(Padding, 0, self.frame.size.width-(Padding*2), self.frame.size.height)];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context,Rgb2UIColor(230, 230, 230).CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, self.frame.size.height);
    CGContextAddLineToPoint(context, self.frame.size.width-Padding, self.frame.size.height);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
