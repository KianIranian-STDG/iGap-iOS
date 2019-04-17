//
//  MC_cellMetaValue.m
//  maincore
//
//  Created by Amir Soleimani on 7/13/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_cellMetaValue.h"
#import "core_utils.h"
#import "UIFont+IRANSansMobile.h"
#import "MC_OSLabel.h"

@implementation MC_cellMetaValue {
    MC_OSLabel *Meta, *Value;
}

- (id)initWithFrame:(CGRect)Frame meta:(NSString*)MetaString value:(NSString*)ValueString {
    if (self = [super initWithFrame:Frame]) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        //--
        UIFont *MetaFont = [UIFont openIRANSansMediumFontOfSize:14];
        UIFont *ValueFont = [UIFont openIRANSansLightFontOfSize:15];
        
        float MetaWidth = [core_utils widthOfString:MetaString withFont:MetaFont];
        float ValueWidth = [core_utils widthOfString:ValueString withFont:ValueFont];
        //-- Meta.
        Meta = [[MC_OSLabel alloc] initWithFrame:CGRectMake(self.frame.size.width-MetaWidth, 0, MetaWidth, self.frame.size.height)];
        [Meta setEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        [Meta setTextAlignment:NSTextAlignmentRight];
        [Meta setFont:MetaFont];
        [Meta setText:MetaString];
        [self addSubview:Meta];
        //-- Value.
        Value = [[MC_OSLabel alloc] initWithFrame:CGRectMake(0, 0, ValueWidth, self.frame.size.height)];
        [Value setEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        [Value setTextAlignment:NSTextAlignmentLeft];
        [Value setFont:ValueFont];
        [Value setText:ValueString];
        [self addSubview:Value];
        //-- Line.
        float PointXs = ValueWidth+5;
        float PointXe = Meta.frame.origin.x-5;
        [self.layer addSublayer:[core_utils DrawLine:PointXs y1:self.frame.size.height/2.0f x2:PointXe y2:self.frame.size.height/2.0f linewidth:1 color:[Rgb2UIColor(240, 240, 240) CGColor]]];
        
    }
    return self;
}

@end
