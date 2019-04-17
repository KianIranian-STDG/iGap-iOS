//
//  TL_ImageBox.m
//  timeline
//
//  Created by Amir Soleimani on 6/16/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_imagebox_view.h"

@implementation MC_imagebox_view {
    NSString *URL;
    float Width,Height;
    BOOL AutoResizing;
    UIImage *Holder;
}

@synthesize ImageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:Rgb2UIColor(230, 230, 230)];
        //--
        ImageView = [[UIImageView alloc] init];
        [self addSubview:ImageView];
        //--ProgressBar
        self.Progress = [[KAProgressLabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        [self.Progress setFillColor:[UIColor clearColor]];
        [self.Progress setTrackColor:[UIColor whiteColor]];
        [self.Progress setProgressColor:[UIColor darkGrayColor]];
        [self.Progress setTrackWidth:2];
        [self.Progress setProgressWidth:2];
        [self addSubview:self.Progress];
        [self.Progress setProgress:0.02f];
    }
    return self;
}

- (void)setImageWithURL:(NSString*)ImageURL width:(float)ImageWidth height:(float)ImageHeight {
    URL = ImageURL;
    Width = ImageWidth;
    Height = ImageHeight;
}

- (void)UpdateSuperFrame:(float)MainWidth {
    CGRect superFrame = self.frame;
    float ParentWidth = MainWidth;
    float newH = (ParentWidth*Height)/Width;
    float maxHeight = ParentWidth*1.2f;
    if (newH > maxHeight)
        superFrame.size.height = ParentWidth;
    else
        superFrame.size.height = newH;
    self.SuperFrame = superFrame;
}

- (void)setAutoResizing:(BOOL)Status {
    [self setAutoResizing:Status main:nil];
}

- (void)setAutoResizing:(BOOL)Status main:(UIView*)Main {
    AutoResizing = Status;
    if (AutoResizing) {
        [ImageView setContentMode:UIViewContentModeScaleAspectFit];
        //--
        if (Main != nil) {
            [self UpdateSuperFrame:Main.frame.size.width];
        }
    } else
        [ImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)layoutSubviews {
    if (AutoResizing) {
        if (CGRectIsEmpty(self.SuperFrame))
            [self UpdateSuperFrame:self.superview.frame.size.width];
        [self setFrame:self.SuperFrame];
    }
    //--
    [ImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+1)];
    [self.Progress setCenter:CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f)];
}

- (void)DownloadImage {
    if (URL != nil) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:URL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.Progress setProgress:downloadProgress.fractionCompleted];
            });
        } success:^(NSURLSessionTask *task, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.Progress removeFromSuperview];
                self->ImageView.image = (UIImage*)responseObject;
            });
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error Download Image: %@", error);
        }];
    } else {
        [self.Progress removeFromSuperview];
        [self setBackgroundColor:[UIColor whiteColor]];
        Holder = _PlaceHolder;
        [self setNeedsDisplay];
    }
}

- (void)setPlaceHolder:(UIImage *)PlaceHolder {
    _PlaceHolder = PlaceHolder;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (Holder != nil) {
        [Holder drawInRect:CGRectMake((self.frame.size.width-100)/2, (self.frame.size.height-100)/2, 100, 100)];
    }
}




@end
