//
//  MC_QRSheet.m
//  maincore
//
//  Created by Amir Soleimani on 9/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_QRSheet.h"
#import "core_utils.h"
#import "MC_ButtonCore.h"

@interface MC_QRSheet ()

@end

@implementation MC_QRSheet{
    MC_ButtonCore *Button;
    UIImageView *QRBox;
    float Padding, ButtonHeight;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ButtonHeight = 45;
        Padding = 10;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    //--
    UIView *Super = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height/2)+90 )];
    [Super setBackgroundColor:[UIColor whiteColor]];
    self.view = Super;
    //--
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.view.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.}].CGPath;
    self.view.layer.mask = maskLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //--QRBox
    QRBox = [[UIImageView alloc] init];
    [QRBox setContentMode:UIViewContentModeScaleAspectFit];
    //--
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *QR = [core_utils qrcodeWithValue:self->_QRContent squaresize:self.view.frame.size.width-(self->Padding*2)];
        [self->QRBox setImage:QR];
    });
    [self.view addSubview:QRBox];
    
    //--Button
    Button = [[MC_ButtonCore alloc] initWithType:MCBUTTONTYPE_BLUE];
    [Button setTitle:[MCLocalization stringForKey:@"GLOBAL_BACK"] forState:UIControlStateNormal];
    [Button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Button];
}

- (void)setQRContent:(NSString *)QRContent {
    _QRContent = QRContent;
}


- (void)close {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewWillLayoutSubviews {
    [Button setFrame:CGRectMake(Padding, self.view.frame.size.height-(ButtonHeight+Padding), self.view.frame.size.width-(Padding*2), ButtonHeight)];
    [QRBox setFrame:CGRectMake(Padding, Padding, Button.frame.size.width, Button.frame.origin.y-(Padding*2))];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [core_utils setStatusBarBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //[core_utils setStatusBarBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

