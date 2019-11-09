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
import RealmSwift

class IGElecBillBranchingInfoTableViewController: BaseTableViewController {


    // MARK: - Outlets
    @IBOutlet weak var lblTitleRow0 : UILabel!
    @IBOutlet weak var lblTitleRow1 : UILabel!
    @IBOutlet weak var lblTitleRow2 : UILabel!
    @IBOutlet weak var lblTitleRow3 : UILabel!
    @IBOutlet weak var lblTitleRow4 : UILabel!
    @IBOutlet weak var lblTitleRow5 : UILabel!
    @IBOutlet weak var lblTitleRow6 : UILabel!
    @IBOutlet weak var lblTitleRow7 : UILabel!
    @IBOutlet weak var lblTitleRow8 : UILabel!
    @IBOutlet weak var lblTitleRow9 : UILabel!
    @IBOutlet weak var lblTitleRow10 : UILabel!
    @IBOutlet weak var lblTitleRow11 : UILabel!
    @IBOutlet weak var lblTitleRow12 : UILabel!
    @IBOutlet weak var lblTitleRow13 : UILabel!
    @IBOutlet weak var lblTitleRow14 : UILabel!
    @IBOutlet weak var lblTitleRow15 : UILabel!
    @IBOutlet weak var lblTitleRow16 : UILabel!
    @IBOutlet weak var lblTitleRow17 : UILabel!
    @IBOutlet weak var lblTitleRow18 : UILabel!
    @IBOutlet weak var lblTitleRow19 : UILabel!
    @IBOutlet weak var lblDataRow0 : UILabel!
    @IBOutlet weak var lblDataRow1 : UILabel!
    @IBOutlet weak var lblDataRow2 : UILabel!
    @IBOutlet weak var lblDataRow3 : UILabel!
    @IBOutlet weak var lblDataRow4 : UILabel!
    @IBOutlet weak var lblDataRow5 : UILabel!
    @IBOutlet weak var lblDataRow6 : UILabel!
    @IBOutlet weak var lblDataRow7 : UILabel!
    @IBOutlet weak var lblDataRow8 : UILabel!
    @IBOutlet weak var lblDataRow9 : UILabel!
    @IBOutlet weak var lblDataRow10 : UILabel!
    @IBOutlet weak var lblDataRow11 : UILabel!
    @IBOutlet weak var lblDataRow12 : UILabel!
    @IBOutlet weak var lblDataRow13 : UILabel!
    @IBOutlet weak var lblDataRow14 : UILabel!
    @IBOutlet weak var lblDataRow15 : UILabel!
    @IBOutlet weak var lblDataRow16 : UILabel!
    @IBOutlet weak var lblDataRow17 : UILabel!
    @IBOutlet weak var lblDataRow18 : UILabel!
    @IBOutlet weak var lblDataRow19 : UILabel!

    @IBOutlet var stackHolder : [UIStackView]!
    // MARK: - Variables
    var billInqueryData : BranchingDataStruct!
    var billNUmber : String!
    // MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initServices()
        initView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar(title: "BILL_BRANCH_DETAILS".localizedNew, rightAction: {})//set Title for Page and nav Buttons if needed

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
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

