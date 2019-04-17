//
//  PU_ActionDelegate.h
//  maincore
//  Page - User Profile
//
//  Created by Amir Soleimani on 8/6/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//
#import <UIKit/UIKit.h>

#ifndef PU_ActionDelegate_h
#define PU_ActionDelegate_h

@class PU_obj_account;
@class CL_LevelsController;

@protocol PU_ActionDelegate <NSObject>

@optional
- (void)PU_OpenPages:(id)Target info:(PU_obj_account*)Info;
- (void)PU_OpenAccountBulkList:(id)Target ids:(NSMutableArray<NSString*>*)Ids;

- (void)PU_AccountShowListSelected:(PU_obj_account*)Info;
- (void)PU_AccountShowListClosed;

- (CL_LevelsController*)CL_UserClubs:(NSString*)AccountId;
- (CL_LevelsController*)CL_UserClubs:(BOOL)getMerchantRegistered merchant:(PU_obj_account*)merchant;

@end

#endif /* PU_ActionDelegate_h */
