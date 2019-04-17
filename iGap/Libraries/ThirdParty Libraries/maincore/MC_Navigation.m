//
//  MC_NavigationVC.m
//  maincore
//
//  Created by Amir Soleimani on 7/18/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_Navigation.h"
#import "core_utils.h"

@interface MC_Navigation ()

@end

@implementation MC_Navigation

@synthesize leftCloseButton;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController leftClose:(BOOL)leftClose {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self setLeftCloseButton:leftClose];
        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self NavigationSetup];
}

- (void)NavigationSetup {
    //--Left Item Button
    NSUInteger Count = [[self viewControllers] count];
    if (Count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"core_back" inBundle:[core_utils getResourcesBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(Back)];
    }
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)setLeftCloseButton:(BOOL)ileftCloseButton {
    leftCloseButton = ileftCloseButton;
    
    UIViewController *V = [[self viewControllers] objectAtIndex:0];
    V.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"core_close" inBundle:[core_utils getResourcesBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStyleDone target:self action:@selector(Close)];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [super pushViewController:viewController animated:animated];
    });
}

- (void)Close {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)Back {
    [self popViewControllerAnimated:true];
}

@end

