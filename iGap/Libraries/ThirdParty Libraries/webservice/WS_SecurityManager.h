//
//  WS_Token.h
//  webservice
//
//  Created by Amir Soleimani on 8/26/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyChainHeader.h"

@interface WS_SecurityManager : NSObject

- (void)Clear;

- (NSString *)getSSOId;

- (NSString*)getJWT;
- (void)setJWT:(NSString*)Value;

- (NSString*)getTokenType;
- (void)setTokenType:(NSString*)Value;

- (NSString*)getRefreshToken;
- (void)setRefreshToken:(NSString*)Value;

- (NSString*)getExpiresIn;
- (void)setExpiresIn:(NSString*)Value;

- (void)setOfflinePublicKey:(NSString*)PubKey;
- (NSString*)getOfflinePublicKey;


@end
