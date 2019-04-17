//
//  UIFont+IRANSansMobile.m
//  maincore
//
//  Created by Amir Soleimani on 7/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "UIFont+IRANSansMobile.h"


@interface KOSFontLoader : NSObject

+ (void)loadFontWithName:(NSString *)fontName;

@end

@implementation KOSFontLoader

+ (void)loadFontWithName:(NSString *)fontName {
    NSURL *fontURL = [[NSBundle mainBundle] URLForResource:fontName withExtension:@"ttf"];
    NSData *fontData;
    
    if (fontURL != nil) {
        fontData = [NSData dataWithContentsOfURL:fontURL];
    } else {
        NSURL *bundleURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"maincore" withExtension:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
        NSURL *fontURL = [bundle URLForResource:fontName withExtension:@"ttf"];
        fontData = [NSData dataWithContentsOfURL:fontURL];
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (font) {
        CFErrorRef error = NULL;
        if (CTFontManagerRegisterGraphicsFont(font, &error) == NO) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:(__bridge NSString *)errorDescription userInfo:@{ NSUnderlyingErrorKey: (__bridge NSError *)error }];
        }
        
        CFRelease(font);
    }
    
    CFRelease(provider);
}

@end

@implementation UIFont (OpenSans)

+ (instancetype)kosLoadAndReturnFont:(NSString *)fontName size:(CGFloat)fontSize onceToken:(dispatch_once_t *)onceToken fontFileName:(NSString *)fontFileName {
    dispatch_once(onceToken, ^{
        [KOSFontLoader loadFontWithName:fontFileName];
    });
    
    return [self fontWithName:fontName size:fontSize];
}


+ (instancetype)openIRANSansFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    return [self kosLoadAndReturnFont:@"IRANSansMobile" size:size onceToken:&onceToken fontFileName:@"IRANSansMobile"];
}


+ (instancetype)openIRANSansUltraLightFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    return [self kosLoadAndReturnFont:@"IRANSansMobile-UltraLight" size:size onceToken:&onceToken fontFileName:@"IRANSansMobile-UltraLight"];
}


+ (instancetype)openIRANSansLightFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    return [self kosLoadAndReturnFont:@"IRANSansMobile-Light" size:size onceToken:&onceToken fontFileName:@"IRANSansMobile-Light"];
}


+ (instancetype)openIRANSansMediumFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    return [self kosLoadAndReturnFont:@"IRANSansMobile-Medium" size:size onceToken:&onceToken fontFileName:@"IRANSansMobile-Medium"];
}


+ (instancetype)openIRANSansBoldFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    return [self kosLoadAndReturnFont:@"IRANSansMobile-Bold" size:size onceToken:&onceToken fontFileName:@"IRANSansMobile-Bold"];
}


@end
