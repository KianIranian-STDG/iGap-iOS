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
            navigationItem.addNavigationViewItems(rightItemText: IGStringsManager.GlobalDone.rawValue.localized, title: IGStringsManager.ChangeSecurityQ.rawValue.localized)
        } else if self.pageAction == IGTwoStepQuestion.questionRecoveryPassword {
            navigationItem.addNavigationViewItems(rightItemText: IGStringsManager.GlobalDone.rawValue.localized, title: IGStringsManager.ForgetPassword.rawValue.localized)
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

        lbl1.text = IGStringsManager.SecurityQOne.rawValue.localized
        lbl3.text = IGStringsManager.SecurityQTwo.rawValue.localized
        lbl2.text = IGStringsManager.Answer.rawValue.localized
        lbl4.text = IGStringsManager.Answer.rawValue.localized
        question1TextField.placeholder = IGStringsManager.Required.rawValue.localized
        question2TextField.placeholder = IGStringsManager.Required.rawValue.localized
        answer1TextField.placeholder = IGStringsManager.Required.rawValue.localized
        answer2TextField.placeholder = IGStringsManager.Required.rawValue.localized
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
                    break
                case .userTwoStepVerificationChangeRecoveryQuestionMaxTryLock:
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
            hud.hide(animated: true)
   
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                    
                case .userTwoStepVerificationRecoverPasswordByAnswersMaxTryLock:
                    break
               
                case .userTwoStepVerificationRecoverPasswordByAnswersInvalidAnswers:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.ErrorInvalidAnswer.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    break
                    
                case .userTwoStepVerificationRecoverPasswordByAnswersForbidden:
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
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalCheckFields.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return false
        }
        return true
    }
}
