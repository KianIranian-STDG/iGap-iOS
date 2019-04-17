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
//    var phoneTF : SMTextField!
    
    /// Create form and reload phone number if it is saved on Default data
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createForm()
		
		if SMUserManager.mobileNumber?.onlyDigitChars().length == 12 {
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
//            NSLayoutConstraint(item: self.confirmBtn, attribute: .top, relatedBy: .equal, toItem: self.phoneTF, attribute: .bottomMargin, multiplier: 1, constant: 20).isActive = true
			NSLayoutConstraint(item: self.confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
			NSLayoutConstraint(item: self.confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
			
		}
		self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }

	

    func createForm() {
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
//            SMMessage.showWithMessage("PhoneNumberIsNotValid".localized)
            
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
