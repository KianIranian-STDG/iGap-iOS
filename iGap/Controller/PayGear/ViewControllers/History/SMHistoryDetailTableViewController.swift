//
//  SMHistoryTableViewController.swift
//  PayGear
//
//  Created by amir soltani on 5/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import models
import webservice

class SMHistoryDetailTableViewController: UITableViewController,HandleReciept {

    var rowData : PAY_obj_history?
    var detail : PAY_obj_history?
    var detailArray : [(String,String)]?
    var recieptButton : SMBottomButton?
    var date : String?
	var accountId: String?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SMTitle = "transaction.info".localized
        SMLoading.showLoadingPage(viewcontroller: self.parent!)
        self.date = Date.init(timeIntervalSince1970: TimeInterval((self.rowData!.pay_date != 0 ? rowData!.pay_date: rowData!.created_at_timestamp)/1000)).localizedDateTime()
		SMHistory.getDetailFromServer(accountId: accountId, orderId: (rowData!._id), { his in
            SMLoading.hideLoadingPage()
            self.detail = his as? PAY_obj_history
            self.detailArray = [(String,String)]()
            if let senderId = self.detail?.sender.account_id, senderId != "", let receiverId = self.detail?.receiver.account_id, receiverId != "" {
                if SMUserManager.accountId == senderId {
                    if let sender_balance_atm = self.detail?.sender.balance_atm {
                        self.detailArray?.append(("remaining_balance".localized, String(sender_balance_atm).inRialFormat().inLocalizedLanguage() + " " + "Currency".localized))
                    }
                } else if SMUserManager.accountId == receiverId {
                    if let receiver_balance_atm = self.detail?.receiver.balance_atm {
                        self.detailArray?.append(("remaining_balance".localized, String(receiver_balance_atm).inRialFormat().inLocalizedLanguage() + " " + "Currency".localized))
                    }
                }
            }
            if let invoice = self.detail?.invoice_number , invoice != 0 { self.detailArray?.append(("invoice_number".localized ,  String(invoice)))  }
            if let trace = self.detail?.trace_no, trace != 0 { self.detailArray?.append(("trace_no".localized,String(trace))) }
            if let cardNo = self.detail?.card_number , cardNo != "" { self.detailArray?.append(("card_number".localized , String(cardNo))) }
            if let targetNo = self.detail?.target_card_number , targetNo != "" {
				if targetNo.length == 16 {
                    self.detailArray?.append(("destination_card_number".localized , String(targetNo)))
				}
				else {
					self.detailArray?.append(("destination_sheba_number".localized , String(targetNo)))
				}
			}
            
			
            self.recieptButton = SMBottomButton(frame: CGRect.init(x: 0, y: 30, width: self.view.frame.width - 20 , height: 50 ))
            let footerView = UIView(frame: CGRect.init(x: 10, y: 0, width: self.view.frame.width - 20 , height: 80 ))
            self.recieptButton?.colors = [UIColor(netHex: 0x66bdf7), UIColor(netHex: 0x2a91e9)]
            self.recieptButton?.layer.cornerRadius = 25
            self.recieptButton?.setTitle("showreciept".localized, for: .normal)
            self.recieptButton?.enable()
            self.recieptButton?.addTarget(self, action: #selector(self.recieptPressed(_:)), for: .touchUpInside)
            footerView.addSubview(self.recieptButton!)
            self.tableView.tableFooterView = footerView
            
            self.tableView.reloadData()
        }, onFailed: {err in
            SMLog.SMPrint(err)
            SMLoading.hideLoadingPage()
        })
        self.tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @objc
    func recieptPressed(_ button: UIButton){
		
		var status = "";
		switch rowData?.is_paid.rawValue {
		case 1:
			status = "success.payment".localized
		case 5:
			status = "success.payment".localized
		default:
			status = "history.paygear.receive.waiting".localized
		}
        let dic = ["recieveName".localized : rowData?.receiver.name ,"transType".localized : SMStringUtil.getTransType(type: (rowData?.transaction_type.rawValue)!), "status".localized :  status , "amount".localized : rowData?.amount  ,"invoice_number".localized : rowData?.invoice_number,"date".localized : date] as [String : Any]
//        let dic = ["status".localized :  (rowData?.is_paid)! == IS_PAID_STATUS.PAID ? "success.payment".localized : "history.paygear.receive.waiting".localized , "amount".localized : rowData?.amount,"invoice_number".localized : rowData?.invoice_number,"date".localized : date] as [String : Any]
        
        let result = ["result" : dic ,"state" : rowData?.is_paid.rawValue] as NSDictionary
       
            SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (detailArray?.count) ?? 0
    }
    
    ///Handle reciept
    func close() {
        
        self.dismiss(animated: true, completion: {
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        })
    }
    
    func screenView() {
        SMReciept.getInstance().screenReciept(viewcontroller: self)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: self.view.frame.width, height: 80.0))
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell") as! SMHistoryTableViewCell
        cell.frame = CGRect.init(x: 0.0, y: 0.0, width: self.view.frame.width, height: 80.0)
        cell.amountLabel.text = String(rowData!.amount).inRialFormat().inLocalizedLanguage()
        cell.timeLabel.text = Date.init(timeIntervalSince1970: TimeInterval((rowData!.pay_date != 0 ? rowData!.pay_date: rowData!.created_at_timestamp)/1000)).localizedDateTime()
		
