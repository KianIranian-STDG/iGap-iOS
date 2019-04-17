//
//  MC_TabSwipe.m
//  maincore
//
//  Created by Amir Soleimani on 8/22/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_TabSwipe.h"
#import "core_utils.h"
#import "MC_borderview.h"
#import "UIFont+IRANSansMobile.h"

@implementation mc_obj_tabbar

@synthesize Id = _Id;
@synthesize Title = _Title;
@synthesize Controller = _Controller;

- (id)initWithId:(int)Id Title:(NSString*)Title controller:(id)Controller {
    if ((self = [super init])) {
        self.Id = Id;
        self.Title = Title;
        self.Controller = Controller;
    }
    return self;
}

@end


/*
 *
 */
@interface MC_TabSwipe ()
@property (nonatomic, copy) NSArray<mc_obj_tabbar*> *tabs;
@end

@implementation MC_TabSwipe {
    float tabHeight ,tabWidth ,indicatorHeight;
    MC_borderview *TabBase;
    UIView *Indicator;
    BOOL IndicatorActive;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self wakeup];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self wakeup];
    }
    return self;
}

- (void)wakeup {
    tabHeight = 44;
    indicatorHeight = 2;
    //--
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [self addChildViewController:self.pageController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    tabWidth = self.view.frame.size.width/[self.tabs count];
    self.activetabindex = [self.tabs firstObject].Id;
    // Do any additional setup after loading the view.
    
    //--Tab Base Setup
    TabBase = [[MC_borderview alloc] init];
    [TabBase setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:TabBase];
    
    //--Tabs View Setup
    for (mc_obj_tabbar *t in [[self.tabs reverseObjectEnumerator] allObjects]) {
        UIButton *TabBtn = [[UIButton alloc] init];
        [TabBtn.titleLabel setFont:[UIFont openIRANSansBoldFontOfSize:13]];
        [TabBtn setTitleColor:Rgb2UIColor(48, 48, 48) forState:UIControlStateNormal];
        [TabBtn addTarget:self action:@selector(TabTab:) forControlEvents:UIControlEventTouchUpInside];
        [TabBtn setTitle:t.Title forState:UIControlStateNormal];
        [TabBtn setTag:t.Id+1];
        [TabBase addSubview:TabBtn];
    }
    
    //--Indicator Setup
    Indicator = [[UIView alloc] init];
    [Indicator setBackgroundColor:Rgb2UIColor(35, 124, 234)];
    [TabBase addSubview:Indicator];
    
    //--PageController View Setup
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    for (id v in self.pageController.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]){
            ((UIScrollView*)v).delegate = self;
        }
    }
    
    //Set Main Controller
    if ([self.tabs count] > 0) {
        NSArray *viewControllers = [NSArray arrayWithObject:[self.tabs objectAtIndex:0].Controller];
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}


/*
 * description : tab touch
 */
- (void)TabTab:(UIButton*)Btn {
    [self SwitchToTab:Btn.tag];
}

- (void)SwitchToTab:(NSInteger)Tag {
    IndicatorActive = true;
    [TabBase setUserInteractionEnabled:false];
    //--
    
    UIPageViewControllerNavigationDirection Direction;
    if (self.activetabindex >= Tag) {
        Direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        Direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    self.activetabindex = Tag-1;
    [self TabSwitched:self.activetabindex];
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.tabs objectAtIndex:Tag-1].Controller];
    [self.pageController setViewControllers:viewControllers direction:Direction animated:YES completion:nil];
    
    UIButton *Btn = [TabBase viewWithTag:Tag];
    
    CGRect IndFrame = Indicator.frame;
    IndFrame.origin.x = Btn.frame.origin.x;
    [UIView animateWithDuration:0.2f animations:^{
        [self->Indicator setFrame:IndFrame];
    } completion:^(BOOL finished) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self->IndicatorActive = false;
            [self->TabBase setUserInteractionEnabled:true];
        });
    }];
}

/*
 * Page Controller
 */
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    return [self.tabs objectAtIndex:index].Controller;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self ReturnIndex:viewController];
    if (index == 0) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self ReturnIndex:viewController];
    index++;
    if (index == [self.tabs count])
        return nil;
    return [self viewControllerAtIndex:index];
}

- (NSUInteger)ReturnIndex:(UIViewController*)VC {
    for (mc_obj_tabbar *i in self.tabs) {
        if ([VC isEqual:i.Controller]) {
            return i.Id;
        }
    }
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (finished) {
        self.activetabindex = [self ReturnIndex:[[self.pageController viewControllers] objectAtIndex:0]];
        [self TabSwitched:self.activetabindex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"FINISH");
}

/*
 * Scroll
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!IndicatorActive) {
        CGRect indicatorFrame = Indicator.frame;
        float changeX = (scrollView.contentOffset.x-self.view.frame.size.width)/[self.tabs count];
        UIButton *activeindexBtn = [TabBase viewWithTag:self.activetabindex+1];
        float Xactiveindex = activeindexBtn.frame.origin.x;
        indicatorFrame.origin.x = Xactiveindex + changeX;
        [Indicator setFrame:indicatorFrame];
    }
}

/*
 * fucking layout :)
 */
- (void)viewWillLayoutSubviews {
    [TabBase setFrame:CGRectMake(0, 0, self.view.frame.size.width, tabHeight)];
    NSArray *ImagesBaseBorder = @[
                                  [MC_obj_borderview borderWithPosition:MC_BORDERVIEW_BOTTOM
                                                                  start:CGPointMake(0, TabBase.frame.size.height)
                                                                    end:CGPointMake(TabBase.frame.size.width, TabBase.frame.size.height)
                                                                  color:Rgb2UIColor(230, 230, 230)
                                   ]
                                  ];
    [TabBase setBorderPositions:ImagesBaseBorder];
    
    int i = 0;
    for (UIButton *btn in TabBase.subviews) {
        [btn setFrame:CGRectMake((i*tabWidth)+(i*1), 0, tabWidth-i, tabHeight)];
        i+=1;
    }
    
    [Indicator setFrame:CGRectMake(tabWidth*([self.tabs count]-1), tabHeight-indicatorHeight, tabWidth, indicatorHeight)];
    [[self.pageController view] setFrame:CGRectMake(0, tabHeight, self.view.frame.size.width, self.view.frame.size.height-tabHeight)];
    //--
}

- (void)addTab:(mc_obj_tabbar*)Tab {
    self.tabs = [[NSArray arrayWithArray:self.tabs] arrayByAddingObject:Tab];
}

/*
 * fuck method interface
 */
- (void)TabSwitched:(NSInteger)TabIndex {}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

