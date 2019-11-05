//
//  IGElecBillDetailPageTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 11/5/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import RealmSwift

class IGElecBillDetailPageTableViewController: BaseTableViewController {
    // MARK: - Outlets
    @IBOutlet weak var lblTTlBillNumber : UILabel!
    @IBOutlet weak var lblDataBillNumber : UILabel!
    @IBOutlet weak var lblTTlBillPayNumber : UILabel!
    @IBOutlet weak var lblDataBillPayNumber : UILabel!
    @IBOutlet weak var lblTTlBillPayAmount : UILabel!
    @IBOutlet weak var lblDataBillPayAmount : UILabel!
    @IBOutlet weak var lblTTlBillPayDate : UILabel!
    @IBOutlet weak var lblDataBillPayDate : UILabel!
    @IBOutlet weak var btnPay : UIButton!
    @IBOutlet weak var btnDetailBranch : UIButton!
    @IBOutlet weak var btnAddToMyBills : UIButton!
    @IBOutlet weak var btnPDFofBill : UIButton!
    @IBOutlet weak var topViewHolder : UIViewX!

    // MARK: - Variables
    var billNumber: String!
    var payDate: String!
    var payAmount: String!
    var payNumber: String!
    // MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initServices()
        initView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar(title: "".localizedNew, rightAction: {})//set Title for Page and nav Buttons if needed

    }
    // MARK: - Development Funcs
    private func initView() {
        customiseTableView()
        initFont()
        initAlignments()
        initColors()
        initStrings()
        customiseView()
    }
    
    private func initServices() {
        if payDate == nil || payAmount == nil || payNumber == nil {
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
            let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

            let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)
            SMLoading.showLoadingPage(viewcontroller: self)
            queryBill(userPhoneNumber: userPhoneNumber)
        }
    }
    
    private func customiseView() {

    }
    
    private func initFont() {

    }
    
    private func initStrings() {

    }
    
    private func initColors() {
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)

    }
    
    private func initAlignments() {

    }
    
    private func customiseTableView() {
        self.tableView.tableFooterView = UIView()
        
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
    private func queryBill(userPhoneNumber: String!) {

        IGApiElectricityBill.shared.queryBill(billNumber: (billNumber.inEnglishNumbersNew()), phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
            SMLoading.hideLoadingPage()
            if success {
                print(response)
                self.payNumber = response?.data?.paymentIdentifier
                self.payDate = response?.data?.paymentDeadLine
                self.payAmount = response?.data?.totalBillDebt

            } else {
                print(errorMessage)
            }
        })
    }
    // MARK: - Actions


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    
}
