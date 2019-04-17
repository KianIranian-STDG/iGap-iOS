/******************************************************************************
 * v. 0.9.5  09 MAY 2013
 * Filename  LNNumberpad.m
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

#import "LNNumberpad.h"


#pragma mark - Private methods

@interface LNNumberpad ()

@property NSTimer * timer1;
@property NSTimer * timer2;
@property (nonatomic, weak) UIResponder <UITextInput> *targetTextInput;


@end

#pragma mark - LNNumberpad Implementation

@implementation LNNumberpad

@synthesize targetTextInput;

#pragma mark - Shared LNNumberpad method

+ (LNNumberpad *)defaultLNNumberpad {
    static LNNumberpad *defaultLNNumberpad = nil;
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
        defaultLNNumberpad = [[[NSBundle mainBundle] loadNibNamed:@"LNNumberpad" owner:self options:nil] objectAtIndex:0];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
           case 2436:
                defaultLNNumberpad.safeArea.hidden = NO;
                defaultLNNumberpad.frame = CGRectMake(0, 0, defaultLNNumberpad.frame.size.width, 260);
                break;
            default:
                defaultLNNumberpad.safeArea.hidden = YES;
                defaultLNNumberpad.frame = CGRectMake(0, 0, defaultLNNumberpad.frame.size.width, 216);
        }
    }
       });
    return defaultLNNumberpad;
}

#pragma mark - view lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addObservers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addObservers];
    }
    return self;
}




- (void)addObservers {
    // Keep track of the textView/Field that we are editing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidEndEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:nil];
    self.targetTextInput = nil;
}

#pragma mark - editingDidBegin/End

// Editing just began, store a reference to the object that just became the firstResponder
- (void)editingDidBegin:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UIResponder class]])
    {
        
        NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedLanguage"];
        if ([value  isEqual: @"en"]){
            [self.one setTitle:@"1" forState:UIControlStateNormal];
            [self.two setTitle:@"2" forState:UIControlStateNormal];
            [self.three setTitle:@"3" forState:UIControlStateNormal];
            [self.four setTitle:@"4" forState:UIControlStateNormal];
            [self.five setTitle:@"5" forState:UIControlStateNormal];
            [self.six setTitle:@"6" forState:UIControlStateNormal];
            [self.seven setTitle:@"7" forState:UIControlStateNormal];
            [self.eight setTitle:@"8" forState:UIControlStateNormal];
            [self.nine setTitle:@"9" forState:UIControlStateNormal];
            [self.zero setTitle:@"0" forState:UIControlStateNormal];
        }
        else{
            [self.one setTitle:@"۱" forState:UIControlStateNormal];
            [self.two setTitle:@"۲" forState:UIControlStateNormal];
            [self.three setTitle:@"۳" forState:UIControlStateNormal];
            [self.four setTitle:@"۴" forState:UIControlStateNormal];
            [self.five setTitle:@"۵" forState:UIControlStateNormal];
            [self.six setTitle:@"۶" forState:UIControlStateNormal];
            [self.seven setTitle:@"۷" forState:UIControlStateNormal];
            [self.eight setTitle:@"۸" forState:UIControlStateNormal];
            [self.nine setTitle:@"۹" forState:UIControlStateNormal];
            [self.zero setTitle:@"۰" forState:UIControlStateNormal];
        }
        
        
        if ([notification.object conformsToProtocol:@protocol(UITextInput)]) {
            self.targetTextInput = notification.object;
            return;
        }
    }
    
    // Not a valid target for us to worry about.
    self.targetTextInput = nil;
}

// Editing just ended.
- (void)editingDidEnd:(NSNotification *)notification {
    self.targetTextInput = nil;
}

#pragma mark - Keypad IBAction's

// A number (0-9) was just pressed on the number pad
// Note that this would work just as well with letters or any other character and is not limited to numbers.
- (IBAction)numberpadNumberPressed:(UIButton *)sender {
    if (self.targetTextInput) {
        NSString *numberPressed  = sender.titleLabel.text;
        if ([numberPressed length] > 0) {
            UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
            if (selectedTextRange) {
                [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:numberPressed];
            }
        }
    }
}

- (IBAction)numberpadDeleteRepeat:(id)sender {
    [self.timer1 invalidate];
    [self.timer2 invalidate];
}



// The delete button was just pressed on the number pad
- (IBAction)numberpadDeletePressed:(UIButton *)sender {
    if (self.targetTextInput) {
        [self deleteCharacter];

        self.timer1 = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(startDeleteCharacterTimer) userInfo:nil repeats:NO];
    }
}

-(void)startDeleteCharacterTimer{
    
    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(deleteCharacter) userInfo:nil repeats:YES];
}

-(void)deleteCharacter {
    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange) {
        // Calculate the selected text to delete
        UITextPosition  *startPosition  = [self.targetTextInput positionFromPosition:selectedTextRange.start offset:-1];
        if (!startPosition) {
            return;
        }
        UITextPosition  *endPosition    = selectedTextRange.end;
        if (!endPosition) {
            return;
        }
        UITextRange     *rangeToDelete  = [self.targetTextInput textRangeFromPosition:startPosition
                                                                           toPosition:endPosition];
        
        [self textInput:self.targetTextInput replaceTextAtTextRange:rangeToDelete withString:@""];
    }
}

// The clear button was just pressed on the number pad
- (IBAction)numberpadClearPressed:(UIButton *)sender {
    if (self.targetTextInput) {
        UITextRange *allTextRange = [self.targetTextInput textRangeFromPosition:self.targetTextInput.beginningOfDocument
                                                                     toPosition:self.targetTextInput.endOfDocument];
        
        [self textInput:self.targetTextInput replaceTextAtTextRange:allTextRange withString:@""];
    }
}

// The done button was just pressed on the number pad
- (IBAction)numberpadDonePressed:(UIButton *)sender {
        if (self.targetTextInput) {
            [self.targetTextInput resignFirstResponder];
        }
}

#pragma mark - text replacement routines

// Check delegate methods to see if we should change the characters in range
- (BOOL)textInput:(id <UITextInput>)textInput shouldChangeCharactersInRange:(NSRange)range withString:(NSString *)string {
	
    if (textInput) {
        if ([textInput isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)textInput;
            if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                if ([textField.delegate textField:textField
                    shouldChangeCharactersInRange:range
                                replacementString:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        } else if ([textInput isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)textInput;
            if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                if ([textView.delegate textView:textView
                        shouldChangeTextInRange:range
                                replacementText:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        }
    }
    return NO;
}

// Replace the text of the textInput in textRange with string if the delegate approves
- (void)textInput:(id <UITextInput>)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string {
    if (textInput) {
        if (textRange) {
            // Calculate the NSRange for the textInput text in the UITextRange textRange:
            int startPos                    = [textInput offsetFromPosition:textInput.beginningOfDocument
                                                                 toPosition:textRange.start];
            int length                      = [textInput offsetFromPosition:textRange.start
                                                                 toPosition:textRange.end];
            NSRange selectedRange           = NSMakeRange(startPos, length);
            
            if ([self textInput:textInput shouldChangeCharactersInRange:selectedRange withString:string]) {
                // Make the replacement:
                [textInput replaceRange:textRange withText:string];
            }
        }
    }
}

@end
