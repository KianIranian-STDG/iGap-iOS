//
//  SMBarcodeMainViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
import SwiftProtobuf
import IGProtoBuff
import webservice


var hasShownQrCode = false
var toID = ""
class SMBarcodeMainViewController: UIViewController ,HandleReciept{
    func close() {
        hasShownQrCode = false
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func screenView() {
        print("test")
    }
    

    @IBOutlet weak var heightConstants: NSLayoutConstraint!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var mianView:UIView!
    @IBOutlet weak var previewView: UIView!
    private var userCards: [SMCard]?
    private var userMerchants: [SMMerchant]?
    private var targetAccountId: String!
    private var transportId : String?
    private var qrCode : String?
    var manualInputView : SMSingleInputView!
    var ManualCodeActive = false

    var scanner: MTBBarcodeScanner?
    private var currentAmount: String = "0" {
        didSet {
            
            lblCurrency.text = "TTL_WALLET_BALANCE_USER".localizedNew + "\(" \n")\(currentAmount) \(" ")" + "CURRENCY".localizedNew
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        self.hideKeyboardWhenTappedAround()
        self.lblCurrency.font = UIFont.igFont(ofSize: 18)
        self.userCards = SMCard.getAllCardsFromDB()
        self.userMerchants = SMMerchant.getAllMerchantsFromDB()

        
        switch currentBussinessType {
        case 0 :
            lblCurrency.text = "TTL_WALLET_BALANCE_STORE".localizedNew + "\(" \n")\(merchantBalance) \(" ")" + "CURRENCY".localizedNew

            break
        case 2 :
            lblCurrency.text = "TTL_WALLET_BALANCE_DRIVER".localizedNew + "\(" \n")\(merchantBalance) \(" ")" + "CURRENCY".localizedNew

            break
        case 3 :
            lblCurrency.text = "TTL_WALLET_BALANCE_USER".localizedNew + "\(" \n")\(merchantBalance) \(" ")" + "CURRENCY".localizedNew
            self.updateAmountOfPayGear()

            break
            
        default :
            break
            
        }

        
    }
    private func updateAmountOfMerchant() {
        for i in userMerchants! {

        }
    }

    private func updateAmountOfPayGear() {
        if let cards = userCards {
            if cards.count > 0 {
                
                for card in cards {
                    if card.type == 1{
                        currentAmount = String.init(describing: card.balance ?? 0).inRialFormat()
                    }
                    else {
                        currentAmount = String.init(describing: card.balance ?? 0).inRialFormat()
                        
                    }
                }
            }
            else {
                currentAmount = "0".inRialFormat()

            }
        }
    }
    
    func initView() {

//        previewView.backgroundColor = .orange
        scanner = MTBBarcodeScanner(previewView: previewView)
        callQR()

    }
    func callQR() {
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            for code in codes {
                                if let stringValue = code.stringValue {
//                                    self.scanner?.stopScanning()
                                    self.resolveScannedQrCode(stringValue)
//                                    self.showPayModal()
                                    return
                                }
                            }
                        }
                    })
                } catch {
                    NSLog("Unable to start scanning")
                }
            } else {
                // no access to camera
            }
        })
    }
    @IBAction func btnTorch(_ sender: Any) {
        if self.scanner?.torchMode == .off {
            
        self.scanner?.torchMode = .on
        }
        else {
            self.scanner?.torchMode = .off

        }
    }
    @IBAction func btnModalTap(_ sender: Any)
    {
        self.ManualCodeActive = true

        if manualInputView == nil {
            manualInputView = SMSingleInputView.loadFromNib()
            manualInputView.confirmBtn.addTarget(self, action: #selector(confirmManualButtonSelected), for: .touchUpInside)
            manualInputView!.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: manualInputView.frame.height)
            
            manualInputView.confirmBtn.setTitle("GLOBAL_OK".localizedNew, for: .normal)
            manualInputView.infoLbl.text = "ENTER_RECIEVER_CODE".localizedNew
            manualInputView.inputTF.placeholder = "ENTER_CODE".localizedNew
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(SMBarcodeMainViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            manualInputView.addGestureRecognizer(swipeDown)
            self.view.addSubview(manualInputView!)
            
        }
        else {
            manualInputView.confirmBtn.setTitle("GLOBAL_OK".localizedNew, for: .normal)
            manualInputView.infoLbl.text = "ENTER_RECIEVER_CODE".localizedNew
            manualInputView.inputTF.placeholder = "ENTER_CODE".localizedNew
        }
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.manualInputView!.frame = CGRect(x: 0, y: self.view.frame.height - self.manualInputView.frame.height - 45 -  bottomPadding!, width: self.view.frame.width, height: self.manualInputView.frame.height)
                
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.manualInputView!.frame = CGRect(x: 0, y: self.view.frame.height - self.manualInputView.frame.height - 45, width: self.view.frame.width, height: self.manualInputView.frame.height)
            }
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
            self.view.endEditing(true)
            hideManualInputView()
        }
    }
    @objc func handleGesture(gesture: UITapGestureRecognizer) {
        // handling code
        hideManualInputView()
        
    }
    func showPayModal(type: SMAmountPopupType, name:String , subTitle : String , imgUser : String) {
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "payModal") as! walletModalViewController? {
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            let _ : [String: String]!
            presentedViewController.name = nil
            presentedViewController.name = name
            if (type == SMAmountPopupType.PopupNoProductTaxi) ||  (type == SMAmountPopupType.PopupProductedTaxi) {
                isTaxi = true
            }
            else {
               isTaxi = false

            }
            presentedViewController.profilePicUrl = imgUser
            UserDefaults.standard.setValue(imgUser, forKey: "modalUserPic")
            UserDefaults.standard.setValue(name, forKey: "modalUserName")
            UserDefaults.standard.setValue(self.lblCurrency.text!, forKey: "modalUserAmount")
            UserDefaults.standard.setValue(self.targetAccountId!, forKey: "modalTargetAccountID")
            print (self.transportId)
            if (self.transportId)  != nil {
                UserDefaults.standard.setValue(self.transportId!, forKey: "modalTrasnportID")
            }


            presentedViewController.type = 2//user Type nuber
            
            self.present(presentedViewController, animated: true, completion: nil)
        }
    }
    @objc func confirmManualButtonSelected() {
        
        hideManualInputView()
        //go to process info
        
        if manualInputView.inputTF.text! == "" {
            SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "GLOBAL_WARNING".localizedNew, message: "ERROR_FORM".localizedNew, leftButtonTitle: "", rightButtonTitle: "GLOBAL_OK".localizedNew,yesPressed: { yes in
                return
            })
        } else {
            getQRCodeInformation(barcodeValue: (manualInputView.inputTF.text!).inEnglishNumbers().onlyDigitChars())
        }
        
    }
    
    func hideManualInputView() {
        self.ManualCodeActive = false

        UIView.animate(withDuration: 0.3, animations: {
            self.manualInputView.frame.origin.y = self.view.frame.height
            self.manualInputView.inputTF.endEditing(true)
            
        }) { (true) in
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotifications()

        if (scanner?.isScanning())! {
//            scanner?.stopScanning()
            initView()
        }
        else {
            initView()

        }
        
//        try! self.scanner?.startScanning()
       
        
    }
    
    // MARK : - init View elements
    func initNavigationBar(){
       
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController!.navigationBar.topItem!.title = "SETTING_PAGE_QRCODE_SCANNER".localizedNew

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TAB0")
        self.hideKeyboardWhenTappedAround()

        initNavigationBar()
        setupNotifications()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.scanner?.stopScanning()
        unsetNotifications()

        super.viewWillDisappear(animated)
    }
    func setupNotifications() {
        unsetNotifications()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SMBarcodeMainViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SMBarcodeMainViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsetNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let window = UIApplication.shared.keyWindow!
        
        if ManualCodeActive {
            if let manualInput = manualInputView {
                window.addSubview(manualInput)
                UIView.animate(withDuration: 0.3) {
                    
                    var frame = manualInput.frame
                    frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight - frame.size.height)
                    manualInput.frame = frame
                    
                }
            }
        }else {
            self.hideManualInputView()
        }
        
        
        
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if let manualInput = manualInputView {
            self.view.addSubview(manualInput)
            UIView.animate(withDuration: 0.3) {
                if manualInput.frame.origin.y < self.view.frame.size.height {
                    manualInput.frame = CGRect(x: 0, y: self.view.frame.height - manualInput.frame.height - 45, width: self.view.frame.width, height: manualInput.frame.height)
                }
            }
        }
        
        self.view.layoutIfNeeded()
    }
    

    func resolveScannedQrCode(_ code: String) {
        print("Found code: \(code)")
        
        if let range = code.range(of: "?jj=") {

            let value = String(code[range.upperBound...])
        if let json = value.toJSON() as? Dictionary<String, AnyObject> {
            print(json)
            if !hasShownQrCode {
                hasShownQrCode = true

                UserDefaults.standard.setValue(String(value).onlyDigitChars().inEnglishNumbers(), forKey: "modalQRCode")

            self.getUserInformation(accountId: json["H"] as! String, qrType: Int(json["T"] as! String)!)
            }
        }
        else {
            if !hasShownQrCode {
                hasShownQrCode = true

            self.getQRCodeInformation(barcodeValue: String(value).onlyDigitChars())
            }
        }
        }
        
        
    }
    
    func getAccountInformation (accountId: String, closure: @escaping (_ name: String, _ subTitle: String, _ imagePath: String, _ acountType: Int) -> ()) {
        
        
        let account = PU_obj_account()
        account.account_id = String(describing: accountId)
        
        let request = WS_methods(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                SMLoading.hideLoadingPage()
                var name: String = ""
                var subTitle: String = ""
                var imagePath: String = ""
                var acountType: Int = 2
                if let n = jsonResult["name"] { name = n as! String }
                if let s = jsonResult["sub_title"] { subTitle = s as! String }
                if let i = jsonResult["profile_picture"] { imagePath = i as! String }
                if let at = jsonResult["account_type"] { acountType = at as! Int }

                closure(name , subTitle, imagePath, acountType)
            }
            
        }
        request.addFailedHandler({ (response: Any) in
            SMLoading.hideLoadingPage()
            //show popup
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
            }
            
        })
        
        request.pu_getaccountinfo(account, mod: 1)
        
        
    }
    func getUserInformation(accountId: String, qrType: Int, productId: String? = "") {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localizedNew)
        
        self.targetAccountId = String(describing:accountId)
        UserDefaults.standard.setValue(self.targetAccountId!, forKey: "modalTargetAccountID")

        self.getAccountInformation(accountId:  String(describing:accountId), closure: {name, subTitle, imagePath, acountType in
            
            if qrType == Int(SMQRCode.SMAccountType.User.rawValue) {
                SMLoading.hideLoadingPage()
//                self.showPopup(type: .PopupUser, value:["name": name, "subTitle": subTitle, "imagePath": imagePath])
                if hasShownQrCode {

                    switch acountType {
                    case 0 :
                        DispatchQueue.main.async {
                            self.showPayModal(type: .PopupNoProductTaxi, name: name, subTitle: subTitle, imgUser: imagePath)
                        }
                        break
                    case 1 :
                        DispatchQueue.main.async {
                            self.showPayModal(type: .PopupProductedTaxi, name: name, subTitle: subTitle, imgUser: imagePath)
                        }

                        break
                    case 2 :
                        DispatchQueue.main.async {
                            self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath)
                        }

                        break
                    default :
                        break
                    }
                    
                }
            }
            else {

                switch acountType {
                case 0 :
                    DispatchQueue.main.async {
                        self.showPayModal(type: .PopupNoProductTaxi, name: name, subTitle: subTitle, imgUser: imagePath)
                        
                    }
                    break
                case 1 :
                    DispatchQueue.main.async {
                        self.showPayModal(type: .PopupProductedTaxi, name: name, subTitle: subTitle, imgUser: imagePath)
                        
                    }
                    break
                case 2 :
                    break
                default :
                    break
                }
            }
        })
    }
    
    /// API call to fetch QR infromation according qr code
    ///
    /// - Parameter barcodeValue: qr code
    func getQRCodeInformation(barcodeValue: String) {
        
        self.qrCode = barcodeValue.inEnglishNumbers()

        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localizedNew)
        let request = WS_methods(delegate: self, failedDialog: true)
        
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                if let id = jsonResult["_id"] as? String , id == "" {
                    SMLoading.hideLoadingPage()
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "GLOBAL_WARNING".localizedNew, message: "INVALID_QR".localizedNew, rightButtonTitle: "GLOBAL_OK".localizedNew)
                }
                else if let accountId = jsonResult["account_id"], !accountId.isKind(of: NSNull.self) {
                    SMLoading.hideLoadingPage()
                    self.targetAccountId = String(describing:accountId)
                    self.transportId = jsonResult["value"] as? String
                    self.getUserInformation(accountId: accountId as! String, qrType: Int(truncating: jsonResult["qr_type"]! as! NSNumber), productId: jsonResult["value"] as? String)
                }
                else {
                    SMLoading.hideLoadingPage()
                    try! self.scanner?.startScanning()
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "GLOBAL_WARNING".localizedNew, message: "INVALID_QR".localizedNew, rightButtonTitle: "GLOBAL_OK".localizedNew)
                }
            }
        }
        request.addFailedHandler { (response: Any) in
            SMLoading.hideLoadingPage()
            try! self.scanner?.startScanning()
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: "SERVER_DOWN".localizedNew)
            }
            SMMessage.showWithMessage(SMCard.testConvert(response))
        }
        request.mc_getqrcodewithid(barcodeValue.inEnglishNumbers())
    }
}
