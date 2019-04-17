//
//  WS_methods.m
//  webservice
//
//  Created by benyamin mokhtarpour on 8/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "WS_methods.h"
#import "WS_SecurityManager.h"

@implementation WS_methods {
    NSString *myId;
}

- (id)initWithDelegate:(id)delegate failedDialog:(BOOL)failedDialog {
    self = [super initWithDelegate:delegate failedDialog:failedDialog];
    if (self) {
        myId = [[[WS_SecurityManager alloc] init] getSSOId];
    }
    return self;
}

/*
 * Global
 */
- (void)GetURL:(NSString*)URL {
    [self Call:URL body:@{} request:@"GET" auth:true];
}

- (void)GetZeus {
    [self Call:@"https://api.raad.cloud/zelda/v3.3/" body:@{} request:@"GET" auth:true];
}

/*
 * PodName : push notification
 */
- (void)PN_updatetoken:(PN_obj_pushaction*)tokens {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@",[self ServiceURL:API_SERVICE_PUSH],@"/v3/user/",myId];
    [self Call:MethodURL body:[tokens ReturnJSON] request:@"PATCH" auth:true];
}

- (void)logout:(NSString*)token {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/logout"];
    [self Call:MethodURL body:@{@"removetoken":@[token]} request:@"POST" auth:true];
}

/*
 * PodName : userauth
 */
- (void)AU_request_otp:(NSString*)MobileNumber callTo:(BOOL)byCall {
	NSDictionary *bodyrequest = @{@"phone":MobileNumber, @"call_to": [NSNumber numberWithBool:byCall]};
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/auth/otp"];
    
    [self setCheckIsOld:true];
    [self Call:MethodURL body:bodyrequest request:@"POST" auth:false];
}


- (void)AU_verify_otp:(NSString *)MobileNumber otp:(NSString*)OTP {
    NSDictionary *bodyrequest = @{@"phone":MobileNumber,
                                  @"otp":OTP,
                                  @"devicetoken":[[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"],
                                  @"os":@"ios",
                                  @"appid":@"59bec3fa0eca810001ceeb86"
                                  };
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/auth/otp/verify"];
    
    [self setCheckIsOld:true];
    [self Call:MethodURL body:bodyrequest request:@"POST" auth:false];
}


- (void)refresh_token {
    //this method is implemented in super class
    [super refresh_token];
}


- (void)AU_register_account:(PU_obj_account*)Info {
    NSString *URL = [NSString stringWithFormat:@"/v3/accounts/%@",myId];
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],URL];
    
    [self setCheckIsOld:true];
    [self Call:MethodURL body:[Info JSON_Register] request:@"PUT" auth:true];
}

- (void)AU_2StepVerification:(NSString *)oldPassword newPassword:(NSString *)newPassword {
    
    NSDictionary *bodyrequest = @{@"old_password":oldPassword,
                                  @"new_password":newPassword
                                  };
    NSString *URL = [NSString stringWithFormat:@"/v3/auth/2step_verification/accounts/%@",myId];
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],URL];

    [self setCheckIsOld:true];
    [self Call:MethodURL body:bodyrequest request:@"POST" auth:true];
}

- (void)AU_2StepVerificationLogin:(NSString *)password {
    
    NSDictionary *bodyrequest = @{@"password":password
                                  };
    NSString *URL = [NSString stringWithFormat:@"/v3/auth/2step_verification/accounts/%@/login",myId];
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],URL];

    [self setCheckIsOld:true];
    [self Call:MethodURL body:bodyrequest request:@"POST" auth:true];
}

/*
 * PodName : explore-search-map
 */
- (void)EX_searchquery:(EX_obj_searchquery*)query {
    NSString *QueryString = @"/v3";
    switch (query.type) {
        case SEARCH_TYPE_USER:
        case SEARCH_TYPE_PAGE:
            QueryString = [QueryString stringByAppendingString:@"/accounts?"];
            break;
        case SEARCH_TYPE_COUPON:
            QueryString = [QueryString stringByAppendingString:@"/coupons?"];
            break;
        case SEARCH_TYPE_PRODUCT:
            QueryString = [QueryString stringByAppendingString:@"/products?"];
            break;
        default:
            QueryString = [QueryString stringByAppendingString:@"/search?"];
            break;
    }
    //--
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_SEARCH],QueryString];
    [self Call:MethodURL body:[query returnJSON] request:@"GET" auth:false];
}

