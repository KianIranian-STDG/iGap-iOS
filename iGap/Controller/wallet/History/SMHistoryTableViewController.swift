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

class SMHistoryTableViewController: BaseTableViewController {
    var isInStandardHistoPage = false
	@IBOutlet var indicator: UIActivityIndicatorView!
	var rowData : [PAY_obj_history]?
	var loadingData : Bool = false
	var hasMoreData : Bool = true
    @IBOutlet weak var placeHolderLabel: UILabel!
	var accountId: String?
	
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateHisto(_:)),
                                               name: NSNotification.Name(rawValue: SMConstants.notificationHistoryMerchantUpdate),
                                               object: nil)
    }
    
    @objc func updateHisto(_ aNotification: Notification) {
        self.rowData?.removeAll()
        self.tableView.reloadWithAnimation()
        if let userId = aNotification.userInfo?["id"] as? String
        
        {
            accountId = userId
            if accountId == nil {
                SMHistory.getHistoryFromServer(last : "",  {his in
                    self.refreshControl?.endRefreshing()
                    self.doSuccess(his as Any)
                }, onFailed: {err in
                    self.refreshControl?.endRefreshing()
                    self.doFail(err)
                })
            }
            else {
                SMHistory.getHistoryFromServer(last : "", accountId: accountId!,  {his in
                    self.refreshControl?.endRefreshing()
                    self.doSuccess(his as Any)
                }, onFailed: {err in
                    self.refreshControl?.endRefreshing()
                    self.doFail(err)
                })
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
//        self.SMTitle = "transaction.history".localized
        SMLoading.showLoadingPage(viewcontroller: self)
		if accountId == nil {
            SMHistory.getHistoryFromServer(last : "",  {his in
                self.doSuccess(his as Any)
            }, onFailed: {err in
                self.doFail(err)
            })
		}
		else {
			SMHistory.getHistoryFromServer(last : "", accountId: accountId!,  {his in
				self.doSuccess(his as Any)
			}, onFailed: {err in
				self.doFail(err)
			})
		}
        self.tableView.tableFooterView = UIView()
		refreshControl = UIRefreshControl()
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl!)
		}
		refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        let direction = SMDirection.TextAlignment()
//        self.placeHolderLabel.textAlignment = direction
        
//        self.placeHolderLabel.font = SMFonts.IranYekanRegular(17)
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "WALLET_HISTORY".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        if isInStandardHistoPage {
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        }
    }
	@objc func pullToRefresh() {
		
		if accountId == nil {
			SMHistory.getHistoryFromServer(last : "",  {his in
				self.refreshControl?.endRefreshing()
				self.doSuccess(his as Any)
			}, onFailed: {err in
				self.refreshControl?.endRefreshing()
				self.doFail(err)
			})
		}
		else {
			SMHistory.getHistoryFromServer(last : "", accountId: accountId!,  {his in
				self.refreshControl?.endRefreshing()
				self.doSuccess(his as Any)
			}, onFailed: {err in
				self.refreshControl?.endRefreshing()
				self.doFail(err)
			})
		}
	}
	func doSuccess(_ his : Any) {
//        SMLoading.hideLoadingPage()
		self.rowData = his as? [PAY_obj_history]
		if self.rowData?.count == 0 {
			self.placeHolderLabel.text = "PU_NODATA".localizedNew
		}
		else{
			self.placeHolderLabel.frame.size = CGSize.init(width: self.placeHolderLabel.frame.width, height: 0 )
		}
		self.tableView.reloadWithAnimation()
	}
	
	func doFail(_ err: Any) {
//        if SMValidation.showConnectionErrorToast(err) {
//            SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
//        }
		SMLog.SMPrint(err)
//        SMLoading.hideLoadingPage()
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
        return (rowData?.count) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historycell", for: indexPath) as! SMHistoryTableViewCell
        let row = rowData![indexPath.row]
        cell.amountLabel.text = String(row.amount).inRialFormat().inLocalizedLanguage()
        cell.timeLabel.text = Date.init(timeIntervalSince1970: TimeInterval((row.pay_date != 0 ? row.pay_date: row.created_at_timestamp)/1000)).localizedDateTime()
        cell.currencyLabel.text = "CURRENCY".localizedNew
        cell.descLabel.text = row.receiver.name
        print("ROW||||")
        print(row.order_type.rawValue)
        print(row)
        switch row.order_type {
        case .CHARGE:
            cell.titleLabel.text = "TTL_TRANSITION_CHARGE_WALLET".localizedNew
            cell.titleImage.isHidden = true
            cell.descLabel.text = "TTL_WALLET_ACCOUNT".localizedNew
            cell.profileImage.image = UIImage.init(named: "AppIcon")
        case .CASH_OUT:
            cell.titleImage.isHidden = false
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "up-arrow")
                cell.titleLabel.text = "TTL_IS_PAYED".localizedNew
            }
			else if (row.is_paid == .REFUND) {
				cell.titleImage.image = UIImage.init(named: "down-arrow")
				cell.titleLabel.text = "TTL_MONEY_REFUND".localizedNew
			}
			else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "TTL_CASHOUT_PENDING".localizedNew
            }
            cell.profileImage.image = UIImage.init(named: "AppIcon")
        case .P2P:
            p2p(cell: cell, row: row)
        case .CLUBPAY:
            club(cell: cell, row: row)
        case .REQUESTMONEY:
            SMLog.SMPrint("request")
        case .PARTIAL_PAY:
            SMLog.SMPrint("partial")
        case .MULTIPLE_PAY:
            SMLog.SMPrint("multiple")
        case .SALE_SHARE:
            self.SaleShare(cell: cell, row: row)
        default:
             p2p(cell: cell, row: row)
        }

        return cell
    }
	
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let lastElement = rowData!.count - 1
		if !loadingData && hasMoreData && indexPath.row == lastElement  {
			indicator.startAnimating()
			loadingData = true
			loadMoreData()
			tableView.tableFooterView = indicator
			tableView.tableFooterView?.isHidden = false
		}
	}
	
	func loadMoreData() {
		
        SMHistory.getHistoryFromServer(last : rowData![(rowData?.count)!-1]._id ,accountId:accountId , { his in
			
			if (his as! [PAY_obj_history]).count < 20  {
				self.hasMoreData = false
			}
			self.rowData?.append(contentsOf: his as! [PAY_obj_history])
			DispatchQueue.main.async {
				self.tableView.reloadData()
				self.indicator.stopAnimating()
				self.loadingData = false
			}
		}, onFailed: {err in
			SMLog.SMPrint(err)
//            if SMValidation.showConnectionErrorToast(err) {
//                SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
//            }
			self.indicator.stopAnimating()
			self.loadingData = false
//        })}else{
//
//            SMHistory.getHistoryFromServer(last: rowData![(rowData?.count)!-1]._id, itemCount: 20, accountId: accountId, { his in
//
//                if (his as! [PAY_obj_history]).count < 20  {
//                    self.hasMoreData = false
//                }
//                self.rowData?.append(contentsOf: his as! [PAY_obj_history])
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    self.indicator.stopAnimating()
//                    self.loadingData = false
//                }
//            }, onFailed: {err in
//                SMLog.SMPrint(err)
//                if SMValidation.showConnectionErrorToast(err) {
//                    SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
//                }
//                self.indicator.stopAnimating()
//                self.loadingData = false
//            })
        })
	}
    
    
    func p2p(cell: SMHistoryTableViewCell , row : PAY_obj_history){
       
        cell.titleImage.isHidden = false
        print(accountId as Any)
        print(SMUserManager.accountId)
		let cAccountId = accountId != nil ? accountId : SMUserManager.accountId
        if row.receiver.account_id == cAccountId {
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "down-arrow")
                cell.titleLabel.text = "TTL_RECIEVE_FRM".localizedNew
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "TTL_PAYMENT_PENDING_FRM".localizedNew
            }
            if let pic = row.sender.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: false)
                _ = request.fs_getFileURL(pic)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
                cell.descLabel.text = row.sender.name
        }
        else{
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "up-arrow")
                cell.titleLabel.text = "TTL_PAYED_WITH_WALLED_CARD_TO".localizedNew
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "TTL_PAY_WITH_WALLET_CARD_PENDING".localizedNew
            }
            
            if let pic = row.receiver.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: false)
                _ = request.fs_getFileURL(pic)
