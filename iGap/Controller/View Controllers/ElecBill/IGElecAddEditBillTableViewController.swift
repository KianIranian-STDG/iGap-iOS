//
//  IGElecAddEditBillTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 11/9/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftEventBus

class IGElecAddEditBillTableViewController: BaseTableViewController {

    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBillName: UILabel!
    @IBOutlet weak var lblBillNUmber: UILabel!
    @IBOutlet weak var lblUserNumber: UILabel!

    @IBOutlet weak var tfBillName: UITextField!
    @IBOutlet weak var tfBillNUmber: UITextField!
    @IBOutlet weak var tfUserNumber: UITextField!
    @IBOutlet weak var btnAddEdit: UIButton!
    // MARK: - Variables
    var billNumber: String!
    var billTitle: String!
    var userNumber: String!
    var canEditBill : Bool = false

    // MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initServices()
        initView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar(title: "BILL_DETAIL".localized, rightAction: {})//set Title for Page and nav Buttons if needed

    }
    // MARK: - Development Funcs
    private func initView() {
        initFont()
        initAlignments()
        initColors()
        initStrings()
        customiseView()
    }
    
    private func initServices() {
        
    }
    
    private func customiseView() {
        btnAddEdit.layer.cornerRadius = 15

    }
    
    private func initFont() {
        lblTitle.font = UIFont.igFont(ofSize: 15,weight: .bold)
        lblBillName.font = UIFont.igFont(ofSize: 14)
        lblBillNUmber.font = UIFont.igFont(ofSize: 14)
        lblBillName.font = UIFont.igFont(ofSize: 14)
        lblUserNumber.font = UIFont.igFont(ofSize: 14)
        
        tfBillName.font = UIFont.igFont(ofSize: 14)
        tfBillNUmber.font = UIFont.igFont(ofSize: 14)
        tfUserNumber.font = UIFont.igFont(ofSize: 14)
        btnAddEdit.titleLabel?.font = UIFont.igFont(ofSize: 14)

    }
    
    private func initStrings() {
        tfUserNumber.text = userNumber.inLocalizedLanguage()
        tfBillNUmber.text = billNumber.inLocalizedLanguage()
        tfBillName.text = billTitle
        if canEditBill {
            btnAddEdit.setTitle("BILL_EDIT_MODE".localized, for: .normal)
        } else {
            btnAddEdit.setTitle("BILL_ADD_MODE".localized, for: .normal)
        }
        lblTitle.text = "BILL_FILL_DATA".localized
        lblUserNumber.text = "BILL_DETAIL_CUSTOMER_MOB".localized
        lblBillNUmber.text = IGStringsManager.ElecBillID.rawValue.localized
        lblBillName.text = "BILL_NAME".localized
    }
    
    private func initColors() {
        btnAddEdit.backgroundColor = UIColor(named: themeColor.labelSecondColor.rawValue)
        lblUserNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblBillNUmber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblBillName.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitle.textColor = UIColor(named: themeColor.labelColor.rawValue)
        
        tfUserNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        tfBillNUmber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        tfBillName.textColor = UIColor(named: themeColor.labelColor.rawValue)
        
        tfUserNumber.layer.borderColor = UIColor(named: themeColor.labelColor.rawValue)?.cgColor
        tfBillNUmber.layer.borderColor = UIColor(named: themeColor.labelColor.rawValue)?.cgColor
        tfBillName.layer.borderColor = UIColor(named: themeColor.labelColor.rawValue)?.cgColor

        tfUserNumber.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        tfBillNUmber.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        tfBillName.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        btnAddEdit.setTitleColor(UIColor(named: themeColor.textFieldBackGround.rawValue), for: .normal)

    }
    
    private func initAlignments() {
        lblUserNumber.textAlignment = lblUserNumber.localizedDirection
        lblBillNUmber.textAlignment = lblBillNUmber.localizedDirection
        lblBillName.textAlignment = lblBillName.localizedDirection
        lblTitle.textAlignment = .center
        tfUserNumber.textAlignment = tfUserNumber.localizedDirection
        tfBillNUmber.textAlignment = tfBillNUmber.localizedDirection
        tfBillName.textAlignment = tfBillName.localizedDirection

    }
    
    private func addBill(userPhoneNumber: String) {
        IGApiElectricityBill.shared.addBill(billNumber: (tfBillNUmber.text!.inEnglishNumbersNew()), phoneNumber: userPhoneNumber.inEnglishNumbersNew(),billTitle: self.tfBillName.text!, completion: {(success, response, errorMessage) in
             SMLoading.hideLoadingPage()
             if success {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.SuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized , cancel: {
                    self.navigationController?.popViewController(animated: true)
                    SwiftEventBus.post(EventBusManager.updateBillsName)
                })

             } else {
                 print(errorMessage)
             }
         })
    }
    private func editBill(userPhoneNumber: String) {
        IGApiElectricityBill.shared.editBill(billNumber: (tfBillNUmber.text!.inEnglishNumbersNew()), phoneNumber: userPhoneNumber.inEnglishNumbersNew(),billTitle: self.tfBillName.text!, completion: {(success, response, errorMessage) in
             SMLoading.hideLoadingPage()
             if success {

                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.SuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized , cancel: {
                    self.navigationController?.popViewController(animated: true)
                    SwiftEventBus.post(EventBusManager.updateBillsName)

                })

             } else {
                 print(errorMessage)
             }
         })
    }
    private func validaatePhoneNUmber(phone : Int64!) -> String {
        let str = String(phone)
        if str.starts(with: "98") {
            return str.replacingOccurrences(of: "98", with: "0")
        } else if str.starts(with: "09") {
            return str
        } else {
            return str
        }
    }

    // MARK: - Actions
    @IBAction func didTapOnAddEditButton(_ sender: UIButton) {
        if tfBillNUmber.text == "" {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalCheckFields.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

        } else {
            if canEditBill {
                let realm = try! Realm()
                let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
                let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

                let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)
                SMLoading.showLoadingPage(viewcontroller: self)

                editBill(userPhoneNumber: userPhoneNumber)
                
            } else {
                let realm = try! Realm()
                let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
                let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

                let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)
                SMLoading.showLoadingPage(viewcontroller: self)

                addBill(userPhoneNumber: userPhoneNumber)
            }

        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
