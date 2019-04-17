//
//  SMSetPasswordViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice

/// This viewcontroller is skipped in current scenario, Its detail is like referral
/// and it is possible the scenario of getting two steps enabled changes on next scenario
class SMSetPasswordViewController: SMBaseFormViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    var confirmBtn : SMGradientButton!
    var cancelBtn : SMBottomButton!
    var moreInfoLbl : UILabel!

    var passwordTF : SMTextField!
    var confirmPasswordTF : SMTextField!
    var buttonContainerView : UIView!

    var cancelBtnConstraintLeading : NSLayoutConstraint!
    var cancelBtnConstraintTrailing : NSLayoutConstraint!
    var moreInfoLblTopConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        setupNotifications()
        SMNavigationController.shared.navigationItem.hidesBackButton = true
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
        buttonContainerView.removeFromSuperview()
        
    }
    
    override
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        contentViewHeightConstraint.constant = contentViewHeightConstraint.constant + keyboardHeight;
        
        UIView.animate(withDuration: 0.3) {
            
            self.buttonContainerView.removeFromSuperview()
            
            self.confirmBtn.layer.cornerRadius = 0
            
            self.cancelBtn.layer.cornerRadius = 0
            self.cancelBtn.layer.borderWidth = 0
            self.cancelBtn.colors = [.red, .red]
            self.cancelBtn.setTitleColor(UIColor(netHex: 0xffffff), for: .normal)
            
            let window = UIApplication.shared.keyWindow!
            window.addSubview(self.buttonContainerView)
            
            //container view constraint
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .leading, relatedBy: .equal, toItem: window, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1, constant: -keyboardHeight).isActive = true
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .trailing, relatedBy: .equal, toItem: window, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            
            
            NSLayoutConstraint(item: self.confirmBtn, attribute: .leading, relatedBy: .equal, toItem: self.buttonContainerView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            
            self.cancelBtnConstraintTrailing.constant = 0
            self.cancelBtnConstraintLeading.constant = 0
            
//            self.view.removeConstraint(self.moreInfoLblTopConstraint)
            self.moreInfoLblTopConstraint.isActive = true

            
        }
        self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }
    
    override
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        contentViewHeightConstraint.constant = contentViewHeightConstraint.constant - keyboardHeight;
        
        UIView.animate(withDuration: 0.3) {
            //define code to showw button on scroll view, if needed
            
        }
        self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }
    
    func createForm() {
        
        
        let infolbl = UILabel()
        infolbl.text = "enterPassword".localized
        infolbl.font = SMFonts.IranYekanBold(16)
        infolbl.textAlignment = .right
        infolbl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(infolbl)
        
        NSLayoutConstraint(item: infolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
        
        passwordTF = SMTextField()
        passwordTF.font = SMFonts.IranYekanBold(16)
        passwordTF.placeholder = "passwordPH".localized
        passwordTF.textAlignment = .right
        passwordTF.borderStyle = .none
        passwordTF.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        passwordTF.layer.cornerRadius = 12
        passwordTF.layer.borderWidth = 1
		passwordTF.inputView =  LNNumberpad.default()
        passwordTF.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTF)
        
        NSLayoutConstraint(item: passwordTF, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: passwordTF, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: passwordTF, attribute: .top, relatedBy: .equal, toItem: infolbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: passwordTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
        let confirmPasswordInfolbl = UILabel()
        confirmPasswordInfolbl.text = "enterConfirmPassword".localized
        confirmPasswordInfolbl.font = SMFonts.IranYekanBold(16)
        confirmPasswordInfolbl.textAlignment = .right
        confirmPasswordInfolbl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(confirmPasswordInfolbl)
        
        NSLayoutConstraint(item: confirmPasswordInfolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: confirmPasswordInfolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: confirmPasswordInfolbl, attribute: .top, relatedBy: .equal, toItem: passwordTF, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: confirmPasswordInfolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
        
        confirmPasswordTF = SMTextField()
        confirmPasswordTF.font = SMFonts.IranYekanBold(16)
        confirmPasswordTF.placeholder = "passwordPH".localized
        confirmPasswordTF.textAlignment = .right
        confirmPasswordTF.borderStyle = .none
        confirmPasswordTF.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        confirmPasswordTF.layer.cornerRadius = 12
        confirmPasswordTF.layer.borderWidth = 1
        confirmPasswordTF.translatesAutoresizingMaskIntoConstraints = false
		confirmPasswordTF.inputView =  LNNumberpad.default()
        contentView.addSubview(confirmPasswordTF)
        
        NSLayoutConstraint(item: confirmPasswordTF, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: confirmPasswordTF, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: confirmPasswordTF, attribute: .top, relatedBy: .equal, toItem: confirmPasswordInfolbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: confirmPasswordTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
        buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonContainerView)
        
        
        NSLayoutConstraint(item: buttonContainerView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buttonContainerView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buttonContainerView, attribute: .top, relatedBy: .equal, toItem: confirmPasswordTF, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: buttonContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        
        
        confirmBtn = SMGradientButton()
        confirmBtn.enable()
        
        confirmBtn.setTitle("confirm".localized, for: .normal)
        confirmBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
        confirmBtn.contentMode = .center
        confirmBtn.contentHorizontalAlignment = .center
        confirmBtn.colors = [UIColor(netHex: 0x00e676), UIColor(netHex: 0x2ecc71)]
        confirmBtn.addTarget(self, action: #selector(self.callSetPasswordAPI(_:)),         for: .touchUpInside)
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.layer.cornerRadius = 24
        
        buttonContainerView.addSubview(confirmBtn)
        
        cancelBtn = SMBottomButton()
        cancelBtn.enable()
        
        cancelBtn.layer.borderColor = UIColor(netHex: 0x00e676).cgColor
        cancelBtn.layer.borderWidth = 2
        cancelBtn.setTitle("cancel".localized, for: .normal)
        cancelBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
        cancelBtn.contentMode = .center
        cancelBtn.contentHorizontalAlignment = .center
        cancelBtn.addTarget(self, action: #selector(self.callCancel(_:)),         for: .touchUpInside)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.layer.cornerRadius = 24
        cancelBtn.setTitleColor(UIColor(netHex: 0x00e676), for: .normal)
        
        buttonContainerView.addSubview(cancelBtn)
        
        
        NSLayoutConstraint(item: confirmBtn, attribute: .leading, relatedBy: .equal, toItem: buttonContainerView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .top, multiplier: 1, constant: 1).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
        cancelBtnConstraintLeading = NSLayoutConstraint(item: cancelBtn, attribute: .leading, relatedBy: .equal, toItem: confirmBtn, attribute: .trailing, multiplier: 1, constant: 15)
        cancelBtnConstraintLeading.isActive = true
        cancelBtnConstraintTrailing = NSLayoutConstraint(item: cancelBtn, attribute: .trailing, relatedBy: .equal, toItem: buttonContainerView, attribute: .trailing, multiplier: 1, constant: -15)
        cancelBtnConstraintTrailing.isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .top, multiplier: 1, constant: 1).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
        NSLayoutConstraint(item: cancelBtn, attribute: .width, relatedBy: .equal, toItem: confirmBtn, attribute: .width, multiplier: 1, constant: 0).isActive = true

        
        let moreInfolbl = UILabel()
        moreInfolbl.text = "passwordInformation".localized
        
        moreInfolbl.font = SMFonts.IranYekanLight(14)
        moreInfolbl.textAlignment = .center
        moreInfolbl.textColor = UIColor(netHex: 0x61000000)
        moreInfolbl.backgroundColor = .clear
        moreInfolbl.translatesAutoresizingMaskIntoConstraints = false
        moreInfolbl.numberOfLines = 0
        contentView.addSubview(moreInfolbl)
        
        NSLayoutConstraint(item: moreInfolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 32).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -32).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .bottom, multiplier: 1, constant: 50).isActive = true
        moreInfoLblTopConstraint = NSLayoutConstraint(item: moreInfolbl, attribute: .top, relatedBy: .equal, toItem: confirmPasswordTF, attribute: .bottom, multiplier: 1, constant: 50)

        NSLayoutConstraint(item: moreInfolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80).isActive = true
        
    }

    @objc
    func callSetPasswordAPI(_ sender: SMBottomButton) {
        
        if passwordTF.text == confirmPasswordTF.text {
        
            let request = WS_methods(delegate: self, failedDialog: true)
            request.addSuccessHandler { (response : Any) in
                //goto next page
                    let navigation = SMNavigationController.shared
                    navigation.navigationBar.isHidden = false
                    navigation.style = .SMSignupStyle
                    navigation.pushNewViewController(page: .RefferalPage)
                    
//                }
            }
            
            request.addFailedHandler({ (response: Any) in
                //                SMLog.SMPrint("Failur")
            })
            
            request.au_2StepVerification("", newPassword: passwordTF.text)
        }
    }
    
    @objc
    func callCancel(_ sender: SMBottomButton) {
        
        let navigation = SMNavigationController.shared
        navigation.navigationBar.isHidden = false
        navigation.style = .SMSignupStyle
        navigation.pushNewViewController(page: .RefferalPage)
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
