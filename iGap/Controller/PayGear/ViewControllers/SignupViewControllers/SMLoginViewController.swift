//
//  SMLoginViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice
/// This class is unused, this class used to showing when user enabled its two step verifications to get second password
/// right now it is not enable from server; The implementation of this class is not completed because it waits in middle of work
class SMLoginViewController: SMBaseFormViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    var confirmBtn : SMGradientButton!
    var passwordTF : SMTextField!

    
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
        
    }
    
    override
    func keyboardWillShow(notification: NSNotification) {
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
        NSLayoutConstraint(item: infolbl, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 150).isActive = true
        NSLayoutConstraint(item: infolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        passwordTF = SMTextField()
        passwordTF.font = SMFonts.IranYekanBold(16)
        passwordTF.placeholder = "passwordPH".localized
        passwordTF.textAlignment = .right
        passwordTF.borderStyle = .none
        passwordTF.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        passwordTF.layer.cornerRadius = 12
        passwordTF.layer.borderWidth = 1
        passwordTF.translatesAutoresizingMaskIntoConstraints = false
//        passwordTF.keyboardType = .numberPad
		passwordTF.inputView =  LNNumberpad.default()
        contentView.addSubview(passwordTF)
        
        NSLayoutConstraint(item: passwordTF, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: passwordTF, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: passwordTF, attribute: .top, relatedBy: .equal, toItem: infolbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: passwordTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
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
        NSLayoutConstraint(item: confirmBtn, attribute: .top, relatedBy: .equal, toItem: passwordTF, attribute: .bottomMargin, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
        
        
        let resendBtn = SMBottomButton()
        resendBtn.enable()
        
        resendBtn.setTitle("forgotPassword".localized, for: .normal)
        resendBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
        resendBtn.contentMode = .center
        resendBtn.contentHorizontalAlignment = .center
        resendBtn.addTarget(self, action: #selector(self.callSignupAPI(_:)),         for: .touchUpInside)
        resendBtn.translatesAutoresizingMaskIntoConstraints = false
        
        resendBtn.setTitleColor(UIColor(netHex: 0x03a9f4), for: .normal)
        resendBtn.backgroundColor = UIColor.clear
        
        contentView.addSubview(resendBtn)
        
        NSLayoutConstraint(item: resendBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: resendBtn, attribute: .top, relatedBy: .equal, toItem: passwordTF, attribute: .bottomMargin, multiplier: 1, constant: 90).isActive = true
        NSLayoutConstraint(item: resendBtn, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: resendBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
        
        
        
        let moreInfolbl = UILabel()
        moreInfolbl.text = "loginInformation".localized
        
        moreInfolbl.font = SMFonts.IranYekanLight(14)
        moreInfolbl.textAlignment = .center
        moreInfolbl.textColor = UIColor(netHex: 0x61000000)
        moreInfolbl.backgroundColor = .clear
        moreInfolbl.translatesAutoresizingMaskIntoConstraints = false
        moreInfolbl.numberOfLines = 0
        contentView.addSubview(moreInfolbl)
        
        NSLayoutConstraint(item: moreInfolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 32).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -32).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .top, relatedBy: .equal, toItem: resendBtn, attribute: .top, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: moreInfolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80).isActive = true
     
        passwordTF.becomeFirstResponder()
    }
	
	/// Call api to confirm password
    @objc
    func callConfirmCodeAPI(_ sender: SMBottomButton) {
        
            let request = WS_methods(delegate: self, failedDialog: true)
            request.addSuccessHandler { (response : Any) in
                //goto next page
					SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Main.rawValue
                    SMUserManager.saveDataToKeyChain()
                    let navigation = SMNavigationController.shared
                    navigation.navigationBar.isHidden = false
                    navigation.style = .SMSignupStyle
                    navigation.pushNewViewController(page: .RefferalPage)
                    SMInitialInfos.updateBaseInfoFromServer()

            }
            
            request.addFailedHandler({ (response: Any) in
                //                SMLog.SMPrint("Failur")
            })
            
            request.au_2StepVerificationLogin(passwordTF.text)

    }
    
    @objc
    func callSignupAPI(_ sender: SMBottomButton) {
        
        SMLog.SMPrint("button did select")
        
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
