//
//  CP_ActionDelegate.h
//  maincore
//  Product - Carts
//
//  Created by Amir Soleimani on 8/6/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//
#import <UIKit/UIKit.h>

#ifndef CP_ActionDelegate_h
#define CP_ActionDelegate_h

@class PU_obj_account;
@class CP_obj_product;
@class CP_obj_sku;

@protocol CP_ActionDelegate <NSObject>

@optional
- (void)CP_OpenProducts:(id)Target info:(PU_obj_account*)Info;
- (void)CP_ShowProduct:(id)Target info:(CP_obj_product*)Info owner:(PU_obj_account *)Owner;
- (void)CP_ShowCart:(id)Target carts:(NSArray<CP_obj_sku*>*)carts;

@end

#endif /* CP_ActionDelegate.h */
