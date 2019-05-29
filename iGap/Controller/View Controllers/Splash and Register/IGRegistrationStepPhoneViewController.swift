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
import AKMaskField
import SwiftProtobuf
import MBProgressHUD
import RxSwift
import IGProtoBuff

class IGRegistrationStepPhoneViewController: UIViewController {

    @IBOutlet weak var countryBackgroundView: UIView!
    @IBOutlet weak var phoneNumberBackgroundView: UIView!
    @IBOutlet weak var countryCodeBackgroundView: UIView!
    @IBOutlet weak var phoneNumberField: AKMaskField!
    @IBOutlet weak var termWebLink: UILabel!
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var btnLoginQrCode: UIButton!
    
    
    @IBOutlet weak var lblHeader: UILabel!

    
    internal static var allowGetCountry:Bool = true
    var phone: String?
    var selectedCountry : IGCountryInfo?
    var registrationResponse : (username:String, userId:Int64, authorHash:String, verificationMethod: IGVerificationCodeSendMethod, resendDelay:Int32, codeDigitsCount:Int32, codeRegex:String, callMethodSupport:Bool)?
    var hud = MBProgressHUD()
    private let disposeBag = DisposeBag()
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

    private func setDefaultNavigationItem() {
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: "NEXT_BTN".localizedNew, title: "SETTING_PAGE_ACCOUNT_PHONENUMBER".localizedNew)
        navItem.rightViewContainer?.addAction {
            self.didTapOnNext()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = "TTL_PICKNUM_WITH_COUNTRYCODE".localizedNew
        countryNameLabel.text = "CHOOSE_COUNTRY".localizedNew
        btnLoginQrCode.setTitle("LOGIN_USING_QR".localizedNew, for: .normal)
        btnLoginQrCode.titleLabel?.font = UIFont.igFont(ofSize: 15)
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
                
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnBackground))
        self.view.addGestureRecognizer(tapRecognizer)
    }

    
    @objc func didTapOnBackground() {
        self.phoneNumberField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
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
        
        
        let terms1 = NSMutableAttributedString(string: "BY_SIGNING_AGREEMENT".localizedNew,
                                               attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor(red: 114/255.0, green: 114/255.0, blue: 114/255.0, alpha: 1.0)]))
        let terms2 = NSAttributedString(string: "TERMS_OF_SERVICE".localizedNew,
                                        attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.organizationalColor()]))
        terms1.append(terms2)
        termLabel.attributedText = terms1
        let tapOnTerms = UITapGestureRecognizer(target: self, action: #selector(showTerms))
        termLabel.addGestureRecognizer(tapOnTerms)
        termLabel.isUserInteractionEnabled = true
        
        let termsWebLink = NSAttributedString(string: "SETTING_PS_TTL_PRIVACY".localizedNew, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.organizationalColor()]))
        termWebLink.attributedText = termsWebLink
        let tapOnTermsWebLink = UITapGestureRecognizer(target: self, action: #selector(showTermsWebLink))
        termWebLink.addGestureRecognizer(tapOnTermsWebLink)
        termWebLink.isUserInteractionEnabled = true
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
    
    
    func didTapOnNext() {
        if connectionStatus == .waitingForNetwork || connectionStatus == .connecting {
            let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "NO_NETWORK".localizedNew, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)

        } else {
            
            var phoneSpaceLess: String?
            let phone = phoneNumberField.text?.inEnglishNumbers()
            if phone != nil && phone != "" {
                phoneSpaceLess = phone?.replacingOccurrences(of: " ", with: "")
                phoneSpaceLess = phoneSpaceLess?.replacingOccurrences(of: "_", with: "")
            }

            if phoneSpaceLess != nil && phoneSpaceLess != "" && Int64(phoneSpaceLess!) != nil{
                if IGGlobal.matches(for: (selectedCountry?.codeRegex)!, in: phoneSpaceLess!) {
                    let countryCode = String(Int((self.selectedCountry?.countryCode)!))
                    let fullPhone = "+" + countryCode.inLocalizedLanguage() + " " + (phone?.replacingOccurrences(of: "_", with: ""))!.inLocalizedLanguage()
                    let alertVC = UIAlertController(title: "IS_IT_CORRECT".localizedNew,message: "IS_PHONE_OK".localizedNew + "\n" + fullPhone.inLocalizedLanguage(),preferredStyle: .alert)
                    let yes = UIAlertAction(title: "GLOBAL_YES".localizedNew, style: .cancel, handler: { (action) in
                        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        self.hud.mode = .indeterminate
                        self.userRegister(phoneSpaceLess: phoneSpaceLess!)
                    })
                    let no = UIAlertAction(title: "BTN_EDITE".localizedNew, style: .default, handler: { (action) in
                        
                    })
                    
                    
                    alertVC.addAction(yes)
                    alertVC.addAction(no)
                    self.present(alertVC, animated: true, completion: {
                        
                    })
                    
                    return;
                }
            }
            let alertVC = UIAlertController(title: "INVALID_PHONE".localizedNew, message: "ENTER_VALID_P_NUMBER".localizedNew, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
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
    
    @objc func showTerms() {
        performSegue(withIdentifier: "presentTerms", sender: self)
    }
    
    @objc func showTermsWebLink() {
        IGHelperOpenLink.openLink(urlString: "https://www.igap.net/privacy.html", navigationController: self.navigationController!)
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
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountryCell" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! IGRegistrationStepSelectCountryTableViewController
            destination.delegate = self
        } else if segue.identifier == "presentTerms" {
            
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