- (void)EX_explore {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_EXPLORE],@"/v3/explore"];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}




/*
 * PodName : page-user-profile
 */
- (void)PU_getaccountinfo:(PU_obj_account*)Info mod:(NSInteger)Mod {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/accounts/",Info.account_id];
    [self Call:MethodURL body:@{@"mod":[NSNumber numberWithInteger:Mod]} request:@"GET" auth:true];
}

- (void)PU_getsocialinfo:(PU_obj_account*)Info {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",Info.account_id];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}


- (void)PU_followaccount:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/follow/%@",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",myId,AccountId];
    [self Call:MethodURL body:@{} request:@"POST" auth:true];
}

- (void)PU_unfollowaccount:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/follow/%@",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",myId,AccountId];
    [self Call:MethodURL body:@{} request:@"DELETE" auth:true];
}

- (void)PU_getAccountingInfo:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/accounts/",AccountId, @"?mod=1"];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PU_getAccountBulk:(NSMutableArray<NSString*>*)Ids {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/accounts/bulk"];
    [self Call:MethodURL postbody:@[Ids] request:@"POST" auth:true];
}

- (void)PU_followersaccount:(NSString*)AccountId last_id:(NSString*)Last_Id per_page:(NSInteger)Per_Page {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/followers",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",AccountId];
    [self Call:MethodURL body:@{@"last_id":Last_Id,@"per_page":[NSNumber numberWithInteger:Per_Page]} request:@"GET" auth:true];
}

- (void)PU_followingsaccount:(NSString*)AccountId last_id:(NSString*)Last_Id per_page:(NSInteger)Per_Page {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/followings",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",AccountId];
    [self Call:MethodURL body:@{@"last_id":Last_Id,@"per_page":[NSNumber numberWithInteger:Per_Page]} request:@"GET" auth:true];
}

- (void)PU_bulkaccounts:(NSMutableArray<NSString*>*)Accounts {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/bulk",[self ServiceURL:API_SERVICE_SOCIAL]];
    [self Call:MethodURL body:Accounts request:@"POST" auth:true];
}

- (void)PU_updateaccount:(NSString*)AccountId fields:(NSDictionary*)Fields {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/accounts/",AccountId];
    [self Call:MethodURL body:Fields request:@"PUT" auth:true];
}

- (void)PU_updateaccount:(NSString*)AccountId fields:(NSDictionary*)Fields withRefCode:(NSString *)refCode {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/?ref_code=%@",[self ServiceURL:API_SERVICE_ACCOUNT],@"/v3/accounts/",AccountId,refCode];
    [self Call:MethodURL body:Fields request:@"PUT" auth:true];
}

/*
 * PodName : payment-coupon-pod
 */
- (void)PC_addcard:(PC_obj_card*)Info {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/cards"];
    [self Call:MethodURL body:[Info JSON_addcard] request:@"POST" auth:true];
}

- (void)PC_listCashOutcard {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/cards?cashout=true"];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_listcardByAccountId:(NSString *)accountId {
//	https://api.raad.cloud/payment/v3/accounts/59abff37b164681dd837d110/cards
	NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/accounts/",accountId, @"/cards"];
	[self Call:MethodURL body:@{} request:@"GET" auth:true];
}
- (void)PC_listcard {
		//accounts/:id/
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/cards"];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_listiban:(NSString *)accountId {
	
	NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/accounts/",accountId, @"/ibans"];
	[self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_setibandefault:(NSString *)accountId iban:(NSString *)iban{
	
	NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/accounts/",accountId, @"/ibans"];
	[self Call:MethodURL body:@{@"default":@true, @"iban" : iban} request:@"POST" auth:true];
}
- (void)PC_deletecard:(NSString*)CardToken {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@/%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/cards",CardToken];
    [self Call:MethodURL body:@{} request:@"DELETE" auth:true];
}


- (void)PC_defaultcard:(NSString*)CardToken isDefault:(NSString*)isDefault {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@/%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/cards",CardToken];
    [self Call:MethodURL body:@{@"default":isDefault} request:@"PUT" auth:true];
}

- (void)PC_payment_init:(PC_obj_payinit*)InitInfo {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/init"];
    [self Call:MethodURL body:[InitInfo returnJSONRequest] request:@"POST" auth:true];
}

- (void)PC_paymentWithToken:(NSString*)Token enc:(NSString*)ENC {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_PAYMENT],@"/v3/pay"];
    [self Call:MethodURL body:@{@"token":Token,@"card_info":ENC} request:@"POST" auth:true];
}


