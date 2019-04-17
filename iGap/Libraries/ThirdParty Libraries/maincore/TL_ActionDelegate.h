//
//  TL_ActionDelegate.h
//  timeline
//  Timeline - Social
//
//  Created by Amir Soleimani on 6/26/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//
#import <UIKit/UIKit.h>

@class PU_obj_account;
@class TL_obj_mainpost;
@class TL_actionbar_button;

#ifndef TL_ActionDelegate_h
#define TL_ActionDelegate_h

@protocol TL_ActionDelegate <NSObject>

@optional
- (void)TL_SharePost:(id)Target postinfo:(TL_obj_mainpost*)PostInfo;

- (void)TL_OpenPosts:(NSArray*)PostIds;
- (void)TL_OpenLikes:(NSString*)PostId;
- (void)TL_OpenComments:(NSString*)PostId authorid:(NSString*)AuthorId;
- (void)TL_LikePost:(TL_obj_mainpost*)PostInfo button:(TL_actionbar_button*)Btn cellindex:(long)CellIndex;
- (void)TL_OptionPost:(TL_obj_mainpost*)PostInfo cellindex:(long)CellIndex;
- (void)TL_FollowerList:(NSString*)AccountId;
- (void)TL_FollowingList:(NSString*)AccountId;
- (void)TL_addedNewPost;
- (void)TL_openContactWithTarget:(id)Target;

@end

#endif /* TL_ActionDelegate_h */
