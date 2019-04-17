//
//  MC_navigationbar.h
//  page-user-profile
//
//  Created by Amir Soleimani on 8/1/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MC_NAVITEMALIGN_LEFT = 0, //LEFT
    MC_NAVITEMALIGN_RIGHT = 1 //RIGHT
} MC_NAVITEMALIGN;

@class MC_navigationitembutton;
@class MC_navigationbar_action;

//--MC_navigationbar_button
@interface MC_navigationbar_button : UIButton

@property (nonatomic,assign) NSUInteger BadgeCount;
@property (nonatomic,assign) BOOL WhiteColor;
- (instancetype)initWithConfig:(MC_navigationbar_action*)Config;

@end

//-- MC_navigationbar_action
@interface MC_navigationbar_action : NSObject

+ (instancetype)actionWithTarget:(id)Target selector:(SEL)Selector icon:(UIImage *)Icon;

@end


//-- MC_navigationbar
@interface MC_navigationbar : UIViewController

@property (nonatomic, strong) NSArray<MC_navigationbar_button*> *leftItem;
@property (nonatomic, strong) NSArray<MC_navigationbar_button*> *rightItem;
@property (nonatomic, assign) NSString *navigationtitle;
@property (nonatomic, assign) NSString *navigationsubtitle;
@property (nonatomic, assign) BOOL navigationTitleShow;
@property (nonatomic, assign) BOOL hideState;
@property (nonatomic, assign) BOOL WhiteColor;

- (void)loadOpacity:(float)ScrollY;
- (void)addLeftItem:(MC_navigationbar_button*)Item;
- (void)addRightItem:(MC_navigationbar_button*)Item;
- (void)hideNavigationBase;


@end

