//
//  core_colors.h
//  timeline
//
//  Created by Amir Soleimani on 4/23/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "core_type.h"
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0] //REPLACE


@interface UIColor(core_colors)

+ (UIColor *)TL_BADGE_COUPON;
+ (UIColor *)TL_BADGE_PAYMENT;
+ (UIColor *)TL_SUBTITLE;
+ (UIColor *)TL_IMAGEHOLDER_BACK;
+ (UIColor *)TL_ATTACHBOX_SHADOW;
+ (UIColor *)TL_ATTACHBOX_SUBTITLE_MERCHANT;
+ (UIColor *)TL_ATTACHBOX_BACK;
+ (UIColor *)TL_ACTIONBAR_LINE;
+ (UIColor *)TL_ACTIONBAR_COUNT;

+ (UIColor *)BUTTON_BORDER_B_COLOR;
+ (UIColor *)BUTTON_BORDER_T_COLOR;
+ (UIColor *)BUTTON_BORDER_H_COLOR;

+ (UIColor *)BUTTON_BLUE_FILL;
+ (UIColor *)BUTTON_BLUE_HOLDFILL;

+ (UIColor *)BUTTON_RED_FILL;
+ (UIColor *)BUTTON_RED_HOLDFILL;

+ (UIColor *)BUTTON_GRAY_HOLDFILL;

+ (UIColor *)BUTTON_BORDER_GRAY;

+ (UIColor *)BUTTON_TITLE_DARKGRAY;

+ (UIColor *)LINE_GRAY_COLOR;

+ (UIColor *)CO_SUBTITLE;

+ (UIColor *)DetectCouponColor:(int)Type;

//--Payment & Coupon.
+ (UIColor *)PC_RECEIPT_SUCCESS;
+ (UIColor *)PC_RECEIPT_FAILED;

+ (UIColor*)NavigationBackgroundColor;
+ (UIColor*)TabBackgroundColor;
+ (UIColor*)TabBorderColor;

+ (UIColor *)BUTTON_GREEN_FILL;
+ (UIColor *)BUTTON_GREEN_HOLDFILL;

+ (UIColor*)PriceGreenLabel;
+ (UIColor*)PriceRedLabel;

+ (UIColor*)EDIT_COLOR;
+ (UIColor*)DELETE_COLOR;

@end

@implementation UIColor(core_colors)


+ (UIColor*)EDIT_COLOR {
    return Rgb2UIColor(65, 200, 90);
}

+ (UIColor*)DELETE_COLOR {
    return Rgb2UIColor(230, 40, 70);
}

+ (UIColor*)PriceRedLabel {
    return Rgb2UIColor(231, 76, 60);
}

+ (UIColor*)PriceGreenLabel {
    return Rgb2UIColor(39, 174, 96);
}

+ (UIColor*)NavigationBackgroundColor {
    return Rgb2UIColor(252,252,252);
}

+ (UIColor*)TabBackgroundColor {
    return Rgb2UIColor(252, 252, 252);
}

+ (UIColor*)TabBorderColor {
    return [UIColor colorWithRed:((130) / 255.0) green:((130) / 255.0) blue:((130) / 255.0) alpha:0.8f];
}

+ (UIColor *)TL_BADGE_COUPON { return Rgb2UIColor(0,108,218); }
+ (UIColor *)TL_BADGE_PAYMENT { return Rgb2UIColor(255,186,0); }

+ (UIColor *)TL_SUBTITLE { return Rgb2UIColor(0, 108, 230); }
+ (UIColor *)TL_IMAGEHOLDER_BACK { return Rgb2UIColor(230, 230, 230); }
+ (UIColor *)TL_ATTACHBOX_SHADOW { return Rgb2UIColor(75, 75, 75); }
+ (UIColor *)TL_ATTACHBOX_SUBTITLE_MERCHANT { return Rgb2UIColor(70, 90, 120); }
+ (UIColor *)TL_ATTACHBOX_BACK { return Rgb2UIColor(250, 250, 250); }

+ (UIColor *)TL_ACTIONBAR_LINE { return Rgb2UIColor(230, 230, 230); }
+ (UIColor *)TL_ACTIONBAR_COUNT { return Rgb2UIColor(0, 95, 205); }

+ (UIColor *)LINE_GRAY_COLOR { return Rgb2UIColor(240, 240, 240); }

+ (UIColor *)BUTTON_BORDER_B_COLOR { return Rgb2UIColor(194, 204, 225); }
+ (UIColor *)BUTTON_BORDER_T_COLOR { return Rgb2UIColor(36, 120, 220); }
+ (UIColor *)BUTTON_BORDER_H_COLOR { return Rgb2UIColor(245, 247, 250); }

+ (UIColor *)BUTTON_BLUE_FILL { return Rgb2UIColor(60, 150, 255); }
+ (UIColor *)BUTTON_BLUE_HOLDFILL { return Rgb2UIColor(0, 95, 195); }

+ (UIColor *)BUTTON_GRAY_HOLDFILL { return Rgb2UIColor(250, 250, 250); }

+ (UIColor *)BUTTON_RED_FILL { return Rgb2UIColor(239, 62, 68); }
+ (UIColor *)BUTTON_RED_HOLDFILL { return Rgb2UIColor(225, 30, 38); }

+ (UIColor *)BUTTON_GREEN_FILL { return Rgb2UIColor(0, 185, 120); }
+ (UIColor *)BUTTON_GREEN_HOLDFILL { return Rgb2UIColor(0, 160, 100); }

+ (UIColor *)BUTTON_BORDER_GRAY { return Rgb2UIColor(235, 235, 235); }
+ (UIColor *)BUTTON_TITLE_DARKGRAY { return Rgb2UIColor(52, 52, 52); }

+ (UIColor *)CO_SUBTITLE { return Rgb2UIColor(70, 90, 120); }
+ (UIColor *)DetectCouponColor:(int)Type {
    switch (Type) {
        default:
        case COUPON_TYPE_PERCENT:
            return Rgb2UIColor(255, 156, 0);
            break;
        case COUPON_TYPE_AMOUNT:
            return Rgb2UIColor(0, 120, 225);
            break;
        case COUPON_TYPE_TICKET:
            return Rgb2UIColor(35, 165, 85);
            break;
    }
}

/*
 * Payment Coupon
 */

+ (UIColor *)PC_RECEIPT_SUCCESS { return Rgb2UIColor(65,220,90); }
+ (UIColor *)PC_RECEIPT_FAILED { return Rgb2UIColor(220,65,85); } //85 Joooon :*

@end

