//
//  MC_DefaultTextField.m
//  maincore
//
//  Created by Amir Soleimani on 7/15/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_DefaultTextField.h"
#import "MC_OSLabel.h"
#import "core_utils.h"

@interface MC_DefaultTextField ()
@property (nonatomic, retain) MC_OSLabel *HolderLabel;
@property (nonatomic, assign) float HolderSize;
@property (nonatomic, assign) NSTextAlignment HolderAlignment;
@end

@implementation MC_DefaultTextField

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self create];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self create];
    }
    return self;
}

- (void)create {
    self.HolderAlignment = NSTextAlignmentRight;
    self.HolderSize = 14;
    //--
    [self setTextColor:Rgb2UIColor(58, 58, 58)];
    [self.layer setCornerRadius:3];
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:Rgb2UIColor(233, 238, 244).CGColor];
    //--
    UIView *LpaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height)];
    UIView *RpaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height)];
    self.leftView = LpaddingView;
    self.rightView = RpaddingView;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.leftViewMode = UITextFieldViewModeAlways;
    //--
    [self setFont:[UIFont openIRANSansLightFontOfSize:self.HolderSize]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged) name:UITextFieldTextDidChangeNotification object:nil];
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

- (void)setPlaceHolderAlign:(NSTextAlignment)Align {
    self.HolderAlignment = Align;
}

- (void)setPlaceHolderSize:(float)Size align:(NSTextAlignment)Align {
    self.HolderSize = Size;
    self.HolderAlignment = Align;
}

- (void)setLeftLabel:(NSString*)Value {
    UIFont *f = [UIFont systemFontOfSize:20];
    float sw = [core_utils widthOfString:Value withFont:f];
    MC_OSLabel *LeftLabel = [[MC_OSLabel alloc] initWithFrame:CGRectMake(0, 0, sw+16, self.frame.size.height-2)];
    [LeftLabel setText:Value];
    [LeftLabel setFont:f];
    [LeftLabel setEdgeInsets:UIEdgeInsetsMake(-3, 0, 0, 0)];
    [LeftLabel setTextColor:Rgb2UIColor(140, 156, 176)];
    [LeftLabel setTextAlignment:NSTextAlignmentCenter];
    self.leftView = LeftLabel;
    self.leftViewMode = UITextFieldViewModeAlways;
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
            _HolderLabel.textAlignment = self.HolderAlignment;
            _HolderLabel.textColor = Rgb2UIColor(140, 156, 176);
            _HolderLabel.alpha = 0;
            _HolderLabel.tag = 999;
            _HolderLabel.edgeInsets = UIEdgeInsetsMake(4, 0, 0, 10);
            [_HolderLabel setFont:[UIFont openIRANSansLightFontOfSize:self.HolderSize]];
            [self addSubview:_HolderLabel];
        }
        
        
        _HolderLabel.text = self.textholder;
        [self sendSubviewToBack:_HolderLabel];
    }
    
    if ([[self text] length] == 0 && [[self textholder] length] > 0) {
        [[self viewWithTag:999] setAlpha:1];
    }
    
}

@end
