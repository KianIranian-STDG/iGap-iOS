//
//  WS_methods.h
//  webservice
//
//  Created by benyamin Mokhtarpour on 8/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <models/EX_obj_searchquery.h>
#import <models/PU_obj_account.h>
#import <models/PC_obj_card.h>
#import <models/PD_obj_pod.h>
#import <models/PC_obj_payinit.h>
#import <models/PC_obj_payment.h>
#import <models/PD_obj_cost.h>
#import <models/NP_obj_newpost.h>
#import <models/TL_obj_contact.h>
#import <models/PN_obj_pushaction.h>
#import <models/st_obj_paymentform.h>
#import <models/CL_obj_registerplan.h>
#import <models/PAY_obj_cashout.h>
#import <models/UP_obj_checker.h>
#import "WS_main.h"

@interface WS_methods : WS_main

/*
 * Global
 */
- (void)GetURL:(NSString*)URL;
- (void)GetZeus;

/*
 * PodName : push service
 */
#pragma mark - push
- (void)PN_updatetoken:(PN_obj_pushaction*)tokens;
- (void)logout:(NSString*)token;

/*
 * PodName : userauth
 */
#pragma mark - userauth
- (void)AU_request_otp:(NSString*)MobileNumber callTo:(BOOL)byCall;
- (void)AU_verify_otp:(NSString *)MobileNumber otp:(NSString*)OTP;
- (void)AU_register_account:(PU_obj_account*)Info;
- (void)AU_2StepVerification:(NSString *)oldPassword newPassword:(NSString *)newPassword;
- (void)AU_2StepVerificationLogin:(NSString *)password;

/*
 * PodName : explore-search-map
 */
#pragma mark - explore-search-map
- (void)EX_searchquery:(EX_obj_searchquery*)query;
- (void)EX_explore;

/*
 * PodName : page-user-profile
 */
#pragma mark - page-user-profile
- (void)PU_getaccountinfo:(PU_obj_account*)Info mod:(NSInteger)Mod; //
- (void)PU_getsocialinfo:(PU_obj_account*)Info; //
- (void)PU_followaccount:(NSString*)AccountId; //
- (void)PU_unfollowaccount:(NSString*)AccountId; //
- (void)PU_getAccountingInfo:(NSString*)AccountId; //
- (void)PU_getAccountBulk:(NSMutableArray<NSString*>*)Ids;
- (void)PU_followersaccount:(NSString*)AccountId last_id:(NSString*)Last_Id per_page:(NSInteger)Per_Page;
- (void)PU_followingsaccount:(NSString*)AccountId last_id:(NSString*)Last_Id per_page:(NSInteger)Per_Page;

- (void)PU_bulkaccounts:(NSMutableArray<NSString*>*)Accounts;

- (void)PU_updateaccount:(NSString*)AccountId fields:(NSDictionary*)Fields;
- (void)PU_updateaccount:(NSString*)AccountId fields:(NSDictionary*)Fields withRefCode:(NSString *)refCode;
/*
 * PodName : payment-coupon-pod
 */
#pragma mark - payment-coupon
- (void)PC_addcard:(PC_obj_card*)Info; //
- (void)PC_listcardByAccountId:(NSString *)accountId;
- (void)PC_listcard; //
- (void)PC_listCashOutcard;
- (void)PC_listiban:(NSString *)accountId;
- (void)PC_setibandefault:(NSString *)accountId iban:(NSString *)iban;
- (void)PC_deletecard:(NSString*)CardToken; //
- (void)PC_defaultcard:(NSString*)CardToken isDefault:(NSString*)isDefault ; //
- (void)PC_payment_init:(PC_obj_payinit*)InitInfo; //
- (void)PC_paymentWithToken:(NSString*)Token enc:(NSString*)ENC; //

- (void)PD_addpod:(PD_obj_pod*)Info; //
- (void)PD_listpod:(NSString*)AccountId; //
- (void)PD_deletepod:(NSString*)PODId; //
- (void)PD_costWithInfo:(PD_obj_cost*)Info;

- (void)CO_listcoupon:(NSString*)AccountId;
- (void)CO_savecoupon:(NSString*)RefCode;
- (void)CO_deletecoupon:(NSString*)RefCode;
- (void)CO_infocoupon:(NSString*)RefCode;
- (void)CO_statecoupon:(NSString*)RefCode;
- (void)CO_synccoupon;

