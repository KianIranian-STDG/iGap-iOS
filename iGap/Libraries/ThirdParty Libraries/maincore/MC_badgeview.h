//
//  MC_badgeview.h
//  maincore
//
//  Created by Amir Soleimani on 8/4/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MC_badgeview : UILabel

- (instancetype)initWithPoint:(CGPoint)Point;

@property (nonatomic, assign) float Rate;

@end
