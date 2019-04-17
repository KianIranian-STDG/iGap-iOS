//
//  core_utils.m
//  maincore
//
//  Created by Amir Soleimani on 7/4/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#ifndef core_utils_h
#define core_utils_h

#import "maincore/core_utils.h"

/*
 * IMP
 */
@implementation core_utils


+ (float)topSafe {
    float topSafe = 0;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:
            {
                if (@available(iOS 11.0, *))
                    topSafe = 25;//[[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
            }
                break;
        }
    }
    return topSafe;
}

+ (float)bottomSafe {
    float BottomSafe = 0;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:
            {
                if (@available(iOS 11.0, *))
                    BottomSafe = 20;//[[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
            }
                break;
        }
    }
    return BottomSafe;
}

+ (float)getScreenHeight {
    float BottomSafe = [self bottomSafe];
    return [UIScreen mainScreen].bounds.size.height;//-BottomSafe;
}

+ (float)getScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

//NSString *PublicKey = @"-----BEGIN PUBLIC KEY----- MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC6D8dUV5yJBTki4ab2t6a8vd+U\n5OUpG7IZSp+MajLsTkURqhZW4K1mlOJLd6HEwDO9F1T249bogij1thNctBC92fVQ\nBWMdsR3VHqIpa52OJP3tLkUNYxNLQTlLf6EcnV67zC7tmEVby+ogFwRZ++XtoKn1\nsrolEMnpeaxW4WNfrwIDAQAB\n-----END PUBLIC KEY-----";

+ (void) SwitchEngine:(UIViewController *)VC {
    [[UIApplication sharedApplication] delegate].window.rootViewController = VC;
    [[[UIApplication sharedApplication] delegate].window makeKeyWindow];
    [[[UIApplication sharedApplication] delegate].window makeKeyAndVisible];
}

+ (NSBundle *)getResourcesBundleForClass:(id)Class resource:(NSString*)Resource {
    NSURL *bundleURL = [[NSBundle bundleForClass:Class] URLForResource:Resource withExtension:@"bundle"];
    if (bundleURL == nil)
        bundleURL = [[NSBundle mainBundle] URLForResource:Resource withExtension:nil];
    //--
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    return bundle;
}

+ (NSBundle *)getResourcesBundle {
    NSURL *bundleURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"maincore" withExtension:@"bundle"];
    if (bundleURL == nil)
        bundleURL = [[NSBundle mainBundle] URLForResource:@"maincore" withExtension:nil];
    //--
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    return bundle;
}

+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    if ([string length] == 0 || string == nil)
        string = @" ";
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

+ (CGFloat)heightOfString:(NSString *)string withFont:(UIFont *)font {
    if ([string length] == 0 || string == nil)
        string = @" ";
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (NSString *)MicroToShamsi:(long)Micro {
    
    NSTimeInterval timestamp = (NSTimeInterval)Micro;
    NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSCalendar *hijriCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    NSDateComponents *hijriComponents = [hijriCalendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:updatetimestamp];
    
    NSString *Year, *Month, *Day, *Hour, *Min;
    Year = [NSString stringWithFormat:@"%ld",(long)[hijriComponents year]];
    if ([hijriComponents month] < 10) {
        Month = [NSString stringWithFormat:@"0%ld",(long)[hijriComponents month]];
    } else {
        Month = [NSString stringWithFormat:@"%ld",(long)[hijriComponents month]];
    }
    if ([hijriComponents day] < 10) {
        Day = [NSString stringWithFormat:@"0%ld",(long)[hijriComponents day]];
    } else {
        Day = [NSString stringWithFormat:@"%ld",(long)[hijriComponents day]];
    }
    
    if ([hijriComponents hour] < 10) {
        Hour = [NSString stringWithFormat:@"0%ld",(long)[hijriComponents hour]];
    } else {
        Hour = [NSString stringWithFormat:@"%ld",(long)[hijriComponents hour]];
    }
    if ([hijriComponents minute] < 10) {
        Min = [NSString stringWithFormat:@"0%ld",(long)[hijriComponents minute]];
    } else {
        Min = [NSString stringWithFormat:@"%ld",(long)[hijriComponents minute]];
    }
    
    NSString *PersianDate = [NSString stringWithFormat:@"%@/%@/%@ %@:%@",Year,Month,Day,Hour,Min];
    
    return PersianDate;
    
}


+ (CAShapeLayer*) DrawLine:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 linewidth:(float)LineWidth color:(CGColorRef)Color {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x1, y1)];
    [path addLineToPoint:CGPointMake(x2, y2)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = Color;
    shapeLayer.lineWidth = LineWidth;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    return shapeLayer;
    
}

