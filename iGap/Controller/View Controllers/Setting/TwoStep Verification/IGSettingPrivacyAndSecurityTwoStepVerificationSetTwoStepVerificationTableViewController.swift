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

class IGSettingPrivacyAndSecurityTwoStepVerificationSetTwoStepVerificationTableViewController: BaseTableViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyTextField: UITextField!
    @IBOutlet weak var question1TextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var question2TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var lblPass: UILabel!
    @IBOutlet weak var lblVerify: UILabel!
    @IBOutlet weak var lblQ1: UILabel!
    @IBOutlet weak var lblA1: UILabel!
    @IBOutlet weak var lblQ2: UILabel!
    @IBOutlet weak var lblA2: UILabel!
    @IBOutlet weak var lblHint: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    var oldPassword: String = ""
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "", title: IGStringsManager.TwoSteps.rawValue.localized,iGapFont: true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            self.setPassword()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblPass.text = IGStringsManager.Password.rawValue.localized
        lblVerify.text = IGStringsManager.PasswordReEnter.rawValue.localized
        lblQ1.text = IGStringsManager.SecurityQOne.rawValue.localized
        lblQ2.text = IGStringsManager.SecurityQTwo.rawValue.localized
        lblA1.text = IGStringsManager.Answer.rawValue.localized
        lblA2.text = IGStringsManager.Answer.rawValue.localized
        lblHint.text = IGStringsManager.InvalidHint.rawValue.localized
        lblEmail.text = IGStringsManager.Email.rawValue.localized
        
        passwordTextField.placeholder = IGStringsManager.Required.rawValue.localized
        verifyTextField.placeholder = IGStringsManager.Required.rawValue.localized
        question1TextField.placeholder = IGStringsManager.Required.rawValue.localized
        question2TextField.placeholder = IGStringsManager.Required.rawValue.localized
        answer1TextField.placeholder = IGStringsManager.Required.rawValue.localized
        answer2TextField.placeholder = IGStringsManager.Required.rawValue.localized
        hintTextField.placeholder = IGStringsManager.Required.rawValue.localized
        emailTextField.placeholder = IGStringsManager.Optional.rawValue.localized
    }
    
    func setPassword(){
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || verifyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || question1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || answer1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || question2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || answer2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || hintTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            alertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalTryAgain.rawValue.localized)
            return
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != verifyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            alertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.ErrorPassNotMatch.rawValue.localized)
            return
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == hintTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            alertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.InvalidHint.rawValue.localized)
            return
        }
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != nil && emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            email = (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationSetPasswordRequest.Generator.generate(oldPassword: oldPassword, newPassword: (passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,questionOne: (question1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,answerOne: (answer1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,questionTwo: (question2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,answerTwo: (answer2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,hint: (hintTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,recoveryEmail: (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                switch protoResponse {
                case let unsetPassword as IGPUserTwoStepVerificationSetPasswordResponse :
                    IGUserTwoStepVerificationSetPasswordRequest.Handler.interpret(response: unsetPassword)
                    self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    self.alertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalTryAgain.rawValue.localized)
                    break
                    
                case .userTwoStepVerificationSetPasswordNewPasswordIsInvalid :
                    self.alertController(title: "Error", message: "Password Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordRecoveryEmailIsNotValid_Minor3 :
                    self.alertController(title: "Error", message: "Email Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordRecoveryEmailIsNotValid_Minor4 :
                    self.alertController(title: "Error", message: "Email Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordFirstRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "First Recovery Question Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordAnswerOfTheFirstRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "Answer Of The First Question Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordSecondRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "Second Recovery Question Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordAnswerOfTheSecondRecoveryQuestionIsInvalid :
                    self.alertController(title: "Error", message: "Answer Of The Second Question Is Invalid")
                    break
                    
                case .userTwoStepVerificationSetPasswordHintIsNotValid :
                    self.alertController(title: "Error", message: "Password Hint Is Not Valid")
                    break
                    
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }).send()
    }
    
    func alertController(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            containerView.textLabel!.text = IGStringsManager.TwoStepPassHeader.rawValue.localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        case 1 :
            break
        default :
            break
        }
        
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            containerFooterView.textLabel!.text = IGStringsManager.TwoStepPassFooter.rawValue.localized
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerFooterView.textLabel?.textAlignment = (containerFooterView.textLabel?.localizedDirection)!
            
            break
        case 1 :
            break
        default :
            break
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0 :
            return 60
        case 1 :
            return 10
        default :
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0 :
            return 90
        case 1 :
            return 50
        default :
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 :
            return IGStringsManager.TwoStepPassHeader.rawValue.localized
        case 1 :
            return ""
        default :
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0 :
            return IGStringsManager.TwoStepPassFooter.rawValue.localized
        case 1 :
            return ""
        default :
            return ""
        }
    }
    
}


