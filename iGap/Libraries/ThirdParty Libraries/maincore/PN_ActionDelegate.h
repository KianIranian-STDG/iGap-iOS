//
//  PN_ActionDelegate.h
//  maincore
//
//  Created by Amir Soleimani on 9/18/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#ifndef PN_ActionDelegate_h
#define PN_ActionDelegate_h

@class PN_obj_notification;

@protocol PN_ActionDelegate <NSObject>

@optional
- (void)PN_Action:(PN_obj_notification*)NotificationInfo;
- (void)PN_OpenSlider:(PN_obj_notification*)Notification;

@end

#endif /* PN_ActionDelegate_h */
