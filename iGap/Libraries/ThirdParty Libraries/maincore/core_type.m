//
//  core_type.m
//  maincore
//
//  Created by Amir Soleimani on 7/4/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "core_type.h"

@implementation core_type

+ (NSDictionary *)POST_TYPE_ENUMS {
    return @{
             @0:@(TL_PT_POST),
             @1:@(TL_PT_ACCOUNT),
             @2:@(TL_PT_COUPON),
             @10:@(TL_PT_SAVE_COUPON),
             @11:@(TL_PT_USE_COUPON),
             @12:@(TL_PT_PAYMENT),
             };
}

+ (NSDictionary *)ACCOUNT_TYPE_ENUMS {
    return @{@0: @(TL_ACCOUNT_MERCHANT),
             @1: @(TL_ACCOUNT_LOCATION),
             @2: @(TL_ACCOUNT_USER),
             @3: @(TL_ACCOUNT_CLUB)
             };
}

+ (NSDictionary *)ATTACH_TYPE_ENUMS {
    return @{@0: @(TL_AT_POST),
             @1: @(TL_AT_ACCOUNT),
             @2: @(TL_AT_COUPON),
             @3: @(TL_AT_PRODUCT),
             @4: @(TL_AT_TAG),
             @5: @(TL_AT_ORDER)
             };
}

+ (NSDictionary *)COUPON_TYPE_ENUMS {
    return @{@0: @(COUPON_TYPE_PERCENT),
             @1: @(COUPON_TYPE_AMOUNT),
             @2: @(COUPON_TYPE_TICKET)
             };
}

+ (NSDictionary *)COUPON_PRIVACY_ENUMS {
    return @{@0: @(COUPON_PRIVACY_PRIVATE),
             @1: @(COUPON_PRIVACY_PUBLIC),
             @2: @(COUPON_PRIVACY_USERCOUPON)
             };
}

+ (NSDictionary *)EXPLORE_TYPE_ENUMS {
    return @{@0: @(EXPLORE_TYPE_SLIDE),
             @1: @(EXPLORE_TYPE_AMIR),
             @2: @(EXPLORE_TYPE_MELIA),
             @3: @(EXPLORE_TYPE_ZEUS)
             };
}

+ (NSDictionary *)SEARCH_TYPE_ENUMS {
    return @{@0: @(SEARCH_TYPE_ALL),
             @1: @(SEARCH_TYPE_USER),
             @2: @(SEARCH_TYPE_PAGE),
             @3: @(SEARCH_TYPE_PRODUCT),
             @4: @(SEARCH_TYPE_COUPON)
             };
}

+ (NSDictionary *)TRANSACTION_TYPE_ENUMS {
    return @{@0: @(TRANSACTION_TYPE_DIRECTCARD),
             @1: @(TRANSACTION_TYPE_CREDIT),
             @2: @(TRANSACTION_TYPE_CASH),
             @3: @(TRANSACTION_TYPE_POS)
             };
}


@end

