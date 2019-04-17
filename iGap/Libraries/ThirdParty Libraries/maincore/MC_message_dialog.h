//
//  MC_message_dialog.h
//  maincore
//
//  Created by Amir Soleimani on 7/11/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MC_OSLabel.h"
#import "MC_ButtonCore.h"

#import "core_utils.h"
#import "core_colors.h"
#import "UIFont+IRANSansMobile.h"


NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, MCMessageDialogActionButton) {
    MCMessageDialogActionButtonBlue,
    MCMessageDialogActionButtonDelete,
    MCMessageDialogActionButtonDefault
};

typedef NS_ENUM(NSInteger, MCMessageDialogInputType) {
    MCMessageDialogInputTypeNone,
    MCMessageDialogInputTypeCurrency,
    MCMessageDialogInputTypeText
};

@interface MC_ActionDialog : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(MCMessageDialogActionButton)style handler:(void (^ __nullable)(void))handler;

@end


@interface MC_message_dialog : UIViewController <UITextFieldDelegate>

- (instancetype)initWithTitle:(NSString*)Title message:(NSString*)Message delegate:(id)myDelegate;
- (instancetype)initWithTitle:(NSString*)Title inputtype:(MCMessageDialogInputType)InputType delegate:(id)myDelegate;
- (void)addAction:(MC_ActionDialog*)Action;
- (void)ShowDialog;

@property (nullable, nonatomic, copy, readonly) NSArray<MC_ActionDialog *> *actions;
@property (nonatomic, assign) MCMessageDialogInputType inputType;
@property (nonatomic, copy) NSString *inputValue;

@end


NS_ASSUME_NONNULL_END
