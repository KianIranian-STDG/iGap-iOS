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

class IGSettingPrivacyAndSecurityTwoStepVerificationChangeSecurityQuestionsTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var question1TextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var question2TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var lbl1:UILabel!
    @IBOutlet weak var lbl2:UILabel!
    @IBOutlet weak var lbl3:UILabel!
    @IBOutlet weak var lbl4:UILabel!

    var password: String?
    var questionOne: String?
    var questionTwo: String?
    var pageAction: IGTwoStepQuestion = IGTwoStepQuestion.changeRecoveryQuestion
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        let navigationItem = self.navigationItem as! IGNavigationItem
        
        if self.pageAction == IGTwoStepQuestion.changeRecoveryQuestion {
            navigationItem.addNavigationViewItems(rightItemText: "GLOBAL_DONE".localized, title: "SETTING_PS_TV_CHANGE_RECOVER_QUESTION".localized)
        } else if self.pageAction == IGTwoStepQuestion.questionRecoveryPassword {
            navigationItem.addNavigationViewItems(rightItemText: "GLOBAL_DONE".localized, title: "SETTING_PS_TV_RECOVER_PASS".localized)
        }
        
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        navigationItem.rightViewContainer?.addAction {
            if self.pageAction == IGTwoStepQuestion.changeRecoveryQuestion {
                self.changeRecoveryQuestion()
            } else if self.pageAction == IGTwoStepQuestion.questionRecoveryPassword {
                self.recoveryPassword()
            }
        }
        
        if self.pageAction == IGTwoStepQuestion.questionRecoveryPassword {
            question1TextField.text = questionOne
            question2TextField.text = questionTwo
        }

        lbl1.text = "SETTING_PS_TV_Q1".localized
        lbl3.text = "SETTING_PS_TV_Q2".localized
        lbl2.text = "SETTING_PS_TV_A1".localized
        lbl4.text = "SETTING_PS_TV_A2".localized
        question1TextField.placeholder = "SETTING_PS_TV_REQUIRED_FIELD".localized
        question2TextField.placeholder = "SETTING_PS_TV_REQUIRED_FIELD".localized
        answer1TextField.placeholder = "SETTING_PS_TV_REQUIRED_FIELD".localized
        answer2TextField.placeholder = "SETTING_PS_TV_REQUIRED_FIELD".localized
    }
    
    func changeRecoveryQuestion(){
        if !isComplete() {
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationChangeRecoveryQuestionRequest.Generator.generate(password: self.password!, questionOne: question1TextField.text!, answerOne: answer1TextField.text!, questionTwo: question2TextField.text!, answerTwo: answer2TextField.text!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                if ((protoResponse as? IGPUserTwoStepVerificationChangeRecoveryQuestionResponse) != nil) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                case .userTwoStepVerificationChangeRecoveryQuestionMaxTryLock:
                    let alert = UIAlertController(title: "GLOBAL_WARNING".localized, message: "SETTING_PS_TV_MAX_TRY_LOCK".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }).send()
    }
    
    func recoveryPassword(){
        if !isComplete(){
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserTwoStepVerificationRecoverPasswordByAnswersRequest.Generator.generate(answerOne: answer1TextField.text!, answerTwo: answer2TextField.text!).success({ (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                let alert = UIAlertController(title: "SUCCESS".localized, message: "SETTING_PS_TV_YOUR_PASS_REMOVED".localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
//                    self.showAlert(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized)
//                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "SETTING_PS_TV_HINT".localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "MSG_PASSWORD_IS_NOT_SET".localized, cancelText: "GLOBAL_CLOSE".localized)

                    break
                    
                case .userTwoStepVerificationRecoverPasswordByAnswersMaxTryLock:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "SETTING_PS_TV_MAX_TRY_LOCK".localized, cancelText: "GLOBAL_CLOSE".localized)

                    break
               
                case .userTwoStepVerificationRecoverPasswordByAnswersInvalidAnswers:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "INVALID_ANSWER".localized, cancelText: "GLOBAL_CLOSE".localized)

                    break
                    
                case .userTwoStepVerificationRecoverPasswordByAnswersForbidden:
                  
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "RECOVER_BY_ANSWER_IS_FORBIDDEN".localized, cancelText: "GLOBAL_CLOSE".localized)

                    break
                    
                default:
                    break
                }
                hud.hide(animated: true)
            }
        }).send()
    }
    
    private func isComplete() -> Bool {
        if question1TextField.text == "" || question2TextField.text == "" || answer1TextField.text == "" || answer2TextField.text == "" {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "CHECK_ALL_FIELDS".localized, cancelText: "GLOBAL_CLOSE".localized)

            return false
        }
        return true
    }
}
