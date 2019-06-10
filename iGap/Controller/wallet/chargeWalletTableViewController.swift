//
//  chargeWalletTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLang()
        initChangeDirection()
    }
    func initChangeLang() {
        tfAmount.placeholder = "PLACE_HOLDER_AMOUNT".localizedNew
        lblEnterChargePriceTitle.text = "TTL_ENTER_CHARGE_PRICE".localizedNew
        amountTitleLabel.text = "TTL_WALLET_ACCOUNT_BALANCE".localizedNew
        cashableAmountLabel.text = "TTL_WALLET_ACCOUNT_CASHABLE".localizedNew
//        balanceLabel.text = "TTL_WALLET_ACCOUNT_CASHABLE".localizedNew

    }
    func initChangeDirection() {
        cashableAmountLabel.textAlignment = cashableAmountLabel.localizedNewDirection
        balanceLabel.textAlignment = balanceLabel.localizedNewDirection

        amountTitleLabel.textAlignment = cashableAmountLabel.localizedNewDirection
        cashableBalanceLabel.textAlignment = balanceLabel.localizedNewDirection
    }
    func initView() {
        btnSubmit.setTitle("GLOBAL_OK".localizedNew, for: .normal)

        self.cashableBalanceLabel.text = balance
        self.balanceLabel.text = balance
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "TTL_TRANSITION_CHARGE_WALLET".localizedNew)
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
        SMCard.initPayment(amount: Int((self.tfAmount.text?.onlyDigitChars())!),accountId:  SMUserManager.accountId, discount_price: "0", onSuccess: { response in
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newStr = string
        
        newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
        textField.text = newStr == "" ? "" : newStr.onlyDigitChars().inRialFormat().inEnglishNumbers()
        
        if string == "" && range.location < textField.text!.length{
            let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        
        return false
    }
    
}
