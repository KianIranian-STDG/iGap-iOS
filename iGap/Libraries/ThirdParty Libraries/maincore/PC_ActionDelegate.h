//
//  PC_ActionDelegate.h
//  maincore
//  Payment - Coupon
//
//  Created by Amir Soleimani on 8/12/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//
//
#import <UIKit/UIKit.h>

#ifndef PC_ActionDelegate_h
#define PC_ActionDelegate_h

@class CO_obj_coupons;
@class PU_obj_account;
@class PAY_obj_paysheet;

@protocol PC_ActionDelegate <NSObject>

@optional
- (void)PC_OpenCoupon:(id)Target info:(CO_obj_coupons*)Info;
- (void)PC_OpenCouponList:(UIViewController*)Target owner:(PU_obj_account*)Owner;
- (void)PC_OpenP2PSheetWithTarget:(id)Target Price:(NSInteger)Price receiver:(PU_obj_account*)Receiver;
- (void)PC_OpenC2BSheetWithTarget:(id)Target info:(PAY_obj_paysheet*)Info;
- (void)PC_OpenPaymentTo:(PU_obj_account*)Receiver thread_id:(NSString*)ThreadId;
- (void)PC_OpenPaymentHistoryListWithTarget:(id)Target;
- (void)PC_OpenHistoryWithTarget:(UINavigationController*)Target orderid:(NSString*)OrderId;
- (void)PC_OpenC2BSheetWithTarget:(id)Target info:(PAY_obj_paysheet *)Info istiny:(BOOL)istiny;

@end

#endif /* PC_ActionDelegate_h */
