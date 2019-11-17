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
import webservice

class IGWalletSettingInnerTableViewController: BaseTableViewController , UITextFieldDelegate {

    var isOTP = false
    var isFirstTime = false
    var merchant: SMMerchant?
    var merchantCard: SMCard?
    var cardToken : String!
    @IBOutlet weak var tfFirst : customUITextField!
    @IBOutlet weak var tfSecond : customUITextField!
    @IBOutlet weak var tfThird : customUITextField!

    @IBOutlet weak var lblFirstRow: UILabel!
    @IBOutlet weak var lblSecondRow : UILabel!
    @IBOutlet weak var lblThirdRow : UILabel!
    @IBOutlet weak var btnSubmit : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        btnSubmit.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 17)
        if isOTP {
            initNavigationBar(title: IGStringsManager.ResetWalletPin.rawValue.localized)
            self.lblFirstRow.text = IGStringsManager.OTPCode.rawValue.localized
            self.tfFirst.placeholder = IGStringsManager.OTPCode.rawValue.localized
            self.lblSecondRow.text = IGStringsManager.NewPass.rawValue.localized
            self.lblThirdRow.text = IGStringsManager.RepeatPassCode.rawValue.localized
        }
        else {
            initNavigationBar(title: IGStringsManager.WalletPin.rawValue.localized)
            self.lblFirstRow.text = IGStringsManager.CurrentPassCode.rawValue.localized
            self.lblSecondRow.text = IGStringsManager.NewPass.rawValue.localized
            self.lblThirdRow.text = IGStringsManager.RepeatPassCode.rawValue.localized
            
            
        }
        getMerChantCards()

    }
    func getMerChantCards(){
        SMLoading.showLoadingPage(viewcontroller: self)
        
        DispatchQueue.main.async {
            SMCard.getMerchatnCardsFromServer(accountId: merchantID, { (value) in
                if let card = value {
                    self.merchantCard = card as? SMCard
                    self.prepareMerChantCard()
                }
            }, onFailed: { (value) in
                // think about it
            })
        }
    }
    
    func prepareMerChantCard() {
        SMLoading.hideLoadingPage()
        if let card = merchantCard {
            if card.type == 1 {
                //                amountLbl.isHidden = false

                print(card)
                cardToken = card.token!
                
                initView()
            }
        }
    }
    func initView() {
        btnSubmit.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 17)
        if isOTP {
            initNavigationBar(title: IGStringsManager.ResetWalletPin.rawValue.localized)
            self.lblFirstRow.text = IGStringsManager.OTPCode.rawValue.localized
            self.tfFirst.placeholder = IGStringsManager.OTPCode.rawValue.localized
            self.lblSecondRow.text = IGStringsManager.NewPass.rawValue.localized
            self.lblThirdRow.text = IGStringsManager.RepeatPassCode.rawValue.localized
        }
        else {
            initNavigationBar(title: IGStringsManager.WalletPin.rawValue.localized)
            self.lblFirstRow.text = IGStringsManager.CurrentPassCode.rawValue.localized
            self.lblSecondRow.text = IGStringsManager.NewPass.rawValue.localized
            self.lblThirdRow.text = IGStringsManager.RepeatPassCode.rawValue.localized


        }
        initServices()
    }
    func initServices() {
        if isOTP {
            callOTPAPI()
        }
    }
    
    func initNavigationBar(title: String) {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: title)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    /// Call API to get OTP message
    func callOTPAPI () {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: IGStringsManager.GlobalLoading.rawValue.localized)
        
        let request = WS_methods.init(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response) in
            //
            SMLoading.hideLoadingPage()
            
            let message = IGStringsManager.NewCodeSuccessSent.rawValue.localized
//
//
                        SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: IGStringsManager.GlobalMessage.rawValue.localized, message: message ,yesPressed :{yes in
////
            })
//            SMLoading.showToast(viewcontroller: self, text: IGStringsManager.NewCodeSuccessSent.rawValue.localized)
        }
        
        request.addFailedHandler { (response) in
            
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
            }
            let message = IGStringsManager.GlobalTryAgain.rawValue.localized
            SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: IGStringsManager.GlobalMessage.rawValue.localized, message: message ,yesPressed :{yes in

                self.navigationController?.popViewController(animated: true)

            })
//            SMLoading.showToast(viewcontroller: self, text: IGStringsManager.GlobalTryAgain.rawValue.localized)

            SMLoading.hideLoadingPage()
        }
        
        let accountId = merchantID
        request.pc_otp(toResetWalletPinCardhash: cardToken, accountId: accountId)
        
    }
    
    /// Call API to reset passcode
    ///
    /// - Parameters:
    ///   - otp: code user received by sms
    ///   - newPass: new passcode
    func callResetAPI (otp: String, newPass: String) {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: IGStringsManager.GlobalLoading.rawValue.localized)
        
        let request = WS_methods.init(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response) in
            //
            SMLoading.hideLoadingPage()
            
            let message = IGStringsManager.PinCodeSuccessChange.rawValue.localized
            
            SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: IGStringsManager.GlobalMessage.rawValue.localized, message: message ,yesPressed :{yes in
                
                self.navigationController?.popViewController(animated: true)
                
            })
            
            self.clearAll()
            
        }
        
        request.addFailedHandler { (response) in
            
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
            }
            SMLoading.hideLoadingPage()
            SMMessage.showWithMessage(SMCard.testConvert(response))

        }
        
        let accountId = merchantID
        var cardHash : String! = ""

        if currentRole == "admin" {
            cardHash = cardToken
        }
        else {
            cardHash =  SMUserManager.payGearToken

        }
