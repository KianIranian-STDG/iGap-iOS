//
//  MC_titlesub_view.h
//  maincore
//
//  Created by Amir Soleimani on 8/6/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MC_OSLabel;

@interface MC_titlesub_view : UIView

@property (nonatomic, strong) MC_OSLabel *Title;
@property (nonatomic, strong) MC_OSLabel *SubTitle;

- (void)setTitleText:(NSString*)Text;
- (void)setSubTitleText:(NSString*)Text;

@end
