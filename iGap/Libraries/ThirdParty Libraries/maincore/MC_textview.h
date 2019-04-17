//
//  MC_textview.h
//  maincore
//
//  Created by Amir Soleimani on 8/23/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MC_textview : UITextView

@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, retain) IBInspectable NSString *placeholder;

-(void)textChanged:(NSNotification*)notification;

@end
