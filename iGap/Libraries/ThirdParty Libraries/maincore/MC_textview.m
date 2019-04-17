//
//  MC_textview.m
//  maincore
//
//  Created by Amir Soleimani on 8/23/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_textview.h"
#import "UIFont+IRANSansMobile.h"
#import "core_utils.h"

@implementation MC_textview

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textContainerInset = UIEdgeInsetsMake(7, 5, 5, -4);
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //--
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setPlaceholder:@""];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification {
    if ([[self placeholder] length] == 0) {
        return;
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
        [_placeHolderLabel setFrame:CGRectMake(self.bounds.size.width-(_placeHolderLabel.frame.size.width+_placeHolderLabel.frame.origin.x), _placeHolderLabel.frame.origin.y, _placeHolderLabel.frame.size.width, _placeHolderLabel.frame.size.height)];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if ([[self text] length] == 0 && [[self placeholder] length] > 0) {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}


@end
