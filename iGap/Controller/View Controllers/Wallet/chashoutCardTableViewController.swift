//
//  chashoutCardTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class chashoutCardTableViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var tfCardNumber: UITextField!
    

    var isImmediate = true
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initNavigationBar()
        initDelegates ()
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Cashout")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    func initDelegates () {
        self.tfAmount.delegate = self
        self.tfCardNumber.delegate = self
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
    //Mark: Actions
    @IBAction func segmentTap(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tfCardNumber.placeholder = "16 Digit Card Number"
        }
        else {
            tfCardNumber.placeholder = "24 Digit IBAN Number"
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
            
            newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
            textField.text = newStr == "" ? "" : newStr.onlyDigitChars().inRialFormat().inEnglishNumbers()
            
            if string == "" && range.location < textField.text!.length{
                let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
        }

        return false
    }


}
