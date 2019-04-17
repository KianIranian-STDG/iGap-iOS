//
//  SMConfirmPhoneViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice

/// After sending sms contains confirm code, at this page user enter that code to validate by system
class SMConfirmPhoneViewController: SMBaseFormViewController {

	/// Base view to handle scrolling up page when keyboard is showing
    @IBOutlet var scrollView: UIScrollView!
	
	/// Main  view of scroll view
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
	
    var confirmBtn : SMGradientButton!
    var codeTF : SMTextField!
    var phoneNumber: String!
	
	/// Create form and back button
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        phoneNumber = SMUserManager.mobileNumber
        self.navigationController?.navigationBar.isHidden = false
        addBackButton()
        createForm()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
	
	/// Change the view constraint of some view
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
    
	/// Reset constraint of confirm button
	///
	/// - Parameter notification: notification user default
    override func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
//        contentViewHeightConstraint.constant = contentViewHeightConstraint.constant - keyboardHeight;
        
        UIView.animate(withDuration: 0.3) {
            //define code to showw button on scroll view, if needed
            self.confirmBtn.removeFromSuperview()
            self.confirmBtn.layer.cornerRadius = 24
            
            self.contentView.addSubview(self.confirmBtn)
            
            NSLayoutConstraint(item: self.confirmBtn, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
            NSLayoutConstraint(item: self.confirmBtn, attribute: .top, relatedBy: .equal, toItem: self.codeTF, attribute: .bottomMargin, multiplier: 1, constant: 20).isActive = true
            NSLayoutConstraint(item: self.confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
            NSLayoutConstraint(item: self.confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true

        }
        self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }
    
    
    
    
   /// Back to signup view to edit phone number
   @objc func backButtonPressed(sender : Any){
    	self.navigationController?.popViewController(animated: true)
    }
    

    func createForm() {
        
        let notificationlbl = UILabel()
        notificationlbl.text = "confirmCodeInfo".localized
        
        notificationlbl.font = SMFonts.IranYekanBold(16)
        notificationlbl.textAlignment = .center
        notificationlbl.textColor = UIColor(netHex: 0x8a000000)
        notificationlbl.backgroundColor = UIColor(netHex: 0xe3f2fd)
        notificationlbl.translatesAutoresizingMaskIntoConstraints = false
        notificationlbl.text =  "\(String(describing: notificationlbl.text!))" + "\n" + "\(phoneNumber!.inLocalizedLanguage())"
        notificationlbl.numberOfLines = 0
        
        contentView.addSubview(notificationlbl)
        
        NSLayoutConstraint(item: notificationlbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: notificationlbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: notificationlbl, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: notificationlbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 72).isActive = true
        
        
        let infolbl = UILabel()
        infolbl.text = "enterConfirmCode".localized
        infolbl.font = SMFonts.IranYekanBold(16)
        infolbl.textAlignment = SMDirection.TextAlignment()
        infolbl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(infolbl)
        
        NSLayoutConstraint(item: infolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .top, relatedBy: .equal, toItem: notificationlbl, attribute: .top, multiplier: 1, constant: 150).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        codeTF = SMTextField()
        codeTF.font = SMFonts.IranYekanBold(16)
        codeTF.placeholder = "confirmCodePH".localized
        codeTF.textAlignment = SMDirection.TextAlignment()
        codeTF.borderStyle = .none
        codeTF.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        codeTF.layer.cornerRadius = 12
        codeTF.layer.borderWidth = 1
        codeTF.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 12.0, *) {
            codeTF.textContentType = .oneTimeCode
        } else {
            // Fallback on earlier versions
        }
//        codeTF.keyboardType = .numberPad
		codeTF.inputView =  LNNumberpad.default()
        contentView.addSubview(codeTF)
        
        NSLayoutConstraint(item: codeTF, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: codeTF, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: codeTF, attribute: .top, relatedBy: .equal, toItem: infolbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: codeTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
        confirmBtn = SMGradientButton()
        confirmBtn.enable()
        confirmBtn.colors = [UIColor(netHex: 0x00e676), UIColor(netHex: 0x2ecc71)]

        confirmBtn.backgroundColor = UIColor(netHex: 0x00e676)
        confirmBtn.titleLabel?.textColor = UIColor(netHex: 0xffffff)
        confirmBtn.setTitle("confirm".localized, for: .normal)
        confirmBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
        confirmBtn.contentMode = .center
        confirmBtn.contentHorizontalAlignment = .center
        confirmBtn.addTarget(self, action: #selector(self.callConfirmCodeAPI(_:)),         for: .touchUpInside)
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.layer.cornerRadius = 24
        
        contentView.addSubview(confirmBtn)
        
        NSLayoutConstraint(item: confirmBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .top, relatedBy: .equal, toItem: codeTF, attribute: .bottomMargin, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
        let resendBtn = SMBottomButton()
        resendBtn.enable()
        
        resendBtn.setTitle("resendRequest".localized, for: .normal)
        resendBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
        resendBtn.contentMode = .center
        resendBtn.contentHorizontalAlignment = .center
        resendBtn.addTarget(self, action: #selector(self.callSignupAPI(_:)),         for: .touchUpInside)
        resendBtn.translatesAutoresizingMaskIntoConstraints = false
        resendBtn.tag = 0
        resendBtn.setTitleColor(UIColor(netHex: 0x03a9f4), for: .normal)
        resendBtn.backgroundColor = UIColor.clear

        contentView.addSubview(resendBtn)
        
        NSLayoutConstraint(item: resendBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: resendBtn, attribute: .top, relatedBy: .equal, toItem: codeTF, attribute: .bottomMargin, multiplier: 1, constant: 90).isActive = true
        NSLayoutConstraint(item: resendBtn, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: resendBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
        
		
		let resendCallBtn = SMBottomButton()
		resendCallBtn.enable()
		
		resendCallBtn.setTitle("resendRequestByCall".localized, for: .normal)
		resendCallBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
		resendCallBtn.contentMode = .center
		resendCallBtn.contentHorizontalAlignment = .center
		resendCallBtn.addTarget(self, action: #selector(self.callSignupAPI(_:)),         for: .touchUpInside)
		resendCallBtn.translatesAutoresizingMaskIntoConstraints = false
		resendCallBtn.tag = 1
		resendCallBtn.setTitleColor(UIColor(netHex: 0x03a9f4), for: .normal)
		resendCallBtn.backgroundColor = UIColor.clear
		
		contentView.addSubview(resendCallBtn)
		
		NSLayoutConstraint(item: resendCallBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
		NSLayoutConstraint(item: resendCallBtn, attribute: .top, relatedBy: .equal, toItem: resendBtn, attribute: .bottomMargin, multiplier: 1, constant: 90).isActive = true
		NSLayoutConstraint(item: resendCallBtn, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
		NSLayoutConstraint(item: resendCallBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
		
        
        let moreInfolbl = UILabel()
        moreInfolbl.text = "confirmCodeInformation".localized
        
        moreInfolbl.font = SMFonts.IranYekanLight(14)
        moreInfolbl.textAlignment = .center
        moreInfolbl.textColor = UIColor(netHex: 0x61000000)
        moreInfolbl.backgroundColor = .clear
        moreInfolbl.translatesAutoresizingMaskIntoConstraints = false
        moreInfolbl.numberOfLines = 0
        contentView.addSubview(moreInfolbl)
        
        NSLayoutConstraint(item: moreInfolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 32).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -32).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .top, relatedBy: .equal, toItem: resendCallBtn, attribute: .top, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80).isActive = true
        
        
    }
	
	/// Validate Pin and call confirm API
    @objc func callConfirmCodeAPI(_ sender: SMBottomButton) {
		
		self.view.endEditing(true)

        if SMValidation.pinCodeValidation(codeTF.text!.inEnglishNumbers()) {
            confirmBtn.gotoLoadingState()
            codeTF.isUserInteractionEnabled = false
            let request = WS_methods(delegate: self, failedDialog: true)
            request.addSuccessHandler { (response : Any) in
                self.confirmBtn.gotoButtonState()
				self.view.endEditing(false)

                self.codeTF.isUserInteractionEnabled = true
                //goto next page
                self.nextLevel(response: response)
            }
            
            request.addFailedHandler({ (response: Any) in
				
//				if (response as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
//					SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((response as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
//				}

				if SMValidation.showConnectionErrorToast(response) {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
                self.confirmBtn.gotoButtonState()
				self.view.endEditing(false)

                self.codeTF.isUserInteractionEnabled = true
                SMLog.SMPrint(response)
            })
            
            request.au_verify_otp(phoneNumber!, otp: codeTF.text!.inEnglishNumbers())
        }
        else {
            //invalid input
            SMMessage.showWithMessage("CodeLengthIsNotValid".localized)

        }
        
    }
    

    /// Handle next step after confirming code, the place where user must go
    func nextLevel(response : Any){
        
        if let jsonResult = response as? Dictionary<String, AnyObject> {
            // do whatever with jsonResult
            let navigation = SMNavigationController.shared
            SMUserManager.token = WS_SecurityManager().getSSOId()
    
            SMInitialInfos.AtLeastOneFailedDelegate = {
                SMLoading.hideLoadingPage()
            }
            
            if let isNew = jsonResult["is_new"] {
                
                if (isNew.boolValue) {
                    SMUserManager.mobileNumber = self.phoneNumber
					
					//The 2-step pass is not implemented right now, so we skip this code
					//Go to referral page and set step final
					SMInitialInfos.AllUpdatedSuccessfully = {
						SMLoading.hideLoadingPage()
						SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Profile.rawValue
						navigation.navigationBar.isHidden = false
						navigation.style = .SMSignupStyle
						navigation.setRootViewController(page: .RefferalPage)
						SMUserManager.saveDataToKeyChain()
					}
					SMInitialInfos.updateBaseInfoFromServer()
					
//                    SMInitialInfos.updateBaseInfoFromServer()
//                    SMInitialInfos.AllUpdatedSuccessfully = {
//                        SMLoading.hideFullPageLoading()
//
//                        navigation.navigationBar.isHidden = false
//                        navigation.style = .SMSignupStyle
//                        SMUserManager.profileLevelsCompleted = "3"
//                        navigation.pushNewViewController(page: .SetPasswordPage)
//                        SMUserManager.saveDataToKeyChain()
//                    }
                }
                else {
                    
                    SMUserManager.mobileNumber = self.phoneNumber
                    
                    if let is2StepVerificationEnable = jsonResult["two_step_verification"] {
                        if is2StepVerificationEnable.boolValue {
                            //go to login page
                            SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Login.rawValue
                            let navigation = SMNavigationController.shared
                            navigation.navigationBar.isHidden = false
                            navigation.style = .SMSignupStyle
                            navigation.pushNewViewController(page: .LoginPage)
                            SMUserManager.saveDataToKeyChain()
                        } else {
                            SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Main.rawValue
                            let navigation = SMNavigationController.shared
                            navigation.navigationBar.isHidden = false
                            navigation.style = .SMMainPageStyle
                            navigation.setRootViewController(page: .Main)
                            SMUserManager.saveDataToKeyChain()
                            SMInitialInfos.updateBaseInfoFromServer()
                        }
                    }
                    else {
						
                    }
                }
            }
        }
    }
    
    /// Request to regenerate and send pass code
    /// If voice button is selected, the callTo is true
	/// - Parameter sender: sender button information; sms or call
    @objc func callSignupAPI(_ sender: SMBottomButton) {
        
        SMLog.SMPrint("button did select")
        sender.gotoLoadingState()
		self.view.endEditing(true)

        let request = WS_methods(delegate: self, failedDialog: true)
        request.addSuccessHandler { (response : Any) in
            sender.gotoButtonState()
            //goto next page
			self.view.endEditing(false)

        }
        request.addFailedHandler({ (response: Any) in
            sender.gotoButtonState()

			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
			self.view.endEditing(false)

        })
        //
		request.au_request_otp(phoneNumber, callTo: Bool(truncating: sender.tag as NSNumber))

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
