//
//  SMWalletPasswordTableViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice

/// Class to Set Passcode
class SMWalletPasswordViewController: SMSettingTableViewController {

	/// Title of cells when page is set passcode
	let newFormTitle = ["newPassword","confirmNewPassword","confirm"]
	/// Title of cells when page is change passcode
	let fullFormTitle = ["currentPassword","newPassword","confirmNewPassword","confirm"]
	/// Container title to use in app as title object
	var formTitle = [""]
	var cardInfo: SMCard?
	var textFields : [UITextField] = []
	var hasOldPin : Bool?
	/// When this page is called from merchant section this value is filled otherwise it is null
	var merchant: SMMerchant?
	
    /// Check set passcode or change passcode view
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		if cardInfo != nil {
			hasOldPin = false
		}
		else {
			hasOldPin = SMUserManager.pin ?? false
		}
		if hasOldPin! {
			formTitle = fullFormTitle
		}
		else  {
			formTitle = newFormTitle
		}
		
		self.SMTitle = "setting.privacy.change.pin.title".localized
		
		
		
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	/// Validate form and then call api to set/change passcode
	///
	/// - Parameter sender: button
	@objc func callChangeWalletPassAPI(_ sender: UIButton) {

		var oldPassword = ""
		var newPassword = ""
		var newCPassword = ""
		
		for textField in textFields {
			switch textField.tag {
			case 0:
				if hasOldPin! {
					oldPassword = textField.text!.onlyDigitChars()
				}
				else {
					newPassword = textField.text!.onlyDigitChars()
				}
				break
			case 1:
				if hasOldPin! {
					newPassword = textField.text!.onlyDigitChars()
				}
				else {
					newCPassword = textField.text!.onlyDigitChars()
				}
				break
			case 2:
				newCPassword = textField.text!.onlyDigitChars()
				break
			default:
				//
				break
			}
			
		}

		if  SMValidation.walletPassCodeValidation(newPassword) {
		
			if newPassword == newCPassword {
			
				//Request to server
				callAPI(oldPass: oldPassword, newPass: newPassword)
			}
			else {
				
				SMMessage.showWithMessage("PassesAreNotMatched".localized)
			}
		}
		else {
			SMMessage.showWithMessage("FieldValuesAreNotValid".localized)
		}

		
	}
	
	
	/// Call API to set/change passcode, the api path of both action is same, if old pass is Empty the action is set passcode
	///
	/// - Parameters:
	///   - oldPass: the current passcode
	///   - newPass: the passcode to be define
	func callAPI (oldPass: String, newPass: String) {
		
		SMLoading.showLoadingPage(viewcontroller: self, text: "loading.text".localized)

		let request = WS_methods.init(delegate: self, failedDialog: true)

		request.addSuccessHandler { (response) in
			//
			SMLoading.hideLoadingPage()
			if self.merchant == nil {
				SMUserManager.pin = true
			}
			
			var message = "SuccessfullChangePass".localized
			if !self.hasOldPin! {
				message = "SuccessfullSetPass".localized
			}
			SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "message".localized, message: message ,yesPressed :{yes in
				
				if self.merchant != nil {
					let message2 = "GoToMerchantPage".localized
					SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "message".localized, message: message2 ,yesPressed :{yes in
						
						let vcs = self.navigationController?.viewControllers
						for vc in vcs! {
							if (vc.isKind(of: SMMerchantViewController.self)) {
								(vc as! SMMerchantViewController).merchantCard?.protected = true
								self.navigationController?.popToViewController(vc, animated: true)
								break
							}
						}
					})
				}
				else {
					self.navigationController?.popViewController(animated: true)
				}

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

		if merchant != nil {
			request.pc_walletpin(newPass, oldpin: oldPass, cardhash: self.cardInfo?.token, accountId: merchant?.id)
		}
		else {
			request.pc_walletpin(newPass, oldpin: oldPass, cardhash: self.cardInfo?.token)
		}
		
	}
	
	
    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
			confirmBtn.addTarget(self, action: #selector(self.callChangeWalletPassAPI(_:)),         for: .touchUpInside)
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
		
		cell.titleField.placeholder = "\(formTitle[indexPath.row].localized)(\("4Digit".localized))"
		

		return cell
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 90
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
