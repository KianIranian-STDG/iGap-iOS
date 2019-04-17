//
//  MC_borderview.h
//  page-user-profile
//
//  Created by Amir Soleimani on 8/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MC_BORDERVIEW_TOP = 1,
    MC_BORDERVIEW_BOTTOM = 2
} MC_BORDERVIEW;

//-- MC_navigationbar_action
@interface MC_obj_borderview : NSObject

+ (instancetype)borderWithPosition:(MC_BORDERVIEW)Position start:(CGPoint)Start end:(CGPoint)End color:(UIColor*)Color;

@end


@interface MC_borderview : UIView {
    NSArray *_borderPositions;
    UIColor *_borderColor;
}

@property (nonatomic,copy) NSArray *borderPositions;
@property (nonatomic,copy) UIColor *borderColor;

@end
