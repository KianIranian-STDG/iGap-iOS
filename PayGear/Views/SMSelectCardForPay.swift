//
//  SMIsDefaultCard.swift
//  PayGear
//
//  Created by a on 4/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMSelectCardForPay: UIView,UITextFieldDelegate{

    
    @IBOutlet weak var secondPassTextField: UITextField!
    @IBOutlet weak var cvv2TextField: UITextField!
    @IBOutlet weak var cvv2TextView: UIView!
    @IBOutlet weak var cvv2TitleView: UIView!
	@IBOutlet var pinLabel: UILabel!
	@IBOutlet var cvv2Label: UILabel!
	
    
    class func instanceFromNib() -> SMSelectCardForPay {
        return UINib(nibName: "selectCardForPay", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMSelectCardForPay
        
    }
    
    func setupUI(){
        secondPassTextField.delegate = self
        cvv2TextField.delegate = self
        secondPassTextField.layer.cornerRadius = 12
        secondPassTextField.layer.borderWidth = 1
        secondPassTextField.layer.borderColor = SMColor.Silver.cgColor
        secondPassTextField.clipsToBounds = true
        cvv2TextField.layer.cornerRadius = 12
        cvv2TextField.layer.borderWidth = 1
        cvv2TextField.layer.borderColor = SMColor.Silver.cgColor
        cvv2TextField.clipsToBounds = true
        secondPassTextField.delegate = self
        cvv2TextField.delegate = self
		
		secondPassTextField.placeholder = "internet_pin_2".localized;
		secondPassTextField.font = SMFonts.IranYekanRegular(14.0)
        secondPassTextField.inputView = LNNumberpad.default()
        cvv2TextField.inputView = LNNumberpad.default()
		
		pinLabel.text = "internet_pin_2".localized
		let alignment = SMDirection.TextAlignment()
		cvv2Label.textAlignment = alignment
		pinLabel.textAlignment = alignment
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         var newStr = string
        newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
        textField.text = newStr.onlyDigitChars()
        
      
        if string == "" && range.location < textField.text!.length{
            let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
      
        return false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

}
