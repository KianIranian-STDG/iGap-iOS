//
//  MC_FieldGender.m
//  maincore
//
//  Created by Amir Soleimani on 7/19/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_FieldGender.h"
#import "core_utils.h"


/*
 * Sub View
 */
@interface MC_FieldGender_Btn : UIView {
    BOOL Selected;
    NSString *IconName;
}
@property (nonatomic,copy) NSString *IconName;
@property (nonatomic,copy) NSString *GenderTag;
@property (nonatomic,copy) UIColor *GenderColor;
@property (nonatomic,assign) BOOL Selected;
@end

@implementation MC_FieldGender_Btn {
    CGRect IconRect;
    UIImage *Icon;
}

@synthesize Selected, IconName;

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        //--
        [self setOpaque:false];
        IconRect = CGRectZero;
    }
    return self;
}

- (void)setSelected:(BOOL)iSelected {
    Selected = iSelected;
    if (Selected) {
        [self setBackgroundColor:Rgb2UIColor(241, 246, 251)];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)setIconName:(NSString *)iIconName {
    IconName = iIconName;
    Icon = [UIImage imageNamed:self.IconName inBundle:[core_utils getResourcesBundle] compatibleWithTraitCollection:nil];
    //--
    float IPd = 6;
    float iconW = (Icon.size.width*16)/45;
    float iconH = 38;
    IconRect = CGRectMake((self.frame.size.width/2.0f)-(iconW/2), IPd, iconW, iconH);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //--
    [self.GenderColor set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, IconRect, [Icon CGImage]);
    CGContextFillRect(context, IconRect);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //    [self setSelected:true];//(Selected ? false : true)
    //    for (MC_FieldGender_Btn *i in self.superview.subviews) {
    //        if (![i isEqual:self])
    //            [i setSelected:false];
    //    }
    [(MC_FieldGender *)self.superview setActiveGender:self.GenderTag];
}

@end


/*
 * Main Class
 */
@implementation MC_FieldGender {
    float btnWidth;
    NSArray *Genders;
}

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        //--
        [self setActiveGender:@"m"];
        [self setOpaque:false];
        [self setClipsToBounds:true];
        [self.layer setCornerRadius:3];
        [self.layer setBorderWidth:1];
        [self.layer setBorderColor:Rgb2UIColor(233, 238, 244).CGColor];
        //--
        Genders = @[@[@"core_gender_man",@"m",Rgb2UIColor(99, 190, 230)],@[@"core_gender_woman",@"f",Rgb2UIColor(185, 125, 235)]];
        //--
        [self GenerateGenders];
    }
    return self;
}

- (void)GenerateGenders {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < [Genders count]; i++) {
        MC_FieldGender_Btn *Base = [[MC_FieldGender_Btn alloc] initWithFrame:CGRectMake((i*btnWidth)+(i*1), 0, btnWidth, self.frame.size.height)];
        Base.IconName = [[Genders objectAtIndex:i] objectAtIndex:0];
        Base.GenderTag = [[Genders objectAtIndex:i] objectAtIndex:1];
        Base.GenderColor = [[Genders objectAtIndex:i] objectAtIndex:2];
        Base.tag = i+1;
        if ([Base.GenderTag isEqualToString:_ActiveGender])
            [Base setSelected:true];
        //--
        if (i != [Genders count]-1)
            [self.layer addSublayer:[core_utils DrawLine:((i+1)*btnWidth)+0.5f y1:0 x2:((i+1)*btnWidth)+0.5f y2:self.frame.size.height linewidth:1.0f color:Rgb2UIColor(233, 238, 244).CGColor]];
        //--
        [self addSubview:Base];
    }
}

- (void)setActiveGender:(NSString *)ActiveGender {
    _ActiveGender = ActiveGender;
    [self GenerateGenders];
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)layoutSubviews {
    btnWidth = (self.frame.size.width-([Genders count]*1))/[Genders count];
    //--
    for (MC_FieldGender_Btn *Base in self.subviews) {
        [Base removeFromSuperview];
    }
    //--
    [self GenerateGenders];
}

@end
