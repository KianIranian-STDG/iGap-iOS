//
//  addNewCardTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class addNewCardTableViewController: UITableViewController , UITextFieldDelegate  {
    @IBOutlet weak var cardTextField: UITextField!
    @IBOutlet weak var mounthTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
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
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Add a new card")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    func initView() {
        cardTextField.delegate = self
        mounthTextField.delegate = self
        yearTextField.delegate = self
    }
    
    @IBAction func btnSaveTap(_ sender: Any) {
        let card = SMCard()
        card.pan = cardTextField.text?.onlyDigitChars().inEnglishNumbers()
        card.exp_y = yearTextField.text?.inEnglishNumbers()
        card.exp_m = mounthTextField.text?.inEnglishNumbers()
        card.isDefault = switchIsDefault.isOn
        SMLoading.showLoadingPage(viewcontroller: self)


        SMCard.addNewCardToServer(card, onSuccess: {
            
           
            self.navigationController?.popViewController(animated: true)
            
        }, onFailed: { err in
            

            if SMValidation.showConnectionErrorToast(err) {
                SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
            }
        })
        
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    //Mark: TextField delegates
    
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
            textField.text = CardUtils.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-")
            
            if string == "" && range.location < textField.text!.length {
                let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
            
            
        }
        else if textField.tag == 1 {
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            let currentCharacterCount = newStr.count
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 3
            
        }
        else if textField.tag == 2 {
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            let currentCharacterCount = newStr.count
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 3
            
        }
        return false
    }
   
}
