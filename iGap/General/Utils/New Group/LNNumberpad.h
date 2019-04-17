/******************************************************************************
 * v. 0.9.5  09 MAY 2013
 * Filename  LNNumberpad.h
 * Project:  LNNumberpad
 * Purpose:  Class to display a custom LNNumberpad on an iPad and properly handle 
 *           the text input.
 * Author:   Louis Nafziger
 *
 * Copyright 2012 - 2013 Louis Nafziger
 ******************************************************************************
 *
 * This file is part of LNNumberpad.
 *
 * COPYRIGHT 2012 - 2013 Louis Nafziger
 *
 * LNNumberpad is free software: you can redistribute it and/or modify
 * it under the terms of the The MIT License (MIT).
 *
 * LNNumberpad is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * The MIT License for more details.
 *
 * You should have received a copy of the The MIT License (MIT)
 * along with LNNumberpad.  If not, see <http://opensource.org/licenses/MIT>.
 *
 *****************************************************************************/

#import <UIKit/UIKit.h>


@interface LNNumberpad : UIView


@property (weak, nonatomic) IBOutlet UIButton *one;
@property (weak, nonatomic) IBOutlet UIButton *two;
@property (weak, nonatomic) IBOutlet UIButton *three;
@property (weak, nonatomic) IBOutlet UIButton *four;
@property (weak, nonatomic) IBOutlet UIButton *five;
@property (weak, nonatomic) IBOutlet UIButton *six;
@property (weak, nonatomic) IBOutlet UIButton *seven;
@property (weak, nonatomic) IBOutlet UIButton *eight;
@property (weak, nonatomic) IBOutlet UIButton *nine;
@property (weak, nonatomic) IBOutlet UIButton *zero;

@property (weak, nonatomic, getter=isAvaiable) IBOutlet UIStackView *safeArea;

// The one and only LNNumberpad instance you should ever need:
+ (LNNumberpad *)defaultLNNumberpad;

@end
