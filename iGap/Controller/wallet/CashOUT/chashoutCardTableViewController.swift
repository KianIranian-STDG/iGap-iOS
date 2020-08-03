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
import models


class chashoutCardTableViewController: BaseTableViewController,UITextFieldDelegate,HandleReciept {
    @IBOutlet weak var btnpay: UIButtonX!
    @IBOutlet weak var cashoutTypeSeg: UISegmentedControl!
    @IBOutlet weak var widthConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var btnGetIban: UIButtonX!
    @IBOutlet weak var tfAmount: customUITextField!
    @IBOutlet weak var tfCardNumber: UITextField!
    @IBOutlet weak var lblWalletAmountBalance: UILabel!
    @IBOutlet weak var lblCashableAmountBalance: UILabel!
    @IBOutlet weak var lblWalletAccountBalanceTitle: UILabel!
    @IBOutlet weak var lblCashableAmountBalanceTitle: UILabel!
    @IBOutlet weak var lblCashoutPriceHeader: UILabel!
    @IBOutlet weak var lblEnterCardNUmberHeader: UILabel!
    var presenter: Presentr?
    var selectCard : SMCashout?
    var tmpCardToken : String? = ""
    var cardToken : String? = ""
    var merchant : SMMerchant!
    var sourceCard: SMCard!
    var balance = "0".inLocalizedLanguage()
    var finishDelegate : HandleDefaultCard?
    var isImmediate = true
    var isToWallet = false
    override func viewDidLoad() {
        super.viewDidLoad()
//        tfAmount.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        tfCardNumber.delegate = self
        tfAmount.delegate = self
        self.hideKeyboardWhenTappedAround()
        initNavigationBar()
        initDelegates ()
        initView()
        if currentRole == "admin" {
            getMerChantCards()
        }
        initTheme()
    }
    private func initTheme() {
        self.lblCashoutPriceHeader.textColor = ThemeManager.currentTheme.LabelColor
        self.lblWalletAmountBalance.textColor = ThemeManager.currentTheme.LabelColor
        self.lblCashableAmountBalance.textColor = ThemeManager.currentTheme.LabelColor
        self.lblEnterCardNUmberHeader.textColor = ThemeManager.currentTheme.LabelColor
        self.lblWalletAccountBalanceTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblCashableAmountBalanceTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.btnpay.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        self.btnGetIban.setTitleColor(ThemeManager.currentTheme.SliderTintColor, for: .normal)
        
        tfAmount.backgroundColor = .clear
        tfAmount.layer.borderWidth = 1.0
        tfAmount.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tfAmount.placeHolderColor = ThemeManager.currentTheme.LabelGrayColor
        tfAmount.layer.cornerRadius = 10
        tfAmount.textColor = ThemeManager.currentTheme.LabelColor

        tfCardNumber.backgroundColor = .clear
        tfCardNumber.layer.borderWidth = 1.0
        tfCardNumber.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tfCardNumber.placeHolderColor = ThemeManager.currentTheme.LabelGrayColor
        tfCardNumber.layer.cornerRadius = 10
        tfCardNumber.textColor = ThemeManager.currentTheme.LabelColor
        
        self.cashoutTypeSeg.backgroundColor = ThemeManager.currentTheme.TableViewCellColor.darker(by: 20)

    }
    func getMerChantCards(){
        SMLoading.showLoadingPage(viewcontroller: self)
        
        DispatchQueue.main.async {
            SMCard.getMerchatnCardsFromServer(accountId: merchantID, { (value) in
                if let card = value {
                    self.sourceCard = card as? SMCard
                    self.prepareMerChantCard()
                }
            }, onFailed: { (value) in
                // think about it
            })
        }
    }
    
