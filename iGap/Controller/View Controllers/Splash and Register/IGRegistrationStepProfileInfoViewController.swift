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

    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IGRegistrationStepProfileInfoViewController.selectCountryObserver = self
        selectedCountry = IGCountryInfo.iranCountry()
        setCountryInfo(country: selectedCountry)

        self.imagePickLabel.layer.cornerRadius = self.imagePickLabel.frame.height / 2.0
        self.imagePickLabel.layer.masksToBounds = true

        nicknameTextField.delegate = self
        initFonts()
        initLanguage()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapOnChangeImage))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: "NEXT_BTN".localizedNew, title: "YOUR_PROFILE".localizedNew)
        navItem.rightViewContainer?.addAction {
            self.didTapOnDone()
        }
        imagePicker.delegate = self
        
//        let tapOnCountry = UITapGestureRecognizer(target: self, action: #selector(showCountriesList))
//        txtCode.addGestureRecognizer(tapOnCountry)

    }
    @IBAction func didTapOnBtnCountryCode(_ sender: UIButton) {
        IGGlobal.isPopView = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = "ENTER_NAME_AND_CHOOSE_PHOTO".localizedNew
//        self.nicknameTextField.becomeFirstResponder()
    }
    private func initFonts() {
        titleLabel.font = UIFont.igFont(ofSize: 13)
        pagetitleLabel.font = UIFont.igFont(ofSize: 30,weight: .bold)
        nicknameTextField.font = UIFont.igFont(ofSize: 15)
        FnameTextField.font = UIFont.igFont(ofSize: 15)
        tfReferralNumber.font = UIFont.igFont(ofSize: 15)
        lblReferralHint.font = UIFont.igFont(ofSize: 13)
        txtCode.font = UIFont.igFont(ofSize: 15)
        lblReferralHint.textAlignment = lblReferralHint.localizedNewDirection
        tfReferralNumber.textAlignment = .left
        nicknameTextField.textAlignment = nicknameTextField.localizedNewDirection
        FnameTextField.textAlignment = nicknameTextField.localizedNewDirection
        txtCode.textAlignment = .center
    }
    @objc func showCountriesList() {
//           performSegue(withIdentifier: "showCountrySelection", sender: self)
       }
    private func initLanguage() {
        txtCode.text = "CHOOSE_COUNTRY".localizedNew
        lblReferralHint.text = "ENTER_REFERRAL_NUMBER".localizedNew
        nicknameTextField.placeholder = "PLACE_HOLDER_F_NAME".localizedNew
        FnameTextField.placeholder = "PLACE_HOLDER_L_NAME".localizedNew
        tfReferralNumber.placeholder = "SETTING_PAGE_ACCOUNT_PHONENUMBER".localizedNew
        pagetitleLabel.text = "PU_INFORMATION".localizedNew
        titleLabel.text = "ENTER_NAME_AND_CHOOSE_PHOTO".localizedNew

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardFrame.size.height + 10, right: 0)
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
                                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "UNSSUCCESS_OTP".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
                            }
                        }).send()
                        
                        
                    default:
                        break
                    }    
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "UNSSUCCESS_OTP".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
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
                    let alertVC = UIAlertController(title: "IS_IT_CORRECT".localizedNew,message: "IS_PHONE_OK".localizedNew + fullPhone,preferredStyle: .alert)
                    let yes = UIAlertAction(title: "GLOBAL_YES".localizedNew, style: .cancel, handler: { (action) in
                        IGGlobal.prgShow(self.view)
                        self.setRepresentative(phone: fullPhone)
                    })
                    let no = UIAlertAction(title: "BTN_EDITE".localizedNew, style: .default, handler: nil)
                    
                    alertVC.addAction(yes)
                    alertVC.addAction(no)
                    self.present(alertVC, animated: true, completion: nil)
                    return
                } else {
                    let alertVC = UIAlertController(title: "INVALID_PHONE".localizedNew, message: "ENTER_VALID_P_NUMBER".localizedNew, preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)

                }            }
        } else {
            IGAppManager.sharedManager.setUserLoginSuccessful()
        }
    }
    @objc func didTapOnChangeImage() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: "TAKE_A_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil{
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraCaptureMode = .photo
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                else {
                    self.present(self.imagePicker, animated: true, completion: nil)//4
                    self.imagePicker.popoverPresentationController?.sourceView = (self.profileImageView)
                    self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                    self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
                }
            }
        })
        let ChoosePhoto = UIAlertAction(title: "CHOOSE_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                self.present(self.imagePicker, animated: true, completion: nil)//4
                self.imagePicker.popoverPresentationController?.sourceView = (self.profileImageView)
                self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            }
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
        }
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = self.profileImageView
        }
        self.present(optionMenu, animated: true, completion: nil)
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

            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
            DispatchQueue.main.async {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "UNSSUCCESS_OTP".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)

            }
        }).send()
    }
    

    
    /************************ Callback ************************/
    
    func onSelectCountry(country: IGCountryInfo) {
        selectedCountry = country
        setCountryInfo(country: country)
    }
    }

extension IGRegistrationStepProfileInfoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            self.profileImageView.image = pickedImage
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2.0
            self.profileImageView.layer.masksToBounds = true

            let avatar = IGFile()
            avatar.attachedImage = pickedImage
            let randString = IGGlobal.randomString(length: 32)
            avatar.cacheID = randString
            avatar.name = randString
            
            IGUploadManager.sharedManager.upload(file: avatar, start: {
                
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
                if let token = uploadTask.token {
                    IGUserAvatarAddRequest.Generator.generate(token: token).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let avatarAddResponse as IGPUserAvatarAddResponse:
                                IGUserAvatarAddRequest.Handler.interpret(response: avatarAddResponse)
                            default:
                                break
                            }
                        }
                    }).error({ (error, waitTime) in
                        
                    }).send()
                }
            }, failure: {
                
            })
        }
        imagePicker.dismiss(animated: true, completion: {
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGRegistrationStepProfileInfoViewController: UINavigationControllerDelegate {
    
}

extension IGRegistrationStepProfileInfoViewController: UITextFieldDelegate {
    
}






// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
