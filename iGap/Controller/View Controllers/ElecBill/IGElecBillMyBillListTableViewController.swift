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

class IGElecBillMyBillListTableViewController: BaseTableViewController {
    
    // MARK: - Outlets
    // MARK: - Variables
    var myBillList: [billObject]!
    var myBillListInnerData : [InqueryDataStruct]!
    var userPhoneNumber : String!
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initServices()
        initView()
        SwiftEventBus.onMainThread(self, name: EventBusManager.updateBillsName) { result in
            self.getBillList(userPhoneNumber: self.userPhoneNumber)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar(title: "BILL_BILL_LIST".localized, rightAction: {})//set Title for Page and nav Buttons if needed
        
    }
    // MARK: - Development Funcs
    private func initView() {
        customiseView()
    }
    
    private func initServices() {
    }
    
    private func customiseView() {
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.tableView.tableFooterView = UIView()
        self.tableView.semanticContentAttribute = self.semantic
        
    }
    
    private func makeHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 70.0))
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.setTitle("ADD_NEW_BILL".localized, for: .normal)
        btn.setTitleColor(UIColor(named: themeColor.labelSecondColor.rawValue), for: .normal)
        btn.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        btn.layer.borderColor = UIColor(named: themeColor.labelSecondColor.rawValue)?.cgColor
        btn.layer.borderWidth = 2.0
        btn.titleLabel!.font = UIFont.igFont(ofSize: 15)
        headerView.addSubview(btn)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnBtn))
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(tap)
        
        headerView.semanticContentAttribute = self.semantic
        
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.top).offset(10)
            make.bottom.equalTo(headerView.snp.bottom).offset(-10)
            make.left.equalTo(headerView.snp.left).offset(10)
            make.right.equalTo(headerView.snp.right).offset(-10)
        }
        headerView.backgroundColor = UIColor(named: themeColor.recentTVCellColor.rawValue)
        
        return headerView
    }

    private func getBillList(userPhoneNumber: String!) {
        IGApiElectricityBill.shared.getBills(phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
            if success {
                self.myBillList = response?.data?.billData
                self.tableView.reloadData()
            } else {
                print(errorMessage)
            }
        })
    }
    
    // MARK: - Actions
    @objc
    func didTapOnBtn(sender:UITapGestureRecognizer) {
        let addEditVC = IGElecAddEditBillTableViewController.instantiateFromAppStroryboard(appStoryboard: .ElectroBill)
        addEditVC.hidesBottomBarWhenPushed = true
        addEditVC.billNumber = ""
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first
        let userPhoneNumber =  IGGlobal.validaatePhoneNUmber(phone: userInDb?.phone)
        addEditVC.userNumber = userPhoneNumber
        addEditVC.canEditBill = false
        addEditVC.billTitle = ""
        self.navigationController!.pushViewController(addEditVC, animated:true)

    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myBillList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "IGElecBillTableViewCell") as! IGElecBillTableViewCell
        cell.setBillsData(bill: self.myBillList[indexPath.row],userPhoneNumber: userPhoneNumber)
        //        cell.setBillsDataInner(billDataInner: self.myBillListInnerData[indexPath.row])
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 228
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return makeHeaderView()
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
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