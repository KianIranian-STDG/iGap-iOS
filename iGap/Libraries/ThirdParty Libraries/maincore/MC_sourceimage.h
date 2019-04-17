//
//  TL_sourceimage.h
//  timeline
//
//  Created by Amir Soleimani on 4/20/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "core_utils.h"
#import "core_type.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface MC_sourceimage : UIView

@property (nonatomic, assign) int Type;
@property (nonatomic, copy) NSString *Color;
@property (nonatomic, retain) UIImageView *ImageBox;
@property (nonatomic, retain) UIImage *Image;

@property (nonatomic, assign) BOOL threadLoad;

- (void)downloadImage:(NSArray*)ImageInfo;

@end
