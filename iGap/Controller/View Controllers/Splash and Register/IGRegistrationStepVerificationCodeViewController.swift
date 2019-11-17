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
import maincore

class IGRegistrationStepVerificationCodeViewController: BaseViewController {

    @IBOutlet weak var countdownTimer: IGCountdownTimer!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var retrySendingCodeLabel: UILabel!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    var canRequestNewCode = false
    var phone : String?
    var phoneNumber : String?
    var delayBeforeSendingAgaing : Int32? = 60
    var delayTime: Int32?
    var username : String?
    var userID : Int64?
    var codeDigitsCount : Int32?
    var codeRegex : String?
    var selectedCountry : IGCountryInfo?
    var isUserNew : Bool?
    var verificationMethod : IGVerificationCodeSendMethod?
    var callMethodSupport: Bool = false
    var hud = MBProgressHUD()
    var defaultYOrigin : CGFloat! = 63

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTimer()
        codeTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
        delayTime = delayBeforeSendingAgaing
        
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: IGStringsManager.GlobalNext.rawValue.localized, title: IGStringsManager.VerifyMobile.rawValue.localized)
        navigaitonItem.rightViewContainer?.addAction {
            self.didTapOnNext()
        }
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if UIDevice.current.hasNotch {

            } else {
                switch UIDevice().type {
                case .iPhone5,.iPhone5S,.iPhoneSE:
                    self.topMargin.constant -= keyboardSize.height
                case .iPhone6,.iPhone6S :
                    self.topMargin.constant -= (keyboardSize.height)/2
                default:
                    break
                }
            }
