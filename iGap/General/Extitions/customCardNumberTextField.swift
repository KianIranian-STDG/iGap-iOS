//
//  customCardNumberTextField.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/30/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class customCardNumberTextField: UITextField, UITextFieldDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
                        delegate = self
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
                delegate = self
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newStr = string
        
        if textField.tag == 0 {
            
       
            
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            textField.text = CardUtils.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()
            
            if string == "" && range.location < textField.text!.length {
                let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
            
            
        }
        
        
        return false
    }
    
    
}