        cell.descLabel.text = rowData!.receiver.name
        
        switch rowData!.order_type {
        case .CHARGE:
            cell.titleLabel.text = "history.paygear.charge".localized
            cell.titleImage.isHidden = true
            cell.descLabel.text = "history.paygearcard".localized
            cell.profileImage.image = UIImage.init(named: "AppIcon")
        case .CASH_OUT:
            cell.titleImage.isHidden = false
            if rowData!.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "down-arrow")
                cell.titleLabel.text = "history.withdraw".localized
			}
			else if (rowData?.is_paid == .REFUND) {
				cell.titleImage.image = UIImage.init(named: "up-arrow")
				cell.titleLabel.text = "history.refund".localized
			}
			else {
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "history.withdraw.waiting".localized
            }
            cell.profileImage.image = UIImage.init(named: "AppIcon")
        case .P2P:
            p2p(cell: cell, row: rowData!)
        case .CLUBPAY:
            club(cell: cell, row: rowData!)
        case .REQUESTMONEY:
            SMLog.SMPrint("request")
        case .PARTIAL_PAY:
            SMLog.SMPrint("partial")
        case .MULTIPLE_PAY:
            SMLog.SMPrint("multiple")
        default:
            p2p(cell: cell, row: rowData!)
        }
      
        
        
        
        headerView.addSubview(cell)
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailcell", for: indexPath) as! SMHistoryDetailTableViewCell
        cell.title.text = detailArray![indexPath.row].0.inLocalizedLanguage()
        cell.value.text = detailArray![indexPath.row].1.inLocalizedLanguage()
        return cell
    }
    
    func p2p(cell: SMHistoryTableViewCell , row : PAY_obj_history){
        
        cell.titleImage.isHidden = false
		let cAccountId = accountId != nil ? accountId : SMUserManager.accountId

        if row.receiver.account_id == cAccountId {
            
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "up-arrow")
                cell.titleLabel.text = "history.paygear.receive".localized
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "history.paygear.receive.waiting".localized
            }
            
            if let pic = row.sender.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: true)
                let str = request.fs_getFileURL(pic)
                cell.profileImage?.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleAspectFit)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
            cell.descLabel.text = row.sender.name
        }
        else{
            
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "down-arrow")
                cell.titleLabel.text = "history.paygear.pay".localized
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "history.paygear.pay.waiting".localized
            }
            
            if let pic = row.receiver.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: true)
                let str = request.fs_getFileURL(pic)
                cell.profileImage?.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleAspectFit)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
        }
    }
    
    
    
    func club(cell: SMHistoryTableViewCell , row : PAY_obj_history){
        
        cell.titleImage.isHidden = false
		let cAccountId = accountId != nil ? accountId : SMUserManager.accountId
        if row.receiver.account_id == cAccountId{
            
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "up-arrow")
                cell.titleLabel.text = "history.paygear.receive.club".localized
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "history.paygear.receive.club.waiting".localized
            }
            
            if let pic = row.sender.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: true)
                let str = request.fs_getFileURL(pic)
                cell.profileImage?.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleAspectFit)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
            cell.descLabel.text = row.sender.name
        }
        else{
            
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "down-arrow")
                cell.titleLabel.text = "history.paygear.pay.club".localized
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "history.paygear.pay.club.waiting".localized
            }
            
            if let pic = row.receiver.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: true)
                let str = request.fs_getFileURL(pic)
                cell.profileImage?.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleAspectFit)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}











