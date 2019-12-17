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

    var tapCount: Int! = 1
    var isChecked: Bool! = false
    
    private let scrollViewMain: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = .clear
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let ivLogo: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "iGapVerticalLogo"))
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let lblHeader: UILabel = {
        let lbl = UILabel()
        lbl.text = IGStringsManager.PickNumWithCountry.rawValue.localized
        lbl.numberOfLines = 3
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let viewCountryBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6.0
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.organizationalColor().cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let viewPhoneNumberBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6.0;
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.organizationalColor().cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewCountryCodeBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6.0;
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.organizationalColor().cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tfPhoneNumber: AKMaskField = {
        let mkField = AKMaskField()
        mkField.font = UIFont.igFont(ofSize: 17)
        mkField.textAlignment = .center
        mkField.keyboardType = .numberPad
        mkField.translatesAutoresizingMaskIntoConstraints = false
        return mkField
    }()
    
    private let lblCountryName: UILabel = {
        let lbl = UILabel()
        lbl.text = IGStringsManager.ChooseCountry.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = .left
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let lblCountryNameEtc: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.font = UIFont.iGapFonticon(ofSize: 20)
        lbl.text = ""
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let viewPrivacy: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let btnCheckmarkPrivacy: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("NOT_CHECKED_ICON".Imagelocalized, for: .normal)
        btn.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btn.titleLabel?.font = UIFont.iGapFonticon(ofSize: 24)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let btnSubmit: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(IGStringsManager.BtnSendCode.rawValue.localized, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btn.backgroundColor = UIColor.organizationalColor()
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let lblAcceptPrivacy: FRHyperLabel = {
        let lbl = FRHyperLabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = IGStringsManager.PrivacyAgreement.rawValue.localized
        lbl.font = UIFont.iGapFonticon(ofSize: 15)
        lbl.textAlignment = lbl.localizedDirection
        lbl.isUserInteractionEnabled = true
        let current: String = SMLangUtil.loadLanguage()
        if current == "fa" {
            guard let range = lbl.text?.range(of: "قوانین و مقررات")?.nsRange else {
                return lbl
            }
            let myMutableString = NSMutableAttributedString(string: lbl.text!, attributes: [NSAttributedString.Key.font :UIFont.igFont(ofSize: 17)])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.iGapSubmitButtons(), range: range)
            
            lbl.attributedText = myMutableString
            
        } else {
            guard let range = lbl.text?.range(of: "terms")?.nsRange else {
                return lbl
            }
            let myMutableString = NSMutableAttributedString(string: lbl.text!, attributes: [NSAttributedString.Key.font :UIFont.igFont(ofSize: 17)])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.iGapSubmitButtons(), range: range)
            
            lbl.attributedText = myMutableString
            
        }
        return lbl
    }()
    
    private let lblCountryCode: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let btnLoginQrCode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(IGStringsManager.LoginWithQrScan.rawValue.localized, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btn.setTitleColor(UIColor.organizationalColor(), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var body: String!
    
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

    @objc func tapLabel(tap: UITapGestureRecognizer) {
        //Step 3: Add link substrings
        
        let current : String = SMLangUtil.loadLanguage()
        if current == "fa" {
            guard let range = self.lblAcceptPrivacy.text?.range(of: "قوانین و مقررات")?.nsRange else {
                return
            }
            
            if tap.didTapAttributedTextInLabel(label: self.lblAcceptPrivacy, inRange: range) {
                showTerms()
            }
            
        } else {
            guard let range = self.lblAcceptPrivacy.text?.range(of: "terms")?.nsRange else {
                return
            }
            if tap.didTapAttributedTextInLabel(label: self.lblAcceptPrivacy, inRange: range) {
                showTerms()
            }
        }
    }
    
    private func setDefaultNavigationItem() {
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: nil, title: IGStringsManager.RegisterationStepOneTitle.rawValue.localized)
        
    }
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //newUIelemnts
        initView()
        setGestureRecognizers()

        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
                
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        
        viewPrivacy.transform = self.transform
        btnCheckmarkPrivacy.transform = self.transform
        lblAcceptPrivacy.transform = self.transform
    }
    
    // MARK: - View Item Initializer
    private func initView() {
        
        edgesForExtendedLayout = []
        
        guard let view = view else {
            return
        }
        
        view.addSubview(scrollViewMain)
        NSLayoutConstraint.activate([scrollViewMain.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     scrollViewMain.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     scrollViewMain.topAnchor.constraint(equalTo: view.topAnchor),
                                     scrollViewMain.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollViewMain.addSubview(ivLogo)
        NSLayoutConstraint.activate([ivLogo.topAnchor.constraint(equalTo: scrollViewMain.topAnchor, constant: 10),
                                     ivLogo.widthAnchor.constraint(lessThanOrEqualTo: scrollViewMain.widthAnchor),
                                     ivLogo.heightAnchor.constraint(equalToConstant: 120),
                                     ivLogo.centerXAnchor.constraint(equalTo: scrollViewMain.centerXAnchor),
        ])

        scrollViewMain.addSubview(lblHeader)
        NSLayoutConstraint.activate([lblHeader.topAnchor.constraint(equalTo: ivLogo.bottomAnchor, constant: 8),
                                     lblHeader.centerXAnchor.constraint(equalTo: ivLogo.centerXAnchor),
                                     lblHeader.widthAnchor.constraint(equalTo: scrollViewMain.widthAnchor, multiplier: 0.9),
                                     lblHeader.heightAnchor.constraint(lessThanOrEqualToConstant: 70)
        ])

        scrollViewMain.addSubview(viewCountryBackground)
        NSLayoutConstraint.activate([viewCountryBackground.centerXAnchor.constraint(equalTo: scrollViewMain.centerXAnchor),
                                     viewCountryBackground.widthAnchor.constraint(equalTo: scrollViewMain.widthAnchor, multiplier: 0.9),
                                     viewCountryBackground.heightAnchor.constraint(equalToConstant: 36),
                                     viewCountryBackground.topAnchor.constraint(equalTo: lblHeader.bottomAnchor, constant: 15)
        ])
        
        viewCountryBackground.addSubview(lblCountryNameEtc)
        NSLayoutConstraint.activate([lblCountryNameEtc.trailingAnchor.constraint(equalTo: viewCountryBackground.trailingAnchor, constant: -10),
                                     lblCountryNameEtc.widthAnchor.constraint(equalToConstant: 24),
                                     lblCountryNameEtc.heightAnchor.constraint(equalTo: viewCountryBackground.heightAnchor),
                                     lblCountryNameEtc.centerYAnchor.constraint(equalTo: viewCountryBackground.centerYAnchor)
        ])

        viewCountryBackground.addSubview(lblCountryName)
        NSLayoutConstraint.activate([lblCountryName.leadingAnchor.constraint(equalTo: viewCountryBackground.leadingAnchor, constant: 10),
                                     lblCountryName.trailingAnchor.constraint(equalTo: lblCountryNameEtc.leadingAnchor),
                                     lblCountryName.centerYAnchor.constraint(equalTo: lblCountryNameEtc.centerYAnchor),
                                     lblCountryName.heightAnchor.constraint(equalTo: lblCountryNameEtc.heightAnchor)
        ])

        scrollViewMain.addSubview(viewCountryCodeBackground)
        NSLayoutConstraint.activate([viewCountryCodeBackground.leftAnchor.constraint(equalTo: viewCountryBackground.leftAnchor),
                                     viewCountryCodeBackground.widthAnchor.constraint(equalToConstant: 80),
                                     viewCountryCodeBackground.heightAnchor.constraint(equalToConstant: 36),
                                     viewCountryCodeBackground.topAnchor.constraint(equalTo: lblCountryName.bottomAnchor, constant: 8)
        ])
        
        viewCountryCodeBackground.addSubview(lblCountryCode)
        NSLayoutConstraint.activate([lblCountryCode.leftAnchor.constraint(equalTo: viewCountryCodeBackground.leftAnchor),
                                     lblCountryCode.rightAnchor.constraint(equalTo: viewCountryCodeBackground.rightAnchor),
                                     lblCountryCode.heightAnchor.constraint(equalTo: viewCountryCodeBackground.heightAnchor),
                                     lblCountryCode.centerYAnchor.constraint(equalTo: viewCountryCodeBackground.centerYAnchor)
        ])
        
        
        scrollViewMain.addSubview(viewPhoneNumberBackground)
        NSLayoutConstraint.activate([viewPhoneNumberBackground.leftAnchor.constraint(equalTo: lblCountryCode.rightAnchor, constant: 8),
                                     viewPhoneNumberBackground.rightAnchor.constraint(equalTo: viewCountryBackground.rightAnchor),
                                     viewPhoneNumberBackground.centerYAnchor.constraint(equalTo: lblCountryCode.centerYAnchor),
                                     viewPhoneNumberBackground.heightAnchor.constraint(equalTo: lblCountryCode.heightAnchor)
        ])

        viewPhoneNumberBackground.addSubview(tfPhoneNumber)
        NSLayoutConstraint.activate([tfPhoneNumber.leftAnchor.constraint(equalTo: viewPhoneNumberBackground.leftAnchor),
                                     tfPhoneNumber.rightAnchor.constraint(equalTo: viewPhoneNumberBackground.rightAnchor),
                                     tfPhoneNumber.centerYAnchor.constraint(equalTo: viewPhoneNumberBackground.centerYAnchor),
                                     tfPhoneNumber.heightAnchor.constraint(equalTo: viewPhoneNumberBackground.heightAnchor)
        ])
        
        
        scrollViewMain.addSubview(viewPrivacy)
        NSLayoutConstraint.activate([viewPrivacy.leadingAnchor.constraint(equalTo: viewCountryBackground.leadingAnchor),
                                     viewPrivacy.trailingAnchor.constraint(equalTo: viewCountryBackground.trailingAnchor),
                                     viewPrivacy.heightAnchor.constraint(equalToConstant: 45),
                                     viewPrivacy.topAnchor.constraint(equalTo: tfPhoneNumber.bottomAnchor, constant: 15)
        ])
        

        viewPrivacy.addSubview(btnCheckmarkPrivacy)
        NSLayoutConstraint.activate([btnCheckmarkPrivacy.leadingAnchor.constraint(equalTo: viewPrivacy.leadingAnchor),
                                     btnCheckmarkPrivacy.centerYAnchor.constraint(equalTo: viewPrivacy.centerYAnchor),
                                     btnCheckmarkPrivacy.widthAnchor.constraint(equalToConstant: 45),
                                     btnCheckmarkPrivacy.heightAnchor.constraint(equalTo: viewPrivacy.heightAnchor)
        ])

        viewPrivacy.addSubview(lblAcceptPrivacy)
        NSLayoutConstraint.activate([lblAcceptPrivacy.leadingAnchor.constraint(equalTo: btnCheckmarkPrivacy.trailingAnchor, constant: 4),
                                     lblAcceptPrivacy.trailingAnchor.constraint(equalTo: viewPrivacy.trailingAnchor),
                                     lblAcceptPrivacy.centerYAnchor.constraint(equalTo: btnCheckmarkPrivacy.centerYAnchor),
                                     lblAcceptPrivacy.heightAnchor.constraint(equalTo: btnCheckmarkPrivacy.heightAnchor)
        ])

        scrollViewMain.addSubview(btnSubmit)
        NSLayoutConstraint.activate([btnSubmit.centerXAnchor.constraint(equalTo: scrollViewMain.centerXAnchor),
                                     btnSubmit.topAnchor.constraint(equalTo: lblAcceptPrivacy.bottomAnchor, constant: 15),
                                     btnSubmit.widthAnchor.constraint(equalToConstant: 180),
                                     btnSubmit.heightAnchor.constraint(equalToConstant: 45)
        ])

        scrollViewMain.addSubview(btnLoginQrCode)
        NSLayoutConstraint.activate([btnLoginQrCode.centerXAnchor.constraint(equalTo: scrollViewMain.centerXAnchor),
                                     btnLoginQrCode.widthAnchor.constraint(equalTo: scrollViewMain.widthAnchor, multiplier: 0.7),
                                     btnLoginQrCode.heightAnchor.constraint(equalToConstant: 35),
                                     btnLoginQrCode.topAnchor.constraint(equalTo: btnSubmit.bottomAnchor, constant: 8)
        ])
        
        
        btnCheckmarkPrivacy.addTarget(self, action: #selector(checkbtnCheckmarkClicked(_:)), for: .touchUpInside)
        
        btnSubmit.addTarget(self, action: #selector(btnSubmitTap(_:)), for: .touchUpInside)
        
        btnLoginQrCode.addTarget(self, action: #selector(didTapOnLoginUsingQRCode(_:)), for: .touchUpInside)
        
        scrollViewMain.layoutSubviews()
        scrollViewMain.contentSize = CGSize(width: scrollViewMain.frame.width, height: btnLoginQrCode.frame.maxY)
        

    }
    
    // MARK: - Keyboard Observer Action
    @objc private func keyboardWillShowAction(notif: Notification) {
        
        if let keyboardSize = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            scrollViewMain.contentSize.height += keyboardHeight
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHideAction(notif: Notification) {
        
        if let keyboardSize = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            scrollViewMain.contentSize.height -= keyboardHeight
        }
        
    }

    private func scrollToBottom() {
        
        let bottomOffset = CGPoint(x: 0, y: scrollViewMain.contentSize.height - scrollViewMain.bounds.size.height + scrollViewMain.contentInset.bottom)
        scrollViewMain.setContentOffset(bottomOffset, animated: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Gesture Recognizer
    private func setGestureRecognizers() {
        
        let tapOnCountry = UITapGestureRecognizer(target: self, action: #selector(showCountriesList))
        viewCountryBackground.addGestureRecognizer(tapOnCountry)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnBackground))
        self.view.addGestureRecognizer(tapRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
        self.lblAcceptPrivacy.addGestureRecognizer(tap)
    }
    
    //actions
    @IBAction func checkbtnCheckmarkClicked(_ sender: Any) {
        btnCheckmarkPrivacy.titleLabel?.font = UIFont.iGapFonticon(ofSize: 23)
        if isChecked {
            btnCheckmarkPrivacy.setTitle("NOT_CHECKED_ICON".Imagelocalized, for: .normal)
            btnCheckmarkPrivacy.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
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
        self.tfPhoneNumber.resignFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationItem.hidesBackButton = true

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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowAction), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideAction), name: UIResponder.keyboardWillHideNotification, object: nil)
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
            let phone = tfPhoneNumber.text?.inEnglishNumbersNew()
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
            destination.phone = tfPhoneNumber.text?.replacingOccurrences(of: "_", with: "")
            destination.selectedCountry = self.selectedCountry
            let fullPhone = "+"+String(Int((self.selectedCountry?.countryCode)!))+" "+tfPhoneNumber.text!.replacingOccurrences(of: "_", with: "")
            destination.phoneNumber = fullPhone
        }
    }
    
    fileprivate func setSelectedCountry(_ country:IGCountryInfo) {
        selectedCountry = country
        lblCountryName.text = selectedCountry?.countryName
        lblCountryCode.text = "+"+String(Int((selectedCountry?.countryCode)!))
        
        if country.codePattern != nil && country.codePattern != "" {
            tfPhoneNumber.setMask((selectedCountry?.codePatternMask)!, withMaskTemplate: selectedCountry?.codePatternTemplate)
        } else {
            //phoneNumberField.refreshMask()
            
            let codePatternMask = "{ddddddddddddddddddddddddd}"
            let codePatternTemplate = "_________________________"
            tfPhoneNumber.setMask(codePatternMask, withMaskTemplate: codePatternTemplate)
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
