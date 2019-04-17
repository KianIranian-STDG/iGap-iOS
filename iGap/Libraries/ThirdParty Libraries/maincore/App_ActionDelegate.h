//
//  App_ActionDelegate.h
//  maincore
//
//  Created by Amir Soleimani on 8/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#ifndef App_ActionDelegate_h
#define App_ActionDelegate_h

@protocol App_ActionDelegate <NSObject>

@optional
- (void)App_SwitchHome;
- (void)App_SwitchLogin;
- (id)ActionPods;

@end

#endif /* App_ActionDelegate_h */
