//
//  UIFont+IRANSansMobile.h
//  maincore
//
//  Created by Amir Soleimani on 7/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIFont (IRANSansMobile)

+ (instancetype)openIRANSansFontOfSize:(CGFloat)size;
+ (instancetype)openIRANSansUltraLightFontOfSize:(CGFloat)size;
+ (instancetype)openIRANSansLightFontOfSize:(CGFloat)size;
+ (instancetype)openIRANSansMediumFontOfSize:(CGFloat)size;
+ (instancetype)openIRANSansBoldFontOfSize:(CGFloat)size;

@end
