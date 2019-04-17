//
//  MC_TextField.m
//  payment-coupon
//
//  Created by Amir Soleimani on 8/22/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_TextField.h"
#import "MC_OSLabel.h"
#import "core_utils.h"

@interface MC_TextField ()
@property (nonatomic, retain) MC_OSLabel *HolderLabel;
@end

@implementation MC_TextField

- (instancetype)init {
    self = [super init];
    if (self) {
        [self wakeup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self wakeup];
    }
    return self;
}

- (void)wakeup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged) name:UITextFieldTextDidChangeNotification object:nil];
}


- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0, 10);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectInset(bounds, 0,12);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return CGRectInset(bounds, 0, 12);
}


- (void)textChanged {
    if([[self textholder] length] == 0) {
        return;
    }
    //--
    [UIView animateWithDuration:0.1f animations:^{
        if([[self text] length] == 0){
            [[self viewWithTag:999] setAlpha:1];
        } else {
            [[self viewWithTag:999] setAlpha:0];
        }
    }];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged];
}

- (void)setTextholder:(NSString *)textholder {
    _textholder = textholder;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //--
    if([[self textholder] length] > 0) {
        if (_HolderLabel == nil) {
            _HolderLabel = [[MC_OSLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            _HolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _HolderLabel.numberOfLines = 0;
            _HolderLabel.font = self.font;
            _HolderLabel.backgroundColor = [UIColor clearColor];
            _HolderLabel.textAlignment = NSTextAlignmentRight;
            _HolderLabel.textColor = Rgb2UIColor(140, 156, 176);
            _HolderLabel.alpha = 0;
            _HolderLabel.tag = 999;
            _HolderLabel.edgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
            [_HolderLabel setFont:[UIFont openIRANSansLightFontOfSize:14]];
            [self addSubview:_HolderLabel];
            //--
        }
        
        
        _HolderLabel.text = self.textholder;
        [self sendSubviewToBack:_HolderLabel];
    }
    
    if ([[self text] length] == 0 && [[self textholder] length] > 0) {
        [[self viewWithTag:999] setAlpha:1];
    }
    
}





@end
