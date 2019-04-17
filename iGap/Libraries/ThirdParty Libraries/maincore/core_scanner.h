//
//  core_scanner.h
//  maincore
//
//  Created by Amir Soleimani on 8/27/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface core_scanner : NSObject

+ (NSString*)coupon_qrcode:(NSString*)RefCode accountid:(NSString*)AccountId;
+ (NSString*)offlinepay_qrcode:(NSString*)pubkey data:(NSDictionary*)Data ownerid:(NSString*)OwnerId;
+ (NSString*)profile_qrcode:(NSString*)AccountId type:(NSInteger)AccountType;
+ (NSString*)payment:(NSString*)AccountId;

@end