        let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)
        SMLoading.showLoadingPage(viewcontroller: self)
        getBranchingInfo(userPhoneNumber: userPhoneNumber)

    }
    
    private func customiseView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.semanticContentAttribute = self.semantic
        for stk in stackHolder {
            stk.semanticContentAttribute = self.semantic
        }

    }
    
    private func initFont() {
        lblTitleRow0.font = UIFont.igFont(ofSize: 15)
        lblTitleRow1.font = UIFont.igFont(ofSize: 15)
        lblTitleRow2.font = UIFont.igFont(ofSize: 15)
        lblTitleRow3.font = UIFont.igFont(ofSize: 15)
        lblTitleRow4.font = UIFont.igFont(ofSize: 15)
        lblTitleRow5.font = UIFont.igFont(ofSize: 15)
        lblTitleRow6.font = UIFont.igFont(ofSize: 15)
        lblTitleRow7.font = UIFont.igFont(ofSize: 15)
        lblTitleRow8.font = UIFont.igFont(ofSize: 15)
        lblTitleRow9.font = UIFont.igFont(ofSize: 15)
        lblTitleRow10.font = UIFont.igFont(ofSize: 15)
        lblTitleRow11.font = UIFont.igFont(ofSize: 15)
        lblTitleRow12.font = UIFont.igFont(ofSize: 15)
        lblTitleRow13.font = UIFont.igFont(ofSize: 15)
        lblTitleRow14.font = UIFont.igFont(ofSize: 15)
        lblTitleRow15.font = UIFont.igFont(ofSize: 15)
        lblTitleRow16.font = UIFont.igFont(ofSize: 15)
        lblTitleRow17.font = UIFont.igFont(ofSize: 15)

        lblDataRow0.font = UIFont.igFont(ofSize: 15)
        lblDataRow1.font = UIFont.igFont(ofSize: 15)
        lblDataRow2.font = UIFont.igFont(ofSize: 15)
        lblDataRow3.font = UIFont.igFont(ofSize: 15)
        lblDataRow4.font = UIFont.igFont(ofSize: 15)
        lblDataRow5.font = UIFont.igFont(ofSize: 15)
        lblDataRow6.font = UIFont.igFont(ofSize: 15)
        lblDataRow7.font = UIFont.igFont(ofSize: 15)
        lblDataRow8.font = UIFont.igFont(ofSize: 15)
        lblDataRow9.font = UIFont.igFont(ofSize: 15)
        lblDataRow10.font = UIFont.igFont(ofSize: 15)
        lblDataRow11.font = UIFont.igFont(ofSize: 15)
        lblDataRow12.font = UIFont.igFont(ofSize: 15)
        lblDataRow13.font = UIFont.igFont(ofSize: 15)
        lblDataRow14.font = UIFont.igFont(ofSize: 15)
        lblDataRow15.font = UIFont.igFont(ofSize: 15)
        lblDataRow16.font = UIFont.igFont(ofSize: 15)
        lblDataRow17.font = UIFont.igFont(ofSize: 15)
    }
    
    private func initStrings() {
        lblTitleRow0.text = "BILL_DETAIL_IDENTIFIER".localizedNew
        lblTitleRow1.text = "BILL_DETAIL_PAY_ID".localizedNew
        lblTitleRow2.text = "BILL_DETAIL_COMPANY_CODE".localizedNew
        lblTitleRow3.text = "BILL_DETAIL_COMPANY_NAME".localizedNew
        lblTitleRow4.text = "BILL_DETAIL_PHASE".localizedNew
        lblTitleRow5.text = "BILL_DETAIL_VOLTAGE".localizedNew
        lblTitleRow6.text = "BILL_DETAIL_TARIFE_TYPE".localizedNew
        lblTitleRow7.text = "BILL_DETAIL_CUSTOMER_TYPE".localizedNew
        lblTitleRow8.text = "BILL_DETAIL_CUSTOMER_NAME".localizedNew
        lblTitleRow9.text = "BILL_DETAIL_CUSTOMER_TEL".localizedNew
        lblTitleRow10.text = "BILL_DETAIL_CUSTOMER_MOB".localizedNew
        lblTitleRow11.text = "BILL_DETAIL_CUSTOMER_ADD".localizedNew
        lblTitleRow12.text = "BILL_DETAIL_CUSTOMER_POSTALCODE".localizedNew
        lblTitleRow13.text = "BILL_DETAIL_CUSTOMER_LOCATION_ZONE".localizedNew
        lblTitleRow14.text = "BILL_DETAIL_CUSTOMER_DEVICE_NUMBER".localizedNew
        lblTitleRow15.text = "BILL_DETAIL_DUE_DATE".localizedNew
        lblTitleRow16.text = "BILL_DETAIL_LAST_READ".localizedNew
        lblTitleRow17.text = "BILL_DETAIL_POWER".localizedNew
        
        lblDataRow0.text = "..."
        lblDataRow1.text = "..."
        lblDataRow2.text = "..."
        lblDataRow3.text = "..."
        lblDataRow4.text = "..."
        lblDataRow5.text = "..."
        lblDataRow6.text = "..."
        lblDataRow7.text = "..."
        lblDataRow8.text = "..."
        lblDataRow9.text = "..."
        lblDataRow10.text = "..."
        lblDataRow11.text = "..."
        lblDataRow12.text = "..."
        lblDataRow13.text = "..."
        lblDataRow14.text = "..."
        lblDataRow15.text = "..."
        lblDataRow16.text = "..."
        lblDataRow17.text = "..."


    }
    
    private func initColors() {
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)

        lblTitleRow0.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow1.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow2.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow3.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow4.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow5.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow6.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow7.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow8.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow9.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow10.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow11.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow12.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow13.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow14.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow15.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow16.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTitleRow17.textColor = UIColor(named: themeColor.labelColor.rawValue)

        lblDataRow0.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow1.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow2.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow3.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow4.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow5.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow6.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow7.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow8.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow9.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow10.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow11.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow12.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow13.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow14.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow15.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow16.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataRow17.textColor = UIColor(named: themeColor.labelColor.rawValue)
    }
    
    private func initAlignments() {
        lblTitleRow0.textAlignment = lblTitleRow0.localizedNewDirection
        lblTitleRow1.textAlignment = lblTitleRow1.localizedNewDirection
        lblTitleRow2.textAlignment = lblTitleRow2.localizedNewDirection
        lblTitleRow3.textAlignment = lblTitleRow3.localizedNewDirection
        lblTitleRow4.textAlignment = lblTitleRow4.localizedNewDirection
        lblTitleRow5.textAlignment = lblTitleRow5.localizedNewDirection
        lblTitleRow6.textAlignment = lblTitleRow6.localizedNewDirection
        lblTitleRow7.textAlignment = lblTitleRow7.localizedNewDirection
        lblTitleRow8.textAlignment = lblTitleRow8.localizedNewDirection
        lblTitleRow9.textAlignment = lblTitleRow9.localizedNewDirection
        lblTitleRow10.textAlignment = lblTitleRow10.localizedNewDirection
        lblTitleRow11.textAlignment = lblTitleRow11.localizedNewDirection
        lblTitleRow12.textAlignment = lblTitleRow12.localizedNewDirection
        lblTitleRow13.textAlignment = lblTitleRow13.localizedNewDirection
        lblTitleRow14.textAlignment = lblTitleRow14.localizedNewDirection
        lblTitleRow15.textAlignment = lblTitleRow15.localizedNewDirection
        lblTitleRow16.textAlignment = lblTitleRow16.localizedNewDirection
        lblTitleRow17.textAlignment = lblTitleRow17.localizedNewDirection

        lblDataRow0.textAlignment = lblDataRow0.localizedNewDirection
        lblDataRow1.textAlignment = lblDataRow1.localizedNewDirection
        lblDataRow2.textAlignment = lblDataRow2.localizedNewDirection
        lblDataRow3.textAlignment = lblDataRow3.localizedNewDirection
        lblDataRow4.textAlignment = lblDataRow4.localizedNewDirection
        lblDataRow5.textAlignment = lblDataRow5.localizedNewDirection
        lblDataRow6.textAlignment = lblDataRow6.localizedNewDirection
        lblDataRow7.textAlignment = lblDataRow7.localizedNewDirection
        lblDataRow8.textAlignment = lblDataRow8.localizedNewDirection
        lblDataRow9.textAlignment = lblDataRow9.localizedNewDirection
        lblDataRow10.textAlignment = lblDataRow10.localizedNewDirection
        lblDataRow11.textAlignment = lblDataRow11.localizedNewDirection
        lblDataRow12.textAlignment = lblDataRow12.localizedNewDirection
        lblDataRow13.textAlignment = lblDataRow13.localizedNewDirection
        lblDataRow14.textAlignment = lblDataRow14.localizedNewDirection
        lblDataRow15.textAlignment = lblDataRow15.localizedNewDirection
        lblDataRow16.textAlignment = lblDataRow16.localizedNewDirection
        lblDataRow17.textAlignment = lblDataRow17.localizedNewDirection
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
    private func getBranchingInfo(userPhoneNumber: String!) {

        IGApiElectricityBill.shared.branchingInfo(billNumber: (billNUmber)!, phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
            SMLoading.hideLoadingPage()
            if success {

                self.billInqueryData = response?.data
                print("BILL BRANCHING INFO",self.billInqueryData)
                self.createTableData(data: self.billInqueryData)
            } else {
                print(errorMessage)
            }
        })
    }
    private func createTableData(data : BranchingDataStruct) {
        lblTitleRow0.text = "BILL_DETAIL_IDENTIFIER".localizedNew
        lblTitleRow1.text = "BILL_DETAIL_PAY_ID".localizedNew
        lblTitleRow2.text = "BILL_DETAIL_COMPANY_CODE".localizedNew
        lblTitleRow3.text = "BILL_DETAIL_COMPANY_NAME".localizedNew
        lblTitleRow4.text = "BILL_DETAIL_PHASE".localizedNew
        lblTitleRow5.text = "BILL_DETAIL_VOLTAGE".localizedNew
        lblTitleRow6.text = "BILL_DETAIL_TARIFE_TYPE".localizedNew
        lblTitleRow7.text = "BILL_DETAIL_CUSTOMER_TYPE".localizedNew
        lblTitleRow8.text = "BILL_DETAIL_CUSTOMER_NAME".localizedNew
        lblTitleRow9.text = "BILL_DETAIL_CUSTOMER_TEL".localizedNew
        lblTitleRow10.text = "BILL_DETAIL_CUSTOMER_MOB".localizedNew
        lblTitleRow11.text = "BILL_DETAIL_CUSTOMER_ADD".localizedNew
        lblTitleRow12.text = "BILL_DETAIL_CUSTOMER_POSTALCODE".localizedNew
        lblTitleRow13.text = "BILL_DETAIL_CUSTOMER_LOCATION_ZONE".localizedNew
        lblTitleRow14.text = "BILL_DETAIL_CUSTOMER_DEVICE_NUMBER".localizedNew
        lblTitleRow15.text = "BILL_DETAIL_DUE_DATE".localizedNew
        lblTitleRow16.text = "BILL_DETAIL_LAST_READ".localizedNew
        lblTitleRow17.text = "BILL_DETAIL_POWER".localizedNew
        
        lblDataRow0.text = data.billIdentifier?.inLocalizedLanguage()
        lblDataRow1.text = data.paymentIdentifier?.inLocalizedLanguage()
        if let companyCode = data.companyCode {
           lblDataRow2.text = String(companyCode).inLocalizedLanguage()
        }
        else{
           lblDataRow2.text = ""
        }
        lblDataRow3.text = data.companyName
        lblDataRow4.text = data.phase?.inLocalizedLanguage()
        lblDataRow5.text = data.voltageType?.inLocalizedLanguage()
        lblDataRow6.text = data.tarifType?.inLocalizedLanguage()
        lblDataRow7.text = data.customerType?.inLocalizedLanguage()
        lblDataRow8.text = data.customerName ?? "" + " " + (data.customerFamilyName ?? "")
        lblDataRow9.text = data.telNumber?.inLocalizedLanguage()
        lblDataRow10.text = data.mobileNumber?.inLocalizedLanguage()
        lblDataRow11.text = data.customerAddress?.inLocalizedLanguage()
        lblDataRow12.text = data.customerPostalCode?.inLocalizedLanguage()
        lblDataRow13.text = data.customerLoactionType?.inLocalizedLanguage()
        lblDataRow14.text = data.deviceSerialNumber?.inLocalizedLanguage()
        let payDate = data.paymentDeadLine
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: payDate!)!
        self.lblDataRow15.text = date.completeHumanReadableTime().inLocalizedLanguage() ?? "..."
        lblDataRow16.text = data.lastReadDate
        if let demandPower = data.demandPower {
           lblDataRow17.text = String(demandPower).inLocalizedLanguage()
        }
        else{
           lblDataRow17.text = ""
        }


    }
    
    // MARK: - Actions

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 18
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