+ (NSString *)CardNumberAsString:(NSString*)originalString {
    NSMutableString *newStr = [NSMutableString new];
    for (NSUInteger i = 0; i < [originalString length]; i++) {
        if (i > 0 && i % 4 == 0)
            [newStr appendString:@" "];
        unichar c = [originalString characterAtIndex:i];
        [newStr appendString:[[NSString alloc] initWithCharacters:&c length:1]];
    }
    return newStr;
}

+ (NSString *)ExpireDateAsString:(NSString*)originalString {
    NSMutableString *newStr = [NSMutableString new];
    for (NSUInteger i = 0; i < [originalString length]; i++) {
        if (i > 0 && i % 2 == 0)
            [newStr appendString:@"/"];
        unichar c = [originalString characterAtIndex:i];
        [newStr appendString:[[NSString alloc] initWithCharacters:&c length:1]];
    }
    return newStr;
}

+ (NSString *)CreateTimeSuggest:(long)Create {
    if ([[MCLocalization sharedInstance].language isEqualToString:@"ar"]) { //TODO: Language Filter
        NSString *TimeString = @"";
        long timeCal = (roundf([[NSDate date] timeIntervalSince1970])-Create);
        long DaysOfCreate = timeCal/86400;
        if (DaysOfCreate > 365) {
            TimeString = @"1 سال";
        } else if (DaysOfCreate > 30) {
            TimeString = [NSString stringWithFormat:@"%ld ماه",DaysOfCreate/30];
        } else if (DaysOfCreate >= 1) {
            TimeString = [NSString stringWithFormat:@"%ld روز",DaysOfCreate];
        } else {
            DaysOfCreate = timeCal/3600;
            if (DaysOfCreate >= 1) {
                TimeString = [NSString stringWithFormat:@"%ld ساعت",DaysOfCreate];
            } else {
                DaysOfCreate = timeCal/60;
                if (DaysOfCreate < 1)
                    TimeString = [NSString stringWithFormat:@"همین الان"];
                else
                    TimeString = [NSString stringWithFormat:@"%ld دقیقه",DaysOfCreate];
            }
        }
        return TimeString;
    } else {
        return @"...";
    }
}

+ (UIColor *)CouponColorHandler:(int)CouponType {
    switch (CouponType) {
        case 0:
            return Rgb2UIColor(0,208,72);
            break;
        case 1:
            return Rgb2UIColor(0,153,255);
            break;
        case 2:
            return Rgb2UIColor(255,160,0);
            break;
        case 3:
            return Rgb2UIColor(255,229,0);
            break;
        default:
            return Rgb2UIColor(0,208,72);
            break;
    }
}

+ (UIColor *)RateColorHandler:(int)RateValue {
    
    //return Rgb2UIColor(255,255,255);
    
    if (RateValue >= 7) { //Love
        return Rgb2UIColor(22,184,0);
    } else if (RateValue >= 5) { //Smile
        return Rgb2UIColor(250,166,25);
    } else if (RateValue == 0) { //Non-Rate
        return Rgb2UIColor(0, 85, 225);
    } else { //Hate
        return Rgb2UIColor(216,52,90);
    }
}

+ (UIColor *)RateBorderColorHandler:(int)RateValue {
    
    //return Rgb2UIColor(255,255,255);
    
    if (RateValue >= 7) { //Love
        return Rgb2UIColor(19,160,0);
    } else if (RateValue >= 5) { //Smile
        return Rgb2UIColor(250,136,25);
    } else if (RateValue == 0) { //Non-Rate
        return [UIColor colorWithRed: 0.125 green: 0.289 blue: 0.568 alpha: 1];
    } else { //Hate
        return Rgb2UIColor(193,23,63);
    }
}

+ (NSString*)EmojiRate:(int)Value {
    NSString *Emoji;
    switch (Value) {
        default:
        case 1:
            Emoji = @"core_emoji_normal";
            break;
        case 2:
            Emoji = @"core_emoji_good";
            break;
        case 3:
            Emoji = @"core_emoji_love";
            break;
    }
    return Emoji;
}

+ (void)CreateBackLightToolbar {
    int ToolbarSize = 62;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height-ToolbarSize;
    
    UIView *BackLight = [[UIView alloc] initWithFrame:CGRectMake(0, ToolbarSize, screenWidth, screenHeight)];
    [BackLight setBackgroundColor:[UIColor darkGrayColor]];
    [BackLight.layer setOpacity:0.95f];
    [BackLight setTag:10000];
    [[[UIApplication sharedApplication] keyWindow] addSubview:BackLight];
}

