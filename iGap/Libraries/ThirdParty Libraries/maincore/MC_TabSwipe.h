//
//  MC_TabSwipe.h
//  maincore
//
//  Created by Amir Soleimani on 8/22/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MC_ViewControllerNav.h"

@interface mc_obj_tabbar : NSObject {
    int _Id;
    NSString *_Title;
    id _Controller;
}

@property (nonatomic, assign) int Id;
@property (nonatomic, copy) NSString *Title;
@property (nonatomic, strong) id Controller;

- (id)initWithId:(int)Id Title:(NSString*)Title controller:(id)Controller;

@end

@interface MC_TabSwipe : MC_ViewControllerNav <UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (nonatomic, assign) NSInteger activetabindex;
- (void)addTab:(mc_obj_tabbar*)Tab;
- (void)TabSwitched:(NSInteger)TabIndex;
- (void)SwitchToTab:(NSInteger)Tag;

@end

