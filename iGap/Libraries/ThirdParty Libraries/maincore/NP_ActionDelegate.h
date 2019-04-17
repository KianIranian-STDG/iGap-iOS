//
//  NP_ActionDelegate.h
//  maincore
//
//  Created by Amir Soleimani on 9/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#ifndef NP_ActionDelegate_h
#define NP_ActionDelegate_h

@class NP_obj_scanner;

@protocol NP_ActionDelegate <NSObject>

@optional
- (void)doAction:(int)Type jsonmodel:(NP_obj_scanner*)JSON;

@end

#endif /* NP_ActionDelegate_h */
