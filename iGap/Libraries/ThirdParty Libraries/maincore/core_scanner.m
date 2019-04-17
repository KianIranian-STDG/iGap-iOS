//
//  core_scanner.m
//  maincore
//
//  Created by Amir Soleimani on 8/27/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "core_scanner.h"
#import "RSA.h"

typedef enum {
    QRCODE_TYPE_PROFILE = 2, //Account Share
    QRCODE_TYPE_PAYMENT = 8,
    QRCODE_TYPE_COUPON = 100, //COUPON
    QRCODE_TYPE_OFFLINEPAY = 110, //OFFLINEPAY
} QRCODE_TYPE;

@implementation core_scanner

+ (NSString*)payment:(NSString*)AccountId {
    NSDictionary *dict = @{@"H":AccountId,@"T":[NSNumber numberWithInt:QRCODE_TYPE_PAYMENT]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    myString = [@"raadapp://?v=" stringByAppendingString:myString];
    return myString;
}

+ (NSString*)coupon_qrcode:(NSString*)RefCode accountid:(NSString*)AccountId {
    NSDictionary *dict = @{@"M":RefCode,@"H":AccountId,@"T":[NSNumber numberWithInt:QRCODE_TYPE_COUPON]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    myString = [@"raadapp://?v=" stringByAppendingString:myString];
    return myString;
}

+ (NSString*)profile_qrcode:(NSString*)AccountId type:(NSInteger)AccountType {
    NSDictionary *dict = @{@"AT":[NSNumber numberWithInteger:AccountType],@"H":AccountId,@"T":[NSNumber numberWithInt:QRCODE_TYPE_PROFILE]};
    NSError *e = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&e];
    if (!jsonData)
        return @"";
    else {
        NSString *myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        myString = [@"raadapp://?v=" stringByAppendingString:myString];
        return myString;
    }
}

+ (NSString*)offlinepay_qrcode:(NSString*)pubkey data:(NSDictionary*)Data ownerid:(NSString*)OwnerId {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Data options:0 error:&err];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *ENC = [RSA encryptString:jsonString publicKey:pubkey];
    
    
    NSDictionary *dict = @{@"H":ENC,@"T":[NSNumber numberWithInt:QRCODE_TYPE_OFFLINEPAY],@"F":OwnerId};
    NSData *returnData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return returnString;
}

@end

