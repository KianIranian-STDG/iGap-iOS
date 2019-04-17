//
//  walletModalViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import webservice

class walletModalViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var verticalConstraints: NSLayoutConstraint!
    @IBOutlet weak var imgProfile: UIImageViewX!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var mainView: UIViewX!
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var segmentPick: UISegmentedControl!
    private var userCards: [SMCard]?
    private var targetAccountId: String!
    private var transportId : String?
    var keyboardHeight : CGFloat?
    var keyBoardIsOpen = false

    public var type: Int = 2
    
    
    
    /// Dictionary contains name, productName, subTitle, price, imagePath
    var value: [String: String]!{
        didSet {
            print(value)
            if type == 0 {
                
                
                
            }
            else if type == 1 {
                
                
            }
            else if type == 2 {
                lblDescription.text = name
                
                if let price = price {
                    tfAmount.text = price as String
                    tfAmount.isEnabled = false
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
 
        self.userCards = SMCard.getAllCardsFromDB()

        initView()
        handleUIChange()
        // Do any additional setup after loading the view.
    }
    func initView() {
        self.hideKeyboardWhenTappedAround()

//        tfAmount.inputView =  LNNumberpad.default()
        self.tfAmount.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)

        profilePicUrl = UserDefaults.standard.string(forKey: "modalUserPic")
        name = UserDefaults.standard.string(forKey: "modalUserName")
        currentAmount = UserDefaults.standard.string(forKey: "modalUserAmount")
        transportId = UserDefaults.standard.string(forKey: "modalTrasnportID")
        targetAccountId = UserDefaults.standard.string(forKey: "modalTargetAccountID")
        qrCode = UserDefaults.standard.string(forKey: "modalQRCode")

        print(name)


            if type == 2 {
                
                lblDescription.text = name
                
                if let price = price {
                    tfAmount.text = price as String
                    tfAmount.isEnabled = false
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
            self.dismiss(animated: true)}
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func payBtnTap(_ sender: Any) {
        
        if self.tfAmount.text == "" ||
            self.tfAmount.text?.inEnglishNumbers() == "0" {
            SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "GLOBAL_WARNING".localizedNew, message: "FILL_AMOUNT".localized, leftButtonTitle: "", rightButtonTitle: "GLOBAL_OK".localizedNew,yesPressed: { yes in return;})
        }
            
        else {
            
            //popup.confirmBtn.gotoLoadingState()
            if segmentPick.selectedSegmentIndex == 0 {
                
                if Int(self.tfAmount.text!.onlyDigitChars())! > Int(self.currentAmount.onlyDigitChars())! {
                    //show message about your amount is not enough
                    SMMessage.showWithMessage("AMOUNT_IS_NOT_ENOUGH".localizedNew)
                    return
                }
                
                if SMUserManager.pin != nil, SMUserManager.pin == true {
                    
                    //show get pin popup
                    SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: "enterpin".localized, yesPressed: { pin in
                        
//                        self.gotoLoadingState()
                        
                        SMCard.initPayment(amount: Int(self.tfAmount.text!.onlyDigitChars()), accountId: self.targetAccountId, transportId : self.transportId, qrCode: self.qrCode , onSuccess: { response in
                            
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
                                        SMCard.payPayment(enc: enc, onSuccess: { resp in
                                            
//                                            self.gotobuttonState()
                                            if let result = resp as? NSDictionary{
                                                
                                                SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                                            }
                                        }, onFailed: {err in
                                            SMLog.SMPrint(err)
                                            
                                           
                                            
//                                            self.gotobuttonState()
                                        })
                                    }
                                }
                            }
                        }, onFailed: { (err) in
                            SMLog.SMPrint(err)
//                            self.gotobuttonState()
                        })
                        
                    }, noPressed: { value in
                        
                    })
                } else {
                    //show SMWalletPasswordViewController
//                    let viewController = SMWalletPasswordViewController(style: .grouped)
//                    SMMainTabBarController.qrTabNavigationController.pushViewController(viewController, animated: true)
                    //TODO: show modally and in dismiss action continue action
                }
            }
            else if segmentPick.selectedSegmentIndex == 1 {
                //pay by card
//                popup.endEditing(true)
                SMLoading.showLoadingPage(viewcontroller: self)
                SMCard.initPayment(amount: Int((self.tfAmount.text?.onlyDigitChars())!),accountId: self.targetAccountId, transportId: self.transportId, qrCode: self.qrCode, onSuccess: { response in
                    SMLoading.hideLoadingPage()
                    let json = response as? Dictionary<String, AnyObject>
                    if let ipg = json?["ipg_url"] as? String ,ipg != "" {
                        if let url = URL(string: ipg) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    }
                    else{
//                        SMUserManager.publicKey = json?["pub_key"] as? String
//                        SMUserManager.payToken = json?["token"] as? String
//                        let vc = SMNavigationController.shared.findViewController(page: .ChooseCard) as! SMChooseCardViewController
//                        vc.toAccountId = self.targetAccountId
//                        vc.amount = self.popup.amountTF.text!.onlyDigitChars()
//                        SMMainTabBarController.qrTabNavigationController.pushViewController(vc, animated: true)
                    }
                }, onFailed: {err in
                    SMLoading.hideLoadingPage()
                    SMLog.SMPrint(err)
                })
            }
        }
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
        
        if let amountString = textField.text?.currencyFormat() {
            
            textField.text = amountString.trimmingCharacters(in: .whitespaces)
            
        }
        
    }
}
