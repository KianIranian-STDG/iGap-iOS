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
import SwiftEventBus
import RealmSwift

class IGElecBillByDeviceListTableViewController: BaseTableViewController ,UIPickerViewDelegate, UIPickerViewDataSource{
    
    // MARK: - Outlets
    @IBOutlet weak var lblEnterSerialNumber : UILabel!
    @IBOutlet weak var lblSelectCompany : UILabel!
    @IBOutlet weak var tfSerialNumber : UITextField!
    @IBOutlet weak var btnCompanyCodes : UIButton!
    @IBOutlet weak var btnSearch : UIButton!
    // MARK: - Variables
    var myBillList: [billByDeviceStruct]!
    var myCompaniesList: [companyStruct]!
    var userPhoneNumber : String!
    var selectedCode : String!
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initServices()
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar(title: "BTN_SEARCH_BILLS".localized, rightAction: {})//set Title for Page and nav Buttons if needed
        
    }
    // MARK: - Development Funcs
    private func initView() {
        customiseView()
        initStrings()
        initFonts()
        initColors()
        initAlignment()
    }
    private func initAlignment() {
        lblEnterSerialNumber.textAlignment = lblEnterSerialNumber.localizedDirection
        lblSelectCompany.textAlignment = lblSelectCompany.localizedDirection
    }
    private func initColors() {
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
//        self.topViewHolder.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        lblSelectCompany.textColor = UIColor(named: themeColor.labelColor.rawValue)
        btnSearch.setTitleColor(UIColor(named: themeColor.textFieldBackGround.rawValue), for: .normal)
        btnCompanyCodes.setTitleColor(UIColor(named: themeColor.labelSecondColor.rawValue), for: .normal)
        lblEnterSerialNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        btnCompanyCodes.layer.borderColor = UIColor(named: themeColor.labelSecondColor.rawValue)?.cgColor
        btnCompanyCodes.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        btnSearch.backgroundColor = UIColor(named: themeColor.labelSecondColor.rawValue)


    }
    private func initStrings() {
        lblEnterSerialNumber.font = UIFont.igFont(ofSize: 15)
        lblSelectCompany.font = UIFont.igFont(ofSize: 15)
        btnCompanyCodes.setTitle("BILL_DETAIL_COMPANY_NAME".localized, for: .normal)
        btnSearch.setTitle("FIND_MY_BILL".localized, for: .normal)
        lblEnterSerialNumber.text = "ENETER_DEVICE_SERIAL_NUMBER".localized
        lblSelectCompany.text = "SELECT_COMPANY_FROM_LIST".localized

    }
    private func initFonts() {
        lblEnterSerialNumber.font = UIFont.igFont(ofSize: 15)
        lblSelectCompany.font = UIFont.igFont(ofSize: 15)
        btnCompanyCodes.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnSearch.titleLabel?.font = UIFont.igFont(ofSize: 15)

        lblEnterSerialNumber.sizeToFit()
        lblSelectCompany.sizeToFit()
        btnCompanyCodes.sizeToFit()
    }
    
    private func initServices() {
    }
    
    private func customiseView() {
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.tableView.tableFooterView = UIView()
        self.tableView.semanticContentAttribute = self.semantic
        self.btnCompanyCodes.layer.cornerRadius = 8
        self.btnSearch.layer.cornerRadius = 15
        btnCompanyCodes.layer.borderWidth = 2
//        self.topViewHolder.borderWidth = 0.5
//        self.topViewHolder.layer.borderColor = UIColor(named: themeColor.labelColor.rawValue)?.cgColor

        
    }

    private func getBillList() {
        if self.selectedCode == nil || self.tfSerialNumber.text == "" || self.tfSerialNumber.text!.isEmpty {
            SMLoading.hideLoadingPage()

            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "CHECK_ALL_FIELDS".localized, cancelText: "GLOBAL_CLOSE".localized )
        } else {
            IGApiElectricityBill.shared.searchBill(serialNumber: self.tfSerialNumber.text!.inEnglishNumbersNew(),companyCode: self.selectedCode, completion: {(success, response, errorMessage) in
                SMLoading.hideLoadingPage()

                if success {
                    self.myBillList = response?.data
                    self.tableView.reloadWithAnimation()
                } else {
                }
            })
        }

    }
    private func getCompaniesList() {
            IGApiElectricityBill.shared.getCompanies(completion: {(success, response, errorMessage) in
                SMLoading.hideLoadingPage()
                if success {
                    self.myCompaniesList = response?.data
                    self.openPickerView()
                    
                } else {
                }
            })
    }
    
    // MARK: - Actions
    var toolBar = UIToolbar()
    var picker  = UIPickerView()

    @IBAction func didTapOnShowCompanies(_ sender: UIButton) {
        if self.myCompaniesList == nil || self.myCompaniesList.count == 0 {
            SMLoading.showLoadingPage(viewcontroller: self)
            self.getCompaniesList()
        } else {

            self.openPickerView()
        }

    }
    @IBAction func didTapOnSearch(_ sender: UIButton) {
        SMLoading.showLoadingPage(viewcontroller: self)

        self.getBillList()
    }
    private func openPickerView() {
        picker = UIPickerView.init()
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barTintColor = UIColor(named: themeColor.labelSecondColor.rawValue)
        toolBar.tintColor = UIColor(named: themeColor.backgroundColor.rawValue)
        toolBar.items = [UIBarButtonItem.init(title: "X", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)

    }
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }


    // MARK: - PICKERVIEW DELAGATE AND DATASOURCE
    // Number of columns

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // Number of rows

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myCompaniesList.count // Number of rows = the amount in currency array
    }

    // Row Title


    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()

            pickerLabel?.font = UIFont.igFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
            
        }

        pickerLabel?.text = myCompaniesList[row].title
        pickerLabel?.textColor = UIColor.black
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let tmpCode : Int = (myCompaniesList[row].code!)
        var myCompanyCode = String(tmpCode)
        self.selectedCode = myCompanyCode
        btnCompanyCodes.setTitle((myCompaniesList[row].title!), for: .normal)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if myBillList != nil {
            return myBillList.count

        } else {
            return 0

        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "IGElecBillByDeviceTableViewCell") as! IGElecBillByDeviceTableViewCell
//        cell.setBillsData(bill: self.myBillList[indexPath.row],userPhoneNumber: userPhoneNumber)
        cell.setBillsData(billData: myBillList[indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "IGElecBillByDeviceTableViewCell") as! IGElecBillByDeviceTableViewCell

        let billDataVC = IGElecBillDetailPageTableViewController.instantiateFromAppStroryboard(appStoryboard: .ElectroBill)
        billDataVC.billNumber = myBillList[indexPath.row].billIdentifier!
        billDataVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(billDataVC, animated:true)

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
