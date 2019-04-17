//
//  MC_PresentationController.m
//  maincore
//
//  Created by Amir Soleimani on 8/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_PresentationController.h"

@interface MC_PresentationController () {
    UIView *BackTransparent;
}
@end

@implementation MC_PresentationController

- (void)presentationTransitionWillBegin {
    BackTransparent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    [BackTransparent setAlpha:0];
    [BackTransparent setBackgroundColor:[UIColor blackColor]];
    [self.containerView addSubview:BackTransparent];
    [UIView animateWithDuration:0.2f animations:^{
        [self->BackTransparent setAlpha:0.8f];
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self->BackTransparent addGestureRecognizer:singleFingerTap];
    }];
}

- (void)dismissalTransitionWillBegin {
    [UIView animateWithDuration:0.2f animations:^{
        [self->BackTransparent setAlpha:0];
    } completion:^(BOOL finished) {
        [BackTransparent removeFromSuperview];
    }];
}

- (CGRect)frameOfPresentedViewInContainerView {
    return CGRectMake(self.presentedView.frame.origin.x, (self.containerView.bounds.size.height-self.presentedView.frame.size.height)+(self.presentedView.frame.origin.y), self.presentedView.frame.size.width, self.presentedView.frame.size.height);
}

- (void)dismiss {
    [self.presentedViewController dismissViewControllerAnimated:true completion:nil];
}

@end

