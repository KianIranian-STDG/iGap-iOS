//
//  MC_message_dialog.m
//  maincore
//
//  Created by Amir Soleimani on 7/11/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_message_dialog.h"
#import "MC_DefaultTextField.h"

#define PROPERTY(property) NSStringFromSelector(@selector(property))

@interface MC_ActionDialog ()
@property (nonatomic, copy) NSString *Title;
@property (nonatomic, assign) MCMessageDialogActionButton Style;
@property (nonatomic, copy) void (^Handler)(MC_ActionDialog *action);
- (void)performAction;
@end

@implementation MC_ActionDialog

+ (instancetype)actionWithTitle:(NSString *)title style:(MCMessageDialogActionButton)style handler:(void (^ __nullable)(void))handler {
    return [[self alloc] initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(MCMessageDialogActionButton)style handler:(void (^ __nullable)(void))handler {
    if ((self = [super init])) {
        _Title = [title copy];
        _Style = style;
        _Handler = [handler copy];
    }
    return self;
}

- (void)performAction {
    if (self.Handler) {
        self.Handler(self);
        self.Handler = nil; // nil out after calling to break cycles.
    }
}

@end

@interface MC_message_dialog ()

@property (nonatomic, copy) NSArray *actions;

@property (nonatomic, copy) NSString *Title;
@property (nonatomic, copy) NSString *Message;
@property (nonatomic, weak) id Delegate;

@property (nonatomic, strong) MC_DefaultTextField *InputField;

@end

@implementation MC_message_dialog {
    float ContentPadding, WindowPadding, DialogWidth, TitleHeight, DialogHeight;
    UIView *DialogBase,*DialogView;
    UIView *DarkBack;
}


- (instancetype)initWithTitle:(NSString*)Title inputtype:(MCMessageDialogInputType)InputType delegate:(id)myDelegate {
    self.inputType = InputType;
    return [self initWithTitle:Title message:@"" delegate:myDelegate];
}

- (instancetype)initWithTitle:(NSString*)Title message:(NSString*)Message delegate:(id)myDelegate {
    if ((self = [super init])) {
        _Title = [Title copy];
        _Message = [Message copy];
        _Delegate = myDelegate;
        //--
        _inputValue = @"";
        [self.Delegate addChildViewController:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}


/*
 * Keyboard & TextField
 */
- (void)keyboardChangeFrame:(NSNotification *)notification {
    [DialogView setTransform:CGAffineTransformMakeTranslation(0, -100)];
}

- (void)addAction:(MC_ActionDialog*)Action {
    NSAssert([Action isKindOfClass:MC_ActionDialog.class], @"Must be of type MC_ActionDialog");
    self.actions = [[NSArray arrayWithArray:self.actions] arrayByAddingObject:Action];
}

- (void)ShowDialog {
    [self CloseDialog];
    //--
    ContentPadding = 10;
    WindowPadding = 20;
    DialogWidth = 320-(WindowPadding*2); //[[UIScreen mainScreen] bounds].size.width
    TitleHeight = 45;
    DialogHeight = 0;
    float BtnHeight = 42;
    
    
    //-- Setup Main View.
    DialogBase = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [core_utils getScreenWidth], [core_utils getScreenHeight])];
    DialogBase.tag = 10001;
    
    //--DarkBack
    DarkBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DialogBase.frame.size.width, DialogBase.frame.size.height)];
    [DarkBack setBackgroundColor:Rgb2UIColor(58, 58, 58)];
    [DarkBack setAlpha:0];
    [DialogBase addSubview:DarkBack];
    UITapGestureRecognizer *outsideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideTap:)];
    [DarkBack addGestureRecognizer:outsideTap];
    
    DialogView = [[UIView alloc] initWithFrame:CGRectMake(WindowPadding, 0, DialogWidth, 0)];
    
    //--
    UIFont *MessageFont = [UIFont openIRANSansLightFontOfSize:14];
    //--
    DialogView.opaque = YES;
    DialogView.backgroundColor = [UIColor whiteColor];
    //    DialogView.layer.cornerRadius = roundf(BtnHeight/2.0f);
    DialogView.layer.shadowRadius  = 2.5f;
    DialogView.layer.shadowColor   = [UIColor TL_ATTACHBOX_SHADOW].CGColor;
    DialogView.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    DialogView.layer.shadowOpacity = 0.9f;
    DialogView.layer.masksToBounds = NO;
    //--
    
    //Base.
    UIView *Base = [[UIView alloc] initWithFrame:CGRectMake(ContentPadding, 0, DialogWidth-(ContentPadding*2), DialogHeight)];
    [DialogView addSubview:Base];
    
    //--Title.
    MC_OSLabel *Title = [[MC_OSLabel alloc] initWithFrame:CGRectMake(0, 0, Base.frame.size.width, TitleHeight)];
    [Title setTextAlignment:NSTextAlignmentCenter];
    [Title setEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
    [Title setFont:[UIFont openIRANSansMediumFontOfSize:18]];
    [Title setText:_Title];
    [Base addSubview:Title];
    [Title.layer addSublayer:[core_utils DrawLine:0 y1:TitleHeight x2:Title.frame.size.width y2:TitleHeight linewidth:2.0f color:[[UIColor LINE_GRAY_COLOR] CGColor]]];
    DialogHeight+=(TitleHeight+12);
    
    float BaseHeight = 0;
    if (_Message != nil && [_Message length] > 0) {
        //--Content.
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = 5;
        paragraph.alignment = NSTextAlignmentRight;
        //    paragraph.baseWritingDirection = NSWritingDirectionRightToLeft;
        paragraph.firstLineHeadIndent = 1.0;
        NSDictionary* attributes = @{NSParagraphStyleAttributeName: paragraph, NSFontAttributeName : MessageFont };
        NSAttributedString* aString = [[NSAttributedString alloc] initWithString:_Message attributes:attributes];
        
        float MessageHeight = [core_utils getHeightForText:_Message withFont:MessageFont andWidth:Base.frame.size.width attr:attributes];
        UILabel *Message = [[UILabel alloc] initWithFrame:CGRectMake(0, DialogHeight+BaseHeight+3, Base.frame.size.width, MessageHeight)];
        [Message setNumberOfLines:99];
        [Message setAttributedText:aString];
        [Message sizeToFit];
        [Message setFrame:CGRectMake(0, Message.frame.origin.y, Base.frame.size.width, Message.frame.size.height)];
        [Base addSubview:Message];
        BaseHeight+=(MessageHeight+15);
    }
    
    if (_inputType != MCMessageDialogInputTypeNone) {
        self.InputField = [[MC_DefaultTextField alloc] initWithFrame:CGRectMake(0, DialogHeight+BaseHeight+3, Base.frame.size.width, 45)];
        [self.InputField becomeFirstResponder];
        [self.InputField setDelegate:self];
        [Base addSubview:self.InputField];
        BaseHeight+=(self.InputField.frame.size.height+15);
        
        //--
        if (_inputType == MCMessageDialogInputTypeCurrency) {
            [self.InputField setTextAlignment:NSTextAlignmentCenter];
            [self.InputField setPlaceHolderAlign:NSTextAlignmentCenter];
            [self.InputField setTextholder:@"مبلغ به ریال"];
            [self.InputField setFont:[UIFont openIRANSansFontOfSize:17]];
            [self.InputField setKeyboardType:UIKeyboardTypeNumberPad];
        }
    }
    
    DialogHeight+=BaseHeight;
    [Base setFrame:CGRectMake(Base.frame.origin.x, Base.frame.origin.y, Base.frame.size.width, DialogHeight)];
    
    
    /*
     * --Button.
     */
    long BtnCount = [self.actions count];
    //--
    float BtnMargin = 5;
    float BtnWidth = (DialogView.frame.size.width-(BtnMargin*(BtnCount+1)))/BtnCount;
    float BtnSpace = BtnMargin;
    
    for (int i = 0; i < BtnCount; i++) {
        MC_ActionDialog *BtnInfo = [self.actions objectAtIndex:i];
        //--
        UIButton *Btn;
        if (BtnInfo.Style == MCMessageDialogActionButtonBlue)
            Btn = [[MC_ButtonCore alloc] initWithFrame:CGRectMake(BtnSpace, DialogHeight, BtnWidth, BtnHeight) type:MCBUTTONTYPE_BLUE];
        else if (BtnInfo.Style == MCMessageDialogActionButtonDelete)
            Btn = [[MC_ButtonCore alloc] initWithFrame:CGRectMake(BtnSpace, DialogHeight, BtnWidth, BtnHeight) type:MCBUTTONTYPE_RED];
        else
            Btn = [[MC_ButtonCore alloc] initWithFrame:CGRectMake(BtnSpace, DialogHeight, BtnWidth, BtnHeight) type:MCBUTTONTYPE_NONE];
        [Btn setTitle:BtnInfo.Title forState:UIControlStateNormal];
        [Btn setTag:i];
        [Btn addTarget:self action:@selector(Action:) forControlEvents:UIControlEventTouchUpInside];
        [DialogView addSubview:Btn];
        BtnSpace+=(BtnWidth+BtnMargin);
    }
    
    
    DialogHeight+=(BtnHeight+5);
    
    //--Add to Window
    [DialogView setCenter:CGPointMake([core_utils getScreenWidth]/2, ([core_utils getScreenHeight]/2)-(DialogHeight/2))];
    CGRect Frame = DialogView.frame;
    Frame.size.height = DialogHeight;
    [DialogView setFrame:Frame];
    
    
    //--Set Shadow
    float CornerRadius = roundf(BtnHeight/2.0f);
    UIBezierPath *DialogborderBox      = [UIBezierPath bezierPathWithRoundedRect:DialogView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){CornerRadius, CornerRadius}];
    CAShapeLayer * DialogView_maskLayer = [CAShapeLayer layer];
    DialogView_maskLayer.path = DialogborderBox.CGPath;
    DialogView.layer.mask = DialogView_maskLayer;
    //
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(3, 0, -3.5f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(DialogView.bounds, shadowInsets) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){CornerRadius, CornerRadius}];
    DialogView.layer.shadowPath    = shadowPath.CGPath;
    
    
    //--Loader
    [self Load];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.inputType == MCMessageDialogInputTypeCurrency) {
        if (string.length == 0) {
            self.inputValue = [self.inputValue substringWithRange:NSMakeRange(0, self.inputValue.length-1)];
        } else {
            self.inputValue = [self.inputValue stringByAppendingString:string];
        }
        if ([self.inputValue intValue] > 0) {
            if ([self.inputValue intValue] < 990000000)
                [self.InputField setText:[core_utils PriceCurrencyString:[self.inputValue intValue]]];
            else {
                self.inputValue = @"";
                self.InputField.text = @"";
            }
        } else
            [self.InputField setText:@""];
        return false;
    }
    
    return true;
}

