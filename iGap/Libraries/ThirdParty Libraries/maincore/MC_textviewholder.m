//
//  core_textview_ph.m
//  newpost
//
//  Created by Amir Soleimani on 3/7/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_textviewholder.h"
#import "UIFont+IRANSansMobile.h"
#import "core_utils.h"

@implementation MC_textviewholder

CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0.25;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if __has_feature(objc_arc)
#else
    [_placeHolderLabel release]; _placeHolderLabel = nil;
    [_placeholderColor release]; _placeholderColor = nil;
    [_placeholder release]; _placeholder = nil;
    [super dealloc];
#endif
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification {
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([self.text length] >= 85 && self.font.pointSize == 20) {
        [self setFont:[UIFont openIRANSansUltraLightFontOfSize:17]];
    } else if ([self.text length] < 85 && self.font.pointSize == 16) {
        [self setFont:[UIFont openIRANSansUltraLightFontOfSize:20]];
    }
    
    [UIView animateWithDuration:0.1f animations:^{
        if([[self text] length] == 0)
        {
            [[self viewWithTag:999] setAlpha:1];
        }
        else
        {
            [[self viewWithTag:999] setAlpha:0];
        }
    }];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect {
    if([[self placeholder] length] > 0) {
        if (_placeHolderLabel == nil) {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,12,self.frame.size.width,0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textAlignment = NSTextAlignmentRight;
            //_placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            _placeHolderLabel.textColor = Rgb2UIColor(140, 156, 176);
            [_placeHolderLabel setFont:[UIFont openIRANSansLightFontOfSize:14]];
            [self addSubview:_placeHolderLabel];
        }
        
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [_placeHolderLabel setFrame:CGRectMake(10, 10, self.frame.size.width-20, _placeHolderLabel.frame.size.height)];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if ([[self text] length] == 0 && [[self placeholder] length] > 0) {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}


@end
