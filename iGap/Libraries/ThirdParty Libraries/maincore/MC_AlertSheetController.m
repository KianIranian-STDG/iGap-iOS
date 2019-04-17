//
//  PU_alertsheetcontroller.m
//  page-user-profile
//
//  Created by Amir Soleimani on 8/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_AlertSheetController.h"
#import "core_utils.h"
#import "UIFont+IRANSansMobile.h"


/*
 * Action Sheet Button
 */
@interface MC_AlertSheetAction ()
@property (nonatomic, copy) NSString *Title;
@property (nonatomic, assign) MCALERTSHEETBUTTON Style;
@property (nonatomic, copy) void (^Handler)(void);
- (void)performAction;
@end

@implementation MC_AlertSheetAction

+ (instancetype)actionWithTitle:(NSString *)title style:(MCALERTSHEETBUTTON)style handler:(void (^ __nullable)(void))handler {
    return [[self alloc] initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(MCALERTSHEETBUTTON)style handler:(void (^ __nullable)(void))handler {
    if ((self = [super init])) {
        _Title = [title copy];
        _Style = style;
        _Handler = [handler copy];
    }
    return self;
}

- (void)performAction {
    if (self.Handler) {
        self.Handler();
        self.Handler = nil; // nil out after calling to break cycles.
    }
}

@end




/*
 * Sheet ViewController
 */
@interface MC_AlertSheetController () {
    float btnHeight;
}

@property (nonatomic, copy) NSArray *buttons;

@end

@implementation MC_AlertSheetController

- (instancetype)init {
    self = [super init];
    if (self) {
        btnHeight = 45;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    //--
    UIView *Super = [[UIView alloc] initWithFrame:CGRectMake(15, -15, self.view.frame.size.width-30, (btnHeight*[_buttons count])+(1*([_buttons count]-1)) )];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: Super.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){20, 20}].CGPath;
    Super.layer.mask = maskLayer;
    //--
    self.view = Super;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:Rgb2UIColor(230, 230, 230)];
    
    _buttons = [[_buttons reverseObjectEnumerator] allObjects];
    int c = 0;
    for (MC_AlertSheetAction *Btn in _buttons) {
        float Y = (c*btnHeight)+(c*1);
        //--
        UIFont *fontStyle;
        if (Btn.Style == MCALERTSHEETBUTTONRED)
            fontStyle = [UIFont openIRANSansMediumFontOfSize:15];
        else
            fontStyle = [UIFont openIRANSansLightFontOfSize:15];
        //--
        UIButton *Button = [[UIButton alloc] initWithFrame:CGRectMake(0, Y, self.view.frame.size.width, btnHeight)];
        [Button setBackgroundColor:[UIColor whiteColor]];
        [Button setTitle:Btn.Title forState:UIControlStateNormal];
        [Button setTitleColor:[self detectTextColor:Btn.Style] forState:UIControlStateNormal];
        [Button setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        [Button setBackgroundImage:[core_utils imageWithColor:Rgb2UIColor(240, 240, 240)] forState:UIControlStateHighlighted];
        [Button addTarget:self action:@selector(Action:) forControlEvents:UIControlEventTouchUpInside];
        [Button setTag:c];
        [Button.titleLabel setFont:fontStyle];
        [self.view addSubview:Button];
        c+=1;
    }
}

/*
 * description : detect color
 */
- (UIColor*)detectTextColor:(MCALERTSHEETBUTTON)BtnType {
    switch (BtnType) {
        case MCALERTSHEETBUTTONRED:
            return Rgb2UIColor(210, 55, 55);
            break;
        case MCALERTSHEETBUTTONBLUE:
            return Rgb2UIColor(0, 65, 170);
            break;
        case MCALERTSHEETBUTTONBLACK:
            return Rgb2UIColor(58, 58, 58);
            break;
        case MCALERTSHEETBUTTONDISABLE:
            return Rgb2UIColor(200, 200, 200);
            break;
            
        default:
            break;
    }
}

/*
 * description : add new button to sheet
 */
- (void)addButton:(MC_AlertSheetAction*)Button {
    self.buttons = [[NSArray arrayWithArray:self.buttons] arrayByAddingObject:Button];
}


/*
 * description : Run Actions
 */
- (void)Action:(UIButton*)Btn {
    [self dismissViewControllerAnimated:true completion:nil];
    MC_AlertSheetAction *BtnInfo = [self.buttons objectAtIndex:Btn.tag];
    [BtnInfo performAction];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
