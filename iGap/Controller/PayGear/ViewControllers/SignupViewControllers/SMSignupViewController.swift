//
//  SMSignupViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice

/// Get phone number to start signup or signin
class SMSignupViewController: SMBaseFormViewController, UITextFieldDelegate {

    /// Base view to handle scrolling up page when keyboard is showing
    @IBOutlet var scrollView: UIScrollView!
	
    /// Main  view of scroll view
    @IBOutlet var contentView: UIView!
	
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    var confirmBtn : SMGradientButton!
    var phoneTF : SMTextField!
    
    /// Create form and reload phone number if it is saved on Default data
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createForm()
		
		if SMUserManager.mobileNumber?.onlyDigitChars().length == 12 {
			var str = SMUserManager.mobileNumber?.onlyDigitChars()
			str = str?.substring(2)
            
        	phoneTF.text =  str?.inLocalizedLanguage() ?? ""
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        let navigation = SMNavigationController.shared
        navigation.navigationBar.isHidden = true

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    
    /// Change the view constraint of confirmBtn when keyboard is shwing
    ///
    /// - Parameter notification: notification user default
    override func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        contentViewHeightConstraint.constant = contentViewHeightConstraint.constant + keyboardHeight;
        
        UIView.animate(withDuration: 0.3) {
            self.confirmBtn.layer.cornerRadius = 0
            self.confirmBtn.removeFromSuperview()
            let window = UIApplication.shared.keyWindow!
            window.addSubview(self.confirmBtn)
            
            NSLayoutConstraint(item: self.confirmBtn, attribute: .leading, relatedBy: .equal, toItem: window, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.confirmBtn, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1, constant: -keyboardHeight).isActive = true
            NSLayoutConstraint(item: self.confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: window, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
            
        }
        self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }
    
    /// Reset constraint of confirmBtn
    ///
    /// - Parameter notification: notification user default
    override func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        contentViewHeightConstraint.constant = contentViewHeightConstraint.constant - keyboardHeight;

		UIView.animate(withDuration: 0.3) {
			//define code to showw button on scroll view, if needed
			self.confirmBtn.removeFromSuperview()
			self.confirmBtn.layer.cornerRadius = 24
			
			self.contentView.addSubview(self.confirmBtn)
			
			NSLayoutConstraint(item: self.confirmBtn, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
			NSLayoutConstraint(item: self.confirmBtn, attribute: .top, relatedBy: .equal, toItem: self.phoneTF, attribute: .bottomMargin, multiplier: 1, constant: 20).isActive = true
			NSLayoutConstraint(item: self.confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
			NSLayoutConstraint(item: self.confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
			
		}
		self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }

	

    func createForm() {
	
        let infolbl = UILabel()
        infolbl.text = "enterPhoneNumber".localized
        infolbl.font = SMFonts.IranYekanBold(16)
        infolbl.textAlignment = SMDirection.TextAlignment()
        infolbl.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(infolbl)

        NSLayoutConstraint(item: infolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 200).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true


        let countryCodelbl = UILabel()
        countryCodelbl.text = "iranPhoneCode".localized
        countryCodelbl.font = SMFonts.IranYekanBold(16)
        countryCodelbl.layer.borderWidth = 1
        countryCodelbl.layer.cornerRadius = 12
        countryCodelbl.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        countryCodelbl.textAlignment = .center
        countryCodelbl.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(countryCodelbl)

        NSLayoutConstraint(item: countryCodelbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: countryCodelbl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 72).isActive = true
        NSLayoutConstraint(item: countryCodelbl, attribute: .top, relatedBy: .equal, toItem: infolbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: countryCodelbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true

        phoneTF = SMTextField()
        phoneTF.font = SMFonts.IranYekanBold(16)
        phoneTF.placeholder = "phonePH".localized
		phoneTF.delegate = self
        phoneTF.textAlignment = SMDirection.TextAlignment()
        phoneTF.borderStyle = .none
        phoneTF.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        phoneTF.layer.cornerRadius = 12
        phoneTF.layer.borderWidth = 1
        phoneTF.translatesAutoresizingMaskIntoConstraints = false
//        phoneTF.keyboardType = .numberPad
		phoneTF.delegate = self
		phoneTF.inputView =  LNNumberpad.default()
        contentView.addSubview(phoneTF)

        NSLayoutConstraint(item: phoneTF, attribute: .leading, relatedBy: .equal, toItem: countryCodelbl, attribute: .trailingMargin, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: phoneTF, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: phoneTF, attribute: .top, relatedBy: .equal, toItem: infolbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: phoneTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true


        confirmBtn = SMGradientButton()
        confirmBtn.enable()
        confirmBtn.colors = [UIColor(netHex: 0x00e676), UIColor(netHex: 0x2ecc71)]
        confirmBtn.backgroundColor = UIColor(netHex: 0x00e676)
        confirmBtn.titleLabel?.textColor = UIColor(netHex: 0xffffff)
        confirmBtn.setTitle("confirm".localized, for: .normal)
        confirmBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
        confirmBtn.contentMode = .center
        confirmBtn.contentHorizontalAlignment = .center
        confirmBtn.addTarget(self, action: #selector(self.callSignupAPI(_:)),         for: .touchUpInside)
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.layer.cornerRadius = 24
		confirmBtn.gotoButtonState()
        contentView.addSubview(confirmBtn)

        NSLayoutConstraint(item: confirmBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .top, relatedBy: .equal, toItem: phoneTF, attribute: .bottomMargin, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
    }

    
	
    /// Validate Phone number and Call Signup API
    ///
    /// - Parameter sender: sender button
    @objc func callSignupAPI(_ sender: SMBottomButton) {
     
//        confirmBtn.
        let phoneNumber = "+98\(phoneTF.text!)".inEnglishNumbers()
        if SMValidation.mobileValidation(phoneNumber) {
            confirmBtn.gotoLoadingState()
            self.view.endEditing(true)
            let request = WS_methods(delegate: self, failedDialog: true)
            
            request.addSuccessHandler { (response : Any) in

                self.confirmBtn.gotoButtonState()
                self.view.endEditing(false)
               //goto next page
                let navigation = SMNavigationController.shared
                navigation.style = .SMSignupStyle
                navigation.navigationBar.isHidden = false
                SMUserManager.mobileNumber = phoneNumber
                navigation.pushNewViewController(page: .ConfirmPhonePage)
				self.phoneTF.isUserInteractionEnabled = true
            }
            request.addFailedHandler({ (response: Any) in
				if SMValidation.showConnectionErrorToast(response) {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
                self.confirmBtn.gotoButtonState()
                self.view.endEditing(false)
                self.phoneTF.isUserInteractionEnabled = true
            })

			request.au_request_otp(phoneNumber, callTo: false)
			
        }
        else {
//            //invalid input
            SMMessage.showWithMessage("PhoneNumberIsNotValid".localized)
            
        }
    }
	
	/// Check TextField input, avoid zero at first index, limit character to 9
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		if range.location == 0, string.inEnglishNumbers() == "0" {
			return false
		}

		if range.location > 9 {
			return false
		}
		
		if range.location == 0, range.length == 1, string == "" {
			phoneTF.textAlignment = SMDirection.TextAlignment()
		}
		else {
			phoneTF.textAlignment = .left
		}
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField.text?.length == 0 {
			phoneTF.textAlignment = SMDirection.TextAlignment()

		}
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
