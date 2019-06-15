//
//  addNewCardTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class addNewCardTableViewController: BaseTableViewController , UITextFieldDelegate  {
    @IBOutlet weak var cardTextField: UITextField!
    @IBOutlet weak var mounthTextField: customYearTextfield!
    @IBOutlet weak var yearTextField: customYearTextfield!
    @IBOutlet weak var btnSave : UIButtonX!
    @IBOutlet weak var imgBankLogo : UIImageViewX!
    @IBOutlet weak var lblcardNum : UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMonth : UILabel!
    @IBOutlet weak var lblDefaultCard : UILabel!
    @IBOutlet weak var switchIsDefault: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initNavigationBar()
    }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        initChangeLang()
        btnSave.setTitle("SAVE".localizedNew, for: .normal)
    }
    func initChangeLang() {
        lblcardNum.text = "TTL_CARDNUM".localizedNew
        lblMonth.text = "TTL_MONTH".localizedNew
        lblYear.text = "TTL_YEAR".localizedNew
        
        mounthTextField.placeholder = "TTL_MONTH".localizedNew
        cardTextField.placeholder = "TTL_ENTER_CARD_NUMBER".localizedNew
        yearTextField.placeholder = "TTL_YEAR".localizedNew
        lblMonth.textAlignment = lblMonth.localizedNewDirection
        lblYear.textAlignment = lblYear.localizedNewDirection
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "TTL_ADD_NEW_CARD".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    func initView() {
        cardTextField.delegate = self
//        mounthTextField.delegate = self
//        yearTextField.delegate = self

    }
    
    @IBAction func btnSaveTap(_ sender: Any) {
        if (yearTextField.text != nil) && (yearTextField.text != "") && (mounthTextField.text != nil) && (mounthTextField.text != "") && (cardTextField.text != nil) && (cardTextField.text != "") {
            
            let card = SMCard()
            card.pan = cardTextField.text?.onlyDigitChars().inEnglishNumbers()
            card.exp_y = yearTextField.text?.inEnglishNumbers()
            card.exp_m = mounthTextField.text?.inEnglishNumbers()
            //        card.isDefault = switchIsDefault.isOn
            SMLoading.showLoadingPage(viewcontroller: self)
            
            
            SMCard.addNewCardToServer(card, onSuccess: {
                
                
                self.navigationController?.popViewController(animated: true)
                
            }, onFailed: { err in
                
                
                if SMValidation.showConnectionErrorToast(err) {
                    SMLoading.showToast(viewcontroller: self, text: "SERVER_DOWN".localizedNew)
                }
            })
            
            
        }
        else {
            IGHelperAlert.shared.showAlert(message: "CHECK_ALL_FIELDS".localizedNew)
        }
        
       
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    //Mark: TextField delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            print("FOCOUSED")

        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newStr = string
        
        if textField.tag == 0 {
            
            if textField.text?.onlyDigitChars().length == 6 {
                imgBankLogo.image = UIImage.init(named: BankModel.getBankLogo(bankCodeNumber: textField.text?.onlyDigitChars().inEnglishNumbers()))
            }
            else if textField.text?.onlyDigitChars().length == 5 {
                imgBankLogo.image = UIImage.init(named:  "bank" )
            }
            
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            textField.text = CardUtils.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()
            
            if string == "" && range.location < textField.text!.length {
                let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
            
            
        }
      

        return false
    }
   
}
