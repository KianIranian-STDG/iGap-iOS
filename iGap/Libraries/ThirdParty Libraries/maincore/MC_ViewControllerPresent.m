//
//  MC_ViewControllerPresent.m
//  maincore
//
//  Created by Amir Soleimani on 8/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_ViewControllerPresent.h"
#import "MC_PresentationController.h"

@interface MC_ViewControllerPresent ()

@end

@implementation MC_ViewControllerPresent

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[MC_PresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

@end