- (void)PD_addpod:(PD_obj_pod*)Info {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/%@", [self ServiceURL:API_SERVICE_DELIVERY], @"/v3/accounts/", myId, @"pod?mod=0"];
    [self Call:MethodURL body:[Info JSON_addpod] request:@"POST" auth:true];
}

- (void)PD_listpod:(NSString*)AccountId {
    NSString *CustommyId;
    if (AccountId == nil) {
        CustommyId = myId;
    } else {
        CustommyId = AccountId;
    }
    
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/%@", [self ServiceURL:API_SERVICE_DELIVERY], @"/v3/accounts/", CustommyId, @"pod"];
    [self Call:MethodURL body:@{@"mod":@0} request:@"GET" auth:true];
}

- (void)PD_deletepod:(NSString*)PODId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/pod/%@", [self ServiceURL:API_SERVICE_DELIVERY], @"/v3/accounts/", myId, PODId];
    [self Call:MethodURL body:@{} request:@"DELETE" auth:true];
}

- (void)PD_costWithInfo:(PD_obj_cost*)Info {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@", [self ServiceURL:API_SERVICE_DELIVERY], @"/v3/calculate"];
    [self Call:MethodURL body:[Info JSON_Return] request:@"GET" auth:true];
}



- (void)CO_listcoupon:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@", [self ServiceURL:API_SERVICE_COUPON], @"/v3/accounts/coupons/", AccountId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CO_savecoupon:(NSString*)RefCode {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@", [self ServiceURL:API_SERVICE_COUPON], @"/v3/coupons"];
    [self Call:MethodURL body:@{@"coupons_ref_code":RefCode} request:@"POST" auth:true];
}

- (void)CO_deletecoupon:(NSString*)RefCode {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@", [self ServiceURL:API_SERVICE_COUPON], @"/v3/coupons/", RefCode];
    [self Call:MethodURL body:@{} request:@"DELETE" auth:true];
}

- (void)CO_infocoupon:(NSString*)RefCode {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@", [self ServiceURL:API_SERVICE_COUPON], @"/v3/coupons/info/", RefCode];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CO_statecoupon:(NSString*)RefCode {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@", [self ServiceURL:API_SERVICE_COUPON], @"/v3/coupons/state/", RefCode];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CO_synccoupon {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@", [self ServiceURL:API_SERVICE_COUPON], @"/v3/coupons"];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_paymenthistory:(NSString*)last_id perpage:(NSInteger)PerPage accountId:(NSString *)accountId {
    [self PC_paymenthistory:last_id perpage:PerPage order_type:0 pre_orders:YES accountId:accountId];
}

- (void)PC_paymenthistory:(NSString*)last_id perpage:(NSInteger)PerPage order_type:(int)OrderType pre_orders:(BOOL)Pre_Orders accountId:(NSString *)accountId {
    NSDictionary *JSON;
	
	if (accountId == nil) { accountId = myId;}
    if (OrderType == 0)
        JSON = @{@"last_id":last_id,@"per_page":[NSNumber numberWithInteger:PerPage],@"pre_orders":[NSNumber numberWithBool:Pre_Orders]};
    else
        JSON = @{@"last_id":last_id,@"per_page":[NSNumber numberWithInteger:PerPage],@"order_type":[NSNumber numberWithInteger:OrderType],@"pre_orders":[NSNumber numberWithBool:Pre_Orders]};
    
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/orders", [self ServiceURL:API_SERVICE_PAYMENT], @"/v3/accounts/", accountId];
    [self Call:MethodURL body:JSON request:@"GET" auth:true];
}

