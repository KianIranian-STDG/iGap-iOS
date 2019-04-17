//
//  MC_TableViewController.m
//  timeline
//
//  Created by Amir Soleimani on 7/25/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_TableViewController.h"
#import "MC_tableview_hint.h"
#import "MC_spinner_cell.h"
#import "core_utils.h"

@interface MC_TableViewController ()

@end

@implementation MC_TableViewController {
    UIView *BaseHint;
    MC_tableview_hint *Hint;
    float keyboardheight;
    UIActivityIndicatorView *Indicator;
}

@synthesize tableView;

- (void)loadView {
    [super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:tableView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.next_page = NO;
    self.next_page_loading = NO;
    self.page_number = 1;
    self.Cells = [[NSMutableArray alloc] init];
}


/*
 * Keyboard & TextField
 */
- (void)keyboardChangeFrame:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    keyboardheight = MIN(keyboardSize.height,keyboardSize.width);
    //--
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height-keyboardheight;
    [UIView animateWithDuration:0.1f animations:^{
        [self.tableView setFrame:tableFrame];
    }];
}

- (void)keyboardHideFrame:(NSNotification *)notification {
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height;
    [UIView animateWithDuration:0.1f animations:^{
        [self.tableView setFrame:tableFrame];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //--
    Indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [Indicator.layer setCornerRadius:20];
    [Indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [Indicator setHidesWhenStopped:true];
    [self.view addSubview:Indicator];
    
    
    //self.clearsSelectionOnViewWillAppear = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    /*
     * Table Config
     */
    self.CellSpaceColor =  [UIColor whiteColor];//Rgb2UIColor(238, 240, 240);
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.translatesAutoresizingMaskIntoConstraints = true;
    [self.tableView registerClass:[MC_noresponse_cell class] forCellReuseIdentifier:@"MC_noresponse_cell"];
    [self.tableView registerClass:[MC_spinner_cell class] forCellReuseIdentifier:@"MC_spinner_cell"];
    
    [self SetupRefreshControll];
    
    
    /*
     * in-Call Status Bar
     */
    CGRect superFrame = self.view.frame;
    if (superFrame.origin.y > 0) {
        superFrame.origin.y = 0;
        [self.view setFrame:superFrame];
    }
}

- (void)StartSpinner {
    [Indicator startAnimating];
    [Indicator setBackgroundColor:[UIColor whiteColor]];
}

- (void)StopSpinner {
    [Indicator stopAnimating];
}

- (void)RemoveRefreshControll { //-1 l :-D
    [self.refreshControl removeFromSuperview];
    self.refreshControl = nil;
}

- (void)SetupRefreshControll {
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
}

- (void)AddNoResponse:(NSString*)String {
    _NoResponseString = String;
    [self.Cells addObject:[MC_noresponse_cell new]];
}

/*
 * Cleaner Cell
 */
- (void)cleanercell {
    if (self.refreshControl.isRefreshing)
        [self.refreshControl endRefreshing];
    //--
    id lastCell = [self.Cells lastObject];
    if ([lastCell isKindOfClass:[MC_noresponse_cell class]] || [lastCell isKindOfClass:[MC_spinner_cell class]])
        [self.Cells removeLastObject];
}

/*
 * description : Add/Remove Screen Hint
 */
- (void)AddScreenHint:(NSString*)Message {
    [self RemoveScreenHint];
    //--
    BaseHint = [[UIView alloc] initWithFrame:CGRectZero];
    [BaseHint setTag:100];
    
    Hint = [[MC_tableview_hint alloc] initWithText:Message];
    
    [BaseHint addSubview:Hint];
    [self.view addSubview:BaseHint];
}

/*
 * description : remove screen hint
 */
- (void)RemoveScreenHint {
    if ([self.view viewWithTag:100])
        [[self.view viewWithTag:100] removeFromSuperview];
}

/*
 * description : kill Scroll
 */
- (void)killScroll {
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
}

/*
 * description : back navigation
 */
- (void)back {
    [self.navigationController popViewControllerAnimated:true];
}

/*
 * description : close view
 */
- (void)close {
    if (self.navigationController != nil)
        [self.navigationController popViewControllerAnimated:true];
    else
        [self dismissViewControllerAnimated:true completion:nil];
}

/*
 * description :
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float y = self.tableView.contentSize.height-(self.tableView.contentOffset.y+self.tableView.frame.size.height);
    if (y < 100 && !self.next_page_loading && self.next_page) {
        [self loadnextpage];
    }
}

/*
 * description :
 */
- (void)addSpinnerFooter {
    [self.Cells addObject:[MC_spinner_cell new]];
}

- (void)loadnextpage {}

- (void)viewWillLayoutSubviews {
    [BaseHint setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [Hint setCenter:CGPointMake(BaseHint.frame.size.width/2.0f, BaseHint.frame.size.height/2.0f)];
    [Indicator setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 )];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

