//
//  TL_ImageBox.h
//  timeline
//
//  Created by Amir Soleimani on 6/16/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "core_colors.h"
#import "KAProgressLabel.h"

@interface MC_imagebox_view : UIView {
    UIImageView *ImageView;
}

- (void)setAutoResizing:(BOOL)Status;
- (void)setAutoResizing:(BOOL)Status main:(UIView*)Main;
- (void)setImageWithURL:(NSString*)ImageURL width:(float)ImageWidth height:(float)ImageHeight;
- (void)DownloadImage;

@property(nonatomic, retain) UIImageView *ImageView;
@property(nonatomic, retain) KAProgressLabel *Progress;
@property(nonatomic, assign) UIImage *PlaceHolder;
@property(nonatomic, assign) CGRect SuperFrame;

@end
