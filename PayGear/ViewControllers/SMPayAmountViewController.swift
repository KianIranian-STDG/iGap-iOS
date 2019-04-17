//
//  SMPayAmountViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/22/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMPayAmountViewController: UIViewController,UITextFieldDelegate {
	
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var okButton: SMBottomButton!
    @IBOutlet weak var balanceLabel: UILabel!
	@IBOutlet weak var amountTitleLabel: UILabel!
	@IBOutlet weak var cashableBalanceLabel: UILabel!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var cashableAmountLabel: UILabel!
	@IBOutlet weak var moreInfoLabel: UILabel!
	@IBOutlet weak var headerInfoLabel: UIView!
	
    var balance = "0".inLocalizedLanguage()
    var finishDelegate : HandleDefaultCard?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SMTitle = "paygear.charge".localized
        okButton.enable()
        amountTextField.delegate = self
        
        
        amountTextField.inputView = LNNumberpad.default()
        amountTextField.layer.cornerRadius = 12
        amountTextField.layer.borderWidth = 1
        amountTextField.layer.borderColor = SMColor.Silver.cgColor
        amountTextField.clipsToBounds = true
		
		amountLabel.text = "paygear_account_balance".localized
		cashableAmountLabel.text = "cashable_balance".localized
		amountTextField.placeholder = "cashout.amount.placeholder".localized
		amountTitleLabel.text = "amount_to_cashin".localized

		moreInfoLabel.text = "charge.more.info".localized
        balanceLabel.text = balance
        cashableBalanceLabel.text = balance
        // Do any additional setup after loading the view.
        self.okButton.layoutIfNeeded()
		okButton.setTitle("OK".localized, for: .normal)

		let transform = SMDirection.PageAffineTransform()
		headerInfoLabel.transform = transform
		amountLabel.transform = transform
		cashableAmountLabel.transform = transform
		balanceLabel.transform = transform
		cashableBalanceLabel.transform = transform
		
		let alignment = SMDirection.TextAlignment()
		amountLabel.textAlignment = alignment
		amountTitleLabel.textAlignment = alignment
		cashableAmountLabel.textAlignment = alignment
		balanceLabel.textAlignment = (alignment == .right) ? .left : .right
		cashableBalanceLabel.textAlignment = (alignment == .right) ? .left : .right

    }
    
    override func viewDidLayoutSubviews() {
      okButton.layer.cornerRadius = okButton.frame.height / 2
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func okPressed(_ sender: Any) {
      
        SMLoading.showLoadingPage(viewcontroller: self)
        SMCard.initPayment(amount: Int((self.amountTextField.text?.onlyDigitChars())!),accountId:  SMUserManager.accountId, onSuccess: { response in
            SMLoading.hideLoadingPage()
            let json = response as? Dictionary<String, AnyObject>
            if let ipg = json?["ipg_url"] as? String ,ipg != "" {
                if let url = URL(string: ipg) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            else{
                SMUserManager.publicKey = json?["pub_key"] as? String
                SMUserManager.payToken = json?["token"] as? String
                let vc = SMNavigationController.shared.findViewController(page: .ChooseCard) as? SMChooseCardViewController
                vc?.amount = (self.amountTextField.text?.onlyDigitChars())!
                vc?.finishDelegate = self.finishDelegate
                SMMainTabBarController.packetTabNavigationController.pushViewController(vc!, animated: true)
            }
        }, onFailed: {err in
			if SMValidation.showConnectionErrorToast(err) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
            SMLoading.hideLoadingPage()
            SMLog.SMPrint(err)
        })
        
        
        
        
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
            var newStr = string
		
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            textField.text = newStr == "" ? "" : newStr.onlyDigitChars().inRialFormat().inLocalizedLanguage()
            
            if string == "" && range.location < textField.text!.length{
                let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
		
        return false
    }
}
