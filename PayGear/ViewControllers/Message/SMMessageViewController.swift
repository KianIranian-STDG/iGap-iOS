//
//  SMMessageViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 8/14/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import messages

/// Subclass of MSG_ThreadController to load pod message it also has an other duty
/// Because of a problem on adding pod-action and customizing payment action
/// This class handle some event from p2p message to pay, request, confirm pay and show receipt on message
class SMMessageViewController: MSG_ThreadController, SMPaymentPopupDelegate {


	/// Paygear card info
	private var card : SMCard!
	/// Payment types
	///
	/// - SMRequest: set init payment as request
	/// - SMPay: set init payment as pay
	private enum SMPaymentType : Int {
		case SMRequest            = 3
		case SMPay                = 5
	}
	/// Load visible view controller to show some popup and loading view
	var presenterVC : UIViewController!
	var popup : SMPaymentPopup!
	
	/// In confirm payment by request, the payment needs token
	private var payToken: String!
	/// Receiver information, such as name, id and ...
	private var receiver : PU_obj_account!
	private var amount : String!
	var finishDelegate : HandleDefaultCard?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.SMTitle = "پیام‌ها".localized

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

	/// Public method to accessible from Other class
	///
	/// - Parameter receiver: message partner info to show confirm message and validate payment
	public func showPopupToSelectPaymentType(to receiver: PU_obj_account) {
		
		presenterVC = ((SMNavigationController.shared.viewControllers[0] as! SMMainTabBarController).viewControllers![2] as! SMNavigationController).visibleViewController

		SMLoading.shared.showInputAmountByTwoTypeActionDialog(viewController: self, icon: nil, title: "", message: "", yesPressed: { (amount) in
			self.handlePaymentAction(amount: (amount as! String).inEnglishNumbers(), type: .SMRequest, receiver: receiver)
		}) { (amount) in
			self.handlePaymentAction(amount: (amount as! String).inEnglishNumbers(), type: .SMPay, receiver: receiver)
		}
	}
	
	/// Show Receipt of an order selected from message pod
	///
	/// - Parameter orderId: the id of transaction
	public func showReceipt(byOrderId orderId: String) {
		
		presenterVC = ((SMNavigationController.shared.viewControllers[0] as! SMMainTabBarController).viewControllers![2] as! SMNavigationController).visibleViewController

		SMLoading.showLoadingPage(viewcontroller: presenterVC)
		SMHistory.getDetailFromServer(accountId: SMUserManager.accountId, orderId: orderId, { (success) in
			SMLoading.hideLoadingPage()
			
			if let row = (success as? PAY_obj_history) {
				
				let date = Date.init(timeIntervalSince1970: TimeInterval((row.pay_date != 0 ? row.pay_date: row.created_at_timestamp)/1000)).localizedDateTime()
				let dic = ["recieveName".localized : row.receiver.name ,"transType".localized : SMStringUtil.getTransType(type: (row.transaction_type.rawValue)), "status".localized :  (row.is_paid) == IS_PAID_STATUS.PAID ? "success.payment".localized : "history.paygear.receive.waiting".localized , "amount".localized : row.amount  ,"invoice_number".localized : row.invoice_number,"date".localized : date] as [String : Any]
				let result = ["result" : dic ] as NSDictionary
				SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
			}
			else {
				//show not available receipt
			}
		}) { (error) in
			SMLog.SMPrint(error)
			SMLoading.hideLoadingPage()
		}
	}
	
	/// Confirm Request and Pay back it
	///
	/// - Parameters:
	///   - Target: the view controller called it
	///   - Info: Pay info
	///   - istiny: I dont know what is it
	public func confirmPaymentRequest(withTarget Target: Any!, info Info: PAY_obj_paysheet!, istiny: Bool) {
		
		presenterVC = ((SMNavigationController.shared.viewControllers[0] as! SMMainTabBarController).viewControllers![2] as! SMNavigationController).visibleViewController
		getCardInfo()
		amount = String(describing:  Info!.totalPrice)
		receiver = Info.receiverInfo
		payToken = Info.orderId
		self.showPopupMessage(amount: amount!, receiver: receiver)
	}
	
	
	/// Show Payment action
	///
	/// - Parameters:
	///   - amount: amount of transfer
	///   - type: pay or request
	///   - receiver: receiver info
	private func handlePaymentAction(amount: String, type: SMPaymentType, receiver: PU_obj_account) {
		
		if type == .SMPay {
			//show pay popup
            self.showPopupMessage(amount: amount, receiver: receiver)
		}
		else {
			//show confirm box of request
			if Int(amount) != nil {
				var message = "Request.Money.message".localized
				message = message.replace("user", withString: receiver.getName() ?? receiver.name ?? "")
				message = message.replace("price", withString: amount.inLocalizedLanguage())
				
				
				SMLoading.shared.showNormalDialog(viewController: self, height: 180, isleftButtonEnabled: true, title: "Request.Money".localized, message: message, yesPressed: { (value) in
					//send request
					self.initRequest(amount: amount, receiver: receiver)
				}) {
					//nothing
				}
			}
			else {
				SMLoading.shared.showNormalDialog(viewController: self.presenterVC, height: 180, isleftButtonEnabled : false, title: "error".localized, message: "fill.amount".localized)
				
			}
		}
	}
	
