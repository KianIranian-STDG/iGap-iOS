//
//  SMHistory.swift
//  PayGear
//
//  Created by amir soltani on 5/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation
import models
import webservice

class SMHistory: SMEntity {
    
    static let ENTITY_NAME = "History"
    

	static func getHistoryFromServer(last:String?, itemCount:Int? = 20, accountId:String? = nil, _ onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
        var serverHistory = [PAY_obj_history]()
        let cardRequest = WS_methods(delegate: self, failedDialog: true)
        cardRequest.addSuccessHandler { (response : Any) in
            for item in (response as! NSDictionary)["result"] as! [NSDictionary]{
                let historyItem = PAY_obj_history()
                ////////////////////////////////////Set object
                historyItem._id = item["_id"] as? String ?? ""
                historyItem.amount = item["amount"] as? Int ?? 0
//                historyItem.card_number = item["card_number"] as! String
                historyItem.club_cash_back_amount = item["club_cash_back_amount"] as? Int ?? 0
                historyItem.club_discount_price = item["club_discount_price"] as? Int ?? 0
                historyItem.created_at_timestamp = item["created_at_timestamp"] as? Int ?? 0
				if (item["status"] as AnyObject).isKind(of:NSNull.self) {
					historyItem.is_paid = IS_PAID_STATUS.WAITING
				}
				else {
					historyItem.is_paid = IS_PAID_STATUS(rawValue: UInt(item["status"] as! NSInteger)) ?? IS_PAID_STATUS.WAITING
				}
//                historyItem. = item["desc"] as! String
                historyItem.discount_price = item["discount_price"] as? Int ?? 0
                historyItem.has_coupon = (item["has_coupon"] != nil)
                historyItem.invoice_number = item["invoice_number"] as? Int ?? 0
                let receiver = PU_obj_account()
                let sender = PU_obj_account()
                if let receive = (item["receiver"] as? NSDictionary){
                receiver.account_id = receive["_id"] as? String ?? ""
                receiver.account_type = ACCOUNT_TYPE.init(receive["account_type"] as? UInt32 ?? 0)
                receiver.name = receive["name"] as? String ?? ""
                receiver.username = receive["username"] as? String ?? ""
                receiver.profile_picture = receive["profile_picture"] as? String ?? ""
                }
                if let send = (item["sender"] as? NSDictionary){
                sender.account_id = send["_id"] as? String ?? ""
                sender.account_type = ACCOUNT_TYPE.init(send["account_type"] as? UInt32 ?? 0)
                sender.name = send["name"] as? String ?? ""
                sender.username = send["username"] as? String ?? ""
                sender.profile_picture = send["profile_picture"] as? String ?? ""
                }
                historyItem.order_type = ORDER_TYPE(rawValue: item["order_type"] as! NSInteger) ?? ORDER_TYPE.DEFAULT
                historyItem.pay_date = item["pay_date"] as? Int ?? 0
                historyItem.payed_price = item["payed_price"] as? Int ?? 0
                historyItem.target_card_number = item["target_card_number"] as? String ?? ""
                historyItem.receiver = receiver
                historyItem.sender = sender
                serverHistory.append(historyItem)
            }
            
            onSuccess?(serverHistory)
        }
        
        
        
        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            SMLoading.hideLoadingPage()
            onFailed?(response)
            
        })
		
		cardRequest.pc_paymenthistory(last, perpage: itemCount!,accountId: accountId ?? nil)
        
    }
    
    
    
	static func getDetailFromServer(accountId : String? = nil, orderId : String ,_ onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
        let cardRequest = WS_methods(delegate: self, failedDialog: true)
        let serverHistory = PAY_obj_history()
        cardRequest.addSuccessHandler { (response : Any) in
            
            if let traceNo = (response as! NSDictionary)["trace_no"] as? Int{
                serverHistory.trace_no = traceNo
            }
            if let invoiceNo = (response as! NSDictionary)["invoice_number"] as? Int{
                serverHistory.invoice_number = invoiceNo
            }
            if let cardNumber = (response as! NSDictionary)["card_number"] as? String{
                serverHistory.card_number = cardNumber
            }
            if let targetCardNumber = (response as! NSDictionary)["target_card_number"] as? String{
                serverHistory.target_card_number = targetCardNumber
            }
            if let targetCardNumber = (response as! NSDictionary)["target_sheba_number"] as? String{
                serverHistory.target_card_number = targetCardNumber
            }
			if let payDate = (response as! NSDictionary)["pay_date"] as? Int{
				serverHistory.pay_date = payDate
			}
			if let ttype = (response as! NSDictionary)["transaction_type"] as? Int{
				serverHistory.transaction_type = TRANSACTION_TYPE(rawValue: ttype)!
			}
			if let amount = (response as! NSDictionary)["amount"] as? Int{
				serverHistory.amount = amount
			}
			if let is_paid = (response as! NSDictionary)["is_paid"] as? Int{
				serverHistory.is_paid = IS_PAID_STATUS(rawValue: UInt(is_paid))!
			}
            // get receiver data
			if let receiver = (response as! NSDictionary)["receiver"] as? NSDictionary {
                serverHistory.receiver = PU_obj_account()
                if let accountId = receiver["_id"] as? String {
                    serverHistory.receiver.account_id = accountId
                }
                if let receiverName = receiver["username"] as? String {
                    serverHistory.receiver.name = receiverName
                }
                if let balanceAtm = receiver["balance_atm"] as? NSInteger {
                    serverHistory.receiver.balance_atm = balanceAtm
                }
			}
            // get sender data
            if let sender = (response as! NSDictionary)["sender"] as? NSDictionary {
                serverHistory.sender = PU_obj_account()
                if let accountId = sender["_id"] as? String {
                    serverHistory.sender.account_id = accountId
                }
                if let receiverName = sender["username"] as? String {
                    serverHistory.sender.name = receiverName
                }
                if let balanceAtm = sender["balance_atm"] as? NSInteger {
                    serverHistory.sender.balance_atm = balanceAtm
                }
            }
			
            onSuccess?(serverHistory)
        }
        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            SMLoading.hideLoadingPage()
            onFailed?(response)
            
        })
		cardRequest.pc_paymentdetails(String(orderId), accountId: accountId)
        
    }
    
    
}
