//
//  CustomTextView.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/30/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {
    

    override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯

    override func insertText(_ text: String) { print("\(text)") }

    override func deleteBackward() {}

    override var canBecomeFirstResponder: Bool { return true }

    override var canResignFirstResponder: Bool { return true }

    override var textInputMode: UITextInputMode? {

        for mode in UITextInputMode.activeInputModes {
            print(mode.primaryLanguage)
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }

}