	/// Show PaymentPopUp
	///
	/// - Parameters:
	///   - amount: value to transfer
	///   - receiver: receiver info
	private func showPopupMessage(amount: String, receiver: PU_obj_account) {
		
		self.receiver = receiver
		self.amount = amount
		DispatchQueue.main.async {
			self.popup = SMPaymentPopup.loadFromNib()
			self.popup.confirmBtn.addTarget(self, action: #selector(self.confirmPopupButtonSelected), for: .touchUpInside)
			self.popup.delegate = self
			self.popup.type = .PopupUser
			self.popup.value = ["price":amount, "name": receiver.getName() ?? receiver.name ?? ""]
			

			self.getCardInfo()
			self.popup.currentAmount = Int(String.init(describing: self.card.balance ?? 0).inRialFormat().inLocalizedLanguage().onlyDigitChars())!
			if let insertedAmount = Int(amount)  {
				if Int(self.popup.currentAmount) > insertedAmount {
					do {
						try self.popup.paymentTypeSwitch.setIndex(0, animated: true)
					}
					catch {
						
					}
				}
				else {
					do {
						try self.popup.paymentTypeSwitch.setIndex(0, animated: true)
					}
					catch {
						
					}
				}
				
				let window = UIApplication.shared.keyWindow!
				window.addSubview(self.popup)
				
			}
			else {
				SMLoading.shared.showNormalDialog(viewController: self.presenterVC, height: 180, isleftButtonEnabled : false, title: "error".localized, message: "fill.amount".localized)
			}
		}
		
	}
	
	/// Payment Popup button selected
	@objc func confirmPopupButtonSelected() {
	
		self.popup.removeFromSuperview()
		//check if
		initPayment(amount: self.amount, receiver: receiver, payRequest: false, token: payToken)
	}
	
	/// Make Request of payment
	///
	/// - Parameters:
	///   - amount: amount
	///   - receiver: receiver info
	private func initRequest(amount: String, receiver: PU_obj_account) {
		
		let receiverId = receiver.account_id
		
		SMLoading.showLoadingPage(viewcontroller: presenterVC)
		SMCard.initPayment(amount: Int(amount), accountId: SMUserManager.accountId , from: receiverId, isCredit: false, onSuccess: { response in
			SMLoading.hideLoadingPage()
			//message request has been sent
			
		}, onFailed: { (err) in
			SMLoading.hideLoadingPage()
			//show error on request
		})
		
	}
	/// Make Payment
	///
	/// - Parameters:
	///   - amount: transfer
	///   - receiver: receiver info
	///   - payRequest: the payment is response of a request if it is true
	///   - token: token of request payment, if payRequest is flase this value is useless
	private func initPayment(amount: String, receiver: PU_obj_account?, payRequest: Bool, token: String? = nil) {
		
		var receiverId = ""
		if let re = receiver {
			receiverId = re.account_id
		}
		if  SMUserManager.pin != nil, SMUserManager.pin == true {
			
			SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: "enterpin".localized, yesPressed: { pin in
				// user entered pin so we try to initailize payment
				SMLoading.showLoadingPage(viewcontroller: self.presenterVC)

                SMCard.initPayment(amount: Int(amount), accountId: receiverId, isCredit: false, onSuccess: { response in
					
					let json = response as? Dictionary<String, AnyObject>
					SMUserManager.publicKey = json?["pub_key"] as? String
					SMUserManager.payToken = json?["token"] as? String
					
					let para  = NSMutableDictionary()
					para.setValue(self.card.token, forKey: "c")
					para.setValue((pin as! String).onlyDigitChars(), forKey: "p2")
					para.setValue(self.card.type, forKey: "type")
					para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
					para.setValue(self.card.bankCode, forKey: "bc")
					
					let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
					let jsonString = String(data: jsonData, encoding: .utf8)
					
					if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey) {
						// payment init susccessfully so called payment
						SMCard.payPayment(enc: enc, onSuccess: {resp in
							
							SMLoading.hideLoadingPage()

							if let result = resp as? NSDictionary{
								
								SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
							}
						}, onFailed: {err in
							SMLoading.hideLoadingPage()
							SMLog.SMPrint(err)
							
							if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
								SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
							}
						})
					}
					
					
				}, onFailed: { (err) in
					SMLoading.hideLoadingPage()
					//					SMLog.SMPrint(err)
					//					self.gotobuttonState()
				})
				})
		}
		else {
			let viewController = SMWalletPasswordViewController(style: .grouped)
			SMMainTabBarController.qrTabNavigationController.pushViewController(viewController, animated: true)
		}
	}
	
	/// Get paygear card info
	private func getCardInfo() {
		let userCards = SMCard.getAllCardsFromDB()
			for card in userCards {
				if card.type == 1 {
					self.card = card
				}
		}
	}

}


// MARK: - Extention to  Receipt handleing
extension SMMessageViewController : HandleReciept {
	
	/// Close action on Receipt
	override func close() {
		self.dismiss(animated: false, completion: {
			self.view.endEditing(true)
			self.tabBarController?.tabBar.isUserInteractionEnabled = true
			self.finishDelegate?.finishDefault(isPaygear: true, isCard: false)
			
		})
		
	}
	
	/// Make screenshot on Receipt
	func screenView() {
		SMReciept.getInstance().screenReciept(viewcontroller: self)
	}
}
