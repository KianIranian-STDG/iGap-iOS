//
//  NSBundle+Language.m
//  app
//
//  Created by Alireza Ghias on 7/26/1395 AP.
//  Copyright © 1395 iccima. All rights reserved.
//

#import "NSBundle+Language.h"
#import <objc/runtime.h>

static const char kBundleKey = 0;

@interface BundleEx : NSBundle

@end

@implementation BundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
	NSBundle *bundle = objc_getAssociatedObject(self, &kBundleKey);
	if (bundle) {
		return [bundle localizedStringForKey:key value:value table:tableName];
	}
	else {
		return [super localizedStringForKey:key value:value table:tableName];
	}
}

@end

@implementation NSBundle (Language)

+ (void)setLanguage:(NSString *)language
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		object_setClass([NSBundle mainBundle],[BundleEx class]);
	});
	id value = language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil;
	objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
