//
//  MC_ButtonCore.m
//  maincore
//
//  Created by Amir Soleimani on 7/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_ButtonCore.h"
#import "MC_OSLabel.h"
#import "core_colors.h"
#import "core_utils.h"

@interface MC_ButtonCore ()
@property (nonatomic,assign) BOOL SpinnerStatus;
@property (nonatomic,assign) int ThemeType;
@end

@implementation MC_ButtonCore {
    NSString *Text;
    UIActivityIndicatorView *Spinner;
    UIColor *DefaultColor,*HoldColor,*TitleColor,*SpinnerColor;
    MC_OSLabel *RightViewLabel;
    BOOL MarginStatus;
    //--
    UIColor *RightBGColor,*RightTXColor;
}


- (instancetype)initWithType:(MCBUTTONTYPE)Type {
    return [self initWithFrame:CGRectZero type:Type margin:true];
}

- (instancetype)initWithFrame:(CGRect)frame type:(MCBUTTONTYPE)Type {
    return [self initWithFrame:frame type:Type margin:true];
}

- (instancetype)initWithFrame:(CGRect)frame type:(MCBUTTONTYPE)Type margin:(BOOL)Margin {
    self = [super initWithFrame:frame];
    if (self) {
        RightBGColor = Rgb2UIColor(0, 85, 200);
        RightTXColor = [UIColor whiteColor];
        //--
        [self setOpaque:NO];
        [self.layer setMasksToBounds:false];
        [self addTarget:self action:@selector(setHighlightedBackground) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(setDefaultBackground) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(setDefaultBackground) forControlEvents:UIControlEventTouchUpOutside];
        //--
        [self setType:Type];
        MarginStatus = Margin;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setType:_ThemeType];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [Spinner setCenter:CGPointMake(self.frame.size.width/2, (self.frame.size.height/2))];
    if (MarginStatus)
        self.layer.cornerRadius = self.frame.size.height/2.0f;//3.0f;
}

/*
 * description : set rightview value
 */
- (void)setRightViewValue:(NSString*)Value backgroundcolor:(UIColor*)BackgrondColor textcolor:(UIColor*)TextColor {
    RightBGColor = BackgrondColor;
    RightTXColor = TextColor;
    [self setRightViewValue:Value];
}

- (void)setRightViewValue:(NSString*)Value {
    [self setClipsToBounds:true];
    //--
    UIFont *font = [UIFont openIRANSansFontOfSize:17];
    float Padding = 5;
    float textWidth = [core_utils widthOfString:Value withFont:font]+(Padding*2);
    if (textWidth < self.frame.size.height)
        textWidth = self.frame.size.height;
    //--
    UIEdgeInsets Edge = self.titleEdgeInsets;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(Edge.top, Edge.left, Edge.bottom, (textWidth)-3)];
    CGRect RightRect = CGRectMake(self.frame.size.width-textWidth, 0, textWidth, self.frame.size.height);
    //--
    if (RightViewLabel == nil) {
        RightViewLabel = [[MC_OSLabel alloc] initWithFrame:RightRect];
        [RightViewLabel setTextAlignment:NSTextAlignmentCenter];
        [RightViewLabel setFont:font];
        [RightViewLabel setEdgeInsets:UIEdgeInsetsMake(7, 0, 0, -2)];
        [RightViewLabel.layer setCornerRadius:(RightViewLabel.frame.size.height/2)+1];
        [RightViewLabel.layer setMasksToBounds:TRUE];
        [self addSubview:RightViewLabel];
    } else
        [RightViewLabel setFrame:RightRect];
    //--
    [self setRightViewStyle];
    [RightViewLabel setText:[core_utils convertEnNumberToFarsi:Value]];
}

- (void)setRightViewStyle {
    [RightViewLabel setTextColor:RightTXColor];
    [RightViewLabel setBackgroundColor:RightBGColor];
}

/*
 * description : set theme config
 */