    func prepareMerChantCard() {
        SMLoading.hideLoadingPage()
        if let card = sourceCard {
            if card.type == 1 {
                //                amountLbl.isHidden = false
                
                cardToken = card.token!
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 17)]
        cashoutTypeSeg.setTitleTextAttributes((font as! [NSAttributedString.Key : Any]), for: .normal)
        if currentRole != "admin" {
            self.cashoutTypeSeg.removeSegment(at: 2, animated: true)
        }
        initChangeLang()
        initChangeDirection()
    }
    func initChangeLang() {
        lblCashoutPriceHeader.text = IGStringsManager.EnterCashoutAmount.rawValue.localized
        lblEnterCardNUmberHeader.text = IGStringsManager.EnterYourCardNumber.rawValue.localized
        lblWalletAccountBalanceTitle.text = IGStringsManager.WalletBalance.rawValue.localized
        lblCashableAmountBalanceTitle.text = IGStringsManager.CashablePrice.rawValue.localized
        cashoutTypeSeg.setTitle(IGStringsManager.ImmidiateCashout.rawValue.localized, forSegmentAt: 0)
        cashoutTypeSeg.setTitle(IGStringsManager.NormalCashout.rawValue.localized, forSegmentAt: 1)
        if currentRole == "admin" {
            cashoutTypeSeg.setTitle(IGStringsManager.ToWallet.rawValue.localized, forSegmentAt: 2)
        }
        btnGetIban.setTitle(IGStringsManager.HowToGetIBAN.rawValue.localized, for: .normal)
        btnpay.setTitle(IGStringsManager.Cashout.rawValue.localized, for: .normal)

    }
    func initChangeDirection() {
        lblWalletAccountBalanceTitle.textAlignment = lblWalletAccountBalanceTitle.localizedDirection
        lblCashableAmountBalanceTitle.textAlignment = lblWalletAccountBalanceTitle.localizedDirection
    }
    @IBAction func cardPickTap(_ sender: Any) {
        tmpCardToken = ""
        SMLoading.shared.showSavedCardDialog(viewController: self, icon: nil, title: IGStringsManager.MyCards.rawValue.localized, cards: SMCashout.getAllCardsFromDB(),yesPressed: { card, saveDefault in
            self.selectCard = (card as! SMCashout)
            print("CARDS IN DB:")
            print(SMCashout.getAllCardsFromDB())
            if let pan = self.selectCard?.pan {
                
                let newStr = pan
                self.tfCardNumber.text = SMStringUtil.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()
                self.tfCardNumber.font = UIFont.igFont(ofSize: 15)
            }
            if let cardToken = self.selectCard?.token! {
                self.tmpCardToken = cardToken
            }
        },noPressed: {
            
        })
        
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.Cashout.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    func initView() {
        tfCardNumber.placeholder = IGStringsManager.PlaceHolder16.rawValue.localized
        self.tfAmount.placeholder = IGStringsManager.AmountPlaceHolder.rawValue.localized
        self.lblWalletAmountBalance.text = balance + " " + IGStringsManager.Currency.rawValue.localized
        self.lblCashableAmountBalance.text = balance + " " + IGStringsManager.Currency.rawValue.localized
        if currentRole == "admin" {
            widthConstrait.constant = 0
            
        }
        else {
            widthConstrait.constant = 0

        }
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
        
        
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "cashoutModalStepOne") as! cashoutModalStepOneViewController? {
            presentedViewController.dialogT = IGStringsManager.CashoutRequest.rawValue.localized
            presentedViewController.amount = amount!.inEnglishNumbersNew()
            presentedViewController.message = resp
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            self.present(presentedViewController, animated: true, completion: nil)
        }
    }
    
