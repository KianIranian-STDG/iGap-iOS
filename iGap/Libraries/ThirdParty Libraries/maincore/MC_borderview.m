//
//  MC_borderview.m
//  page-user-profile
//
//  Created by Amir Soleimani on 8/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_borderview.h"
#import "core_utils.h"

/* ----------------------
 *
 *
 * ----------------------
 */
@interface MC_obj_borderview ()
@property (nonatomic, assign) MC_BORDERVIEW Position;
@property (nonatomic, assign) CGPoint Start;
@property (nonatomic, assign) CGPoint End;
@property (nonatomic, copy) UIColor *Color;
@end

@implementation MC_obj_borderview

+ (instancetype)borderWithPosition:(MC_BORDERVIEW)Position start:(CGPoint)Start end:(CGPoint)End color:(UIColor*)Color {
    return [[self alloc] initWithPosition:Position start:Start end:End withcolor:Color];
}

- (instancetype)initWithPosition:(MC_BORDERVIEW)Position start:(CGPoint)Start end:(CGPoint)End withcolor:(UIColor*)withColor {
    if ((self = [super init])) {
        _Position = Position;
        _Start = Start;
        _End = End;
        _Color = withColor;
    }
    return self;
}

@end


@implementation MC_borderview {
    CGPoint Start,End;
}

@synthesize borderPositions = _borderPositions;
@synthesize borderColor = _borderColor;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self Create];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self Create];
    }
    return self;
}

- (void)Create {
    [self setOpaque:NO];
    _borderColor = Rgb2UIColor(220, 220, 220);
}

- (void)setBorderColor:(UIColor *)xborderColor {
    _borderColor = xborderColor;
    [self setNeedsDisplay];
}

- (void)setBorderPositions:(NSArray *)xborderPositions {
    _borderPositions = xborderPositions;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if ([_borderPositions count] > 0) {
        for (MC_obj_borderview *Border in _borderPositions) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(context, Border.Color.CGColor);
            CGContextSetLineWidth(context, 1.0);
            CGContextMoveToPoint(context, Border.Start.x,Border.Start.y);
            CGContextAddLineToPoint(context, Border.End.x, Border.End.y);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
}

@end
