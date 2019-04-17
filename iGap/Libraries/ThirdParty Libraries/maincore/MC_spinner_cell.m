//
//  MC_spinner_cell.m
//  maincore
//
//  Created by Amir Soleimani on 9/1/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_spinner_cell.h"

@implementation MC_spinner_cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.Indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.Indicator startAnimating];
        [self addSubview:self.Indicator];
        //--
        self.focusStyle = UITableViewCellFocusStyleCustom;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews {
    self.Indicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self setBackgroundColor:[UIColor clearColor]];
}

@end
