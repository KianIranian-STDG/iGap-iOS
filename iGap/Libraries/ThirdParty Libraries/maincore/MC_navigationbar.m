//
//  MC_navigationbar.m
//  page-user-profile
//
//  Created by Amir Soleimani on 8/1/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_navigationbar.h"
#import "MC_borderview.h"
#import "core_utils.h"
#import "core_colors.h"
#import "MC_OSLabel.h"
#import "UIFont+IRANSansMobile.h"


/* ----------------------
 *
 * Model->MC_navigationbar_action
 *
 * ----------------------
 */
@interface MC_navigationbar_action ()
@property (nonatomic, copy) id Target;
@property (nonatomic) SEL Selector;
@property (nonatomic, copy) UIImage *Icon;
@end

@implementation MC_navigationbar_action


+ (instancetype)actionWithTarget:(id)Target selector:(SEL)Selector icon:(UIImage *)Icon {
    return [[self alloc] initWithTarget:Target selector:Selector icon:Icon];
}

- (instancetype)initWithTarget:(id)Target selector:(SEL)Selector icon:(UIImage*)Icon {
    if ((self = [super init])) {
        _Target = Target;
        _Selector = Selector;
        _Icon = Icon;
    }
    return self;
}

@end



/* ----------------------
 *
 * sView->MC_navigationbar_button
 *
 * ----------------------
 */

@implementation MC_navigationbar_button {
    UIImage *IconImage;
    CGRect IconRect;
    MC_OSLabel *badgeLabel;
}

