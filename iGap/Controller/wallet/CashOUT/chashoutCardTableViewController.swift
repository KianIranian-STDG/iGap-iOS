//
//  chashoutCardTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import Presentr


class chashoutCardTableViewController: UITableViewController,UITextFieldDelegate {
    @IBOutlet weak var cashoutTypeSeg: UISegmentedControl!
    @IBOutlet weak var widthConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var tfCardNumber: UITextField!
    @IBOutlet weak var lblWalletAmountBalance: UILabel!
    @IBOutlet weak var lblCashableAmountBalance: UILabel!
    var presenter: Presentr?
    var selectCard : SMCashout?

    var merchant : SMMerchant!
    var sourceCard: SMCard!
    var balance = "0".inLocalizedLanguage()
    var finishDelegate : HandleDefaultCard?
    var isImmediate = true
    override func viewDidLoad() {
        super.viewDidLoad()
        tfAmount.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        tfCardNumber.delegate = self
        tfAmount.delegate = self
        self.hideKeyboardWhenTappedAround()
        initNavigationBar()
        initDelegates ()
        initView()
    }
    @IBAction func cardPickTap(_ sender: Any) {

        SMLoading.shared.showSavedCardDialog(viewController: self, icon: nil, title: "SAVED_CARDS".localizedNew, cards: SMCashout.getAllCardsFromDB(),yesPressed: { card, saveDefault in
            self.selectCard = (card as! SMCashout)
            if let pan = self.selectCard?.pan {
                
                let newStr = pan
                self.tfCardNumber.text = SMStringUtil.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()
                self.tfCardNumber.font = UIFont.igFont(ofSize: 15)
            }
        },noPressed: {
            
        })
        
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Cashout")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    func initView() {
        self.lblWalletAmountBalance.text = balance + " " + "CURRENCY".localizedNew
        self.lblCashableAmountBalance.text = balance + " " + "CURRENCY".localizedNew
    }
    func initDelegates () {
        self.tfAmount.delegate = self
        self.tfCardNumber.delegate = self
    }
    // MARK: - UI Based Funcs
    func clearUI() {
        self.tfCardNumber.text = nil
        self.tfAmount.text = nil
    }
    func showConfirmDialog(resp : Any?,amount: String?){
        
        
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "cashoutModalStepOne") as! cashoutModalStepOneViewController! {
            presentedViewController.dialogT = "CASHOUT_REQUEST".localizedNew
            presentedViewController.amount = amount
            presentedViewController.message = resp
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            self.present(presentedViewController, animated: true, completion: nil)
        }
    }
    
    func showInputPinDialog(viewController:UIViewController, icon:UIImage?, title:String, message:String, yesPressed: CallBack? = nil, noPressed: CallBack? = nil, forgotPin: SimpleCallBack? = nil){
        
        let alertView : SMTextFieldAlertViewController! = storyboard?.instantiateViewController(withIdentifier: "textalert") as! SMTextFieldAlertViewController!

        alertView.title = title
        alertView.message = message
        
        alertView.leftButtonTitle = "GLOBAL_NO".localizedNew
        alertView.leftButtonAction = noPressed
        
        alertView.rightButtonTitle = "GLOBAL_YES".localizedNew
        alertView.rightButtonAction = yesPressed
        alertView.forgotButtonTitle = "FORGET_WALLET_PIN".localizedNew
        alertView.forgotPinAction = forgotPin
        
        
        alertView.modalPresentationStyle = .overCurrentContext
        self.present(alertView, animated: true , completion: {
            alertView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    public func showNormalDialog(viewController:UIViewController, height: Float ,isleftButtonEnabled : Bool? = true ,title:String? ,message:String? ,leftButtonTitle : String? = "GLOBAL_NO".localizedNew ,rightButtonTitle :String? = "GLOBAL_YES".localizedNew , yesPressed: CallBack? = nil, noPressed: SimpleCallBack? = nil){
        
        let alertView : SMNormalAlertViewController! = storyboard?.instantiateViewController(withIdentifier: "normalalert") as! SMNormalAlertViewController!
        alertView.dialogT = title
        alertView.leftButtonEnable = isleftButtonEnabled
        
        alertView.message = message
        
        alertView.leftButtonTitle = leftButtonTitle
        alertView.leftButtonAction = noPressed
        
        alertView.rightButtonTitle = rightButtonTitle
        alertView.rightButtonAction = yesPressed
        
        
        let customType = PresentationType.custom(width: ModalSize.custom(size: 285), height: ModalSize.custom(size: height), center: ModalCenterPosition.center)
        self.presenter = Presentr(presentationType: customType)
        self.presenter?.dismissOnSwipe = false
        viewController.customPresentViewController(self.presenter!, viewController: alertView, animated: true, completion: nil)
        
    }
    
    func payNormal(amountStr:String? , cardNumber : String?) {
        
        guard let amount = Int(amountStr!.onlyDigitChars()) else {
            return
        }
        
        
        
            let accountId = (merchant != nil) ? merchant.id : SMUserManager.accountId
//            gotoLoadingState()
        
        
        if cashoutTypeSeg.selectedSegmentIndex == 0 {
        
            guard let cardNu = cardNumber?.onlyDigitChars() else {
                return
            }
            SMCard.confirmChashout(amount: amount,
                                   cardNumber: (cardNumber?.removeSepratorCardNum()),
                                   cardToken:  "",
                                   accountId: accountId , onSuccess: {resp in
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        self.showConfirmDialog(resp: resp, amount: amountStr)
                                    })
                                    SMLog.SMPrint(resp)
                                    
            }, onFailed: {err in
                //?
                if SMValidation.showConnectionErrorToast(err)  {
                    SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
                }

                
                
            })
        }
        else {
            var sourceCardToken  = ""
            if self.sourceCard != nil { sourceCardToken = self.sourceCard.token! } else { sourceCardToken = SMUserManager.payGearToken! }
            guard let cardNu = cardNumber?.inEnglishNumbers() else {
                return
            }

            SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: "ENTER_WALLET_PIN".localizedNew, yesPressed: { pin in
//                self.gotoLoadingState()
                SMLoading.showLoadingPage(viewcontroller: self)
                SMCard.chashout(amount: amount , cardNumber:  cardNu, cardToken: "",sourceCardToken: sourceCardToken, pin: (pin as? String) ,isFast : false, accountId: accountId ,onSuccess: {resp in
                    
                    SMLoading.shared.showNormalDialog(viewController: self, height: 180,isleftButtonEnabled: false, title: "SUCCESS_OPERATION".localizedNew, message: "SUCCESS".localizedNew, yesPressed: { pin in
                        
                
                        
                        self.finishDelegate?.finishDefault(isPaygear: true, isCard: false)
                        self.navigationController!.popToRootViewController(animated: true)
                        
                    })
                    SMLog.SMPrint(resp)
                }, onFailed: {err in
                    SMLoading.hideLoadingPage()
                    
                })
                
            }, noPressed: { value in
                
            }, forgotPin: {
                let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)

                let walletSettingPage : IGWalletSettingTableViewController? = storyboard.instantiateViewController(withIdentifier: "walletSettingPage") as! IGWalletSettingTableViewController
                self.navigationController!.pushViewController(walletSettingPage!, animated: true)            })
            
        }
    }
    
    

    
    func gotoLoadingState(){
        self.view.endEditing(true)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      
            return 8
    }
    //Mark: Actions
    @IBAction func btnPayTap(_ sender: Any) {
        if tfAmount.text == nil || tfCardNumber.text == nil || tfAmount.text == "" || tfCardNumber.text == "" {
            
        }
        else {
            let amount : Int! =  Int(tfAmount.text!.onlyDigitChars())
            if amount <= Int(SMUserManager.userBalance) {
                if isReadyToPay(isImmediate: isImmediate, cardNum: tfCardNumber.text!, amount: tfAmount.text!) {
                    payNormal(amountStr: tfAmount.text!, cardNumber: tfCardNumber.text!)
                }
                else {
                    SMLoading.showToast(viewcontroller: self, text: "CHECK_ALL_FIELDS".localizedNew)
                }
                
            }
            else {
                SMMessage.showWithMessage("BALANCE_NOT_ENOUGH".localizedNew)
            }
            
        }
      
    }
    
    func isReadyToPay(isImmediate: Bool ,cardNum: String , amount : String) -> Bool {
        if isImmediate {
            if (cardNum.removeSepratorCardNum().count == 16 ) && (amount.onlyDigitChars().count < 9) {
                return true
            }
            else {
                return false
            }
        }
        else {
            if (cardNum.removeSepratorCardNum().count == 26 ) && (amount.onlyDigitChars().count < 9) {
                return true
            }
            else {
                return false
            }
        }

    }
    @IBAction func btnIbanGuidTap(_ sender: Any) {
        
        UIApplication.shared.open(URL(string : "https://paygear.ir/iban")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (status) in
            
        })
        
    }
    @IBAction func segmentTap(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            widthConstrait.constant = 46
            self.loadViewIfNeeded()

            tfCardNumber.placeholder = "16 Digit Card Number"
            isImmediate = true
            clearUI()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()

        }
        else {
            
            widthConstrait.constant = 0
            self.loadViewIfNeeded()
            tfCardNumber.placeholder = "24 Digit IBAN Number"
            isImmediate = false
            clearUI()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewCell
        if cell.tag == 0 {
            return 60
        }
        if cell.tag == 1 {
            return 84
        }
        if cell.tag == 2 {
            return 36
        }
        if cell.tag == 3 {
            return 64
        }
        if cell.tag == 4 {
            return 36
        }
        if cell.tag == 5 {
            return 64
        }
        if cell.tag == 6 {
            return 64
        }
        if cell.tag == 7 {
            if isImmediate {
                return 0
            }
            else {
                return 64
            }
        }
        else {
            return 60
        }
    }

    

    //Mark: TextField delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newStr = string
        
        if textField.tag == 0 {
            
            if isImmediate {

           
                newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
                textField.text = CardUtils.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-")
                
                if string == "" && range.location < textField.text!.length {
                    let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                    textField.selectedTextRange = textField.textRange(from: position, to: position)
                }
            }
            else {
                
                newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
                textField.text =  "IR" + CardUtils.separateFormat(newStr, separators: [24], delimiter: "")
                
            }

        }
        else if textField.tag == 1 {
            let minLength = 8
            
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            textField.text = newStr == "" ? "" : newStr.onlyDigitChars().inRialFormat().inEnglishNumbers()
            
            if string == "" && range.location < textField.text!.length{
                let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
            if isImmediate {
                if newStr.length > 8 {
                    
                    self.tfAmount.text = "30000000".currencyFormat()
                }
            }
            else {
                if newStr.length > 9 {
                    
                    self.tfAmount.text = "150000000".currencyFormat()
                }
            }
           
        }

        return false
    }

    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
      
        if let string = tfAmount.text {
            let amount = string.RemoveingCurrencyFormat()
            if let intAmount = Int64(amount) {
                if cashoutTypeSeg.selectedSegmentIndex == 0 {
                    if intAmount > 30000000 {
                        
                        tfAmount.text = "30000000".currencyFormat()
                        return
                    }

                }
                else {
                    if intAmount > 150000000 {
                        
                        tfAmount.text = "150000000".currencyFormat()
                        return
                    }

                }
                
            }
            
            
        }
        
    }

}
