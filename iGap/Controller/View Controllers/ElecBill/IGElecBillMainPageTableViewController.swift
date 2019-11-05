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

class IGElecBillMainPageTableViewController: BaseTableViewController {
    // MARK: - Outlets

    @IBOutlet weak var topViewHolder : UIViewX!
    @IBOutlet weak var lblTopHolder : UILabel!
    @IBOutlet weak var btnQueryTopHolder : UIButton!
    @IBOutlet weak var btnScanBarcode : UIButton!
    @IBOutlet weak var btnMyBills : UIButton!
    @IBOutlet weak var btnSearchBills : UIButton!
    @IBOutlet weak var tfBillIdNumber : UITextField!
    
    // MARK: - Variables

    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initServices()
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar(title: "TTL_BILL_OPERATIONS".localizedNew, rightAction: {})
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
        
    }
    
    private func customiseView() {
        self.topViewHolder.borderWidth = 0.5
        self.btnMyBills.layer.borderWidth = 2
        self.btnMyBills.layer.borderColor = UIColor(named: themeColor.navigationSecondColor.rawValue)?.cgColor
        self.btnSearchBills.layer.borderWidth = 2
        self.btnSearchBills.layer.borderColor = UIColor(named: themeColor.navigationSecondColor.rawValue)?.cgColor
        self.btnMyBills.layer.cornerRadius = 15
        self.btnSearchBills.layer.cornerRadius = 15
        self.btnQueryTopHolder.layer.cornerRadius = 15
        self.tfBillIdNumber.keyboardType = .numberPad
    }
    
    private func initFont() {
        btnScanBarcode.titleLabel?.font = UIFont.iGapFonticon(ofSize: 40)
        btnSearchBills.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnQueryTopHolder.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnMyBills.titleLabel?.font = UIFont.igFont(ofSize: 15)
        lblTopHolder.font = UIFont.igFont(ofSize: 15, weight: .bold)
        tfBillIdNumber.font = UIFont.igFont(ofSize: 15)
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: themeColor.textFieldPlaceHolderColor.rawValue),
            NSAttributedString.Key.font : UIFont.igFont(ofSize: 15)]
        tfBillIdNumber.attributedPlaceholder = NSAttributedString(string: "BILL_ID".localizedNew, attributes:attributes as [NSAttributedString.Key : Any])
    }
    
    private func initStrings() {
        btnQueryTopHolder.setTitle("BTN_INQUERY".localizedNew, for: .normal)
        btnMyBills.setTitle("BTN_MY_BILLS".localizedNew, for: .normal)
        btnSearchBills.setTitle("BTN_SEARCH_BILLS".localizedNew, for: .normal)
        btnScanBarcode.setTitle("", for: .normal)
        lblTopHolder.text = "LBL_ELECTRICITYBILL_PAY".localizedNew
    }
    
    private func initColors() {
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.topViewHolder.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        lblTopHolder.textColor = UIColor(named: themeColor.labelColor.rawValue)
        btnScanBarcode.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        btnMyBills.setTitleColor(UIColor(named: themeColor.navigationSecondColor.rawValue), for: .normal)
        btnSearchBills.setTitleColor(UIColor(named: themeColor.navigationSecondColor.rawValue), for: .normal)
        self.btnSearchBills.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.btnMyBills.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.btnQueryTopHolder.backgroundColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
    }
    
    private func initAlignments() {
        lblTopHolder.textAlignment = .center
        tfBillIdNumber.textAlignment = .center
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
    
    // MARK: - Actions
    @IBAction func txtBillNUmber(_ sender: UITextField) {

    }
    @IBAction func didTapOnScanBarcode(_ sender: UIButton) {
        let scanner = IGSettingQrScannerViewController.instantiateFromAppStroryboard(appStoryboard: .Setting)
        scanner.scannerPageType = .BillBarcode
        scanner.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(scanner, animated:true)

    }
    @IBAction func didTapOnBtnInquery(_ sender: UIButton) {
        if tfBillIdNumber.text!.count <= 0 ||  tfBillIdNumber.text!.count > 13{
            tfBillIdNumber.shake()
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "MSG_CHARACTER_COUNT_ELECTRICITY_BILL".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
        } else {
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
            let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

            let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)
            SMLoading.showLoadingPage(viewcontroller: self)
            IGApiElectricityBill.shared.queryBill(billNumber: (tfBillIdNumber.text?.inEnglishNumbersNew())!, phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
                SMLoading.hideLoadingPage()
                if success {
                    print(response)
                    
                } else {
                    print(errorMessage)
                }
            })
        }
    }

    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0 :
                return 210
            case 1 :
                return 50
            case 2 :
                return 50
            default:
                return 50
                
            }
        } else {
            return 0
        }
        
        
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
