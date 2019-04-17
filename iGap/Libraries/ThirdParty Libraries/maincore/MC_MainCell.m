//
//  DynamicTableViewCell.m
//  Rad
//
//  Created by Amir Soleimani on 9/2/16.
//  Copyright © 2016 Amir Soleimani. All rights reserved.
//

#import "MC_MainCell.h"

@interface MC_MainCell()

@end

@implementation MC_MainCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