+ (void)RemoveBackLightToolbar {
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:10000] removeFromSuperview];
}

+ (NSString*)convertEnNumberToFarsi:(NSString*)number {
    if ([[MCLocalization sharedInstance].language isEqualToString:@"ar"]) { //TODO: Language Filter
        NSString *text;
        NSDecimalNumber *someNumber = [NSDecimalNumber decimalNumberWithString:number];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fa"];
        [formatter setLocale:gbLocale];
        text = [formatter stringFromNumber:someNumber];
        return text;
    } else
        return number;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString*)convertEnNumberToFarsiInString:(NSString*)Number {
    if ([[MCLocalization sharedInstance].language isEqualToString:@"ar"]) { //TODO: Language Filter
        NSArray *Nums = @[@"۰",@"۱",@"۲",@"۳",@"۴",@"۵",@"۶",@"۷",@"۸",@"۹"];
        for (int i = 0;i < [Nums count];i++) {
            Number = [Number stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d",i] withString:[Nums objectAtIndex:i]];
        }
    }
    return Number;
}

+ (NSString *)CurrencyStrcutre:(long)Amount {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:Amount]];
    numberAsString = [numberAsString stringByReplacingOccurrencesOfString:[numberAsString substringWithRange:NSMakeRange(0,1)] withString:@""];
    numberAsString = [numberAsString substringWithRange:NSMakeRange(0, numberAsString.length-3)];
    
    return numberAsString;
}


+ (NSString *)CurrencyStrcutrePersian:(long)Amount {
    NSString *V = [self CurrencyStrcutre:Amount];
    return [self convertEnNumberToFarsiInString:V];
}

+ (NSString *)languageForString:(NSString *)text{
    if ([text length] > 0) {
        if (text.length < 100) {
            return (NSString *) CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, text.length)));
        } else {
            return (NSString *)CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)text, CFRangeMake(0, 100)));
        }
    } else {
        return @"en";
    }
}




+ (NSAttributedString*)LabelSetSpaceLine:(NSString*)Text space:(int)Space {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = Space;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:Text attributes:attributes];
    return attributedText;
    
}

+ (NSAttributedString*)LabelSetSpaceLineRight:(NSString*)Text space:(int)Space {
    
    if ([Text length] < 1)
        Text = @"خطا در خواندن اطلاعات دریافتی. مجددا تلاش نمایید.";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = Space;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:Text attributes:attributes];
    return attributedText;
    
}


+ (float)getHeightForText:(NSString*)text withFont:(UIFont*)font andWidth:(float)width attr:(NSDictionary<NSString*,id>*)Attr {
    CGSize constraint = CGSizeMake(width , 20000.0f);
    CGSize title_size;
    float totalHeight;
    title_size = [text boundingRectWithSize:constraint
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:Attr
                                    context:nil].size;
    
    totalHeight = ceil(title_size.height);
    CGFloat height = MAX(totalHeight, 25.0f);
    return height;
}

