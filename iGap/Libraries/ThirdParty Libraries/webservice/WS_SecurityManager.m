//
//  WS_Token.m
//  webservice
//
//  Created by Amir Soleimani on 8/26/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "WS_SecurityManager.h"

@implementation WS_SecurityManager {
    UICKeyChainStore *keychain;
    NSString *KCServiceName;
    NSString *RaadClientServiceName;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        RaadClientServiceName = @"RaadKeyChainService";
        KCServiceName = [WS_KeyChainConfig getconfig].service_name;
        keychain = [UICKeyChainStore keyChainStoreWithService:KCServiceName];
    }
    return self;
}

- (NSDictionary*)JWTJSON {
    NSArray *Split = [[self getJWT] componentsSeparatedByString:@"."];
    if ([Split count] > 0) {
        NSString *Key = [Split objectAtIndex:1];
        int len = Key.length%4;
        for (int i = 0; i < len; i++)
            Key = [Key stringByAppendingString:@"="];
        NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:Key options:0];
        NSString *base64Decoded = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
        NSData *data = [base64Decoded dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return json;
    } else {
        return @{};
    }
}

- (void)Clear {
    [self setJWT:nil];
    [self setExpiresIn:nil];
    [self setTokenType:nil];
    [self setRefreshToken:nil];
}

//--SSO Id (accountid)
- (NSString *)getSSOId {
    NSDictionary *JSON = [self JWTJSON];
    return [JSON objectForKey:@"id"];
}

//--JWT Main
- (NSString*)getJWT {
    if ([KCServiceName isEqualToString:RaadClientServiceName])
        return keychain[@"accesstoken"];
    else
        return keychain[@"merchant_accesstoken"];
}

- (void)setJWT:(NSString*)Value {
    if ([KCServiceName isEqualToString:RaadClientServiceName])
        keychain[@"accesstoken"] = Value;
    else
        keychain[@"merchant_accesstoken"] = Value;
    //--
    if (Value != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[self getSSOId] forKey:@"self.accountid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//--Token Type
- (NSString*)getTokenType {
    if ([KCServiceName isEqualToString:RaadClientServiceName])
        return keychain[@"tokentype"];
    else
        return keychain[@"merchant_tokentype"];
}

- (void)setTokenType:(NSString*)Value {
    if ([KCServiceName isEqualToString:RaadClientServiceName])
        keychain[@"tokentype"] = Value;
    else
        keychain[@"merchant_tokentype"] = Value;
}

//--Refresh Token
- (NSString*)getRefreshToken {
    return keychain[@"refreshtoken"];
}

- (void)setRefreshToken:(NSString*)Value {
    keychain[@"refreshtoken"] = Value;
}

//--Expire In
- (NSString*)getExpiresIn {
    return keychain[@"expiresin"];
}

- (void)setExpiresIn:(NSString*)Value {
    keychain[@"expiresin"] = Value;
}

- (void)setOfflinePublicKey:(NSString*)PubKey {
    keychain[@"offline_pubkey"] = PubKey;
}

- (NSString*)getOfflinePublicKey {
    return keychain[@"offline_pubkey"];
}

@end
