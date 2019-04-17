//
//  core_strings.h
//  timeline
//
//  Created by Amir Soleimani on 6/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//


#import "core_type.h"


@interface NSString(core_strings)

+ (NSString *)IconName:(ICONS)Type; //Tag to String Image Name
+ (ICONS)RateIconType:(NSInteger)Rate; //Rate to Image Name Tag
+ (int)getAccount_IconCode:(ACCOUNT_TYPE)Type;

@end


@implementation NSString(core_strings)

+ (ICONS)RateIconType:(NSInteger)Rate {
    switch (Rate) {
        case 1:
            return ACCOUNT_ATTACH_RATE_VERYBAD;
            break;
        case 2:
            return ACCOUNT_ATTACH_RATE_BAD;
            break;
        default:
        case 3:
            return ACCOUNT_ATTACH_RATE_SMILE;
            break;
        case 4:
            return ACCOUNT_ATTACH_RATE_LOVE;
            break;
    }
}

+ (int)getAccount_IconCode:(ACCOUNT_TYPE)Type {
    switch (Type) {
        default:
        case TL_ACCOUNT_USER:
            return ICON_ACCOUNT_USER;
            break;
        case TL_ACCOUNT_MERCHANT:
            return ICON_ACCOUNT_MERCHANT;
            break;
        case TL_ACCOUNT_LOCATION:
            return ICON_ACCOUNT_LOCATION;
            break;
    }
}

+ (NSString *)IconName:(ICONS)Type {
    switch (Type) {
        case ACCOUNT_ATTACH_RATE_VERYBAD:
            return @"core_tl_rate_verybad";
            break;
        case ACCOUNT_ATTACH_RATE_BAD:
            return @"core_tl_rate_bad";
            break;
        case ACCOUNT_ATTACH_RATE_SMILE:
            return @"core_tl_rate_smile";
            break;
        case ACCOUNT_ATTACH_RATE_LOVE:
            return @"core_tl_rate_love";
            break;
        case ACCOUNT_ATTACH_PAYMENT:
            return @"core_tl_payment";
            break;
        case ICON_PRODUCT:
            return @"core_product";
            break;
        case ICON_COUPON:
            return @"core_coupon";
            break;
        case ICON_ACCOUNT_USER:
            return @"core_account_user";
            break;
        case ICON_ACCOUNT_LOCATION:
            return @"core_account_location";
            break;
        case ICON_ACCOUNT_MERCHANT:
            return @"core_account_merchant";
            break;
        case ICON_TAG:
            return @"core_tag";
            break;
        case ICON_MESSAGE_THREAD:
            return @"tab_message";
            break;
        default:
        case ICON_NONE:
            return @"";
            break;
    }
    return nil;
}



@end