- (void)PC_paymentdetails:(NSString*)order_id accountId:(NSString *)accountId {
	
	if (accountId == nil) { accountId = myId;}
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/orders/%@", [self ServiceURL:API_SERVICE_PAYMENT], @"/v3/accounts/", accountId, order_id];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_getrsakey {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@", [self ServiceURL:API_SERVICE_PAYMENT], @"/v3/key"];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

/*
 * PodName : Product-Cart
 */
- (void)CP_listproduct:(NSString*)AccountId page:(NSInteger)Page categoryid:(NSString*)CategoryId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@",[self ServiceURL:API_SERVICE_PRODUCT],@"/v3/merchants/",AccountId];
    NSDictionary *Params = @{};
    if (CategoryId != nil) {
        MethodURL = [MethodURL stringByAppendingString:@"/products/filters"];
        Params = @{@"categories":CategoryId};
    }
    MethodURL = [MethodURL stringByAppendingString:[NSString stringWithFormat:@"?page=%ld",Page]];
    [self Call:MethodURL body:Params request:@"GET" auth:true];
}

- (void)CP_getproduct:(NSString*)ProductId ownerid:(NSString*)OwnerId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@%@%@",[self ServiceURL:API_SERVICE_PRODUCT],@"/v3/merchants/",OwnerId,@"/product/",ProductId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CP_gettransport:(NSString*)TransportId  {
	NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@",[self ServiceURL:API_SERVICE_TRANSPORT],@"/v3/transports/",TransportId];
	[self Call:MethodURL body:@{} request:@"GET" auth:true];
}
	
- (void)CP_getcategories:(NSString*)AccountId parent:(NSString*)Parent {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@",[self ServiceURL:API_SERVICE_PRODUCT],@"/v3.1/categories/merchants/",AccountId];
    if (Parent != nil)
        MethodURL = [MethodURL stringByAppendingString:[NSString stringWithFormat:@"/%@",Parent]];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}


/*
 * PodName : Timeline
 */
- (void)TL_timeline:(NSString*)AccountId last_id:(NSString*)Last_Id perpage:(NSInteger)PerPage getposts:(BOOL)GetPosts {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@%@",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",AccountId,@"/timeline"];
    [self Call:MethodURL body:@{@"last_id":Last_Id,@"per_page":[NSNumber numberWithInteger:PerPage],@"get_posts":[NSNumber numberWithBool:GetPosts]} request:@"GET" auth:true];
}

- (void)TL_likepost:(NSString*)PostId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/likes/%@",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",myId,PostId];
    [self Call:MethodURL body:@{} request:@"POST" auth:true];
}

- (void)TL_dislikepost:(NSString*)PostId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@/likes/%@",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",myId,PostId];
    [self Call:MethodURL body:@{} request:@"DELETE" auth:true];
}

- (void)TL_likedby:(NSString*)PostId last_id:(NSString*)Last_Id perpage:(NSInteger)PerPage {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@/posts/%@/likes",[self ServiceURL:API_SERVICE_SOCIAL],myId,PostId];
    [self Call:MethodURL body:@{@"last_id":Last_Id,@"per_page":[NSNumber numberWithInteger:PerPage]} request:@"GET" auth:true];
}

- (void)TL_comments:(NSString*)PostId authorid:(NSString*)authorId last_id:(NSString*)Last_Id perpage:(NSInteger)PerPage {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@/posts/%@/comments",[self ServiceURL:API_SERVICE_SOCIAL],myId,PostId];
    [self Call:MethodURL body:@{@"last_id":Last_Id,@"per_page":[NSNumber numberWithInteger:PerPage]} request:@"GET" auth:true];
}

- (void)TL_deletepost:(NSString*)PostId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@/posts/%@",[self ServiceURL:API_SERVICE_SOCIAL],myId,PostId];
    [self Call:MethodURL body:@{} request:@"DELETE" auth:true];
}

- (void)TL_sendcomment:(NSString*)PostId authorid:(NSString*)authorId content:(NSString*)Content {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@/posts/%@/comments",[self ServiceURL:API_SERVICE_SOCIAL],myId,PostId];
    [self Call:MethodURL body:@{@"content":Content} request:@"POST" auth:true];
}