    func showInputPinDialog(viewController:UIViewController, icon:UIImage?, title:String, message:String, yesPressed: CallBack? = nil, noPressed: CallBack? = nil, forgotPin: SimpleCallBack? = nil){
        
        let alertView : SMTextFieldAlertViewController! = storyboard?.instantiateViewController(withIdentifier: "textalert") as! SMTextFieldAlertViewController?

        alertView.title = title
        alertView.message = message
        
        alertView.leftButtonTitle = IGStringsManager.GlobalNo.rawValue.localized
        alertView.leftButtonAction = noPressed
        
        alertView.rightButtonTitle = IGStringsManager.GlobalYes.rawValue.localized
        alertView.rightButtonAction = yesPressed
        alertView.forgotButtonTitle = IGStringsManager.ResetWalletPin.rawValue.localized
        alertView.forgotPinAction = forgotPin
        
        
        alertView.modalPresentationStyle = .overCurrentContext
        self.present(alertView, animated: true , completion: {
            alertView.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    public func showNormalDialog(viewController:UIViewController, height: Float ,isleftButtonEnabled : Bool? = true ,title:String? ,message:String? ,leftButtonTitle : String? = IGStringsManager.GlobalNo.rawValue.localized ,rightButtonTitle :String? = IGStringsManager.GlobalYes.rawValue.localized , yesPressed: CallBack? = nil, noPressed: SimpleCallBack? = nil){
        
        let alertView : SMNormalAlertViewController! = storyboard?.instantiateViewController(withIdentifier: "normalalert") as! SMNormalAlertViewController?
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
    
    func payNormal(amountStr:String? , cardNumber : String? = "" ,cardToken : String? = "") {
        
        guard let amount = Int(amountStr!.onlyDigitChars()) else {
            return
        }
        
        
        
            let accountId = merchantID
//            gotoLoadingState()
        
        
        if cashoutTypeSeg.selectedSegmentIndex == 0 {
        
            guard (cardNumber?.onlyDigitChars()) != nil else {
                return
            }
            SMCard.confirmChashout(amount: amount,
                                   cardNumber: (self.tfCardNumber.text?.removeSepratorCardNum().inEnglishNumbersNew()),
                                   cardToken:  cardToken,
                                   accountId: accountId , onSuccess: {resp in
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        self.showConfirmDialog(resp: resp, amount: amountStr)
                                    })
                                    SMLog.SMPrint(resp)
                                    
            }, onFailed: {err in
                //?
                if SMValidation.showConnectionErrorToast(err)  {
                    SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
                }
                let message = (err as! NSDictionary).value(forKey: "message") as! String
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: message)


                
                
            })
        }
        else if cashoutTypeSeg.selectedSegmentIndex == 1 {
            var sourceCardToken  = ""
            if self.sourceCard != nil { sourceCardToken = self.sourceCard.token! } else { sourceCardToken = SMUserManager.payGearToken! }
            guard let cardNu = cardNumber?.inEnglishNumbersNew() else {
                return
            }

            SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: IGStringsManager.EnterWalletPin.rawValue.localized, yesPressed: { pin in
//                self.gotoLoadingState()
                SMLoading.showLoadingPage(viewcontroller: self)
                if currentRole == "admin" {
                    
                }
                SMCard.chashout(amount: amount , cardNumber:  cardNu, cardToken: "",sourceCardToken: sourceCardToken, pin: (pin as? String) ,isFast : false, accountId: accountId ,onSuccess: {resp in
                    
                    SMLoading.shared.showNormalDialog(viewController: self, height: 180,isleftButtonEnabled: false, title: IGStringsManager.GlobalSuccess.rawValue.localized , message: IGStringsManager.SuccessOperation.rawValue.localized, yesPressed: { pin in
                        
                
                        
                        self.finishDelegate?.finishDefault(isPaygear: true, isCard: false)
                        self.navigationController!.popToRootViewController(animated: true)
                        
                    })
                    SMLog.SMPrint(resp)
                }, onFailed: {err in
                    
                    SMLoading.hideLoadingPage()
                    let message = (err as! NSDictionary).value(forKey: "message") as! String
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: message)

                    
                })
                
            }, noPressed: { value in
                
            }, forgotPin: {
                let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)

                let walletSettingPage = (storyboard.instantiateViewController(withIdentifier: "walletSettingPage") as! IGWalletSettingTableViewController)
                walletSettingPage.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(walletSettingPage, animated: true)            })
            
        }
        else {
            //show get pin popup
            SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: IGStringsManager.EnterWalletPin.rawValue.localized, yesPressed: { pin in
                
//                self.gotoLoadingState()
                SMLoading.showLoadingPage(viewcontroller: self)

                SMCard.initPayment(amount: amount, accountId: SMUserManager.accountId, from: merchantID, orderType: ORDER_TYPE.P2P, discount_price: nil, isCredit: true, onSuccess: { response in
                    SMLoading.hideLoadingPage()

                    let json = response as? Dictionary<String, AnyObject>
                    SMUserManager.publicKey = json?["pub_key"] as? String
                    SMUserManager.payToken = json?["token"] as? String
                    
                    

                    if let card = self.sourceCard {
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
                                //self.popup.endEditing(true)
                                //self.showReciept(response: NSDictionary())
                                SMCard.payPayment(enc: enc, enc2: nil, onSuccess: {resp in
                                    
                                    if let result = resp as? NSDictionary{
                                        
                                        SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                                    }
                                }, onFailed: {err in
                                    let message = (err as! NSDictionary).value(forKey: "message") as! String
                                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: message)

                                    SMLoading.hideLoadingPage()
                                    
                                })
                                
                            }

                            
                        }
                    }

                }, onFailed: { (err) in
                    SMLog.SMPrint(err)
                    let message = (err as! NSDictionary).value(forKey: "message") as! String
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: message)

                })
                
                
                
            }, forgotPin: {
                
                let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)
                
                let walletSettingPage = (storyboard.instantiateViewController(withIdentifier: "walletSettingPage") as! IGWalletSettingTableViewController)
                walletSettingPage.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(walletSettingPage, animated: true)            })
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
    ///Handle reciept
    func close() {
        
        self.dismiss(animated: true, completion: {
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        })
    }
    
    func screenView() {
        close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            SMReciept.getInstance().screenReciept(viewcontroller: self)
        }
    }
    //Mark: Actions
    @IBAction func btnPayTap(_ sender: Any) {
        if currentRole != "admin" {
            if tfAmount.text == nil || tfCardNumber.text == nil || tfAmount.text == "" || tfCardNumber.text == "" {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalCheckFields.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                
            }
            else {
                let amount : Int! =  Int((tfAmount.text!.onlyDigitChars()).inEnglishNumbersNew())
                if amount <= Int(SMUserManager.userBalance) {
                    if currentRole == "admin" {
                        self.tmpCardToken = ""
                    }
                    if isReadyToPay(isImmediate: isImmediate, cardNum: (tfCardNumber.text!).inEnglishNumbersNew(), amount: (tfAmount.text!).inEnglishNumbersNew().onlyDigitChars()) {
                        payNormal(amountStr: (tfAmount.text!).inEnglishNumbersNew().onlyDigitChars(), cardNumber: (tfCardNumber.text!).inEnglishNumbersNew(),cardToken: self.tmpCardToken)
                    }
                    else {
                        SMLoading.showToast(viewcontroller: self, text: IGStringsManager.GlobalCheckFields.rawValue.localized)
                    }
                    
                }
                else {
                    SMMessage.showWithMessage(IGStringsManager.LowWalletbalance.rawValue.localized)
                }
                
            }
            
        }else {

            if tfAmount.text == nil || tfAmount.text == ""  {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalCheckFields.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            }
            else {
                let amount : Int! =  Int((tfAmount.text!.onlyDigitChars()).inEnglishNumbersNew())
                if amount <= Int(SMUserManager.userBalance) {
                    if currentRole == "admin" {
                        payNormal(amountStr: (tfAmount.text!.onlyDigitChars()).inEnglishNumbersNew(), cardNumber: self.tfCardNumber.text?.inEnglishNumbersNew() ,cardToken: self.tmpCardToken)

                    }
                    else {
                        if isReadyToPay(isImmediate: isImmediate, cardNum: (tfCardNumber.text!).inEnglishNumbersNew(), amount: (tfAmount.text!.onlyDigitChars()).inEnglishNumbersNew()) {
                            payNormal(amountStr: (tfAmount.text!.onlyDigitChars()).inEnglishNumbersNew(), cardNumber: (tfCardNumber.text!).inEnglishNumbersNew(),cardToken: self.tmpCardToken)
                        }
                        else {
                            SMLoading.showToast(viewcontroller: self, text: IGStringsManager.GlobalCheckFields.rawValue.localized)
                        }
                    }

                    
                }
                else {
                    SMMessage.showWithMessage(IGStringsManager.LowWalletbalance.rawValue.localized)
                }
                
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
            if currentRole == "admin" {
                widthConstrait.constant = 0
                
            }
            else {
                widthConstrait.constant = 0

            }
            self.loadViewIfNeeded()
            tfCardNumber.placeholder = IGStringsManager.PlaceHolder16.rawValue.localized
            lblEnterCardNUmberHeader.text = IGStringsManager.EnterYourCardNumber.rawValue.localized

            isImmediate = true
            isToWallet = false
            clearUI()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()

        }
        else if sender.selectedSegmentIndex == 1  {
            if currentRole == "admin" {
                widthConstrait.constant = 0

            }
            else {
                widthConstrait.constant = 0

            }
            widthConstrait.constant = 0
            self.loadViewIfNeeded()
            tfCardNumber.placeholder = IGStringsManager.PlaceHolder24.rawValue.localized
            lblEnterCardNUmberHeader.text = IGStringsManager.EnterIbanNumber.rawValue.localized

            isImmediate = false
            isToWallet = false

            clearUI()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        else {
            self.loadViewIfNeeded()
            if currentRole == "admin" {
                widthConstrait.constant = 0
                
            }
            else {
                widthConstrait.constant = 0
                
            }
            isImmediate = false
            isToWallet = true

            clearUI()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()

        }
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) 
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
            if currentRole != "admin" {
                
                return 36

            }else {
                if !isToWallet {
                    return 36

                }
                else {
                    return 0

                }

            }
        }
        if cell.tag == 5 {
            if currentRole != "admin" {
                return 64

            }else {
                if !isToWallet {
                    return 64

                }
                else {
                    return 0
                    
                }
            }
        }
        if cell.tag == 6 {
            return 64
        }
        if cell.tag == 7 {
            if isImmediate {
                return 0
            }
            else {
                if currentRole != "admin" {
                    return 64
                    
                }else {
                    if !isToWallet {
                        return 64

                    }
                    else {
                        return 0
                        
                    }
                }
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

           
                newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars().inLocalizedLanguage()
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
                                
                newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).trimmingCharacters(in: .whitespaces).inEnglishNumbersNew().currencyFormat()
                textField.text = newStr == "" ? "" : newStr.trimmingCharacters(in: .whitespaces).inEnglishNumbersNew().currencyFormat()
                
                if string == "" && range.location < textField.text!.length{
                    let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                    textField.selectedTextRange = textField.textRange(from: position, to: position)
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
