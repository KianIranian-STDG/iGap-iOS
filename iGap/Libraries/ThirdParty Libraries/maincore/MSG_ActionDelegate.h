//
//  MSG_ActionDelegate.h
//  maincore
//
//  Created by Amir Soleimani on 9/16/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#ifndef MSG_ActionDelegate_h
#define MSG_ActionDelegate_h

@class MSG_obj_thread;

@protocol MSG_ActionDelegate <NSObject>

@optional
- (void)MSG_NewMessageWithTarget:(id)Target info:(MSG_obj_thread*)Info;
@end

#endif /* MSG_ActionDelegate_h */
