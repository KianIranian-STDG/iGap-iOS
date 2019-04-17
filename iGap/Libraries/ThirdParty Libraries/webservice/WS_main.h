//
//  WS_main.h
//  webservice
//
//  Created by benyamin Mokhtarpour  on 7/23/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>

typedef enum {
    API_SERVICE_ACCOUNT = 0,
    API_SERVICE_SEARCH = 1,
    API_SERVICE_SOCIAL = 2,
    API_SERVICE_PAYMENT = 3,
    API_SERVICE_DELIVERY = 4,
    API_SERVICE_COUPON = 5,
    API_SERVICE_PRODUCT = 6,
    API_SERVICE_GEO = 7,
    API_SERVICE_EXPLORE = 8,
    API_SERVICE_FILESERVICE = 9,
    API_SERVICE_PUSH = 10,
    API_SERVICE_CLUB = 11,
    API_SERVICE_CASHOUT = 12,
    API_SERVICE_CREDIT = 13,
    API_SERVICE_QR = 14,
    API_SERVICE_SETPASSWORD = 15,
    API_SERVICE_LOGIN = 16,
	API_SERVICE_TRANSPORT = 17,
    NEW_API_SERVICE_ACCOUNT = 18
} API_SERVICES;

NS_ASSUME_NONNULL_BEGIN

@interface WS_main : NSObject

/*
 * Property
 */
@property (nonatomic,weak) id delegate;
@property (nonatomic,strong) AFURLSessionManager *manager;
@property (nonatomic,assign) BOOL CheckIsOld;

/*
 * Methods
 */
- (id)initWithDelegate:(id)delegate failedDialog:(BOOL)failedDialog;
- (void)addSuccessHandler:(void (^ __nullable)(id Response))successhandler;
- (void)addFailedHandler:(void (^ __nullable)(NSDictionary *Response))failedhandler;
- (void)addCancelHandler:(void (^ __nullable)(void))cancelhandler;

- (void)Call:(NSString*)Method postbody:(NSArray*__nonnull)Body request:(NSString*)Request auth:(BOOL)Auth;
- (void)Call:(NSString*)Method body:(id __nonnull)Body request:(NSString*)Request auth:(BOOL)Auth;
- (void)CallMultiPart:(NSString*)Method files:(NSMutableArray*)Files auth:(BOOL)Auth;

- (void)ErrorHandler:(NSDictionary*)Response;

- (void)cancelRequest;

- (NSString*)ServiceURL:(API_SERVICES)ServiceCode;

- (void)refresh_token;

@end


NS_ASSUME_NONNULL_END

