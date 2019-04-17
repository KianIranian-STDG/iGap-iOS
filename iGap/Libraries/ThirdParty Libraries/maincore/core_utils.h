//
//  core_utils.h
//  core_utils
//
//  Created by Amir Soleimani on 7/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "RSAEncryption.h"
//#import "RSA.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface core_utils : NSObject

+ (NSBundle *)getResourcesBundle;
+ (NSBundle *)getResourcesBundleForClass:(id)Class resource:(NSString*)Resource;
+ (void) SwitchEngine:(UIViewController *)VC;
//--
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (CAShapeLayer*)DrawLine:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 linewidth:(float)LineWidth color:(CGColorRef)Color;
+ (NSString *)CardNumberAsString:(NSString*)originalString;
+ (NSString *)ExpireDateAsString:(NSString*)originalString;
+ (NSString *)CreateTimeSuggest:(long)Create;
+ (UIColor *)CouponColorHandler:(int)CouponType;
+ (UIColor *)RateColorHandler:(int)RateValue;
+ (UIColor *)RateBorderColorHandler:(int)RateValue;
+ (void)CreateBackLightToolbar;
+ (void)RemoveBackLightToolbar;
+ (NSString *)CurrencyStrcutre:(long)Amount;
+ (NSString *)CurrencyStrcutrePersian:(long)Amount;
+ (NSString *)languageForString:(NSString *)text;
+ (NSAttributedString*)LabelSetSpaceLine:(NSString*)Text space:(int)Space;
+ (NSAttributedString*)LabelSetSpaceLineRight:(NSString*)Text space:(int)Space;
+ (float)getHeightForText:(NSString*)text withFont:(UIFont*)font andWidth:(float)width attr:(NSDictionary<NSString*,id>*)Attr;
+ (NSString*)convertEnNumberToFarsi:(NSString*)number;
+ (NSString*)convertEnNumberToFarsiInString:(NSString*)Number;
+ (UIColor*)colorWithHexString:(NSString*)hex;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSString*)EmojiRate:(int)Value;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width;
+ (NSString*)DetectSearchDefaultPicture:(int)Type;
+ (NSString*)DetectDefaultPicture:(int)isUserType;
+ (NSString *)MicroToShamsi:(long)Micro;
+ (NSString*)DetectAccountList:(int)Type;
+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;
+ (CGFloat)heightOfString:(NSString *)string withFont:(UIFont *)font;
+ (NSString *)CreateTimeSuggestPersian:(long)Create;
//+ (NSString*)RSA:(NSString*)D;
+ (NSArray*)imageURLSplit:(NSString*)URL;
+ (NSMutableDictionary*)URLParse:(NSString*)URL;
+ (BOOL)isNumber:(NSString*)string;
+ (void)setStatusBarBackgroundColor:(UIColor *)color;
+ (UIColor*)getRateColor:(float)Rate;
+ (NSString *)PriceCurrencyString:(NSUInteger)Price;
+ (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font; //NEW
+ (NSString *)hexStringFromColor:(UIColor *)color;
+ (NSString*)fileuploadName:(NSData*)Response;
+ (UIImage*)qrcodeWithValue:(NSString*)Value squaresize:(float)SquareSize;

+ (float)getScreenHeight;
+ (float)getScreenWidth;
+ (float)bottomSafe;
+ (float)topSafe;

/*
 * description : Micro (13len)
 */
+ (NSString*)ConvertMicrotimeToPersian:(NSInteger)Micro;

@end


