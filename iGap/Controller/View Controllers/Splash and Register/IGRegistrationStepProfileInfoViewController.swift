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
import YPImagePicker

class IGRegistrationStepProfileInfoViewController: BaseTableViewController,SelectCountryObserver {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pagetitleLabel: UILabel!
    @IBOutlet weak var imagePickLabel: UILabel!
    @IBOutlet weak var lblReferralHint: UILabel!
    @IBOutlet weak var tfReferralNumber: AKMaskField!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var FnameTextField: UITextField!
    @IBOutlet weak var txtCode: UILabel!
    @IBOutlet weak var textFiledEditingIndicatorView: UIView!
    var selectedCountry: IGCountryInfo!
    static var selectCountryObserver: SelectCountryObserver!
    var popView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IGRegistrationStepProfileInfoViewController.selectCountryObserver = self
        selectedCountry = IGCountryInfo.iranCountry()
        setCountryInfo(country: selectedCountry)

        self.imagePickLabel.layer.cornerRadius = self.imagePickLabel.frame.height / 2.0
        self.imagePickLabel.layer.masksToBounds = true

        initFonts()
        initLanguage()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapOnChangeImage))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: IGStringsManager.GlobalNext.rawValue.localized, title: IGStringsManager.YourProfile.rawValue.localized)
        navItem.rightViewContainer?.addAction {
            self.didTapOnDone()
        }
        txtCode.text = "+98"
        txtCode.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor
        txtCode.layer.cornerRadius = 5
        txtCode.layer.borderWidth = 1.0
        
        tfReferralNumber.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor
        tfReferralNumber.layer.cornerRadius = 5
        tfReferralNumber.layer.borderWidth = 1.0
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        self.profileImageView.layer.masksToBounds = true

        tfReferralNumber.setLeftPaddingPoints(10)
        tfReferralNumber.setRightPaddingPoints(10)
        nicknameTextField.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor
        nicknameTextField.layer.cornerRadius = 5
        nicknameTextField.layer.borderWidth = 1.0
        
        FnameTextField.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor
        FnameTextField.layer.cornerRadius = 5
        FnameTextField.layer.borderWidth = 1.0



    }
    @IBAction func didTapOnBtnCountryCode(_ sender: UIButton) {
        IGGlobal.isPopView = true
        let countryPage = IGRegistrationStepSelectCountryTableViewController.instantiateFromAppStroryboard(appStoryboard: .Register)
        self.navigationController!.pushViewController(countryPage, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = IGStringsManager.EnterNameAndPhoto.rawValue.localized
    }
    
    private func initFonts() {
        titleLabel.font = UIFont.igFont(ofSize: 13)
        pagetitleLabel.font = UIFont.igFont(ofSize: 30,weight: .bold)
        nicknameTextField.font = UIFont.igFont(ofSize: 15)
        FnameTextField.font = UIFont.igFont(ofSize: 15)
        tfReferralNumber.font = UIFont.igFont(ofSize: 15)
        lblReferralHint.font = UIFont.igFont(ofSize: 13)
        txtCode.font = UIFont.igFont(ofSize: 15)
        tfReferralNumber.textAlignment = .center
        nicknameTextField.textAlignment = .center
        FnameTextField.textAlignment = .center
        txtCode.textAlignment = .center
        
    }
    @objc func showCountriesList() {}
    
    private func initLanguage() {
        txtCode.text = IGStringsManager.ChooseCountry.rawValue.localized
        lblReferralHint.text = IGStringsManager.SetRefferalNumberHint.rawValue.localized
        nicknameTextField.placeholder = IGStringsManager.FirstName.rawValue.localized
        FnameTextField.placeholder = IGStringsManager.LastName.rawValue.localized
        tfReferralNumber.placeholder =  IGStringsManager.PhoneNumber.rawValue.localized
        pagetitleLabel.text = IGStringsManager.Information.rawValue.localized
        titleLabel.text = IGStringsManager.EnterNameAndPhoto.rawValue.localized

        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 0)
        })
    }
    
    func didTapOnOutside() {
        nicknameTextField.resignFirstResponder()
    }
    
    func didTapOnDone() {
        if let nickname = nicknameTextField.text {
            IGGlobal.prgShow(self.view)
            IGUserProfileSetNicknameRequest.Generator.generate(nickname: nickname).success({ (responseProto) in
                DispatchQueue.main.async {
                    switch responseProto {
                    case let setNicknameReponse as IGPUserProfileSetNicknameResponse:
                        IGAppManager.sharedManager.save(nickname: setNicknameReponse.igpNickname)
                        
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
                                IGGlobal.prgHide()
                                self.checkReferral()
                            }
                        }).error({ (errorCode, waitTime) in
                            DispatchQueue.main.async {
                                IGGlobal.prgHide()
                                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            }
                        }).send()
                        
                        
                    default:
                        break
                    }    
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                }
            }).send()
        }
    }
    
    private func checkReferral() {
        if tfReferralNumber.text != "" {
            var phoneSpaceLess: String?
            let phone = tfReferralNumber.text
            if phone != nil && phone != "" {
                phoneSpaceLess = phone?.replacingOccurrences(of: " ", with: "")
                phoneSpaceLess = phoneSpaceLess?.replacingOccurrences(of: "_", with: "")
            }
            
            if phoneSpaceLess != nil && phoneSpaceLess != "" && Int64(phoneSpaceLess!) != nil{
                if IGGlobal.matches(for: (selectedCountry?.codeRegex)!, in: phoneSpaceLess!) {
                    let countryCode = String(Int((self.selectedCountry?.countryCode)!))
                    let fullPhone = countryCode + " " + (phone?.replacingOccurrences(of: "_", with: ""))!
                    let message = IGStringsManager.YouHaveEnteredNumber.rawValue.localized + "\n" + fullPhone.inLocalizedLanguage() + "\n" + IGStringsManager.ConfirmIfNumberIsOk.rawValue.localized
                    IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: nil, showIconView: true, showDoneButton: true, showCancelButton: true, message: message, doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.dialogEdit.rawValue.localized, cancel: {}, done: {
                        IGGlobal.prgShow(self.view)
                        self.setRepresentative(phone: fullPhone)
                    })

                    return
                } else {}
            }
        } else {
            IGAppManager.sharedManager.setUserLoginSuccessful()
            let tabbar = IGTabBarController.instantiateFromAppStroryboard(appStoryboard: .Main)
            UIApplication.topNavigationController()!.pushViewController(tabbar, animated: true)
             self.dismiss(animated: false) {
                 RootVCSwitcher.updateRootVC(storyBoard: "Main", viewControllerID: "MainTabBar")
             }
        }
    }
    
    @objc func didTapOnChangeImage() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: IGStringsManager.Camera.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.photo])
        })
        let ChoosePhoto = UIAlertAction(title: IGStringsManager.Gallery.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.library])
        })
        
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        optionMenu.addAction(ChoosePhoto)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
        }
        optionMenu.addAction(cancelAction)
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = self.profileImageView
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func pickImage(screens: [YPPickerScreen]){
        IGHelperAvatar.shared.pickAndUploadAvatar(type: .user, screens: screens) { (file) in
            DispatchQueue.main.async {
                self.profileImageView?.setAvatar(avatar: file)
            }
        }
    }
    
    private func setCountryInfo(country: IGCountryInfo){
        txtCode.text = country.countryName
        txtCode.text = "+"+String(Int((country.countryCode)))
        
        if country.codePattern != nil && country.codePattern != "" {
            tfReferralNumber.setMask((country.codePatternMask), withMaskTemplate: country.codePatternTemplate)
        } else {
            let codePatternMask = "{ddddddddddddddddddddddddd}"
            let codePatternTemplate = "_________________________"
            tfReferralNumber.setMask(codePatternMask, withMaskTemplate: codePatternTemplate)
        }
    }
    
    private func setRepresentative(phone: String){
        IGUserProfileSetRepresentativeRequest.Generator.generate(phone: phone).success({ (protoResponse) in
            IGGlobal.prgHide()
            if let response = protoResponse as? IGPUserProfileSetRepresentativeResponse {
                IGUserProfileSetRepresentativeRequest.Handler.interpret(response: response)
                IGAppManager.sharedManager.setUserLoginSuccessful()
                self.dismiss(animated: false) {
                    RootVCSwitcher.updateRootVC(storyBoard: "Main", viewControllerID: "MainTabBar")
                }
            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
            IGAppManager.sharedManager.setUserLoginSuccessful()
            self.dismiss(animated: false) {
                RootVCSwitcher.updateRootVC(storyBoard: "Main", viewControllerID: "MainTabBar")
            }
        }).send()
    }
    
    /************************ Callback ************************/
    
    func onSelectCountry(country: IGCountryInfo) {
        selectedCountry = country
        setCountryInfo(country: country)
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
