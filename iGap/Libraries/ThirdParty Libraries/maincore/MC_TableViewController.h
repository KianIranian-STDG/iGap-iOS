//
//  MC_TableViewController.h
//  timeline
//
//  Created by Amir Soleimani on 7/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MC_ViewControllerNav.h"
#import "MC_obj_cell.h"
#import "MC_MainCell.h"
#import "MC_noresponse_cell.h"

@interface MC_TableViewController : MC_ViewControllerNav <UIGestureRecognizerDelegate,UIScrollViewDelegate> {
    UITableView *tableView;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *Cells;
@property (nonatomic, copy) UIColor *CellSpaceColor;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (void)killScroll;
- (void)AddScreenHint:(NSString*)Message;
- (void)RemoveScreenHint;
- (void)RemoveRefreshControll;
- (void)SetupRefreshControll;

- (void)StartSpinner;
- (void)StopSpinner;

- (void)back;
- (void)close;

- (void)keyboardChangeFrame:(NSNotification *)notification;
- (void)keyboardHideFrame:(NSNotification *)notification;

@property (nonatomic, copy, readonly) NSString *NoResponseString;
- (void)AddNoResponse:(NSString*)String;

@property (nonatomic, assign) BOOL next_page;
@property (nonatomic, assign) NSInteger page_number;
@property (nonatomic, assign) BOOL next_page_loading;
- (void)loadnextpage;

- (void)addSpinnerFooter;
- (void)cleanercell;

@end

