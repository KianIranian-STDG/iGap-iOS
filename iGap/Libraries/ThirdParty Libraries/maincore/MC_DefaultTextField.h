//
//  MC_DefaultTextField.h
//  maincore
//
//  Created by Amir Soleimani on 7/15/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MC_DefaultTextField : UITextField

- (void)setLeftLabel:(NSString*)Value;
- (void)setPlaceHolderSize:(float)Size align:(NSTextAlignment)Align;
- (void)setPlaceHolderAlign:(NSTextAlignment)Align;

@property (nonatomic, retain) IBInspectable NSString *textholder;

@end
