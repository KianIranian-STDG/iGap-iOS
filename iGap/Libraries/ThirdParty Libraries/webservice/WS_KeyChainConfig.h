//
//  WS_KeyChainConfig.h
//  webservice
//
//  Created by Amir Soleimani on 8/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct KEYCHAINCONFIG {
    __unsafe_unretained NSString *service_name;
} KEYCHAINCONFIG;

@interface WS_KeyChainConfig : NSObject

+ (KEYCHAINCONFIG)getconfig;

@end
