//
//  ST_ActionDelegate.h
//  settings
//
//  Created by Amir Soleimani on 9/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#ifndef ST_ActionDelegate_h
#define ST_ActionDelegate_h

@protocol ST_ActionDelegate <NSObject>

@optional
- (void)ST_EditProfile:(id)Target;
- (void)ST_OpenSetting:(id)Target;

@end

#endif /* ST_ActionDelegate_h */