//            self.topMargin.constant = 10

        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.topMargin.constant = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.codeTextField.becomeFirstResponder()
        setTitleText(verificationMethod: verificationMethod!)
        updateCountDown()
    }
    
    func initTimer() {
        countdownTimer.labelFont = UIFont.igFont(ofSize: 30)
        countdownTimer.labelTextColor = UIColor.iGapSubmitButtons()
        countdownTimer.timerFinishingText = "00"
        countdownTimer.lineWidth = 4
        countdownTimer.lineColor = UIColor.iGapSubmitButtons()
        countdownTimer.start(beginingValue: 59, interval: 1)
    }

    private func setTitleText(verificationMethod: IGVerificationCodeSendMethod){
        var varificationMethodString = IGStringsManager.Via.rawValue.localized + " "
        switch verificationMethod {
        case .sms:
            varificationMethodString += IGStringsManager.SMS.rawValue.localized
            break
            
        case .call:
            varificationMethodString += IGStringsManager.CALL.rawValue.localized
            break
            
        case .igap:
            varificationMethodString += IGStringsManager.iGap.rawValue.localized
            break
            
        case .both:
            varificationMethodString += IGStringsManager.SmsAndIGap.rawValue.localized
            break
        }
        self.titleLabel.text = IGStringsManager.VeridyCodeSentTo.rawValue.localized + "\n" + phoneNumber!.inLocalizedLanguage() + "\n" + varificationMethodString
    }
    
    
    func didTapOnNext() {

        if let code = codeTextField.text?.inEnglishNumbersNew() {
            if IGGlobal.matches(for: self.codeRegex!, in: code) {
                verifyUser()
            } else {
                IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.EnterValidVerification.rawValue.localized, cancelText:  IGStringsManager.GlobalClose.rawValue.localized)
            }
        }
    }
    
    @objc func updateCountDown() {
        self.delayBeforeSendingAgaing! -= 1
        if self.delayBeforeSendingAgaing! > 0 {
            let fixedText = IGStringsManager.ResendCode.rawValue.localized
            let remainingSeconds = self.delayBeforeSendingAgaing!%60
            let remainingMiuntes = self.delayBeforeSendingAgaing! / 60
            if remainingSeconds < 10 {
                retrySendingCodeLabel.text = "\(fixedText)"
            } else {
                retrySendingCodeLabel.text = "\(fixedText)"
            }
            self.perform(#selector(IGRegistrationStepVerificationCodeViewController.updateCountDown), with: nil, afterDelay: 1.0)
        } else {
            retrySendingCodeLabel.text = IGStringsManager.ResendCode.rawValue.localized
            let tap = UITapGestureRecognizer(target: self, action: #selector(IGRegistrationStepVerificationCodeViewController.tapFunction))
            retrySendingCodeLabel.isUserInteractionEnabled = true
            retrySendingCodeLabel.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        manageGetRegisterationCode()
    }
    
    func manageGetRegisterationCode(){
        if callMethodSupport {
            let alert = UIAlertController(title: nil, message: IGStringsManager.ResendCode.rawValue.localized + " " + IGStringsManager.Via.rawValue.localized, preferredStyle: IGGlobal.detectAlertStyle())
            
            let sendViaSms = UIAlertAction(title: IGStringsManager.SMS.rawValue.localized.localized, style: .default, handler: { (action) in
                self.getRegisterToken(preferenceMethod: IGPUserRegister.IGPPreferenceMethod.verifyCodeSms)
            })
            
            let sendViaCall = UIAlertAction(title: IGStringsManager.CALL.rawValue.localized, style: .default, handler: { (action) in
                self.getRegisterToken(preferenceMethod: IGPUserRegister.IGPPreferenceMethod.verifyCodeCall)
            })
            
            let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
            
            alert.addAction(sendViaSms)
            alert.addAction(sendViaCall)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            getRegisterToken(preferenceMethod: IGPUserRegister.IGPPreferenceMethod.verifyCodeSms)
        }
    }
    
    func getRegisterToken(preferenceMethod: IGPUserRegister.IGPPreferenceMethod?){
        
        delayBeforeSendingAgaing = delayTime
        updateCountDown()
        initTimer()

        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        let phoneSpaceLess = phone?.replacingOccurrences(of: " ", with: "")
        let reqW = IGUserRegisterRequest.Generator.generate(countryCode: (self.selectedCountry?.countryISO)!, phoneNumber: Int64(phoneSpaceLess!)!, preferenceMethod: preferenceMethod)
        reqW.success { (responseProto) in
            DispatchQueue.main.async {
                switch responseProto {
                case let userRegisterReponse as IGPUserRegisterResponse:
                    let register = IGUserRegisterRequest.Handler.intrepret(response: userRegisterReponse)
                    self.setTitleText(verificationMethod: register.verificationMethod)
                    self.hud.hide(animated: true)
                default:
                    break
                }
            }
            
            }.error { (errorCode, waitTime) in
                var errorTitle = ""
                var errorBody = ""
                switch errorCode {
                case .userRegisterBadPaylaod:
                    errorTitle = "Error"
                    errorBody = "Invalid data\nCode \(errorCode)"
                    break
                case .userRegisterInvalidCountryCode:
                    errorTitle = "Error"
                    errorBody = "Invalid country"
                    break
                case .userRegisterInvalidPhoneNumber:
                    errorTitle = "Error"
                    errorBody = "Invalid phone number"
                    break
                case .userRegisterInternalServerError:
                    errorTitle = "Error"
                    errorBody = "Internal Server Error"
                    break
                case .userRegisterBlockedUser:
                    errorTitle = "Error"
                    errorBody = "This phone number is blocked"
                    break
                case .userRegisterLockedManyCodeTries:
                    errorTitle = "Error"
                    errorBody = "To many failed code verification attempt."
                    break
                case .userRegisterLockedManyResnedRequest:
                    errorTitle = "Error"
                    errorBody = "To many code sending request."
                    break
                case .timeout:
                    errorTitle = "Timeout"
                    errorBody = "Please try again later"
                    break
                default:
                    errorTitle = "Unknown error"
                    errorBody = "An error occured. Please try again later.\nCode \(errorCode)"
                    break
                }
                
                
                if waitTime != nil  && waitTime! != 0 {
                    errorBody += "\nPlease try again in \(waitTime! ) seconds."
                }
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: errorTitle, message: errorBody, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }.send()
    }
    
    fileprivate func verifyUser() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        if let code = Int32(codeTextField.text!.inEnglishNumbersNew()){
            IGUserVerifyRequest.Generator.generate(usename: self.username!, code: code).success({ (responseProto) in
                DispatchQueue.main.async {
                    switch responseProto {
                    case let userVerifyReponse as IGPUserVerifyResponse:
                        let interpretedResponse = IGUserVerifyRequest.Handler.intrepret(response: userVerifyReponse)
                        IGAppManager.sharedManager.save(token: interpretedResponse.token)
//                        self.isUserNew = true
                        self.isUserNew = interpretedResponse.newuser
                        self.loginUser(token: interpretedResponse.token)
                        
                    default:
                        break
                    }    
                }
            }).error({ (errorCode, waitTime) in
                if errorCode == .userVerifyTwoStepVerificationEnabled {
                    DispatchQueue.main.async {
                        self.hud.hide(animated: false)
                        self.performSegue(withIdentifier:"twoStepPassword", sender: nil);
                    }
                } else {
                    var errorTitle = ""
                    var errorBody = ""
                    switch errorCode {
                    case .userVerifyBadPayload:
                        errorTitle = "Error"
                        errorBody = "Invalid payload"
                        break
                    case .userVerifyBadPayloadInvalidCode:
                        errorTitle = "Error"
                        errorBody = "The code payload is invalid."
                        break
                    case .userVerifyBadPayloadInvalidUsername:
                        errorTitle = "Error"
                        errorBody = "Username payload is invalid."
                        break
                    case .userVerifyInternalServerError:
                        errorTitle = "Error"
                        errorBody = "Inernal server error. Try agian later and if problem persists contact iGap support."
                        break
                    case .userVerifyUserNotFound:
                        errorTitle = "Error"
                        errorBody = "Could not found the request user. Try agian later and if problem persists contact iGap support."
                        break
                    case .userVerifyBlockedUser:
                        errorTitle = "Error"
                        errorBody = "This use is blocked. You cannot register."
                        break
                    case .userVerifyInvalidCode:
                        errorTitle = "Invalid Code"
                        errorBody = "The code you entred is not valid. Verify the code and try again."
                        break
                    case .userVerifyExpiredCode:
                        errorTitle = "Invalid Code"
                        errorBody = "Code has been expired. Please request a new code."
                        break
                    case .userVerifyMaxTryLock:
                        errorTitle = ""
                        errorBody = "Too many failed code verification attempt."
                        break
                    case .timeout:
                        errorTitle = "Timeout"
                        errorBody = "Please try again later."
                        self.verifyUser()
                        return
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
                    if self.isUserNew! {
                        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_REGISTRATION_NEW_USER)
                        self.hud.hide(animated: true)
                        self.performSegue(withIdentifier: "showWelcom", sender: self)
                    } else {
                        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_REGISTRATION_USER)
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
                                IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            }
                        }).send()
                    }

                default:
                    break
                }    
            }
        }).error({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                self.hud.hide(animated: true)
                IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            }
        }).send()
    }
}

extension IGRegistrationStepVerificationCodeViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if IGGlobal.matches(for: self.codeRegex!, in: textField.text! + string) {
//            self.verifyUser()
//        }
        return true
    }
}