+ (UIColor*)colorWithHexString:(NSString*)hex {
    if ([hex length] > 6)
        hex = [hex substringWithRange:NSMakeRange(0, 6)];
    
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+ (NSString*)DetectSearchDefaultPicture:(int)Type {
    
    switch (Type) {
        default:
        case 1: //Merchant
            return @"icon_nopic_merchant.png";
            break;
        case 2: //Product
            return @"icon_nopic_product.png";
            break;
        case 3: //User
            return @"icon_nopic_user.png";
            break;
        case 4: //Tag
            return @"icon_nopic_tag.png";
            break;
    }
    
}


+ (NSString*)DetectAccountList:(int)Type {
    
    switch (Type) {
        default:
        case 0: //Merchant
            return @"icon_nopic_merchant.png";
            break;
        case 1: //User
            return @"icon_nopic_user.png";
            break;
    }
    
}


+ (NSString*)DetectDefaultPicture:(int)isUserType {
    
    if(isUserType != 1)
        return @"icon_nopic_merchant.png";
    else
        return @"icon_nopic_user.png";
    
}


//+ (NSString *)RSA:(NSString*)D {
//    RSA *R = [[RSA alloc] init];
//    NSString *Pk = @"-----BEGIN PUBLIC KEY----- MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC6D8dUV5yJBTki4ab2t6a8vd+U\n5OUpG7IZSp+MajLsTkURqhZW4K1mlOJLd6HEwDO9F1T249bogij1thNctBC92fVQ\nBWMdsR3VHqIpa52OJP3tLkUNYxNLQTlLf6EcnV67zC7tmEVby+ogFwRZ++XtoKn1\nsrolEMnpeaxW4WNfrwIDAQAB\n-----END PUBLIC KEY-----";
//    return [R encryptString:D publicKey:Pk];
//}


+ (NSString *)CreateTimeSuggestPersian:(long)Create {
    NSString *myTime = [self CreateTimeSuggest:Create];
    myTime = [myTime stringByReplacingOccurrencesOfString:@"Mo" withString:@" ماه"];
    myTime = [myTime stringByReplacingOccurrencesOfString:@"y" withString:@" سال"];
    myTime = [myTime stringByReplacingOccurrencesOfString:@"d" withString:@" روز"];
    myTime = [myTime stringByReplacingOccurrencesOfString:@"m" withString:@" دقیقه"];
    return myTime;
}


+ (NSString *)PriceCurrencyString:(NSUInteger)Price {
    NSString *PriceCurrency = [core_utils CurrencyStrcutre:Price];
    PriceCurrency = [core_utils convertEnNumberToFarsiInString:PriceCurrency];
    return [NSString stringWithFormat:@"%@ ریال",PriceCurrency];
}


/*
 * New
 */
+ (NSArray*)imageURLSplit:(NSString*)URL {
    @try {
        URL = [URL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *ImageURL = [NSString stringWithFormat:@"%@%@",@"https://api.raad.cloud/files/v3/",URL];
        NSArray *ImageSplit = [URL componentsSeparatedByString:@"_"];
        
        NSString *LastUnderline = @"";
        NSArray *Sizes = @[@1,@1];
        if ([ImageSplit count] > 0) {
            LastUnderline = [ImageSplit lastObject];
            NSString *SizeString = [[LastUnderline componentsSeparatedByString:@"."] firstObject];
            Sizes = [SizeString componentsSeparatedByString:@"x"];
        }
        
        if ([Sizes count] == 2) {
            NSLog(@"url : %@",ImageURL);
            return @[ImageURL,[Sizes objectAtIndex:0],[Sizes objectAtIndex:1]];
        } else {
            return @[ImageURL,@1,@1];
        }
    } @catch (NSException *exception) {
        return @[@"",@1,@1];
    }
    
}

+ (NSMutableDictionary*)URLParse:(NSString*)URL {
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [URL componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    //--
    return queryStringDictionary;
}

+ (BOOL)isNumber:(NSString*)string {
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

+ (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

+ (UIColor*)getRateColor:(float)Rate {
    if (Rate < 1)
        return Rgb2UIColor(149, 165, 166);
    else if (Rate < 5)
        return Rgb2UIColor(231, 76, 60);
    else if (Rate < 8)
        return Rgb2UIColor(243, 156, 18);
    else if (Rate >= 8)
        return Rgb2UIColor(46, 204, 113);
    //--
    return Rgb2UIColor(149, 165, 166);
}

/*
 * description : Micro (13len)
 */
+ (NSString*)ConvertMicrotimeToPersian:(NSInteger)Micro {
    NSTimeInterval _interval = Micro/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"EEEE dd MMMM ساعت H:mm"];
    NSLocale *iranLocale = [NSLocale localeWithLocaleIdentifier:@"fa_IR"];
    
    [f setLocale:iranLocale];
    NSCalendar *persian = [[NSCalendar alloc] initWithCalendarIdentifier:@"persian"];
    
    [f setCalendar:persian];
    NSString *formattedDate = [f stringFromDate:date];
    return formattedDate;
}

+ (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGFloat result = font.pointSize + 4;
    if (text) {
        CGSize textSize = { widthValue, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        CGRect frame = [text boundingRectWithSize:textSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName:font }
                                          context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height+1);
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

/**
 * description : handle file upload name
 */
+ (NSString*)fileuploadName:(NSData*)Response {
    @try {
        NSString *FileName = [[NSString stringWithUTF8String:[Response bytes]] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        FileName = [FileName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return FileName;
    } @catch (NSException *exception) {
        return @"";
    }
}

/**
 * description : qrcode generator
 */
+ (UIImage*)qrcodeWithValue:(NSString*)Value squaresize:(float)SquareSize {
    NSData *stringData = [Value dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    CGAffineTransform transform = CGAffineTransformMakeScale(SquareSize/100, SquareSize/100);
    CIImage *output = [filter.outputImage imageByApplyingTransform: transform];
    return [UIImage imageWithCIImage:output];
}

@end

#endif /* core_utils_h */
