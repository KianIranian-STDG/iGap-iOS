//
//  MC_options_cell.h
//  raad
//
//  Created by Amir Soleimani on 9/17/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MC_OSLabel.h"

@interface MC_options_cell : UITableViewCell

@property (nonatomic, retain) MC_OSLabel *Title;
@property (nonatomic, assign) BOOL hasChild;
@property (nonatomic, assign) BOOL isRed;

@end