- (void)TL_contactsync:(NSMutableArray<TL_obj_contact*>*)Contacts {
    NSMutableArray *ContactRequest = [[NSMutableArray alloc] init];
    for (TL_obj_contact *c in Contacts)
        [ContactRequest addObject:[c ReturnJSON]];
    //--
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@/contacts",[self ServiceURL:NEW_API_SERVICE_ACCOUNT],myId];
    NSLog(@"%@", ContactRequest);
    NSLog(@"%@", MethodURL);
    [self Call:MethodURL body:ContactRequest request:@"POST" auth:true];
}

- (void)TL_bulkposts:(NSMutableArray<NSString*>*)Posts {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/posts/list?per_page=30",[self ServiceURL:API_SERVICE_SOCIAL]];
    [self Call:MethodURL body:Posts request:@"POST" auth:true];
}

- (void)TL_getactivity:(NSString*)accountId type:(NSString*)type last_ts:(NSInteger)last_ts per_page:(NSInteger)per_page {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@%@%@",[self ServiceURL:API_SERVICE_SOCIAL],@"/v3/accounts/",accountId,@"/activities"];
    [self Call:MethodURL body:@{@"last_ts":[NSNumber numberWithInteger:last_ts],@"per_page":[NSNumber numberWithInteger:per_page],@"type":type} request:@"GET" auth:true];
}


#pragma mark - Settings
- (void)ST_citylist {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_GEO],@"/v3/cities"];
    
    [self setCheckIsOld:true];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)ST_provincelist {
    NSString *MethodURL = [NSString stringWithFormat:@"%@%@",[self ServiceURL:API_SERVICE_GEO],@"/v3/provinces"];
    
    [self setCheckIsOld:true];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)ST_updatepaymentform:(st_obj_paymentform*)PaymentForm {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@/payment",[self ServiceURL:API_SERVICE_ACCOUNT],myId];
    [self Call:MethodURL body:[PaymentForm ReturnJSON_Update] request:@"PUT" auth:true];
}


- (void)ST_getpaymentform {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@/payment",[self ServiceURL:API_SERVICE_ACCOUNT],myId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}


#pragma mark - Payment
- (void)CL_getClubMerchants:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/clubs/%@/merchants",[self ServiceURL:API_SERVICE_CLUB],AccountId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CL_getClubLevels:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/clubs/%@/levels",[self ServiceURL:API_SERVICE_CLUB],AccountId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CL_getLevelInfo:(NSString*)ClubId levelid:(NSString*)LevelId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/clubs/%@/levels/%@",[self ServiceURL:API_SERVICE_CLUB],ClubId,LevelId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CL_getLevelPlans:(NSString*)ClubId levelid:(NSString*)LevelId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/clubs/%@/levels/%@/plans",[self ServiceURL:API_SERVICE_CLUB],ClubId,LevelId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CL_getMerchantClubs:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/merchants/%@/clubs",[self ServiceURL:API_SERVICE_CLUB],AccountId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CL_getUserClubs:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/users/%@/clubs",[self ServiceURL:API_SERVICE_CLUB],AccountId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CL_postRegisterPlan:(NSString*)ClubId levelid:(NSString*)LevelId planid:(NSString*)PlanId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/clubs/%@/levels/%@/plans/%@/register",[self ServiceURL:API_SERVICE_CLUB],ClubId,LevelId,PlanId];
    [self Call:MethodURL body:@{} request:@"POST" auth:true];
}

- (void)CL_postVerifyPay:(NSString*)token {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/register/verify",[self ServiceURL:API_SERVICE_CLUB]];
    [self Call:MethodURL body:@{@"token":token} request:@"POST" auth:true];
}

- (void)CL_getLevelMerchants:(NSString*)ClubId levelid:(NSString*)LevelId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/clubs/%@/levels/%@/merchants",[self ServiceURL:API_SERVICE_CLUB],ClubId,LevelId];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)CL_getMerchantRegisteredClub:(NSString*)AccountId {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/merchants/%@/clubs",[self ServiceURL:API_SERVICE_CLUB],AccountId];
    [self Call:MethodURL body:@{@"registered":[NSNumber numberWithBool:YES]} request:@"GET" auth:true];
}

