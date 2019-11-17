/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import SwiftProtobuf
import IGProtoBuff
import MBProgressHUD

class IGSettingPrivacyAndSecurityTwoStepVerificationVerifyPasswordTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var btnForgetPassword: UIButton!
    @IBOutlet weak var lblPass: IGLabel!
    @IBOutlet weak var lblTextHint: IGLabel!
    
    var twoStepVerification: IGTwoStepVerification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        btnForgetPassword.removeUnderline()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "GLOBAL_DONE".localized, title: "PASSWORD".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.verifyPassword()
        }
        btnForgetPassword.setTitle("FORGET_PASSWORD".localized, for: .normal)
        btnForgetPassword.titleLabel!.font = UIFont.igFont(ofSize: 15)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "SETTING_PS_TV_REQUIRED_FIELD".localized
        passwordTextField.font = UIFont.igFont(ofSize: 17)
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnForgetPassword.setTitle("FORGET_PASSWORD".localized, for: .normal)
        btnForgetPassword.titleLabel!.font = UIFont.igFont(ofSize: 15)
        lblPass.text = "PASSWORD".localized
        lblTextHint.text = "twoStepVerfi_HEADER".localized
    }

    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
        if let hint = self.twoStepVerification?.hint {
            return "SETTING_PS_TV_HINT".localized + "\(hint)"
        }
        return ""
        }
        else {
            return ""
        }
        
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        let containerView = view as! UITableViewHeaderFooterView
        containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
        containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    var twoStepPassword:String?
    
    
    func verifyPassword() {
        if let password = passwordTextField.text, password != "" {
//            self.tableView.isUserInteractionEnabled = false
            self.tableView.isScrollEnabled = false
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .indeterminate
            
            IGUserTwoStepVerificationCheckPasswordRequest.Generator.generate(password: password).successPowerful({ (protoResponse, requestWrapper) in
                DispatchQueue.main.async {
                    if protoResponse is IGPUserTwoStepVerificationCheckPasswordResponse {
                        if let message = requestWrapper.message as? IGPUserTwoStepVerificationCheckPassword {
                            self.twoStepPassword = message.igpPassword
                            self.tableView.isUserInteractionEnabled = true
                            self.tableView.isScrollEnabled = true
                            self.performSegue(withIdentifier: "showTwoStepOptions", sender: self)
                        }
                    } else {
                        self.tableView.isUserInteractionEnabled = true
                        self.tableView.isScrollEnabled = true
                    }
                    hud.hide(animated: true)
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.isScrollEnabled = true
                    switch errorCode {
                    case .userTwoStepVerificationCheckPasswordBadPayload:
                        self.showAlert(title: IGStringsManager.GlobalWarning.rawValue.localized, message: "Bad Payload")
                    case .userTwoStepVerificationCheckPasswordInternalServerError:
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "MSG_INTERNAL_SERVER_ERROR".localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    case .userTwoStepVerificationCheckPasswordInvalidPassword:
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "MSG_INVALID_PASS".localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    case .userTwoStepVerificationCheckPasswordMaxTryLock:
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "Maximum try reached. Please try after \(waitTime!) seconds", cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    case .userTwoStepVerificationCheckPasswordNoPassword:
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "MSG_PASSWORD_IS_NOT_SET".localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    case.timeout: break
//                        self.showAlert(title: IGStringsManager.GlobalWarning.rawValue.localized, message:  "TIME_OUT".localized)
                    default: break
//                        self.showAlert(title: IGStringsManager.GlobalWarning.rawValue.localized, message: "Unknown Error")
                    }
                }
            }).send()
        }
    }
    
    @IBAction func didTapOnForgotPasswordButton(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "FORGET_PASSWORD".localized, message: "MSG_FORGET_PASSWORD".localized, preferredStyle: IGGlobal.detectAlertStyle())
        
        let email = UIAlertAction(title: "SETTING_PAGE_ACCOUNT_EMAIL".localized, style: .default) { (action) in
            self.performSegue(withIdentifier: "showRecoverByEmail", sender: self)
        }
        let questions = UIAlertAction(title: "RECOVERY_QUESTIONS".localized, style: .default) { (action) in
            self.performSegue(withIdentifier: "changePasswordWithQuestions", sender: self)
        }
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel) { (action) in
            
        }
        if (twoStepVerification?.hasVerifiedEmailAddress)! {
            alertVC.addAction(email)
        }
        alertVC.addAction(questions)
        alertVC.addAction(cancel)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationOptionsTableViewController {
            destinationVC.twoStepVerification = twoStepVerification
            destinationVC.password = twoStepPassword
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationChangeSecurityQuestionsTableViewController {
            destinationVC.password = twoStepPassword
            destinationVC.questionOne = twoStepVerification?.question1
            destinationVC.questionTwo = twoStepVerification?.question2
            destinationVC.pageAction = IGTwoStepQuestion.questionRecoveryPassword
        }
        
        if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationVerifyUnconfirmedEmail {
            destinationVC.pageAction = IGTwoStepEmail.recoverPassword
        }
    }
}
