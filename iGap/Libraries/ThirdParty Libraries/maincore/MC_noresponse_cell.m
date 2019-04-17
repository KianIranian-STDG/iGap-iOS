//
//  MC_noresponse_cell.m
//  maincore
//
//  Created by Amir Soleimani on 8/27/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import "MC_noresponse_cell.h"
#import "MC_OSLabel.h"

@implementation MC_noresponse_cell {
    MC_OSLabel *Label;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        Label = [[MC_OSLabel alloc] init];
        [Label setTextAlignment:NSTextAlignmentCenter];
        [Label setFont:[UIFont openIRANSansLightFontOfSize:13]];
        [Label setNumberOfLines:99];
        [Label setTextColor:[UIColor blackColor]];
        [self addSubview:Label];
        //--
        self.focusStyle = UITableViewCellFocusStyleCustom;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews {
    [Label setFrame:self.bounds];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setMessage:(NSString *)Message {
    _Message = Message;
    [Label setText:_Message];
}

@end
