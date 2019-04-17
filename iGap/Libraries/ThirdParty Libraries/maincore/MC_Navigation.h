//
//  MC_Navigation.h
//  maincore
//
//  Created by Amir Soleimani on 7/18/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MC_Navigation : UINavigationController <UIGestureRecognizerDelegate> {
    BOOL leftCloseButton;
}

@property (nonatomic,assign) BOOL leftCloseButton;
@property (nonatomic,weak) id parentdelegate;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController leftClose:(BOOL)leftClose;

@end
