//
//  core_textview_ph.h
//  newpost
//
//  Created by Amir Soleimani on 3/7/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MC_textviewholder : UITextView

@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, retain) IBInspectable NSString *placeholder;
@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
