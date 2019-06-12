//
//  customTextfield.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/11/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class customUITextField: UITextField, UITextFieldDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)

//        delegate = self
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)

//        delegate = self
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        if let amountString = textField.text?.currencyFormat() {
            textField.text = amountString.trimmingCharacters(in: .whitespaces)
        }
        
    }

}
