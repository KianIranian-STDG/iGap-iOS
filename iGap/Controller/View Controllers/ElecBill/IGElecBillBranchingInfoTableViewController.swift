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
        
    }
    
    private func initFont() {
        
    }
    
    private func initStrings() {
        
    }
    
    private func initColors() {

    }
    
    private func initAlignments() {

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
        lblTitleRow0.text = "".localizedNew
        lblTitleRow1.text = "".localizedNew
        lblTitleRow2.text = "".localizedNew
        lblTitleRow3.text = "".localizedNew
        lblTitleRow4.text = "".localizedNew
        lblTitleRow5.text = "".localizedNew
        lblTitleRow6.text = "".localizedNew
        lblTitleRow7.text = "".localizedNew
        lblTitleRow8.text = "".localizedNew
        lblTitleRow9.text = "".localizedNew
        lblTitleRow10.text = "".localizedNew
        lblTitleRow11.text = "".localizedNew
        lblTitleRow12.text = "".localizedNew
        lblTitleRow13.text = "".localizedNew
        lblTitleRow14.text = "".localizedNew
        lblTitleRow15.text = "".localizedNew
        lblTitleRow16.text = "".localizedNew
        lblTitleRow17.text = "".localizedNew
        lblTitleRow18.text = "".localizedNew
        lblTitleRow19.text = "".localizedNew
        
        lblTitleRow0.text = data.billIdentifier
        lblTitleRow1.text = data.paymentIdentifier
        if let companyCode = data.companyCode {
           lblTitleRow2.text = String(companyCode)
        }
        else{
           lblTitleRow2.text = ""
        }
        lblTitleRow3.text = ""
        lblTitleRow4.text = ""
        lblTitleRow5.text = ""
        lblTitleRow6.text = ""
        lblTitleRow7.text = ""
        lblTitleRow8.text = ""
        lblTitleRow9.text = ""
        lblTitleRow10.text = ""
        lblTitleRow11.text = ""
        lblTitleRow12.text = ""
        lblTitleRow13.text = ""
        lblTitleRow14.text = ""
        lblTitleRow15.text = ""
        lblTitleRow16.text = ""
        lblTitleRow17.text = ""
        lblTitleRow18.text = ""
        lblTitleRow19.text = ""

    }
    
    // MARK: - Actions

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 19
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
