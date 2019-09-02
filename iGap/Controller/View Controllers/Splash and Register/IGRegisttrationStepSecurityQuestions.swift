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
import IGProtoBuff
import SwiftProtobuf
import MBProgressHUD

class IGRegisttrationStepSecurityQuestions: UIViewController,UIGestureRecognizerDelegate {

    
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblSecQOne : UILabel!
    @IBOutlet weak var lblSecQTwo : UILabel!

    @IBOutlet weak var tfSecQOne : UITextField!
    @IBOutlet weak var tfSecQTwo : UITextField!

    @IBOutlet weak var btnSubmit : UIButton!
    var pass : String! = ""
    var hud = MBProgressHUD()

    var secQOne : String! = ""
    var secQTwo : String! = ""
    var secQAnswerOne : String! = ""
    var secQAnswerTwo : String! = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        initView()
        
    }
    func initView() {
        IGGlobal.setLanguage()
        
        lblHeader.text = IGStringsManager.RGP_MSG_SECURITYHEADER
        lblSecQOne.text = IGStringsManager.RGP_SECURITYQUESTION_ONE + "\n" + secQOne
        lblSecQTwo.text = IGStringsManager.RGP_SECURITYQUESTION_TWO + "\n" + secQTwo
        
        btnSubmit.setTitle(IGStringsManager.GLOBALOK, for: .normal)
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnSubmit.layer.cornerRadius = 10
        directionManager()
        fontManager()
        initNavigation()
        
    }
    func initNavigation() {
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.GLOBAL_SECURITY_QUESTIONS)
        
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    func directionManager() {
        lblHeader.textAlignment = .center
        lblSecQOne.textAlignment = lblSecQOne.localizedNewDirection
        lblSecQTwo.textAlignment = lblSecQTwo.localizedNewDirection
    }
    func fontManager() {
        lblHeader.font = UIFont.igFont(ofSize: 15)
        lblSecQOne.font = UIFont.igFont(ofSize: 14)
        lblSecQTwo.font = UIFont.igFont(ofSize: 14)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IGGlobal.setLanguage()
    }
    
    //actions
    @IBAction func didTapOnSubmit(_ sender: Any) {
        if (tfSecQOne.text == "" || tfSecQOne.text!.isEmpty) || (tfSecQTwo.text == "" || tfSecQTwo.text!.isEmpty) {
            IGHelperAlert.shared.showAlert(view: self,message: IGStringsManager.RGP_MSG_ANSWERS_WAS_EMPTY)
//            IGHelperAlert.shared.showAlert(view: self,message: IGStringsManager.RGP_MSG_ANSWERS_WAS_WRONG)

        } else {
            
                IGUserTwoStepVerificationRecoverPasswordByAnswersRequest.Generator.generate(answerOne: tfSecQOne.text!, answerTwo: tfSecQTwo.text!).success({ (UserTwoStepVerificationRecoverPasswordByAnswersResponse) in
                    DispatchQueue.main.async {
                        switch UserTwoStepVerificationRecoverPasswordByAnswersResponse {
                        case let UserTwoStepVerificationRecoverPasswordByAnswersResponse as IGPUserTwoStepVerificationRecoverPasswordByAnswersResponse:
                            let interpretedResponse = IGUserTwoStepVerificationRecoverPasswordByAnswersRequest.Handler.interpret(response: UserTwoStepVerificationRecoverPasswordByAnswersResponse)
                            IGAppManager.sharedManager.save(token: interpretedResponse)
                            self.loginUser(token: interpretedResponse)
                            
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    var errorTitle = ""
                    var errorBody = ""
                    switch errorCode {
                    case .userTwoStepVerificationVerifyPasswordBadPayload :
                        errorTitle = "Error"
                        errorBody = "Invalid payload"
                        break
                    case .userTwoStepVerificationVerifyPasswordInternalServerError :
                        errorTitle = "Error"
                        errorBody = "Inernal server error. Try agian later and if problem persists contact iGap support."
                        break
                    case .userTwoStepVerificationVerifyPasswordMaxTryLock :
                        errorTitle = ""
                        errorBody = "Too many failed password verification attempt."
                        break
                    case .userTwoStepVerificationVerifyPasswordInvalidPassword :
                        errorTitle = "Invalid Code"
                        errorBody = "The password you entered is not valid. Verify the password and try again."
                        break
                    case .timeout:
                        errorTitle = "Timeout"
                        errorBody = "Please try again later."
                        break
                    default:
                        errorTitle = "Unknown error"
                        errorBody = "An error occured. Please try again later.\nCode \(errorCode)"
                        break
                    }
                    if waitTime != nil &&  waitTime != 0 {
                        errorBody += "\nPlease try again in \(waitTime!) seconds."
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: errorTitle, message: errorBody, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }).send()

            
        }
}
    
    fileprivate func loginUser(token: String) {
        IGUserLoginRequest.Generator.generate(token: token).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPUserLoginResponse:
                    IGUserLoginRequest.Handler.intrepret(response: (protoResponse as? IGPUserLoginResponse)!)
                    IGAppManager.sharedManager.isUserLoggedIn.value = true
                    
                    IGUserInfoRequest.Generator.generate(userID: IGAppManager.sharedManager.userID()!).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let userInfoResponse as IGPUserInfoResponse:
                                let igpUser = userInfoResponse.igpUser
                                IGFactory.shared.saveRegistredUsers([igpUser])
                                break
                            default:
                                break
                            }
                            self.hud.hide(animated: true)
                            self.dismiss(animated: true, completion: {
                                IGAppManager.sharedManager.setUserLoginSuccessful()
                            })
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            self.hud.hide(animated: true)
                            let alertVC = UIAlertController(title: "Error", message: "There was an error logging you in. Try again please.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertVC.addAction(ok)
                            self.present(alertVC, animated: true, completion: nil)
                        }
                    }).send()
                    
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                self.hud.hide(animated: true)
                let alertVC = UIAlertController(title: "Error", message: "There was an error logging you in. Try again please.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertVC.addAction(ok)
                self.present(alertVC, animated: true, completion: nil)
            }
        }).send()
    }


}