- (void)CL_getMerchants:(NSString *)AccountId{
//	NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts?filters=[{\"bool\":{\"must\":[{\"match\":{\"users.user_id\":\"%@\"}}]}}]",[self ServiceURL:API_SERVICE_SEARCH],AccountId];
	
	NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/merchants?per_page=30&page=1&role=admin&role=finance",[self ServiceURL:API_SERVICE_ACCOUNT]]; 
	[self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_cashout:(PAY_obj_cashout*)Body cardhash:(NSString*)CardHash accountId :(NSString*)Id  {
	if (Id == nil) { Id = myId;}
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/%@/%@",[self ServiceURL:API_SERVICE_CASHOUT],Id,CardHash];
    [self Call:MethodURL body:[Body JSON_requestcashout] request:@"POST" auth:true];
}


- (void)PC_version:(UP_obj_checker*)Body   {
    NSString *MethodURL = [NSString stringWithFormat:@"https://api.raad.cloud/application/v3/version/ios"];
    [self Call:MethodURL body:[Body JSON_requestupdate] request:@"POST" auth:true];
}


- (void)PC_cashoutlimits:(NSString*)CardHash {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/%@/%@/limits",[self ServiceURL:API_SERVICE_CASHOUT],myId,CardHash];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_walletpin:(NSString*)newPIN oldpin:(NSString*)oldPIN cardhash:(NSString*)CardHash {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/password/%@",[self ServiceURL:API_SERVICE_CREDIT],CardHash];
    [self Call:MethodURL body:@{@"old_password":oldPIN,@"new_password":newPIN} request:@"PUT" auth:true];
}

- (void)PC_walletpin:(NSString*)newPIN oldpin:(NSString*)oldPIN cardhash:(NSString*)CardHash accountId: (NSString*)Id {
	NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/password/%@/accounts/%@",[self ServiceURL:API_SERVICE_CREDIT],CardHash,Id];
	[self Call:MethodURL body:@{@"old_password":oldPIN,@"new_password":newPIN} request:@"PUT" auth:true];
}

- (void)PC_otpToResetWalletPinCardhash:(NSString*)CardHash accountId: (NSString*)Id {
	NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/password/%@/accounts/%@",[self ServiceURL:API_SERVICE_CREDIT],CardHash,Id];
	[self Call:MethodURL body:@{} request:@"GET" auth:true];
}

- (void)PC_resetWalletpin:(NSString*)otp newPin:(NSString*)newPIN cardhash:(NSString*)CardHash accountId: (NSString*)Id {
	NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/password/%@/accounts/%@",[self ServiceURL:API_SERVICE_CREDIT],CardHash,Id];
	[self Call:MethodURL body:@{@"OTP":otp,@"old_password":@"",@"new_password":newPIN} request:@"PUT" auth:true];
}
- (void)PC_cashoutconfirm:(NSString*)CardNo cardToken:(NSString*)CardTo amount:(NSInteger)Amount accountId :(NSString*)Id{
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/%@/confirmation",[self ServiceURL:API_SERVICE_CASHOUT],Id];
    [self Call:MethodURL body:@{@"amount":[NSNumber numberWithInteger:Amount],@"card_number":CardNo,@"card_token":CardTo} request:@"GET" auth:true];
}



#pragma mark - qrcode
- (void)MC_getqrcodewithid:(NSString*)Id {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/qr/%@",[self ServiceURL:API_SERVICE_QR],Id];
    [self Call:MethodURL body:@{} request:@"GET" auth:true];
}

#pragma mark -
/*
 * PodName : newpost
 */
- (void)NP_newpost:(NP_obj_newpost*)Post {
    NSString *myId = [[[WS_SecurityManager alloc] init] getSSOId];
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/accounts/%@%@",[self ServiceURL:API_SERVICE_SOCIAL],myId,@"/posts"];
    [self Call:MethodURL body:[Post returnJSONRequest] request:@"POST" auth:true];
}


/*
 * PodName : fileservice
 */
- (void)FS_upload:(NSMutableArray*)Files {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/upload/images",[self ServiceURL:API_SERVICE_FILESERVICE]];
    [self CallMultiPart:MethodURL files:Files auth:true];
}

- (NSString *)FS_getFileURL:(NSString *)filePath {
    NSString *MethodURL = [NSString stringWithFormat:@"%@/v3/%@",[self ServiceURL:API_SERVICE_FILESERVICE], filePath];
    return MethodURL;
}



@end