- (instancetype)initWithConfig:(MC_navigationbar_action*)Config {
    float nvH = 44;
    //--
    self = [super initWithFrame:CGRectMake(0, 20, nvH, nvH)];
    if (self) {
        IconImage = Config.Icon;
        //--Size & Rect
        float IconSize = self.frame.size.height-(22);
        IconRect = CGRectMake((self.frame.size.width/2)-(IconSize/2), 11, IconSize, IconSize);
        //--
        [self addTarget:Config.Target action:Config.Selector forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setBadgeCount:(NSUInteger)BadgeCount {
    _BadgeCount = BadgeCount;
    //--
    if (_BadgeCount > 0) {
        //        IconRect.origin.x = ((self.frame.size.width/2)-(IconRect.size.width/2))+2;
        //--
        if (badgeLabel == nil) {
            CGRect badgeRect = CGRectMake(2, self.frame.size.height-26, 20, 20);
            badgeLabel = [[MC_OSLabel alloc] initWithFrame:badgeRect];
            [badgeLabel setBackgroundColor:Rgb2UIColor(240, 31, 80)];
            [badgeLabel.layer setCornerRadius:badgeLabel.frame.size.height/2];
            [badgeLabel setTextAlignment:NSTextAlignmentCenter];
            [badgeLabel setTextColor:[UIColor whiteColor]];
            [badgeLabel setFont:[UIFont openIRANSansMediumFontOfSize:13]];
            [badgeLabel.layer setMasksToBounds:true];
            [badgeLabel setEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
            [badgeLabel setAlpha:0];
            [self addSubview:badgeLabel];
        }
        [badgeLabel setText:[core_utils convertEnNumberToFarsi:[NSString stringWithFormat:@"%ld",(unsigned long)_BadgeCount]]];
        [UIView animateWithDuration:0.2f animations:^{
            [self->badgeLabel setAlpha:1];
            [self->badgeLabel setTransform:CGAffineTransformMakeScale(1.1f, 1.1f)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1f animations:^{
                [self->badgeLabel setTransform:CGAffineTransformMakeScale(1, 1)];
            }];
        }];
    } else {
        if (badgeLabel != nil)
            [badgeLabel removeFromSuperview];
        //        IconRect.origin.x = ((self.frame.size.width/2)-(IconRect.size.width/2));
    }
    //--
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (self.WhiteColor)
        [[UIColor whiteColor] set];
    //--
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, IconRect, [IconImage CGImage]);
    CGContextFillRect(context, IconRect);
}

@end



/* ----------------------
 *
 * Controller NavigationBar
 *
 * ----------------------
 */
@interface MC_navigationbar ()

@end

@implementation MC_navigationbar {
    MC_borderview *NavigationBase;
    MC_OSLabel *Title, *SubTitle;
    float LeftPadding,RightPadding;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //Title
        Title = [[MC_OSLabel alloc] initWithFrame:CGRectZero];
        [Title setFont:[UIFont openIRANSansFontOfSize:15]];
        [Title setEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
        [Title setTextAlignment:NSTextAlignmentCenter];
        [Title setAlpha:0];
    }
    return self;
}

- (void)loadView {
    UIView *Super = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [core_utils getScreenWidth], 64)];
    self.view = Super;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     * Config NavigationBase
     */
    NavigationBase = [[MC_borderview alloc] init];
    [NavigationBase setBackgroundColor:[UIColor NavigationBackgroundColor]];
    [NavigationBase setAlpha:1];
    NSArray *NavigationBase_Border = @[
                                       [MC_obj_borderview borderWithPosition:MC_BORDERVIEW_BOTTOM
                                                                       start:CGPointMake(0, self.view.frame.size.height+[core_utils topSafe])
                                                                         end:CGPointMake(self.view.frame.size.width, self.view.frame.size.height+[core_utils topSafe])
                                                                       color:Rgb2UIColor(150, 150, 150)
                                        ]
                                       ];
    [NavigationBase setBorderPositions:NavigationBase_Border];
    
    [self.view addSubview:NavigationBase];
    
    /*
     * Build Title & SubTitle
     */
    [self.view addSubview:Title];
    
}

- (void)hideNavigationBase {
    [NavigationBase setAlpha:0];
    self.hideState = true;
}

- (void)setNavigationtitle:(NSString *)navigationtitle {
    _navigationtitle = navigationtitle;
    [Title setText:self.navigationtitle];
}

- (void)setNavigationsubtitle:(NSString *)navigationsubtitle {
    _navigationsubtitle = navigationsubtitle;
    if (SubTitle == nil && ![_navigationsubtitle isEqualToString:@""]) {
        SubTitle = [[MC_OSLabel alloc] init];
        [SubTitle setFont:[UIFont openIRANSansLightFontOfSize:12]];
        [SubTitle setEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [SubTitle setTextColor:Rgb2UIColor(78, 78, 78)];
        [SubTitle setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:SubTitle];
    } else {
        [SubTitle removeFromSuperview];
    }
    [SubTitle setText:_navigationsubtitle];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.view setFrame:CGRectMake(0, 0, [core_utils getScreenWidth], 64+[core_utils topSafe])];
    [NavigationBase setFrame:self.view.frame];
    LeftPadding = 0;
    RightPadding = 0;
    float topSafeNav = [core_utils topSafe];
    float topSafeTitle = 0;
    if (topSafeNav > 0) {
        topSafeTitle = 5;
        topSafeNav+=12;
    }
    //--
    for (MC_navigationbar_button *Item in self.leftItem) {
        if (topSafeNav == 0)
            topSafeNav = Item.frame.origin.y;
        //--
        [Item setFrame:CGRectMake(LeftPadding, topSafeNav, Item.frame.size.width, Item.frame.size.height)];
        [Item setWhiteColor:self.WhiteColor];
        [Item setNeedsDisplay];
        LeftPadding+=Item.frame.size.width;
    }
    //--
    for (MC_navigationbar_button *Item in self.rightItem) {
        RightPadding+=Item.frame.size.width;
        [Item setFrame:CGRectMake(self.view.frame.size.width-RightPadding, topSafeNav, Item.frame.size.width, Item.frame.size.height)];
        [Item setWhiteColor:self.WhiteColor];
        [Item setNeedsDisplay];
    }
    //--
    if (SubTitle != nil) {
        [Title setFrame:CGRectMake(LeftPadding+10, 20+topSafeTitle, self.view.frame.size.width-(20+LeftPadding+RightPadding), self.view.frame.size.height-40)];
        [SubTitle setFrame:CGRectMake(Title.frame.origin.x, Title.frame.origin.y+Title.frame.size.height, Title.frame.size.width, 20)];
    } else {
        [Title setFrame:CGRectMake(LeftPadding+10, 20+topSafeTitle, self.view.frame.size.width-(20+LeftPadding+RightPadding), self.view.frame.size.height-20)];
    }
}


- (void)setNavigationTitleShow:(BOOL)navigationTitleShow {
    _navigationTitleShow = navigationTitleShow;
    if (_navigationTitleShow)
        [Title setAlpha:1];
    else
        [Title setAlpha:0];
}


/*
 * description : add custom LeftItem, navigationbar
 */
- (void)addLeftItem:(MC_navigationbar_button*)Item {
    self.leftItem = [[NSArray arrayWithArray:self.leftItem] arrayByAddingObject:Item];
    [self.view addSubview:Item];
}

/*
 * description : add custom RightItem, navigationbar
 */
- (void)addRightItem:(MC_navigationbar_button*)Item {
    self.rightItem = [[NSArray arrayWithArray:self.rightItem] arrayByAddingObject:Item];
    [self.view addSubview:Item];
}


/*
 * description : load Opacity
 */
- (void)loadOpacity:(float)ScrollY {
    if (self.hideState) {
        if (!self.navigationTitleShow && ScrollY > 100) {
            [UIView animateWithDuration:0.2f animations:^{
                [self->NavigationBase setAlpha:1];
                [self->Title setAlpha:1];
            }];
        } else if (ScrollY < 100 && NavigationBase.alpha == 1) {
            [UIView animateWithDuration:0.2f animations:^{
                [self->NavigationBase setAlpha:0];
                [self->Title setAlpha:0];
            }];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