- (void)outsideTap:(UITapGestureRecognizer *)recognizer {
    [self VibrateView];
}

- (void)Load {
    [DialogView setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
    [DialogView setAlpha:0];
    
    [DialogBase addSubview:DialogView];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:DialogBase];
    
    [UIView animateWithDuration:0.2f animations:^(void){
        [self->DarkBack setAlpha:0.8f];
        [self->DialogView setAlpha:1];
        [self->DialogView setTransform:CGAffineTransformMakeScale(1.05, 1.05)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f animations:^(void){
            [self->DialogView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        }];
    }];
}

- (void)VibrateView {
    UIView *Base = [[[[UIApplication sharedApplication] delegate] window] viewWithTag:10001];
    if (Base != nil) {
        UIView *Child = [[Base subviews] objectAtIndex:1];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        animation.duration = 0.07;
        animation.byValue = @(2);
        animation.autoreverses = YES;
        animation.repeatCount = 2;
        [Child.layer addAnimation:animation forKey:@"Shake"];
    }
}

- (void)CloseDialog {
    UIView *Base = [[[[UIApplication sharedApplication] delegate] window] viewWithTag:10001];
    if (Base != nil) {
        UIView *ChildZero = [[Base subviews] objectAtIndex:0];
        UIView *Child = [[Base subviews] objectAtIndex:1];
        [UIView animateWithDuration:0.1f animations:^(void){
            [Child setAlpha:0];
            [ChildZero setAlpha:0];
            [Child setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
        } completion:^(BOOL finished) {
            [Base removeFromSuperview];
        }];
    }
}

- (void)Action:(UIButton*)Btn {
    [self removeFromParentViewController];
    [self CloseDialog];
    MC_ActionDialog *BtnInfo = [self.actions objectAtIndex:Btn.tag];
    [BtnInfo performAction];
}


@end
