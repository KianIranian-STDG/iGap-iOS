//
//  core_type.h
//  timeline
//
//  Created by Amir Soleimani on 6/21/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TRANSACTION_TYPE) {
    TRANSACTION_TYPE_DIRECTCARD = 0,
    TRANSACTION_TYPE_CREDIT = 1,
    TRANSACTION_TYPE_CASH = 2,
    TRANSACTION_TYPE_POS = 3
};

// <-- Attach Types -->
typedef enum {
    TL_AT_POST = 0, //POST
    TL_AT_ACCOUNT = 1, //ACCOUNT
    TL_AT_COUPON = 2, //COUPON
    TL_AT_PRODUCT = 3, //PRODUCT
    TL_AT_TAG = 4, //TAG
    TL_AT_ORDER = 5, //ORDER
} ATTACH_TYPE;

// <-- ACCOUNT_TYPE -->
typedef enum {
    TL_ACCOUNT_USER = 2, //User
    TL_ACCOUNT_MERCHANT = 0, //Merchant
    TL_ACCOUNT_LOCATION = 1, //Location
    TL_ACCOUNT_CLUB = 3, //Location
} ACCOUNT_TYPE;

// <-- COUPON_TYPE -->
typedef enum {
    COUPON_TYPE_PERCENT = 0, //%
    COUPON_TYPE_AMOUNT = 1, //$
    COUPON_TYPE_TICKET = 2 //Ticket
} COUPON_TYPE;

// <-- COUPON_PRIVACY -->
typedef enum {
    COUPON_PRIVACY_PRIVATE = 0,
    COUPON_PRIVACY_PUBLIC = 1,
    COUPON_PRIVACY_USERCOUPON = 2
} COUPON_PRIVACY;


// <-- SEARCH_TYPE -->
typedef enum {
    SEARCH_TYPE_ALL = 0,
    SEARCH_TYPE_USER = 1,
    SEARCH_TYPE_PAGE = 2,
    SEARCH_TYPE_PRODUCT = 3,
    SEARCH_TYPE_COUPON = 4
} SEARCH_TYPE;


// <-- EXPLORE_TYPE -->
typedef enum {
    EXPLORE_TYPE_ZEUS = 3,
    EXPLORE_TYPE_MELIA = 2,
    EXPLORE_TYPE_AMIR = 1,
    EXPLORE_TYPE_SLIDE = 0
} EXPLORE_TYPE;


// <-- Post Types -->
typedef enum {
    TL_PT_POST = 0, //POST
    TL_PT_ACCOUNT = 1, //ACCOUNT
    TL_PT_COUPON = 2, //COUPON
    TL_PT_SAVE_COUPON = 10, //SAVE_COUPON
    TL_PT_USE_COUPON = 11, //USE_COUPON
    TL_PT_PAYMENT = 12 //PAYMENT
} POST_TYPE;


// <-- Account Icon Types -->
typedef enum {
    ACCOUNT_ATTACH_RATE_LOVE,
    ACCOUNT_ATTACH_RATE_SMILE,
    ACCOUNT_ATTACH_RATE_BAD,
    ACCOUNT_ATTACH_RATE_VERYBAD,
    ACCOUNT_ATTACH_PAYMENT,
    ICON_NONE,
    ICON_PRODUCT,
    ICON_COUPON,
    ICON_ACCOUNT_USER, //User
    ICON_ACCOUNT_MERCHANT, //Merchant
    ICON_ACCOUNT_LOCATION, //Location
    ICON_TAG, //TAG
    ICON_MESSAGE_THREAD
} ICONS;

// <-- onTouch Types -->
typedef enum {
    LT_OPEN_PAGES = 1,
    LT_OPEN_POSTS = 2,
    LT_OPEN_COMMENTS = 3,
    LT_OPEN_LIKES = 4
} LINK_TYPE;


@interface core_type : NSObject

+ (NSDictionary *)POST_TYPE_ENUMS;
+ (NSDictionary *)ACCOUNT_TYPE_ENUMS;
+ (NSDictionary *)ATTACH_TYPE_ENUMS;
+ (NSDictionary *)COUPON_TYPE_ENUMS;
+ (NSDictionary *)COUPON_PRIVACY_ENUMS;
+ (NSDictionary *)EXPLORE_TYPE_ENUMS;
+ (NSDictionary *)SEARCH_TYPE_ENUMS;
+ (NSDictionary *)TRANSACTION_TYPE_ENUMS;

@end