- (void)PC_paymenthistory:(NSString*)last_id perpage:(NSInteger)PerPage order_type:(int)OrderType accountId:(NSString *)accountId;
- (void)PC_paymenthistory:(NSString*)last_id perpage:(NSInteger)PerPage accountId:(NSString *)accountId;
- (void)PC_paymentdetails:(NSString*)order_id accountId:(NSString *)accountId;

- (void)PC_getrsakey;

- (void)CL_getClubMerchants:(NSString*)AccountId;
- (void)CL_getClubLevels:(NSString*)AccountId;
- (void)CL_getLevelInfo:(NSString*)ClubId levelid:(NSString*)LevelId;
- (void)CL_getLevelPlans:(NSString*)ClubId levelid:(NSString*)LevelId;
- (void)CL_getMerchantClubs:(NSString*)AccountId;
- (void)CL_getUserClubs:(NSString*)AccountId;
- (void)CL_postRegisterPlan:(NSString*)ClubId levelid:(NSString*)LevelId planid:(NSString*)PlanId;
- (void)CL_postVerifyPay:(NSString*)token;
- (void)CL_getLevelMerchants:(NSString*)ClubId levelid:(NSString*)LevelId;
- (void)CL_getMerchantRegisteredClub:(NSString*)AccountId;
- (void)CL_getMerchants:(NSString *)AccountId;

- (void)PC_version:(UP_obj_checker*)Body;
  
- (void)PC_cashout:(PAY_obj_cashout*)Body cardhash:(NSString*)CardHash accountId :(NSString*)Id ;
- (void)PC_cashoutlimits:(NSString*)CardHash;
- (void)PC_otpToResetWalletPinCardhash:(NSString*)CardHash accountId: (NSString*)Id;
- (void)PC_resetWalletpin:(NSString*)otp newPin:(NSString*)newPIN cardhash:(NSString*)CardHash accountId: (NSString*)Id;
- (void)PC_walletpin:(NSString*)newPIN oldpin:(NSString*)oldPIN cardhash:(NSString*)CardHash;
- (void)PC_walletpin:(NSString*)newPIN oldpin:(NSString*)oldPIN cardhash:(NSString*)CardHash accountId: (NSString*)Id;
- (void)PC_cashoutconfirm:(NSString*)Card cardToken:(NSString*)CardTo amount:(NSInteger)Amount accountId :(NSString*)Id;


#pragma mark - qrcode
- (void)MC_getqrcodewithid:(NSString*)Id;

/*
 * PodName : product-cart
 */
#pragma mark - product-cart
- (void)CP_listproduct:(NSString*)AccountId page:(NSInteger)Page categoryid:(NSString*)CategoryId;
- (void)CP_getproduct:(NSString*)ProductId ownerid:(NSString*)OwnerId;
- (void)CP_gettransport:(NSString*)TransportId;
- (void)CP_getcategories:(NSString*)AccountId parent:(NSString*)Parent;


/*
 * PodName : timeline
 */
#pragma mark - timeline
- (void)TL_timeline:(NSString*)AccountId last_id:(NSString*)Last_Id perpage:(NSInteger)PerPage getposts:(BOOL)GetPosts; //
- (void)TL_likepost:(NSString*)PostId; //
- (void)TL_dislikepost:(NSString*)PostId; //
- (void)TL_likedby:(NSString*)PostId last_id:(NSString*)Last_Id perpage:(NSInteger)PerPage;
- (void)TL_comments:(NSString*)PostId authorid:(NSString*)authorId last_id:(NSString*)Last_Id perpage:(NSInteger)PerPage;
- (void)TL_deletepost:(NSString*)PostId; //
- (void)TL_sendcomment:(NSString*)PostId authorid:(NSString*)authorId content:(NSString*)Content;

- (void)TL_contactsync:(NSMutableArray<TL_obj_contact*>*)Contacts;
- (void)TL_bulkposts:(NSMutableArray<NSString*>*)Posts;

- (void)TL_getactivity:(NSString*)accountId type:(NSString*)type last_ts:(NSInteger)last_ts per_page:(NSInteger)per_page;

/*
 * PodName : settings
 */
#pragma mark - settings
- (void)ST_citylist;
- (void)ST_provincelist;
- (void)ST_updatepaymentform:(st_obj_paymentform*)PaymentForm;
- (void)ST_getpaymentform;

/*
 * PodName : newpost
 */
#pragma mark - new post
- (void)NP_newpost:(NP_obj_newpost*)Post;

/*
 * PodName : fileservice
 */
#pragma mark - fileservice
- (void)FS_upload:(NSMutableArray*)Files;
//Against pattern of method in this class, below method only return full path of image to download by image extention
- (NSString *)FS_getFileURL:(NSString *)filePath;
@end







