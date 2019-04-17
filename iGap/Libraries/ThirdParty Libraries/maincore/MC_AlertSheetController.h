//
//  PU_alertsheetcontroller.h
//  page-user-profile
//
//  Created by Amir Soleimani on 8/3/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MC_ViewControllerPresent.h"

typedef NS_ENUM(NSInteger, MCALERTSHEETBUTTON) {
    MCALERTSHEETBUTTONBLUE,
    MCALERTSHEETBUTTONRED,
    MCALERTSHEETBUTTONBLACK,
    MCALERTSHEETBUTTONDISABLE
};


NS_ASSUME_NONNULL_BEGIN

//--
@interface MC_AlertSheetAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(MCALERTSHEETBUTTON)style handler:(void (^ __nullable)(void))handler;

@end


//--
@interface MC_AlertSheetController : MC_ViewControllerPresent

- (void)addButton:(MC_AlertSheetAction*)Button;

@end

NS_ASSUME_NONNULL_END
