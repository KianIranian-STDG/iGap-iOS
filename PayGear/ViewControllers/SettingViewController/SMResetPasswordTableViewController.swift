//
//  SMResetPasswordTableViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 7/21/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice

/// Reset Passcode
class SMResetPasswordTableViewController: SMSettingTableViewController {

	/// Title of cells
	let formTitle = ["otp","newPassword","confirmNewPassword","confirm"]
	var textFields : [UITextField] = []
	var cardInfo: SMCard?
	/// When this page is called from merchant section this value is filled otherwise it is null
	var merchant: SMMerchant?
	
    /// Call API to get sms to reset passcode
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		self.SMTitle = "setting.privacy.reset.pin.title".localized
		
		tableView.register(UINib(nibName: "SMFormTableViewCell", bundle: nil), forCellReuseIdentifier: "FormItem")
		tableView.separatorColor = .clear
		
		if cardInfo == nil {
			let allCard = SMCard.getAllCardsFromDB()
			for card in allCard {
				if card.type == 1 {
					cardInfo = card
				}
			}
		}

		let message = "reset.pass.otp.message".localized
		SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: true , title: "message".localized, message: message, rightButtonTitle : "send".localized ,
										  yesPressed :{yes in
											self.callOTPAPI()
											
		},
										  noPressed: {
											self.navigationController?.popViewController(animated: true)
		})
		
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
        return formTitle.count
    }

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width , height: 60))
		
		let lbl = UILabel(frame: CGRect(x: 15, y: 10, width: tableView.frame.size.width - 30 , height: 40))
		lbl.font = SMFonts.IranYekanBold(15)
		if merchant != nil {
			lbl.text = "\("setting.privacy.change.pin.title".localized) \(String(describing: (merchant?.name!)!))"
		}
		else {
			lbl.text = "\("setting.privacy.change.pin.title".localized) \(String(describing: (SMUserManager.fullName)))"
			
		}
		lbl.textAlignment = SMDirection.TextAlignment()
		view.addSubview(lbl)
		view.backgroundColor = .white
		return view
	}
	
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == formTitle.count - 1 {
			//button form
			let cell  = tableView.dequeueReusableCell(withIdentifier: "ExitItem")
			
			let confirmBtn = SMGradientButton()
			confirmBtn.enable()
			confirmBtn.colors = [UIColor(netHex: 0x00e676), UIColor(netHex: 0x2ecc71)]
			confirmBtn.backgroundColor = UIColor(netHex: 0x00e676)
			confirmBtn.titleLabel?.textColor = UIColor(netHex: 0xffffff)
			confirmBtn.setTitle("confirm".localized, for: .normal)
			confirmBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
			confirmBtn.contentMode = .center
			confirmBtn.contentHorizontalAlignment = .center
			confirmBtn.addTarget(self, action: #selector(self.callResetWalletPassAPI(_:)),         for: .touchUpInside)
			confirmBtn.translatesAutoresizingMaskIntoConstraints = false
			confirmBtn.layer.cornerRadius = 24
			cell?.selectionStyle = .none
			cell?.addSubview(confirmBtn)
			
			NSLayoutConstraint(item: confirmBtn, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: 15).isActive = true
			NSLayoutConstraint(item: confirmBtn, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 20).isActive = true
			NSLayoutConstraint(item: confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
			NSLayoutConstraint(item: confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
			
			return (cell)!
			
		}
		let cell  = tableView.dequeueReusableCell(withIdentifier: "FormItem") as! SMFormTableViewCell
		
		cell.titleLbl.text = formTitle[indexPath.row].localized
		cell.titleField.tag = indexPath.row
		
		if !textFields.contains(cell.titleField) {
			textFields.append(cell.titleField)
		}
		if indexPath.row == 0 {
			
			cell.titleField.placeholder = "\(formTitle[indexPath.row].localized)(\("6Digit".localized))"
		}
		else {
			cell.titleField.placeholder = "\(formTitle[indexPath.row].localized)(\("4Digit".localized))"
		}

		return cell
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}

	
	/// Validate form to reset passcode
	///
	/// - Parameter sender: button
	@objc func callResetWalletPassAPI(_ sender: UIButton) {
		var otp = ""
		var newPassword = ""
		var newCPassword = ""
		
		for textField in textFields {
			switch textField.tag {
			case 0:
				otp = textField.text!.onlyDigitChars()
				break
			case 1:
				newPassword = textField.text!.onlyDigitChars()
				break
			case 2:
				newCPassword = textField.text!.onlyDigitChars()
				break
			default:
				//
				break
			}
			
		}
		
		if SMValidation.walletPassCodeValidation(otp), SMValidation.walletPassCodeValidation(newPassword) {
			
			if newPassword == newCPassword {
				
				//request to server
				callResetAPI(otp: otp, newPass: newPassword)
			}
			else {
				
				SMMessage.showWithMessage("PassesAreNotMatched".localized)
			}
		}
		else {
			SMMessage.showWithMessage("FieldValuesAreNotValid".localized)
		}
	
	}
	
	
	/// Call API to reset passcode
	///
	/// - Parameters:
	///   - otp: code user received by sms
	///   - newPass: new passcode 
	func callResetAPI (otp: String, newPass: String) {
		
		SMLoading.showLoadingPage(viewcontroller: self, text: "loading.text".localized)
		
		let request = WS_methods.init(delegate: self, failedDialog: true)
		
		request.addSuccessHandler { (response) in
			//
			SMLoading.hideLoadingPage()
			
			let message = "SuccessfullSetPass".localized
			
			SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "message".localized, message: message ,yesPressed :{yes in
				
				self.navigationController?.popViewController(animated: true)
				
			})
			
			
			for textField in self.textFields {
				textField.text = ""
			}
		}
		
		request.addFailedHandler { (response) in
			
			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
			SMLoading.hideLoadingPage()
		}
		
		let accountId = (merchant != nil) ? merchant?.id : SMUserManager.accountId
		request.pc_resetWalletpin(otp, newPin: newPass, cardhash: self.cardInfo?.token, accountId: accountId)
		
	}

	/// Call API to get OTP message
	func callOTPAPI () {
		
		SMLoading.showLoadingPage(viewcontroller: self, text: "loading.text".localized)
		
		let request = WS_methods.init(delegate: self, failedDialog: false)
		
		request.addSuccessHandler { (response) in
			//
			SMLoading.hideLoadingPage()
			
			let message = "SuccessfullResetOTPSent".localized
			
			SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "message".localized, message: message ,yesPressed :{yes in
				
			})
		}
		
		request.addFailedHandler { (response) in
			
			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
			let message = "UnSuccessfullResetOTPSent".localized
			SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "message".localized, message: message ,yesPressed :{yes in
				
				self.navigationController?.popViewController(animated: true)
				
			})
			SMLoading.hideLoadingPage()
		}
		
		let accountId = (merchant != nil) ? merchant?.id : SMUserManager.accountId

		request.pc_otp(toResetWalletPinCardhash: self.cardInfo?.token, accountId: accountId)
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}

}
