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

class chargeWalletTableViewController: BaseTableViewController,UITextFieldDelegate {
    @IBOutlet weak var tfAmount : UITextField!
    @IBOutlet weak var btnSubmit : UIButtonX!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var cashableBalanceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var cashableAmountLabel: UILabel!
    @IBOutlet weak var lblEnterChargePriceTitle: UILabel!
    
    var balance = "0".inLocalizedLanguage()
    var finishDelegate : HandleDefaultCard?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        initDelegates ()
        initView()
//        tfAmount.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLang()
        initChangeDirection()
    }
    func initChangeLang() {
        tfAmount.placeholder = "PLACE_HOLDER_AMOUNT".localized
        lblEnterChargePriceTitle.text = "TTL_ENTER_CHARGE_PRICE".localized
        amountTitleLabel.text = "TTL_WALLET_ACCOUNT_BALANCE".localized
        cashableAmountLabel.text = "TTL_WALLET_ACCOUNT_CASHABLE".localized
//        balanceLabel.text = "TTL_WALLET_ACCOUNT_CASHABLE".localized

    }
    func initChangeDirection() {
        cashableAmountLabel.textAlignment = cashableAmountLabel.localizedDirection
        balanceLabel.textAlignment = balanceLabel.localizedDirection

        amountTitleLabel.textAlignment = cashableAmountLabel.localizedDirection
        cashableBalanceLabel.textAlignment = balanceLabel.localizedDirection
    }
    func initView() {
        btnSubmit.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)

        self.cashableBalanceLabel.text = balance
        self.balanceLabel.text = balance
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "TTL_TRANSITION_CHARGE_WALLET".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    func initDelegates () {
        self.tfAmount.delegate = self
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
    
    @IBAction func okPressed(_ sender: Any) {
        
        SMLoading.showLoadingPage(viewcontroller: self)
        SMCard.initPayment(amount: Int(((self.tfAmount.text?.onlyDigitChars())!).inEnglishNumbersNew()),accountId:  SMUserManager.accountId, discount_price: "0", onSuccess: { response in
            SMLoading.hideLoadingPage()
            let json = response as? Dictionary<String, AnyObject>
            if let ipg = json?["ipg_url"] as? String ,ipg != "" {
                if let url = URL(string: ipg) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            
        }, onFailed: {err in
            if SMValidation.showConnectionErrorToast(err) {
                SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
            }
            SMLoading.hideLoadingPage()
            SMLog.SMPrint(err)
        })
        
        
        
        
        
    }
//    MARK: - UITETFIELD delegates
    @objc func myTextFieldDidChange(_ textField: UITextField) {
          
//          textField.text = textField.text
        if let amountString = textField.text {
              
            textField.text = amountString.trimmingCharacters(in: .whitespaces).inEnglishNumbersNew().currencyFormat()
              
          }
      }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newStr = string
        
        newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).trimmingCharacters(in: .whitespaces).inEnglishNumbersNew().currencyFormat()
        textField.text = newStr == "" ? "" : newStr.trimmingCharacters(in: .whitespaces).inEnglishNumbersNew().currencyFormat()
        
        if string == "" && range.location < textField.text!.length{
            let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        
        return false
    }
    
}
