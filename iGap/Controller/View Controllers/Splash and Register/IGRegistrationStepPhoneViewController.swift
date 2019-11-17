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
import MBProgressHUD
import RxSwift
import IGProtoBuff

class IGRegistrationStepPhoneViewController: BaseViewController {

    var tapCount : Int! = 1
    var isChecked : Bool! = false

    @IBOutlet weak var countryBackgroundView: UIView!
    @IBOutlet weak var phoneNumberBackgroundView: UIView!
    @IBOutlet weak var countryCodeBackgroundView: UIView!
    @IBOutlet weak var phoneNumberField: AKMaskField!
    @IBOutlet weak var termWebLink: UILabel!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var btnCheckmarkPrivacy: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var lblAceptPrivacy: FRHyperLabel!

    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var btnLoginQrCode: UIButton!
    
    var body : String!
    @IBOutlet weak var lblHeader: UILabel!

    
    internal static var allowGetCountry:Bool = true
    var phone: String?
    var selectedCountry : IGCountryInfo?
    var registrationResponse : (username:String, userId:Int64, authorHash:String, verificationMethod: IGVerificationCodeSendMethod, resendDelay:Int32, codeDigitsCount:Int32, codeRegex:String, callMethodSupport:Bool)?
    var hud = MBProgressHUD()
    var connectionStatus: IGAppManager.ConnectionStatus?
    
    private func updateNavigationBarBasedOnNetworkStatus(_ status: IGAppManager.ConnectionStatus) {
        let navigationItem = self.navigationItem as! IGNavigationItem
        self.navigationItem.hidesBackButton = true
        switch status {
        case .waitingForNetwork:
            navigationItem.setNavigationItemForWaitingForNetwork()
            connectionStatus = .waitingForNetwork
            break
        case .connecting:
            navigationItem.setNavigationItemForConnecting()
            connectionStatus = .connecting
            /*
            if selectedCountry == nil {
                selectedCountry = IGCountryInfo.defaultCountry()
            }
            self.setSelectedCountry(selectedCountry!)
            */
            break
        case .connected:
            self.setDefaultNavigationItem()
            self.getUserCurrentLocation()
            connectionStatus = .connected
            break
        case .iGap:
            connectionStatus = .iGap
            break
        }
    }

    
    private func setPrivacyAgreementLabel() {
        self.lblAceptPrivacy.text = IGStringsManager.PrivacyAgreement.rawValue.localized
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
        self.lblAceptPrivacy.addGestureRecognizer(tap)
        self.lblAceptPrivacy.isUserInteractionEnabled = true
        let current: String = SMLangUtil.loadLanguage()
        if current == "fa" {
            guard let range = self.lblAceptPrivacy.text?.range(of: "قوانین و مقررات")?.nsRange else {
                return
            }
            let myMutableString = NSMutableAttributedString(string: self.lblAceptPrivacy.text!, attributes: [NSAttributedString.Key.font :UIFont.igFont(ofSize: 17)])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.iGapSubmitButtons(), range: range)
            
            lblAceptPrivacy.attributedText = myMutableString
            
        } else {
            guard let range = self.lblAceptPrivacy.text?.range(of: "terms")?.nsRange else {
                return
            }
            let myMutableString = NSMutableAttributedString(string: self.lblAceptPrivacy.text!, attributes: [NSAttributedString.Key.font :UIFont.igFont(ofSize: 17)])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.iGapSubmitButtons(), range: range)
            