//        let cardHash =  SMUserManager.payGearToken

//        let cardHash = "5f349a8c-5411-4013-8704-126b8032000c"
        request.pc_resetWalletpin(otp, newPin: newPass, cardhash: cardHash, accountId: accountId)
        
    }
    func callChangeWalletPassAPISequence() {
        
        var oldPassword = ""
        var newPassword = ""
        var newCPassword = ""
        
        if isFirstTime {
            oldPassword = ""
            newCPassword = self.tfThird.text!.inEnglishNumbersNew().onlyDigitChars()
            newPassword = self.tfSecond.text!.inEnglishNumbersNew().onlyDigitChars()

        }
        else {
            
            oldPassword = self.tfFirst.text!.inEnglishNumbersNew().onlyDigitChars()
            newCPassword = self.tfThird.text!.inEnglishNumbersNew().onlyDigitChars()
            newPassword = self.tfSecond.text!.inEnglishNumbersNew().onlyDigitChars()
            
        }
        
        if  SMValidation.walletPassCodeValidation(newPassword.onlyDigitChars()) {
            
            if newPassword.onlyDigitChars() == newCPassword.onlyDigitChars() {

                SMUserManager.loadPassFromKeychain()
                    //Request to server
                    callAPI(oldPass: oldPassword, newPass: newPassword)
            }
            else {
                
                SMMessage.showWithMessage(IGStringsManager.PinNotMatch.rawValue.localized)
            }
        }
        else {
            SMMessage.showWithMessage(IGStringsManager.IncorrectInput.rawValue.localized)
        }
        
        
    }
    
    /// - Parameters:
    ///   - oldPass: the current passcode
    ///   - newPass: the passcode to be define
    func callAPI (oldPass: String, newPass: String) {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: IGStringsManager.GlobalLoading.rawValue.localized)
        
        let request = WS_methods.init(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response) in
            //
            SMLoading.hideLoadingPage()
            if self.merchant == nil {
                SMUserManager.pin = true
            }
            
            var message = IGStringsManager.PinCodeSuccessChange.rawValue.localized
            if !self.isFirstTime {
                message = IGStringsManager.PinCodeSuccessChange.rawValue.localized
            }
            SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: IGStringsManager.GlobalMessage.rawValue.localized, message: message ,yesPressed :{yes in
                
                    self.navigationController?.popViewController(animated: true)
                
                
            })
            
            self.clearAll()
        }
        
        request.addFailedHandler { (response) in
            
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
            }
            SMLoading.hideLoadingPage()
            SMMessage.showWithMessage(SMCard.testConvert(response))

        }
        let cardHash =  SMUserManager.payGearToken
        let accountId = (merchant != nil) ? merchant?.id : SMUserManager.accountId

        if !isFirstTime{
            request.pc_walletpin(newPass, oldpin: oldPass, cardhash: cardHash, accountId: accountId)
        }
        else {
            SMUserManager.userPass = newPass
            SMUserManager.savePassToKeyChain()
            request.pc_walletpin(newPass, oldpin: oldPass, cardhash: cardHash)
        }
        
    }
    func clearAll() {
        self.tfFirst.text = ""
        self.tfSecond.text = ""
        self.tfThird.text = ""
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) 

        if cell.tag == 0 {
            if isFirstTime {
                return 0
            }
            else {
                return 100
            }
        }
        else if cell.tag == 1 {
            return 100
        }
        else if cell.tag == 2 {
            return 100
        }
        else if cell.tag == 3 {
            return 54
        }
        else {
            return 54
        }
        
        
    }
    @IBAction func btnOKTaped(_ sender: Any) {
        if isOTP {
        otpSequence()
        }
        else {
            callChangeWalletPassAPISequence()
        }
    }
    func otpSequence() {
        var otp = ""
        _ = ""
        var newPassword = ""
        var newCPassword = ""
        if isOTP {
            otp = self.tfFirst.text!.inEnglishNumbersNew()
            newPassword = self.tfSecond.text!.inEnglishNumbersNew().onlyDigitChars()
            newCPassword = self.tfThird.text!.inEnglishNumbersNew().onlyDigitChars()
            
            if SMValidation.walletPassCodeValidation(otp.onlyDigitChars().inEnglishNumbersNew()), SMValidation.walletPassCodeValidation(newPassword.onlyDigitChars().inEnglishNumbersNew()) {
                
                if newPassword == newCPassword {
                    
                    //request to server
                    callResetAPI(otp: otp.onlyDigitChars().inEnglishNumbersNew(), newPass: newPassword.onlyDigitChars().inEnglishNumbersNew())
                }
                else {
                    
                    SMMessage.showWithMessage(IGStringsManager.PinNotMatch.rawValue.localized)
                }
            }
            else {
                SMMessage.showWithMessage(IGStringsManager.IncorrectInput.rawValue.localized)
            }
            
            
        }
        else {
            
        }
        
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
