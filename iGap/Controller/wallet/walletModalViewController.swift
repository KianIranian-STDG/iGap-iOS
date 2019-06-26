//
//  walletModalViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import webservice
import SnapKit

public var isTaxi : Bool! = false


protocol HandlePayModal {
    func payTaped()
}

class walletModalViewController: UIViewController , UITextFieldDelegate ,HandleReciept {
    func close() {
        hasShownQrCode = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func screenView() {
        print("test")
    }
    
    
    var dismissBtn : UIButton!
    var delegate : HandlePayModal?
    
    @IBOutlet weak var lblPersonesCount: UILabel!
    @IBOutlet weak var lblPaidToTitle: UILabel!
    @IBOutlet weak var stepperPersons: UIStepper!
    @IBOutlet weak var verticalConstraints: NSLayoutConstraint!
    @IBOutlet weak var imgProfile: UIImageViewX!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var tfAmountToPy : customUITextField!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var mainView: UIViewX!
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentPick: UISegmentedControl!
    @IBOutlet weak var btnPay: UIButton!
    private var userCards: [SMCard]?
    private var targetAccountId: String!
    private var transportId : String?
    var keyboardHeight : CGFloat?
    var keyBoardIsOpen = false
    
    public var type: Int = 2
    
    
    
    /// Dictionary contains name, productName, subTitle, price, imagePath
    var value: [String: String]!{
        didSet {
            if type == 0 {
            }else if type == 1 {
            }else if type == 2 {
                lblDescription.text = name
                if let price = price {
                    //                    tfAmountToPy.text = price as String
                    //                    tfAmount.isEnabled = false
                }
            }
            DispatchQueue.main.async {
                let request = WS_methods(delegate: self, failedDialog: true)
                let str = request.fs_getFileURL(self.profilePicUrl)
                self.imgProfile.downloadedFrom(link: str!.filter { !" \\ \n \" \t\r".contains($0) },contentMode : .scaleAspectFill)
            }
        }
    }
    
    var username : String!
    var phoneNum : String!
    var amount : String!
    var name : String!
    var id : String!
    var price : String!
    var currentAmount : String!
    var profilePicUrl : String!
    private var qrCode : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        lblPersonesCount.font = UIFont.igFont(ofSize: 20)
        self.userCards = SMCard.getAllCardsFromDB()
        
        initView()
        handleUIChange()
        creatBtnDismiss()
        //        btnPay.addTarget(self, action: #selector(btnPayTaped), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    func creatBtnDismiss() {
        dismissBtn = UIButton()
        dismissBtn.backgroundColor = UIColor.clear
        self.view.insertSubview(dismissBtn, at: 2)
        dismissBtn.addTarget(self, action: #selector(didtapOutSide), for: .touchUpInside)
        
        dismissBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.mainView.snp.top)
            make.right.equalTo(self.view.snp.right)
            make.left.equalTo(self.view.snp.left)
        }
        
    }
    @objc func didtapOutSide() {
        if dismissBtn != nil {
            
            name = nil
            lblDescription.text = ""
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNoticationDismissWalletPay),
                                            object: nil,
                                            userInfo: nil)
            hasShownQrCode = false
            dismissBtn.removeFromSuperview()
            dismissBtn = nil
            
            self.dismiss(animated: true)
            
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 15)]
        segmentPick.setTitleTextAttributes((font as! [NSAttributedString.Key : Any]), for: .normal)
        
        name = UserDefaults.standard.string(forKey: "modalUserName")
        
        lblDescription.text = name
        
        if isTaxi {
            lblPersonesCount.isHidden = true
            stepperPersons.isHidden = true
            self.view.layoutIfNeeded()
        }
        else {
            lblPersonesCount.isHidden = true
            stepperPersons.isHidden = true
            self.view.layoutIfNeeded()
            
            
        }
    }
    func initView() {
        self.hideKeyboardWhenTappedAround()
        
        //        tfAmount.inputView =  LNNumberpad.default()
        //        self.tfAmountToPy.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        self.tfAmountToPy.delegate = self
        
        self.tfAmountToPy.font = UIFont.igFont(ofSize: 15)
        profilePicUrl = UserDefaults.standard.string(forKey: "modalUserPic")
        currentAmount = UserDefaults.standard.string(forKey: "modalUserAmount")
        transportId = UserDefaults.standard.string(forKey: "modalTrasnportID")
        targetAccountId = UserDefaults.standard.string(forKey: "modalTargetAccountID")
        qrCode = UserDefaults.standard.string(forKey: "modalQRCode")
        
        if type == 2 {
            
            lblDescription.text = name
            
            if let price = price {
            }
        }
        
        DispatchQueue.main.async {
            let request = WS_methods(delegate: self, failedDialog: true)
            let str = request.fs_getFileURL(self.profilePicUrl)
            self.imgProfile.downloadedFrom(link: str!.filter { !" \\ \n \" \t\r".contains($0) },contentMode : .scaleAspectFill)
            self.imgProfile.layer.cornerRadius = self.imgProfile.bounds.width/2
            self.imgProfile.layer.borderWidth = 1
            self.imgProfile.layer.borderColor = UIColor.black.cgColor
            self.imgProfile?.layer.shadowRadius = 10
            self.imgProfile?.layer.shadowColor = UIColor.black.cgColor
            self.imgProfile?.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.imgProfile?.layer.shadowOpacity = 0.5
            
        }
        segmentPick.setTitle("SETTING_PAGE_WALLET".localizedNew, forSegmentAt: 0)
        segmentPick.setTitle("SETTING_PAGE_CARD".localizedNew, forSegmentAt: 1)
        btnPay.setTitle("BTN_PAY_CASHOUT".localizedNew, for: .normal)
        lblPaidToTitle.text = "PAIED_TO_LBL".localizedNew
        lblPaidToTitle.textAlignment = lblPaidToTitle.localizedNewDirection
        lblDescription.textAlignment = lblDescription.localizedNewDirection
        
        if isHyperMe {
            print((UserDefaults.standard.string(forKey: "modalHyperPrice")))
            //            self.tfAmountToPy.text = (UserDefaults.standard.string(forKey: "modalHyperPrice"))!.inLocalizedLanguage().inRialFormat()
            self.tfAmountToPy.isEnabled = false
            
            self.tfAmountToPy.placeholder = (UserDefaults.standard.string(forKey: "modalHyperPrice"))?.inRialFormat().inLocalizedLanguage()
        }
        else {
            self.tfAmountToPy.text = ""
            self.tfAmountToPy.placeholder = ""
            
            self.tfAmountToPy.isEnabled = true
            
        }
    }
    
    @IBAction func stepperTaped(_ sender: Any) {
        lblPersonesCount.text = String(Int(stepperPersons.value))
        if let tmpCount = Float(lblPersonesCount.text!) {
            
        }
    }
    @IBAction func segPickedTap(_ sender: Any) {
        if segmentPick.selectedSegmentIndex == 0 {
            print("wallet")
        }
        else {
            print("Card")
        }
    }
    func AnimateMainViewHeight() {
        UIView.animate(withDuration: 0.5, animations: {
            self.mainViewHeight.constant = 600 // heightCon is the IBOutlet to the constraint
            self.mainView.layoutIfNeeded()
        })
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func payBtnTapedDows(_ sender: Any) {
        
        tfAmountToPy.resignFirstResponder()
        
        if self.tfAmountToPy.text == "" ||
            self.tfAmountToPy.text?.inEnglishNumbers() == "0" {
            SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "GLOBAL_WARNING".localizedNew, message: "FILL_AMOUNT".localizedNew, leftButtonTitle: "", rightButtonTitle: "GLOBAL_OK".localizedNew,yesPressed: { yes in return;})
        }
            
        else {

            self.GetMutualClubList(MerchantCode: self.targetAccountId, UserCode: merchantID) { response in
//                self.getAmountPopup.removeFromSuperview()
                self.paySequence(ClubList: response)

            }
        }
    }
    
    
    func paySequence(ClubList: [Any]) {
        
        //popup.confirmBtn.gotoLoadingState()
        if segmentPick.selectedSegmentIndex == 0 {
            
            let tmp1 = Int(self.tfAmountToPy.text!.inEnglishNumbers().onlyDigitChars())!
            let tmp2 = Int(self.currentAmount.inEnglishNumbers().onlyDigitChars())!
            if Int(tmp1) > Int(tmp2) {
                //show message about your amount is not enough
                SMMessage.showWithMessage("AMOUNT_IS_NOT_ENOUGH".localizedNew)
                return
            }
            
            if SMUserManager.pin != nil, SMUserManager.pin == true {
                //show get pin popup
                SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: "enterpin".localized, yesPressed: { pin in
                    //                        self.gotoLoadingState()
                    if isTaxi {
                        if isUser {
                            self.qrCode?.removeAll()
                            
                        }
                        SMCard.initPayment(amount: Int(tmp1), accountId: self.targetAccountId, transportId : self.transportId, qrCode: self.qrCode, discount_price : "0", isCredit: true, transaction_type: 1, hyperme_invoice_number: nil, onSuccess: { response in
                            
                            let json = response as? Dictionary<String, AnyObject>
                            SMUserManager.publicKey = json?["pub_key"] as? String
                            SMUserManager.payToken = json?["token"] as? String
                            
                            
                            for card in self.userCards! {
                                if card.type == 1 {
                                    let para  = NSMutableDictionary()
                                    para.setValue(card.token, forKey: "c")
                                    para.setValue((pin as! String).onlyDigitChars(), forKey: "p2")
                                    para.setValue(card.type, forKey: "type")
                                    para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
                                    para.setValue(card.bankCode, forKey: "bc")
                                    
                                    let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
                                    let jsonString = String(data: jsonData, encoding: .utf8)
                                    
                                    if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey) {
                                        //                                            self.popup.endEditing(true)
                                        //                                    self.showReciept(response: NSDictionary())
                                        SMCard.payPayment(enc: enc, enc2: nil, onSuccess: { resp in
                                            
                                            //                                                self.gotobuttonState()
                                            if let result = resp as? NSDictionary{
                                                
                                                SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                                            }
                                        }, onFailed: {err in
                                            SMLog.SMPrint(err)
                                            
                                            if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
                                                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
                                            }
                                            //                                                self.gotobuttonState()
                                        })
                                    }
                                    
                                }
                            }
                            
                            
                        }, onFailed: { (err) in
                            self.dismiss(animated: true, completion: nil)
                            //                                }
                        })
                    }
                    else {
                        
                        self.qrCode = merchantID
                        let tmp = self.qrCode
                        SMCard.initPayment(amount: Int(tmp1), accountId: self.targetAccountId, transportId : self.transportId, qrCode: self.qrCode, discount_price : "0", isCredit: true, transaction_type: 1, hyperme_invoice_number: nil, onSuccess: { response in
                            
                            let json = response as? Dictionary<String, AnyObject>
                            SMUserManager.publicKey = json?["pub_key"] as? String
                            SMUserManager.payToken = json?["token"] as? String
                            
                            
                            for card in self.userCards! {
                                if card.type == 1 {
                                    
                                    let para  = NSMutableDictionary()
                                    
                                    para.setValue(card.token, forKey: "c")
                                    para.setValue((pin as! String).onlyDigitChars(), forKey: "p2")
                                    para.setValue(card.type, forKey: "type")
                                    para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
                                    para.setValue(card.bankCode, forKey: "bc")
                                    
                                    let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
                                    let jsonString = String(data: jsonData, encoding: .utf8)
                                    
                                    if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey) {
                                        //                                        self.popup.endEditing(true)
                                        //                                    self.showReciept(response: NSDictionary())
                                        SMCard.payPayment(enc: enc, enc2: nil, onSuccess: {resp in
                                            
                                            if let result = resp as? NSDictionary{
                                                
                                                SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                                            }
                                        }, onFailed: {err in
                                            SMLoading.hideLoadingPage()
                                            
                                        })
                                    }
                                }
                                else {
                                    
                                }
                            }
                        }, onFailed: {err in
                            SMLog.SMPrint(err)
                            
                            SMLoading.hideLoadingPage()
                            //                                if (err as! Dictionary<String, AnyObject>)["message"] != nil {
                            //                                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["message"]! as! String).localized)
                            //                                } else if (err as! Dictionary<String, AnyObject>)["server serror"] != nil {
                            //                                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "serverDown".localized)
                            //                                }
                            //                                if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
                            //                                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
                            //                                }
                        })
                    }
                    
                }, noPressed: { value in
                    
                })
            }
                
            else {
            }
            
        }
        else if segmentPick.selectedSegmentIndex == 1 {
            //pay by card
            SMLoading.showLoadingPage(viewcontroller: self)
            SMCard.initPayment(amount: Int((self.tfAmountToPy.text?.inEnglishNumbers().onlyDigitChars())!), accountId: self.targetAccountId,from : merchantID, transportId: self.transportId, qrCode: "", discount_price: "0", onSuccess: { response in
                
                
                SMLoading.hideLoadingPage()
                let json = response as? Dictionary<String, AnyObject>
                if let ipg = json?["ipg_url"] as? String ,ipg != "" {
                    if let url = URL(string: ipg) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                else{
                }
            }, onFailed: {err in
                SMLoading.hideLoadingPage()
                SMLog.SMPrint(err)
            })
        }
    }
    //touch handler
    
    //call merchants cards available list for pay
    
    func GetMutualClubList(MerchantCode: String, UserCode: String, completed: @escaping ([Any])->()) {
        
        self.qrCode = MerchantCode.inEnglishNumbers()
        SMLoading.showLoadingPage(viewcontroller: self, text: "loading.text".localized)
        let request = WS_methods(delegate: self, failedDialog: true)
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? NSArray { // here check for mututal club
                
                SMLoading.hideLoadingPage()
                completed(jsonResult as! [Any])
                
            }
            
        }
        request.addFailedHandler { (response: Any) in
            
            SMLoading.hideLoadingPage()
//            self.reader.startScanning()
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "serverDown".localized)
            } else if (response as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((response as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
            }
        }
        
        request.pc_availablelistcard(MerchantCode.inEnglishNumbers(), userID: UserCode.inEnglishNumbers())
    }
    func handleUIChange() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    /// Change position of popup by keyboard size
    func refreshPopupPosition(){
        print(keyBoardIsOpen)
        if !keyBoardIsOpen {
            verticalConstraints.constant += (keyboardHeight!)
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        refreshPopupPosition()
        keyBoardIsOpen = true
        
        self.view.layoutIfNeeded()
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        keyBoardIsOpen = false
        
        verticalConstraints.constant = 0
        self.view.layoutIfNeeded()
        
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        textField.text = textField.text?.inLocalizedLanguage()
        if let amountString = textField.text?.currencyFormat() {
            
            textField.text = amountString.trimmingCharacters(in: .whitespaces)
            
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newStr = string
        
        newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
        textField.text = newStr == "" ? "" : newStr.onlyDigitChars().inRialFormat().inLocalizedLanguage()
        
        if string == "" && range.location < textField.text!.length{
            let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        if newStr.length > 8 {
            
            self.tfAmountToPy.text = "30000000".currencyFormat().inLocalizedLanguage()
        }
        return false
    }
}
