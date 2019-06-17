//
//  customAmountTextField.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/17/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import UIKit

class customAmountTextField: UITextField, UITextFieldDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        //                delegate = self
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        //        delegate = self
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = (textField.text)?.inLocalizedLanguage() {
            if amountString.count <= 9 {
                let tmpTXT = (amountString.inEnglishNumbers().trimmingCharacters(in: .whitespaces)).currencyFormat()
                textField.text = tmpTXT.inLocalizedLanguage()
            }
            else {
                textField.deleteBackward()
                
            }
        }
        
    }
    
    
}
