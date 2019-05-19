//
//  IGWalletSettingInnerTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/13/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import webservice

class IGWalletSettingInnerTableViewController: BaseTableViewController , UITextFieldDelegate, UIGestureRecognizerDelegate {

    var isOTP = false
    var isFirstTime = false
    var merchant: SMMerchant?
    var cardInfo: SMCard?
    @IBOutlet weak var tfFirst : UITextField!
    @IBOutlet weak var tfSecond : UITextField!
    @IBOutlet weak var tfThird : UITextField!

    @IBOutlet weak var lblFirstRow: UILabel!
    @IBOutlet weak var lblSecondRow : UILabel!
    @IBOutlet weak var lblThirdRow : UILabel!
    @IBOutlet weak var btnSubmit : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        initView()
    }
    func initView() {
        btnSubmit.setTitle("GLOBAL_OK".localizedNew, for: .normal)
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 17)
        if isOTP {
            initNavigationBar(title: "RESET_WALLET_PIN".localizedNew)
            self.lblFirstRow.text = "OTP_CODE".localizedNew
            self.tfFirst.placeholder = "OTP_CODE_PLACEHOLDER".localizedNew
            self.lblSecondRow.text = "NEW_PASS".localizedNew
            self.lblThirdRow.text = "CONFIRM_NEW_PASS".localizedNew
        }
        else {
            initNavigationBar(title: "WALLET_PIN".localizedNew)
            self.lblFirstRow.text = "CURRENT_PASS".localizedNew
            self.lblSecondRow.text = "NEW_PASS".localizedNew
            self.lblThirdRow.text = "CONFIRM_NEW_PASS".localizedNew


        }
        initServices()
    }
    func initServices() {
        if isOTP {
            callOTPAPI()
        }
    }
    
    func initNavigationBar(title: String){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: title)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    /// Call API to get OTP message
    func callOTPAPI () {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localizedNew)
        
        let request = WS_methods.init(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response) in
            //
            SMLoading.hideLoadingPage()
            
            let message = "SUCCESS_OTP".localizedNew
//
//
                        SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "GLOBAL_MESSAGE".localizedNew, message: message ,yesPressed :{yes in
////
            })
//            SMLoading.showToast(viewcontroller: self, text: "SUCCESS_OTP".localizedNew)

        }
        
        request.addFailedHandler { (response) in
            
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: "SERVER_DOWN".localizedNew)
            }
            let message = "UNSSUCCESS_OTP".localizedNew
            SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "GLOBAL_MESSAGE".localizedNew, message: message ,yesPressed :{yes in

                self.navigationController?.popViewController(animated: true)

            })
//            SMLoading.showToast(viewcontroller: self, text: "UNSSUCCESS_OTP".localizedNew)

            SMLoading.hideLoadingPage()
        }
        
        let accountId = (merchant != nil) ? merchant?.id : SMUserManager.accountId
        let cardHash =  SMUserManager.payGearToken
        
        request.pc_otp(toResetWalletPinCardhash: cardHash, accountId: accountId)
        
    }
    
    /// Call API to reset passcode
    ///
    /// - Parameters:
    ///   - otp: code user received by sms
    ///   - newPass: new passcode
    func callResetAPI (otp: String, newPass: String) {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localizedNew)
        
        let request = WS_methods.init(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response) in
            //
            SMLoading.hideLoadingPage()
            
            let message = "SUCCESSFULL_CHANGE_PASS".localizedNew
            
            SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "GLOBAL_MESSAGE".localizedNew, message: message ,yesPressed :{yes in
                
                self.navigationController?.popViewController(animated: true)
                
            })
            
            self.clearAll()
            
        }
        
        request.addFailedHandler { (response) in
            
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: "SERVER_DOWN".localizedNew)
            }
            SMLoading.hideLoadingPage()
            SMMessage.showWithMessage(SMCard.testConvert(response))

        }
        
        let accountId = (merchant != nil) ? merchant?.id : SMUserManager.accountId
        let cardHash =  SMUserManager.payGearToken

        request.pc_resetWalletpin(otp, newPin: newPass, cardhash: cardHash, accountId: accountId)
        
    }
    func callChangeWalletPassAPISequence() {
        
        var oldPassword = ""
        var newPassword = ""
        var newCPassword = ""
        
        if isFirstTime {
            oldPassword = ""
            newCPassword = self.tfThird.text!
            newPassword = self.tfSecond.text!

        }
        else {
            
            oldPassword = self.tfFirst.text!
            newCPassword = self.tfThird.text!
            newPassword = self.tfSecond.text!
            
        }
        
        if  SMValidation.walletPassCodeValidation(newPassword) {
            
            if newPassword == newCPassword {

                SMUserManager.loadPassFromKeychain()
//                if oldPassword == SMUserManager.userPass {
                    //Request to server
                    callAPI(oldPass: oldPassword, newPass: newPassword)
//
//                }
//                else {
//                    SMMessage.showWithMessage("OLD_PASSCODE_NOT_MACHED".localizedNew)
//
//                }
            }
            else {
                
                SMMessage.showWithMessage("PASSCODE_NOT_MACHED".localizedNew)
            }
        }
        else {
            SMMessage.showWithMessage("INPUT_VALUE_NOT_CORRECT".localizedNew)
        }
        
        
    }
    
    /// - Parameters:
    ///   - oldPass: the current passcode
    ///   - newPass: the passcode to be define
    func callAPI (oldPass: String, newPass: String) {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localizedNew)
        
        let request = WS_methods.init(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response) in
            //
            SMLoading.hideLoadingPage()
            if self.merchant == nil {
                SMUserManager.pin = true
            }
            
            var message = "SUCCESSFULL_CHANGE_PASS".localizedNew
            if !self.isFirstTime {
                message = "SUCCESSFULL_SET_PASS".localizedNew
            }
            SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "GLOBAL_MESSAGE".localizedNew, message: message ,yesPressed :{yes in
                
                    self.navigationController?.popViewController(animated: true)
                
                
            })
            
            self.clearAll()
        }
        
        request.addFailedHandler { (response) in
            
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: "SERVER_DOWN".localizedNew)
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
        var currentPassword = ""
        var newPassword = ""
        var newCPassword = ""
        if isOTP {
            otp = self.tfFirst.text!
            newPassword = self.tfSecond.text!
            newCPassword = self.tfThird.text!
            
            if SMValidation.walletPassCodeValidation(otp.onlyDigitChars().inEnglishNumbers()), SMValidation.walletPassCodeValidation(newPassword.onlyDigitChars().inEnglishNumbers()) {
                
                if newPassword == newCPassword {
                    
                    //request to server
                    callResetAPI(otp: otp.onlyDigitChars().inEnglishNumbers(), newPass: newPassword.onlyDigitChars().inEnglishNumbers())
                }
                else {
                    
                    SMMessage.showWithMessage("PASSCODE_NOT_MACHED".localizedNew)
                }
            }
            else {
                SMMessage.showWithMessage("INPUT_VALUE_NOT_CORRECT".localizedNew)
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
