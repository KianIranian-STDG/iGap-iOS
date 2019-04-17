//
//  ViewControllerNav.m
//  userauth
//
//  Created by Amir Soleimani on 7/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_ViewControllerNav.h"
#import "core_utils.h"
#import "MC_titlesub_view.h"

@interface MC_ViewControllerNav ()

@end

@implementation MC_ViewControllerNav

@synthesize leftCloseButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self NavigationSetup];
}

/*
 * description : set title/Subtitle
 */
- (void)NavigationWithTitle:(NSString*)Title subtitle:(NSString*)Subtitle {
    MC_titlesub_view *NavigationTitle = [[MC_titlesub_view alloc] init];
    [NavigationTitle setTitleText:Title];
    [NavigationTitle setSubTitleText:Subtitle];
    self.navigationItem.titleView = NavigationTitle;
}

- (void)NavigationSetup {
    //--Left Item Button
    NSUInteger Count = [[self.navigationController viewControllers] count];
    if (Count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"core_back" inBundle:[core_utils getResourcesBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(Back)];
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)setLeftCloseButton:(BOOL)ileftCloseButton {
    leftCloseButton = ileftCloseButton;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"core_close" inBundle:[core_utils getResourcesBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(Close)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //--
    if (self.CustomNavigation)
        [self.navigationController setNavigationBarHidden:true animated:true];
    else
        [self.navigationController setNavigationBarHidden:false animated:true];
}

- (void)Close {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)Back {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
