//
//  MC_badgeview.m
//  maincore
//
//  Created by Amir Soleimani on 8/4/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_badgeview.h"
#import "core_utils.h"
#import "UIFont+IRANSansMobile.h"

@implementation MC_badgeview {
    NSMutableParagraphStyle *style;
    NSDictionary *RateAttr;
    NSString *RateString;
}

- (instancetype)initWithPoint:(CGPoint)Point {
    self = [super initWithFrame:CGRectMake(Point.x, Point.y, 30, 30)];
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //--Style
        style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        
        //--Count
        RateAttr = @{ NSFontAttributeName: [UIFont openIRANSansMediumFontOfSize:15],
                       NSParagraphStyleAttributeName: style,
                       NSLigatureAttributeName: @1,
                       NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
    return self;
}

- (void)setRate:(float)Rate {
    _Rate = Rate;
    RateString = [core_utils convertEnNumberToFarsiInString:[NSString stringWithFormat:@"%.1f",_Rate]];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //--
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(15, 0)];
    [bezierPath addCurveToPoint: CGPointMake(28.29, 3.33) controlPoint1: CGPointMake(15, 0) controlPoint2: CGPointMake(26.82, -0)];
    [bezierPath addCurveToPoint: CGPointMake(28.29, 26.67) controlPoint1: CGPointMake(29.77, 6.67) controlPoint2: CGPointMake(31.25, 18.33)];
    [bezierPath addCurveToPoint: CGPointMake(15, 30) controlPoint1: CGPointMake(28.29, 26.67) controlPoint2: CGPointMake(26.82, 30)];
    [bezierPath addCurveToPoint: CGPointMake(1.71, 26.67) controlPoint1: CGPointMake(3.18, 30) controlPoint2: CGPointMake(1.71, 26.67)];
    [bezierPath addCurveToPoint: CGPointMake(1.71, 3.33) controlPoint1: CGPointMake(-1.25, 18.33) controlPoint2: CGPointMake(0.23, 6.67)];
    [bezierPath addCurveToPoint: CGPointMake(15, 0) controlPoint1: CGPointMake(3.18, -0) controlPoint2: CGPointMake(15, 0)];
    [bezierPath closePath];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, bezierPath.CGPath);
    CGContextSetFillColorWithColor(ctx, [core_utils getRateColor:self.Rate].CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    
    //--
    [RateString drawInRect:CGRectMake(0, 6, self.frame.size.width, self.frame.size.height) withAttributes:RateAttr];
}



@end
