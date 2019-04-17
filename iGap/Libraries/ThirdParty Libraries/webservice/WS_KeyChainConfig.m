//
//  WS_KeyChainConfig.m
//  webservice
//
//  Created by Amir Soleimani on 8/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "WS_KeyChainConfig.h"


@implementation WS_KeyChainConfig

+ (KEYCHAINCONFIG)getconfig {
    struct KEYCHAINCONFIG Config;
    Config.service_name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"KCServiceName"]; //RaadKeyChainService
    return Config;
}

@end