- (void)ConfigTheme {
    switch (self.ThemeType) {
        case MCBUTTONTYPE_GREEN:
        {
            DefaultColor = [UIColor BUTTON_GREEN_FILL];
            HoldColor = [UIColor BUTTON_GREEN_HOLDFILL];
            TitleColor = [UIColor whiteColor];
            SpinnerColor = [UIColor whiteColor];
            [self.layer setBorderWidth:0];
        }
            break;
        case MCBUTTONTYPE_RED:
        {
            DefaultColor = [UIColor BUTTON_RED_FILL];
            HoldColor = [UIColor BUTTON_RED_HOLDFILL];
            TitleColor = [UIColor whiteColor];
            SpinnerColor = [UIColor whiteColor];
            [self.layer setBorderWidth:0];
        }
            break;
        case MCBUTTONTYPE_BLUE:
        {
            DefaultColor = [UIColor BUTTON_BLUE_FILL];
            HoldColor = [UIColor BUTTON_BLUE_HOLDFILL];
            TitleColor = [UIColor whiteColor];
            SpinnerColor = [UIColor whiteColor];
            [self.layer setBorderWidth:0];
        }
            break;
        case MCBUTTONTYPE_BLACK:
        {
            DefaultColor = [UIColor blackColor];
            HoldColor = Rgb2UIColor(58, 58, 58);
            TitleColor = [UIColor whiteColor];
            SpinnerColor = [UIColor whiteColor];
            [self.layer setBorderWidth:0];
        }
            break;
        case MCBUTTONTYPE_NONE:
        {
            DefaultColor = [UIColor whiteColor];
            HoldColor = [UIColor BUTTON_GRAY_HOLDFILL];
            TitleColor = [UIColor BUTTON_TITLE_DARKGRAY];
            SpinnerColor = [UIColor darkGrayColor];
            //--
            [self.layer setBorderColor:[[UIColor BUTTON_BORDER_GRAY] CGColor]];
            [self.layer setBorderWidth:1.0f];
        }
            break;
        case MCBUTTONTYPE_BORDER_GRAY:
        {
            DefaultColor = [UIColor whiteColor];
            HoldColor = [UIColor BUTTON_GRAY_HOLDFILL];
            TitleColor = [UIColor BUTTON_BORDER_T_COLOR];
            SpinnerColor = [UIColor darkGrayColor];
            //--
            [self.layer setBorderWidth:1.0f];
            [self.layer setBorderColor:[[UIColor BUTTON_BORDER_B_COLOR] CGColor]];
        }
            break;
        case MCBUTTONTYPE_GRAY_TEXT_BLUE:
        {
            DefaultColor = Rgb2UIColor(240, 240, 240);
            HoldColor = [UIColor BUTTON_GRAY_HOLDFILL];
            TitleColor = [UIColor BUTTON_BORDER_T_COLOR];
            SpinnerColor = [UIColor darkGrayColor];
            //--
            [self.layer setBorderWidth:0];
        }
            break;
        case MCBUTTONTYPE_BORDER_BLUE:
        {
            DefaultColor = [UIColor clearColor];
            HoldColor = [UIColor clearColor];
            TitleColor = [UIColor BUTTON_BLUE_HOLDFILL];
            SpinnerColor = [UIColor darkGrayColor];
            //--
            [self.layer setBorderWidth:1.0f];
            [self.layer setBorderColor:[[UIColor BUTTON_BLUE_FILL] CGColor]];
        }
            break;
        case MCBUTTONTYPE_BORDER_BLACK:
        {
            DefaultColor = [UIColor whiteColor];
            HoldColor = [UIColor clearColor];
            TitleColor = [UIColor blackColor];
            SpinnerColor = [UIColor darkGrayColor];
            //--
            [self.layer setBorderWidth:1.0f];
            [self.layer setBorderColor:[[UIColor blackColor] CGColor]];
        }
            break;
        case MCBUTTONTYPE_NOBORDER_NONE:
        {
            DefaultColor = [UIColor whiteColor];
            HoldColor = [UIColor clearColor];
            TitleColor = [UIColor blackColor];
            SpinnerColor = [UIColor darkGrayColor];
            //--
            [self.layer setBorderWidth:0];
        }
            break;
            
        default:
            break;
    }
    //--
    [self setDefaultBackground];
    if (self.frame.size.height < 30)
        [self setFontSize:11];
    else if (self.frame.size.height < 40)
        [self setFontSize:13];
    else
        [self setFontSize:15];
    [self setTitleColor:TitleColor forState:UIControlStateNormal];
    //--
    UIEdgeInsets Edge = self.titleEdgeInsets;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(3, Edge.left, Edge.bottom, Edge.right)];
    //--
    if (Spinner == nil) {
        Spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [Spinner setColor:SpinnerColor];
        [Spinner setHidesWhenStopped:YES];
        [self addSubview:Spinner];
    }
}

- (void)setHighlightedBackground { [self setBackgroundColor:HoldColor]; }
- (void)setDefaultBackground { [self setBackgroundColor:DefaultColor]; }


/*
 * ...
 */
- (void)setType:(MCBUTTONTYPE)Type {
    self.ThemeType = Type;
    [self ConfigTheme];
    //--
    if (RightViewLabel != nil)
        [self setRightViewStyle];
}

- (void)setFontSize:(float)Size {
    [self.titleLabel setFont:[UIFont openIRANSansFontOfSize:Size]];
}

- (void)spinner:(BOOL)Status {
    self.SpinnerStatus = Status;
    if (self.SpinnerStatus) { //Show
        [Spinner startAnimating];
        Text = self.currentTitle;
        [self setTitle:@"" forState:UIControlStateNormal];
        [self setUserInteractionEnabled:false];
    } else { //Hide
        [Spinner stopAnimating];
        [self setTitle:Text forState:UIControlStateNormal];
        [self setUserInteractionEnabled:true];
    }
}

- (BOOL)isSpinnerStatus {
    return self.SpinnerStatus;
}

- (MCBUTTONTYPE)isType {
    return self.ThemeType;
}

@end