            lblAceptPrivacy.attributedText = myMutableString
            
        }
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        //Step 3: Add link substrings
        
        let current : String = SMLangUtil.loadLanguage()
        if current == "fa" {
            guard let range = self.lblAceptPrivacy.text?.range(of: "قوانین و مقررات")?.nsRange else {
                return
            }
            
            if tap.didTapAttributedTextInLabel(label: self.lblAceptPrivacy, inRange: range) {
                showTerms()
            }
            
        } else {
            guard let range = self.lblAceptPrivacy.text?.range(of: "terms")?.nsRange else {
                return
            }
            if tap.didTapAttributedTextInLabel(label: self.lblAceptPrivacy, inRange: range) {
                showTerms()
            }
        }
    }
    
    private func setDefaultNavigationItem() {
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: nil, title: IGStringsManager.RegisterationStepOneTitle.rawValue.localized)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //newUIelemnts
        btnSubmit.setTitle(IGStringsManager.BtnSendCode.rawValue.localized, for: .normal)
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnSubmit.layer.cornerRadius = 10
        
        let locale = Locale.userPreferred // e.g "en_US"
        lblHeader.text = IGStringsManager.PickNumWithCountry.rawValue.localized
        countryNameLabel.text = IGStringsManager.ChooseCountry.rawValue.localized
        btnLoginQrCode.setTitle(IGStringsManager.LoginWithQrScan.rawValue.localized, for: .normal)
        btnLoginQrCode.titleLabel?.font = UIFont.igFont(ofSize: 15)
        setPrivacyAgreementLabel()

        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
                
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        
        privacyView.transform = self.transform
        btnCheckmarkPrivacy.transform = self.transform
        lblAceptPrivacy.transform = self.transform
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnBackground))
        self.view.addGestureRecognizer(tapRecognizer)
    }

    //actions
    @IBAction func checkbtnCheckmarkClicked(_ sender: Any) {
        btnCheckmarkPrivacy.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        if isChecked {
            btnCheckmarkPrivacy.setTitle("NOT_CHECKED_ICON".Imagelocalized, for: .normal)
            btnCheckmarkPrivacy.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        }
        else {
            btnCheckmarkPrivacy.setTitle("CHECKED_ICON".Imagelocalized, for: .normal)
            btnCheckmarkPrivacy.setTitleColor(#colorLiteral(red: 0.2549019608, green: 0.6941176471, blue: 0.1254901961, alpha: 1), for: .normal)
        }
        isChecked = !isChecked

    }
    
    @IBAction func btnSubmitTap(_ sender: Any) {
        if isChecked {
            didTapOnSubmit()
        } else {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.MSGForgetTerms.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
        }
    }
    
    
    @objc func didTapOnBackground() {
        self.phoneNumberField.resignFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        navigationController?.navigationItem.hidesBackButton = true
        countryBackgroundView.layer.cornerRadius = 6.0;
        countryBackgroundView.layer.masksToBounds = true
        countryBackgroundView.layer.borderWidth = 1.0
        countryBackgroundView.layer.borderColor = UIColor.organizationalColor().cgColor
        let tapOnCountry = UITapGestureRecognizer(target: self, action: #selector(showCountriesList))
        countryBackgroundView.addGestureRecognizer(tapOnCountry)
        
        phoneNumberBackgroundView.layer.cornerRadius = 6.0;
        phoneNumberBackgroundView.layer.masksToBounds = true
        phoneNumberBackgroundView.layer.borderWidth = 1.0
        phoneNumberBackgroundView.layer.borderColor = UIColor.organizationalColor().cgColor
        
        countryCodeBackgroundView.layer.cornerRadius = 6.0;
        countryCodeBackgroundView.layer.masksToBounds = true
        countryCodeBackgroundView.layer.borderWidth = 1.0
        countryCodeBackgroundView.layer.borderColor = UIColor.organizationalColor().cgColor

        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: 64)
       
        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(rgb: 0xB9E244).cgColor, UIColor(rgb: 0x41B120).cgColor]
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = orangeGradientLocation as [NSNumber]
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
            navigationBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(IGRegistrationStepPhoneViewController.allowGetCountry){
            getUserCurrentLocation()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapOnNextBarButtonItem(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func didTapOnLoginUsingQRCode(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showQRCode", sender: self)
    }
    
    
    func didTapOnSubmit() {
        if connectionStatus == .waitingForNetwork || connectionStatus == .connecting {
            let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)

        } else {
            
            var phoneSpaceLess: String?
            let phone = phoneNumberField.text?.inEnglishNumbersNew()
            if phone != nil && phone != "" {
                phoneSpaceLess = phone?.replacingOccurrences(of: " ", with: "")
                phoneSpaceLess = phoneSpaceLess?.replacingOccurrences(of: "_", with: "")
            }

            if phoneSpaceLess != nil && phoneSpaceLess != "" && Int64(phoneSpaceLess!) != nil{
                if IGGlobal.matches(for: (selectedCountry?.codeRegex)!, in: phoneSpaceLess!) {
                    let countryCode = String(Int((self.selectedCountry?.countryCode)!))
                    let fullPhone = "+" + countryCode.inLocalizedLanguage() + " " + (phone?.replacingOccurrences(of: "_", with: ""))!.inLocalizedLanguage()
                    
                    let message = IGStringsManager.YouHaveEnteredNumber.rawValue.localized + "\n" + fullPhone.inLocalizedLanguage() + "\n" + IGStringsManager.ConfirmIfNumberIsOk.rawValue.localized
                    IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: nil, showIconView: true, showDoneButton: true, showCancelButton: true, message: message, doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.dialogEdit.rawValue.localized, cancel: {}, done: {
                        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        self.hud.mode = .indeterminate
                        self.userRegister(phoneSpaceLess: phoneSpaceLess!)

                    })
                    
                    return;
                }
            }
        }
    }
    
    
    func userRegister(phoneSpaceLess: String){
        let reqW = IGUserRegisterRequest.Generator.generate(countryCode: (self.selectedCountry?.countryISO)!, phoneNumber: Int64(phoneSpaceLess)!)
        reqW.success { (responseProto) in
            DispatchQueue.main.async {
                switch responseProto {
                case let userRegisterReponse as IGPUserRegisterResponse:
                    self.registrationResponse = IGUserRegisterRequest.Handler.intrepret(response: userRegisterReponse)
                    IGAppManager.sharedManager.save(userID: self.registrationResponse?.userId)
                    IGAppManager.sharedManager.save(username: self.registrationResponse?.username)
                    IGAppManager.sharedManager.save(authorHash: self.registrationResponse?.authorHash)
                    self.hud.hide(animated: true)
                    self.performSegue(withIdentifier: "showRegistration", sender: self)
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
                    self.userRegister(phoneSpaceLess: phoneSpaceLess)
                    errorTitle = "Timeout"
                    errorBody = "Please try again later"
                    return
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

    @objc func showCountriesList() {
        performSegue(withIdentifier: "showCountryCell", sender: self) //presentConutries
    }
    
    func showTerms() {
        performSegue(withIdentifier: "presentTerms", sender: self)
    }
    
    @objc func showTermsWebLink() {
        let myURLString = "https://www.igap.net/privacy.html"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        
        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            body = myHTMLString
        } catch let error {
            print("Error: \(error)")
        }
        self.performSegue(withIdentifier: "presentPrivacyPolicy", sender: self)


//        IGHelperOpenLink.openLink(urlString: "https://www.igap.net/privacy.html", navigationController: self.navigationController!)
    }
 
    
    
    func getUserCurrentLocation() {
        IGInfoLocationRequest.Generator.generate().success({(protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let locationProtoResponse as IGPInfoLocationResponse:
                   let country = IGCountryInfo(responseProtoMessage: locationProtoResponse)
                   self.selectedCountry = country
                    self.setSelectedCountry(self.selectedCountry!)
                    
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:

                break
            default:
                break
            }
            
        }).send()
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
        if segue.identifier == "showCountryCell" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! IGRegistrationStepSelectCountryTableViewController
            destination.delegate = self
        } else if segue.identifier == "presentTerms" {
            
        } else if segue.identifier == "presentPrivacyPolicy" {
            let destination = segue.destination as! IGRegistrationStepPrivacyPolicyViewController
            destination.body = body

        } else if segue.identifier == "showRegistration" {
            let destination = segue.destination as! IGRegistrationStepVerificationCodeViewController
            destination.codeDigitsCount = self.registrationResponse?.codeDigitsCount
            destination.codeRegex = self.registrationResponse?.codeRegex
            destination.delayBeforeSendingAgaing = self.registrationResponse?.resendDelay
            destination.username = self.registrationResponse?.username
            destination.verificationMethod = self.registrationResponse?.verificationMethod
            destination.callMethodSupport = (self.registrationResponse?.callMethodSupport)!
            destination.phone = phoneNumberField.text?.replacingOccurrences(of: "_", with: "")
            destination.selectedCountry = self.selectedCountry
            let fullPhone = "+"+String(Int((self.selectedCountry?.countryCode)!))+" "+phoneNumberField.text!.replacingOccurrences(of: "_", with: "")
            destination.phoneNumber = fullPhone
        }
    }
    
    fileprivate func setSelectedCountry(_ country:IGCountryInfo) {
        selectedCountry = country
        countryNameLabel.text = selectedCountry?.countryName
        countryCodeLabel.text = "+"+String(Int((selectedCountry?.countryCode)!))
        
        if country.codePattern != nil && country.codePattern != "" {
            phoneNumberField.setMask((selectedCountry?.codePatternMask)!, withMaskTemplate: selectedCountry?.codePatternTemplate)
        } else {
            //phoneNumberField.refreshMask()
            
            let codePatternMask = "{ddddddddddddddddddddddddd}"
            let codePatternTemplate = "_________________________"
            phoneNumberField.setMask(codePatternMask, withMaskTemplate: codePatternTemplate)
        }
    }
    
    
}

extension IGRegistrationStepPhoneViewController : IGRegistrationStepSelectCountryTableViewControllerDelegate {
    func didSelectCountry(country: IGCountryInfo) {
        self.setSelectedCountry(country)
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
