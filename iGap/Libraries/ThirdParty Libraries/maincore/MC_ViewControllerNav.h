//
//  ViewControllerNav.h
//  userauth
//
//  Created by Amir Soleimani on 7/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MC_ViewControllerNav : UIViewController <UIGestureRecognizerDelegate> {
    BOOL leftCloseButton;
}

@property (nonatomic,assign) BOOL leftCloseButton;
@property (nonatomic, assign) BOOL CustomNavigation;

- (void)NavigationWithTitle:(NSString*)Title subtitle:(NSString*)Subtitle;

@end
