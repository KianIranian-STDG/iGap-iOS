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



class SMBarcodeMainViewController: UIViewController {

    @IBOutlet weak var heightConstants: NSLayoutConstraint!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var mianView:UIView!
    @IBOutlet weak var previewView: UIView!
    private var userCards: [SMCard]?
    private var targetAccountId: String!
    private var transportId : String?
    private var qrCode : String?
    var manualInputView : SMSingleInputView!
    var scanner: MTBBarcodeScanner?
    var hasShown = false
    private var currentAmount: String = "0" {
        didSet {
            lblCurrency.text = "\("Wallet Card Balance" + " \n")\(currentAmount) \(" Rial")"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        self.lblCurrency.font = UIFont.igFont(ofSize: 18)
        self.userCards = SMCard.getAllCardsFromDB()
        self.updateAmountOfPayGear()
        
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
        print(self.scanner?.torchMode)
        if self.scanner?.torchMode == .off {
            
        self.scanner?.torchMode = .on
        }
        else {
            self.scanner?.torchMode = .off

        }
    }
    @IBAction func btnModalTap(_ sender: Any)
    {
       
    }
    func showPayModal(type: SMAmountPopupType, name:String , subTitle : String , imgUser : String) {
        hasShown = true
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "payModal") as! walletModalViewController! {
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            let value : [String: String]!
            presentedViewController.name = name
            presentedViewController.profilePicUrl = imgUser
            UserDefaults.standard.setValue(imgUser, forKey: "modalUserPic")
            UserDefaults.standard.setValue(name, forKey: "modalUserName")
            print(lblCurrency.text)
            UserDefaults.standard.setValue(self.lblCurrency.text!, forKey: "modalUserAmount")
            UserDefaults.standard.setValue(self.targetAccountId!, forKey: "modalTargetAccountID")


            presentedViewController.type = 2//user Type nuber
            
            self.present(presentedViewController, animated: true, completion: nil)
        }
    }
    @objc func confirmManualButtonSelected() {
        
        hideManualInputView()
        //go to process info
        
        if manualInputView.inputTF.text! == ""{
//            SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "fill".localized, leftButtonTitle: "", rightButtonTitle: "ok".localized,yesPressed: { yes in return;})
        }else{
            
//            getQRCodeInformation(barcodeValue: manualInputView.inputTF.text!)
        }
        
    }
    
    func hideManualInputView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.manualInputView.frame.origin.y = self.view.frame.height
            self.manualInputView.inputTF.endEditing(true)
            
        }) { (true) in
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        initView()
       
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.scanner?.stopScanning()
        
        super.viewWillDisappear(animated)
    }
    
    
    
    func resolveScannedQrCode(_ code: String) {
        print("Found code: \(code)")
        
        if let range = code.range(of: "?jj=") {
            hasShown = true

            let value = String(code[range.upperBound...])
        if let json = value.toJSON() as? Dictionary<String, AnyObject> {
            if self.hasShown {
                print(json["H"])
                print(json["H"] as! String)
                UserDefaults.standard.setValue(String(value).onlyDigitChars().inEnglishNumbers(), forKey: "modalQRCode")

            self.getUserInformation(accountId: json["H"] as! String, qrType: Int(json["T"] as! String)!)
            }
        }
        else {
            self.getQRCodeInformation(barcodeValue: String(value).onlyDigitChars())
        }
        }
        
        
    }
    
    func getAccountInformation (accountId: String, closure: @escaping (_ name: String, _ subTitle: String, _ imagePath: String) -> ()) {
        
        
        let account = PU_obj_account()
        account.account_id = String(describing: accountId)
        
        let request = WS_methods(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                SMLoading.hideLoadingPage()
                var name: String = ""
                var subTitle: String = ""
                var imagePath: String = ""
                if let n = jsonResult["name"] { name = n as! String }
                if let s = jsonResult["sub_title"] { subTitle = s as! String }
                if let i = jsonResult["profile_picture"] { imagePath = i as! String }
                
                closure(name , subTitle, imagePath)
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
        
        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localized)
        
        self.targetAccountId = String(describing:accountId)
        UserDefaults.standard.setValue(self.targetAccountId!, forKey: "modalTargetAccountID")

        self.getAccountInformation(accountId:  String(describing:accountId), closure: {name, subTitle, imagePath in
            
            if qrType == Int(SMQRCode.SMAccountType.User.rawValue) {
                SMLoading.hideLoadingPage()
//                self.showPopup(type: .PopupUser, value:["name": name, "subTitle": subTitle, "imagePath": imagePath])
                if self.hasShown {
                    print(name)
                    print(imagePath)
                self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath)
                }
            }
            else {
                
            }
        })
    }
    
    /// API call to fetch QR infromation according qr code
    ///
    /// - Parameter barcodeValue: qr code
    func getQRCodeInformation(barcodeValue: String) {
        
        self.qrCode = barcodeValue.inEnglishNumbers()

        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localized)
        let request = WS_methods(delegate: self, failedDialog: true)
        
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                if let id = jsonResult["_id"] as? String , id == "" {
                    
                    SMLoading.hideLoadingPage()
//                    try! self.scanner?.startScanning()
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "GLOBAL_WARNING".localizedNew, message: "INVALID_QR".localizedNew, rightButtonTitle: "OK".localized)
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
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "GLOBAL_WARNING".localizedNew, message: "INVALID_QR".localizedNew, rightButtonTitle: "OK".localized)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