//                cell.profileImage?.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleAspectFit)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
        }
    }
    
    
    
    func club(cell: SMHistoryTableViewCell , row : PAY_obj_history){
        
        cell.titleImage.isHidden = false
		let cAccountId = accountId != nil ? accountId : SMUserManager.accountId
        if row.receiver.account_id == cAccountId {
            
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "up-arrow")
                cell.titleLabel.text = "TTL_BUY_CLUB_FROM".localizedNew
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "history.paygear.receive.club.waiting".localized
            }
            
            if let pic = row.sender.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: false)
                _ = request.fs_getFileURL(pic)
//                cell.profileImage?.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleAspectFit)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
            cell.descLabel.text = row.sender.name
        }
        else{
            
            if row.is_paid == .PAID {
                cell.titleImage.image = UIImage.init(named: "up-arrow")
                cell.titleLabel.text = "فروش طرح باشگاه به".localized
            }else{
                cell.titleImage.image = UIImage.init(named: "hourglass")
                cell.titleLabel.text = "در انتظار فروش طرح باشگاه به".localized
            }
            
            if let pic = row.receiver.profile_picture , pic != "" {
                let request = WS_methods(delegate: self, failedDialog: false)
                _ = request.fs_getFileURL(pic)
//                cell.profileImage?.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleAspectFit)
            }
            else{
                cell.profileImage.image = UIImage.init(named: "AppIcon")
            }
        }
    }
    
    func SaleShare(cell: SMHistoryTableViewCell , row: PAY_obj_history) {
        cell.titleImage.isHidden = false
        //let cAccountId = accountId != nil ? accountId : SMUserManager.accountId
        if row.is_paid  == .PAID{
            cell.titleImage.image = UIImage.init(named: "down-arrow")
            cell.titleLabel.text = "history.sale.share".localizedNew
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyDetailsVC = (storyboard?.instantiateViewController(withIdentifier: "historydetail") as! SMHistoryDetailTableViewController)
        historyDetailsVC.rowData = rowData?[indexPath.row]
        historyDetailsVC.accountId = accountId
        historyDetailsVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(historyDetailsVC, animated: true)
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











