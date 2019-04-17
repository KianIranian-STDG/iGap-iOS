//
//  TL_sourceimage.m
//  timeline
//
//  Created by Amir Soleimani on 4/20/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_sourceimage.h"
#import "core_strings.h"

@implementation MC_sourceimage {
    UIImage *HolderIcon;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config {
    self.opaque = NO;
    self.ImageBox = [[UIImageView alloc] init];
    [self addSubview:self.ImageBox];
}

- (void)setColor:(NSString *)Color {
    _Color = Color;
    self.backgroundColor = [core_utils colorWithHexString:_Color];
}

- (void)setType:(int)Type {
    _Type = Type;
    HolderIcon = [UIImage imageNamed:[NSString IconName:_Type] inBundle:[core_utils getResourcesBundle] compatibleWithTraitCollection:nil];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //--
    [self.ImageBox setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.frame = CGRectInset(self.frame, 0,0);
    self.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1f].CGColor;
    self.layer.borderWidth = 0.5f;
    //--
    //[self.layer setCornerRadius:roundf(self.frame.size.height/4)];
    //[self.layer setMasksToBounds:YES];
}

- (void)downloadImage:(NSArray*)ImageInfo {
    
    if (self.threadLoad)
        [self ThreadLoader:ImageInfo];
    else
        [self NormalLoader:ImageInfo];
    
}

/**
 * description : normal load
 */
- (void)NormalLoader:(NSArray*)ImageInfo {
    
    if ([ImageInfo count] > 0) { // && self.ImageBox.image == nil
        
        __weak typeof(UIImageView*) weakImageView = self.ImageBox;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[ImageInfo objectAtIndex:0]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [weakImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage new] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.Image = [UIImage new];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.ImageBox.image = image;
                [self setNeedsDisplay];
            });
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed");
        }];
        
    } else {
        [self.ImageBox setImage:nil];
        self.Image = nil;
        [self setNeedsDisplay];
    }
}

/**
 * description : thread load
 */
- (void)ThreadLoader:(NSArray*)ImageInfo {
    
    if ([ImageInfo count] > 0) { // && self.ImageBox.image == nil
        
        __weak typeof(UIImageView*) weakImageView = self.ImageBox;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[ImageInfo objectAtIndex:0]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [weakImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage new] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.Image = [UIImage new];
            //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
            //dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                CGSize destinationSize = CGSizeMake(300, 300);
                UIGraphicsBeginImageContext(destinationSize);
                [image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.ImageBox.image = newImage;
                    [self setNeedsDisplay];
                });
                
            });
            
            
            
            //});
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed");
        }];
        
    } else {
        [self.ImageBox setImage:nil];
        self.Image = nil;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //--
    if (self.Image == nil && HolderIcon != nil) {
        CGRect bounds = CGRectMake(7, 7, self.frame.size.width-14, self.frame.size.height-14);
        [[UIColor whiteColor] set];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextClipToMask(context, bounds, [HolderIcon CGImage]);
        CGContextFillRect(context, bounds);
    }
}



@end

