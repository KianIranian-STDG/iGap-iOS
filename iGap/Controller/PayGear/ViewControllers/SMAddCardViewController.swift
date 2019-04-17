//
//  SMAddCardViewController.swift
//  PayGear
//
//  Created by a on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMAddCardViewController: SMScrolableButtonViewController, UITextFieldDelegate, Keyboard {
    
    @IBOutlet weak var cardLabel: UILabel!
	@IBOutlet weak var monthLabel: UILabel!
	@IBOutlet weak var yearLabel: UILabel!
	@IBOutlet weak var defaultLabel: UILabel!
	
	@IBOutlet weak var defaultView: UIView!
	
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardTextField: UITextField!
    @IBOutlet weak var mounthTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: SMBottomButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var isDefaultSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        setupUI()
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
    }

    var finishDelegate : HandleDefaultCard?
    
    @IBAction func switchChanged(_ sender: Any) {
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newStr = string
       
        if textField.tag == 0 {
        
        if textField.text?.onlyDigitChars().length == 6 {
            cardImage.image = UIImage.init(named: SMBank.getBankLogo(bankCodeNumber: textField.text?.onlyDigitChars().inEnglishNumbers()))
        }
        else if textField.text?.onlyDigitChars().length == 5 {
            cardImage.image = UIImage.init(named:  "bank" )
        }
        
        newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
        textField.text = SMStringUtil.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()
        
        if string == "" && range.location < textField.text!.length {
            let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
      
        
        }
        else if textField.tag == 1 {
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            let currentCharacterCount = newStr.count
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 3
            
        }
        else if textField.tag == 2 {
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            let currentCharacterCount = newStr.count
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 3
            
        }
        return false
    }
    
    
    func up(hieght : CGFloat?) {
        
        heightConstraint.constant = heightConstraint.constant + (hieght ?? 0.0)
        self.view.layoutIfNeeded()
        //(self.view.subviews[0] as! UIScrollView).contentSize = CGSize.init(width: self.view.frame.width, height: hieght ?? 0.0)
    }
    
    func down(hieght : CGFloat?) {
        
        heightConstraint.constant = heightConstraint.constant - (hieght ?? 0.0)
        self.view.layoutIfNeeded()
        //(self.view.subviews[0] as! UIScrollView).contentSize = CGSize.init(width: self.view.frame.width, height: hieght ?? 0.0)
    }
    
    
    override func viewDidLayoutSubviews() {
        
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        cardImage.layer.cornerRadius = cardImage.frame.width / 2
        cardImage.layer.borderWidth = 1
        cardImage.layer.borderColor = SMColor.PrimaryColor.cgColor
        self.cardImage?.layer.shadowRadius = 10
        self.cardImage?.layer.shadowColor = UIColor.black.cgColor
        self.cardImage?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.cardImage?.layer.shadowOpacity = 0.5
    }
    
    
    override func setupUI() {
        
        self.SMTitle = "wallet.addcard.title".localized
    
        cardTextField.delegate = self
        yearTextField.delegate = self
        mounthTextField.delegate = self
        cardTextField.layer.cornerRadius = 12
        cardTextField.layer.borderWidth = 1
        cardTextField.layer.borderColor = SMColor.Silver.cgColor
        cardTextField.clipsToBounds = true
        mounthTextField.layer.cornerRadius = 12
        mounthTextField.layer.borderWidth = 1
        mounthTextField.layer.borderColor = SMColor.Silver.cgColor
        mounthTextField.clipsToBounds = true
        yearTextField.layer.cornerRadius = 12
        yearTextField.layer.borderWidth = 1
        yearTextField.layer.borderColor = SMColor.Silver.cgColor
        yearTextField.clipsToBounds = true
        saveButton.isEnabled = true
        saveButton.isUserInteractionEnabled = true
        self.cardTextField.inputView = LNNumberpad.default()
        self.mounthTextField.inputView = LNNumberpad.default()
        self.yearTextField.inputView = LNNumberpad.default()
		
		cardTextField.placeholder = "enter.card.number".localized
		mounthTextField.placeholder = "month".localized
		yearTextField.placeholder = "year".localized
		cardLabel.text = "card_number".localized
		monthLabel.text = "month".localized
		yearLabel.text = "year".localized
		defaultLabel.text = "default.card".localized
		saveButton.setTitle("Save".localized, for: .normal)
		
		
		let transform = SMDirection.PageAffineTransform()
//		isDefaultSwitch.transform = transform
		defaultView.transform = transform
		defaultLabel.transform = transform
		
		let alignment = SMDirection.TextAlignment()
		yearLabel.textAlignment = alignment
		monthLabel.textAlignment = alignment
		cardLabel.textAlignment = alignment
		defaultLabel.textAlignment = alignment
    }
    
    
    @IBAction func addCardPress(_ sender: Any) {
        let card = SMCard()
        card.pan = cardTextField.text?.onlyDigitChars().inEnglishNumbers()
        card.exp_y = yearTextField.text?.inEnglishNumbers()
        card.exp_m = mounthTextField.text?.inEnglishNumbers()
        card.isDefault = isDefaultSwitch.isOn
        saveButton.gotoLoadingState()
        self.view.isUserInteractionEnabled = false
        SMCard.addNewCardToServer(card, onSuccess: {
          
          self.saveButton.gotoButtonState()
          self.view.isUserInteractionEnabled = true
          self.finishDelegate?.finishDefault(isPaygear: false, isCard: true)
          self.navigationController?.popViewController(animated: true)
          
        }, onFailed: { err in
            
          self.saveButton.gotoButtonState()
          self.view.isUserInteractionEnabled = true
            if SMValidation.showConnectionErrorToast(err) {
          SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
            }
            })
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
