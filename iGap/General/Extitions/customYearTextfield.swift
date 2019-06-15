//
//  customYearTextfield.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/15/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import UIKit

class customYearTextfield: UITextField, UITextFieldDelegate {
    
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
        
        if let amountString = textField.text {
            if amountString.count <= 2 {
                textField.text = amountString.trimmingCharacters(in: .whitespaces).inLocalizedLanguage()

            }
            else {
                textField.deleteBackward()

            }
        }
        
    }

    
}
