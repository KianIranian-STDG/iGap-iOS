//
//  MC_ButtonCore.h
//  maincore
//
//  Created by Amir Soleimani on 7/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+IRANSansMobile.h"

typedef enum {
    MCBUTTONTYPE_NONE = 100,
    MCBUTTONTYPE_GREEN = 1,
    MCBUTTONTYPE_BLUE = 2,
    MCBUTTONTYPE_BORDER_GRAY = 3,
    MCBUTTONTYPE_RED = 4,
    MCBUTTONTYPE_BLACK = 5,
    MCBUTTONTYPE_BORDER_BLUE = 6,
    MCBUTTONTYPE_GRAY_TEXT_BLUE = 7,
    MCBUTTONTYPE_BORDER_BLACK = 8,
    MCBUTTONTYPE_NOBORDER_NONE = 9
} MCBUTTONTYPE;


@interface MC_ButtonCore : UIButton

- (void)setFontSize:(float)Size;
- (void)spinner:(BOOL)Status;

@property (nonatomic,assign,getter=isSpinnerStatus) BOOL isSpinner;
@property (nonatomic,assign,getter=isType) MCBUTTONTYPE ButtonType;

- (instancetype)initWithFrame:(CGRect)frame type:(MCBUTTONTYPE)Type margin:(BOOL)Margin;
- (instancetype)initWithFrame:(CGRect)frame type:(MCBUTTONTYPE)Type;
- (instancetype)initWithType:(MCBUTTONTYPE)Type;
- (void)setType:(MCBUTTONTYPE)Type;
- (void)setRightViewValue:(NSString*)Value;
- (void)setRightViewValue:(NSString*)Value backgroundcolor:(UIColor*)BackgrondColor textcolor:(UIColor*)TextColor;

@end

