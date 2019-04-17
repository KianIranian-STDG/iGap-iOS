//
//  ProfileViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/16/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import ImagePicker
import webservice
import SafariServices



/// Class to show user profile and let user to edit name-family, username, image and birthdate and provience
class SMProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate ,UINavigationControllerDelegate, SMPersianTimePickerDelegate {

	// MARK: - Variables:
	
    /// Handle to know which view selected during editing EditView
    ///
    /// - SMUserInfo: User name and family is selected
    /// - SMUsername: Username is selected
    private enum SMEditView : Int {
        case SMUserInfo                = 4
        case SMUsername                = 5
    }
	
	/// Status of Image profile during editing profile
	///
	/// - SMImageChanged: the image is changed
	/// - SMImageDeleted: the image is deleted
	/// - SMImageNotModified: the image is not modified
	private enum SMImageProfileStatus: Int {
		case SMImageChanged = 1
		case SMImageDeleted = 2
		case SMImageNotModified = 3
	}
	let heightOfComponent : CGFloat = 220.0
	
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImageView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileImageLbl: UILabel!
    @IBOutlet var userInfoBtn: UIButton!
    @IBOutlet var usernameBtn: UIButton!
    @IBOutlet var statePickerView: UIPickerView!
	var datePicker: SMPersianTimePicker!
	
    @IBOutlet var footerView: UIView!
    @IBOutlet var footerLbl: FRHyperLabel!
    
    @IBOutlet var editTextFieldView: UIView!
    @IBOutlet var editTF: UITextField!
    @IBOutlet var doneBtn: UIButton!
	
    private var editViewTag : Int!
    private var selectedIndexPath : IndexPath!
    private var provinceId : Int = 0
    private var stateList : [Dictionary<String, AnyObject>] = []
    
    private var accountInfo: PU_obj_account!
    private var imageProfileStatus : SMImageProfileStatus = .SMImageNotModified
    
    @IBOutlet var editTextFieldConstraintBottom: NSLayoutConstraint!
    @IBOutlet var pickecrViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Load functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.SMTitle = "profile.main.title".localized
        getAccountInfo()
        getState()
		
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.masksToBounds = true
		profileImage.image = SMImage.getImage(imageName: "profile.png")
		
		profileImageLbl.text = "edit".localized
		
		doneBtn.setTitle("confirm".localized, for: .normal)
        doneBtn.layer.borderColor =  UIColor(netHex: 0x999999).cgColor
        doneBtn.layer.cornerRadius = 5
        doneBtn.layer.borderWidth = 1
		
		statePickerView.frame.size.height = heightOfComponent
        statePickerView.delegate = self
        statePickerView.dataSource = self
        
        
		let saveBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 61, height: 40))

        saveBtn.setTitle("Save".localized, for: .normal)
        saveBtn.addTarget(self, action: #selector(saveProfileChange), for: .touchUpInside)
        saveBtn.titleLabel?.font = SMFonts.IranYekanBold(18)
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        
        userInfoBtn.setTitle("NameAndFamily".localized, for: .normal)
        usernameBtn.setTitle("Username".localized, for: .normal)
        
    }

	/// Setup footer view, this view shows a text about user profile
	func setFooterText() {
		
		footerLbl.numberOfLines = 0
		let string = "footerText".localized
		let linkAttributes: [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.foregroundColor : UIColor.blue,
			NSAttributedString.Key.font : SMFonts.IranYekanRegular(14),
			NSAttributedString.Key.link: URL(string: "http://www.google.com")!]
		
		let attributedString = NSMutableAttributedString(string: string , attributes: nil)

		if let range = string.range(of: "privacy.policy".localized) {
			SMLog.SMPrint(range)
			let range = NSRange(location: range.lowerBound.encodedOffset, length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
			attributedString.setAttributes(linkAttributes, range: range)
			
		}
		footerLbl.attributedText = attributedString
		footerLbl.layer.masksToBounds = true
//		footerLbl.textAlignment = SMDirection.TextAlignment()
		let handler = {
			(hyperLabel: FRHyperLabel?, substring: String?) -> Void in
			//open page
			SMLog.SMPrint("tapp privacy")
			if let url = URL(string: "https://paygear.ir/policy.html") {
				let svc = SFSafariViewController(url: url)
				self.present(svc, animated: true, completion: nil)
			}
		}
		footerLbl.setLinksForSubstrings(["privacy.policy".localized, "پگیر"], withLinkHandler: handler)

	}
	
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SMProfileViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SMProfileViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsetNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setupNotifications()
	}

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsetNotifications()
	}
	
    @objc
     func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
		
		self.editTextFieldConstraintBottom.constant = keyboardHeight + 1

        UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded();
        }
		
        SMLog.SMPrint(keyboardHeight);
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
		self.editTextFieldConstraintBottom.constant = -40

        UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded();

        }
		
        SMLog.SMPrint(keyboardHeight);
    }
	
	
    /// Reload text after loading data from server
    func reloadView () {
        
		//Reload data on username and name and image profile
        userInfoBtn.setTitle(self.accountInfo.name?.inLocalizedLanguage() ?? "NameAndFamily".localized , for: .normal)
        usernameBtn.setTitle(self.accountInfo.username?.inLocalizedLanguage() ?? "Username".localized, for: .normal)
		
		if accountInfo.profile_picture != nil && accountInfo.profile_picture != "" {
			profileImage.downloadedFrom(link: "\(SMUserManager.imageSource)\(String(accountInfo.profile_picture!.filter { !" \\ \n \" \t\r".contains($0) }))",
			contentMode: .scaleAspectFill) { (result) in
				if result {
					SMImage.saveImage(image: self.profileImage.image!, withName: "profile.png")
				}
			}
		}
		
		var frame =  self.view.bounds
		frame.origin.y =  frame.height
		frame.size.height = heightOfComponent
		datePicker = SMPersianTimePicker(frame: frame)
		datePicker.selectedDate = getDateFromString(string: accountInfo.birth_date ?? "")
		datePicker.inputs = [.Year, .Month, .Day]
		datePicker.backgroundColor = .white
		datePicker.delegate = self
		datePicker.pickerDidShow()
		
		self.view.addSubview(datePicker)
//        reload tableview
        tableView.reloadData()
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/

	
	// MARK: - Server Connections

	/// Get province lists
	func getState() {
		
		// get list of provience from server
		let request = WS_methods(delegate: self, failedDialog: false)
		request.addSuccessHandler { (response : Any) in
			if let jsonResult = response as? [Dictionary<String, AnyObject>] {
				self.stateList = jsonResult
				self.stateList.insert(["title": "SelectState".localized  as AnyObject,"id": 0 as AnyObject], at: 0)
				for state in self.stateList {
					if self.accountInfo.province_id != 0, state["id"] as! Int == self.accountInfo.province_id {
						let provinceIndex: IndexPath = IndexPath(row: 1, section: 1)
						if let cell = self.tableView.cellForRow(at: provinceIndex)  {
							(cell as! SMProfileTableViewCell).descriptionLbl.text = state["title"] as? String
						}
					}
				}
				self.statePickerView.reloadAllComponents()
			}
		}
		request.addFailedHandler({ (response: Any) in
			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
		})
		
		request.st_provincelist()
	}
	
	
	/// Get account info from API
	func getAccountInfo() {
		
		SMLoading.showLoadingPage(viewcontroller: self, text: "loading.text".localized)
		accountInfo = PU_obj_account()
		accountInfo.account_id = SMUserManager.accountId
		
		let request = WS_methods(delegate: self, failedDialog: true)
		
		request.addSuccessHandler { (response : Any) in
			
			if let jsonResult = response as? Dictionary<String, AnyObject> {
				
				if let value = jsonResult["username"] {
                    self.accountInfo.username = value as? String
				}
				
				if let value = jsonResult["name"]  {
					self.accountInfo.name = value as? String
				}
				
				if let value = jsonResult["profile_picture"] {
                    self.accountInfo.profile_picture = value as? String
				}
				
				if let value  = jsonResult["province_id"] {
					self.accountInfo.province_id = value as! Int
				}
				
				if let value = jsonResult["email"] {
                    self.accountInfo.email =  value as? String
				}
				
				if let value = jsonResult["birth_date"] {
                    self.accountInfo.birth_date = value as? String
				}
				if let value = jsonResult["account_type"] {
					self.accountInfo.account_type = ACCOUNT_TYPE(rawValue: UInt32(value as! Int))
				}
				
				self.reloadView()
				SMLoading.hideLoadingPage()
				
			}
			request.addFailedHandler({ (response: Any) in
				SMLoading.hideLoadingPage()
				if SMValidation.showConnectionErrorToast(response) {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
			})
			
		}
		request.pu_getaccountinfo(accountInfo, mod: 0)
		
	}
	// MARK: -
	
	
	/// Upload image profile if the image is changed
	///
	/// - Parameter closure: return uploaded image path
	func uploadImageProfile (closure: @escaping (_ imagePath: String) -> ()) {
		
		var imagePath : String = ""
		if self.imageProfileStatus == .SMImageChanged {
			
			SMLoading.showLoadingPage(viewcontroller: self, text: "".localized)
			let requestUploadFile: WS_methods = WS_methods.init(delegate: self, failedDialog: true)
			
			requestUploadFile.addSuccessHandler { (response: Any) in
				//
				imagePath = String(data: response as! Data, encoding: .utf8)!
				SMLoading.hideLoadingPage()
				closure(imagePath)
			}
			requestUploadFile.addFailedHandler({ (response) in
				if SMValidation.showConnectionErrorToast(response) {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
				SMLoading.hideLoadingPage()
				closure(imagePath)
			})
			
			requestUploadFile.fs_upload([profileImage.image!])
		}
		else {
			closure(imagePath)
		}
	}
	
	/// Save profile object on server
	@objc func saveProfileChange() {
		
		self.view.endEditing(true)
		
		/**
		* Call Update API
		*/
		
		uploadImageProfile { (imagePath) in
			SMLoading.showLoadingPage(viewcontroller: self, text: "".localized)
			let request: WS_methods = WS_methods.init(delegate: self, failedDialog: true)
			
			request.addSuccessHandler { (response : Any) in
				//dismiss loading
				SMLoading.hideLoadingPage()
				self.view.endEditing(false)
				
				SMImage.saveImage(image: self.profileImage.image!, withName: "profile.png")
				SMUserManager.firstName = "\(self.accountInfo.name!)"
				
				SMLoading.shared.showNormalDialog(viewController: self, height: 180 ,isleftButtonEnabled: false , title: "message".localized, message: "update.profile.done".localized ,yesPressed :{yes in
					
					self.navigationController?.popViewController(animated: true)
				})
				
				
			}
			
			request.addFailedHandler { (response : Any) in
				//dismiss loading
				if SMValidation.showConnectionErrorToast(response) {
					SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
				}
				SMLoading.hideLoadingPage()
				self.view.endEditing(false)
			}
			if self.imageProfileStatus != .SMImageNotModified {
				self.accountInfo.profile_picture = imagePath
			}
			request.pu_updateaccount(self.accountInfo.account_id, fields: self.accountInfo.returnJSON_UpdateProfile())
			
		}
		
	}
	
	// MARK: - Edit Field and Picker  Button Action
	
	/// Done button of Edit Field and Picker button selected
	///
	/// - Parameter sender: sender
	@IBAction func doneBtnDidSelect(_ sender: Any) {
		
		if editViewTag != nil  {
			switch editViewTag {
			case SMEditView.SMUserInfo.rawValue:
				userInfoBtn.setTitle(editTF.text!, for: .normal)
				accountInfo.name = editTF.text!
				break
			case SMEditView.SMUsername.rawValue:
				usernameBtn.setTitle(editTF.text!, for: .normal)
				accountInfo.username = editTF.text!
				break
			default:
				break
			}
		}
		else if selectedIndexPath != nil {
			let cell = tableView.cellForRow(at: selectedIndexPath) as! SMProfileTableViewCell
			cell.descriptionLbl.text = editTF.text!
			
			switch selectedIndexPath.section {
			case 0:
				accountInfo.email = editTF.text!
				break
			case 1:
				if selectedIndexPath.row == 0 {
					accountInfo.birth_date = editTF.text!
				}
				else if selectedIndexPath.row == 1 {
					accountInfo.province_id = self.provinceId
				}
				break
			default:
				break
			}
		}
		
		pickecrViewHeightConstraint.constant = 0
		self.editTextFieldConstraintBottom.constant = -40
		editTF.text = ""
		editTF.resignFirstResponder()
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
		selectedIndexPath = nil
		editViewTag = nil
	}
	
	///Province done button on Date Picker selected
	@IBAction func doneButtonSelected (_ sender: UIButton?) {
		
		self.pickecrViewHeightConstraint.constant = 0

		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	///Birthdate done button selected on DatePicker
	func doneButtonDidSelect(selectedDateString: String, selectedDate: Date) {
		
		let iso = DateFormatter()
		iso.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
		let isoFormatString = iso.string(from: selectedDate)
		
		accountInfo.birth_date = isoFormatString
		
		let cell = tableView.cellForRow(at: selectedIndexPath) as! SMProfileTableViewCell
		cell.descriptionLbl.text = selectedDateString
	}
    // MARK: - Image Picker
	
    /// ImagePicker done button did select
    ///
    /// - Parameter sender: sender
    @IBAction func imageViewDidSelect(_ sender: Any) {
		
		var actions:[[String:UIAlertAction.Style]] = []
		actions.append(["camera".localized: UIAlertAction.Style.default])
		actions.append(["gallery".localized: UIAlertAction.Style.default])
		actions.append(["delete".localized: UIAlertAction.Style.destructive])
		actions.append(["no".localized: UIAlertAction.Style.cancel])
		
		SMLoading.showActionsheet(viewController: self, title: "edit.profile.image".localized, message: "", actions: actions) { (index) in
			switch index {
			case 0: do {
                let imagePickerController = UIImagePickerController()
                imagePickerController.allowsEditing = false
                imagePickerController.sourceType = .camera
                imagePickerController.modalPresentationStyle = .fullScreen
                imagePickerController.popoverPresentationController?.sourceView = self.view
                imagePickerController.mediaTypes = [kUTTypeImage as String]
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
                
			}
				break
				
			case 1: do {
				let imagePickerController = UIImagePickerController()
				imagePickerController.allowsEditing = false
				imagePickerController.sourceType = .photoLibrary
				imagePickerController.modalPresentationStyle = .fullScreen
				imagePickerController.popoverPresentationController?.sourceView = self.view
				imagePickerController.mediaTypes = [kUTTypeImage as String]
				imagePickerController.delegate = self
				self.present(imagePickerController, animated: true, completion: nil)
				
			}
				break
			case 2: do {
				//remove image
				self.profileImage.image = UIImage.init(named: "user")!
				self.imageProfileStatus = .SMImageDeleted
			}
				break
			case 2: do {
				//					close action sheet
			}
				break
			default: break
			}
		}

    }
	
	/// No action
	func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
		
	}
	
    /// Image Picker did select
    ///
    /// - Parameters:
    ///   - picker: selected picker view
    ///   - info: info returns by image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        DispatchQueue.main.async {
            self.profileImage.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
            self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
            picker.dismiss(animated: true, completion: nil)
            self.imageProfileStatus = .SMImageChanged
        }
        
        
    }
    
    /// Cancelled image picker
    ///
    /// - Parameter picker: selected picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
	
    // MARK: - Header Buttons action
    /// User info or username label is selected to edit
    ///
    /// - Parameter sender: selected item
    @IBAction func userBtnSelected(_ sender: Any) {
		
        editTF.becomeFirstResponder()
        editViewTag = (sender as! UIButton).tag
        editTF.text = (sender as! UIButton).titleLabel?.text
		
        if editViewTag == 4, editTF.text! == "NameAndFamily".localized {
            editTF.text = ""
        }
        if editViewTag == 5, editTF.text! == "Username".localized {
            editTF.text = ""
        }
        
    }

    // MARK: - TableView Delegate and DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! SMProfileTableViewCell
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                cell.titleLbl.text = "PhoneNumber".localized
				cell.descriptionLbl.text = SMUserManager.mobileNumber?.inLocalizedLanguage()
            }
            else if indexPath.row == 1 {
                
                cell.titleLbl.text = "Email".localized
                cell.descriptionLbl.text = accountInfo.email?.inLocalizedLanguage()
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                
                cell.titleLbl.text = "BirthDate".localized
				if accountInfo.birth_date != nil {
				
					cell.descriptionLbl.text = getDateFromString(string: accountInfo.birth_date!).localizedDate()
				}
                
            }
            else if indexPath.row == 1 {
                
                cell.titleLbl.text = "State".localized
                for state in self.stateList {
                    if accountInfo.province_id != 0, state["id"] as! Int == accountInfo.province_id {
                        cell.descriptionLbl.text = state["title"] as? String
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath

        if indexPath.section == 0 {
			
			if indexPath.row == 0 {
				//not editable field
			}
			else {
				editTF.becomeFirstResponder()
				let cell = tableView.cellForRow(at: indexPath) as! SMProfileTableViewCell
				editTF.text = cell.descriptionLbl.text
//				editViewTag = indexPath.row * (2) + indexPath.section
			}
        }
        else {
            if indexPath.row == 0 {
				
				self.view.addSubview(self.datePicker)
				UIView.animate(withDuration: 0.3) {
					self.datePicker.frame.origin.y = self.view.bounds.height - (44) - self.heightOfComponent //44 is height of tab bar
				}
				self.pickecrViewHeightConstraint.constant = 0
				self.editTextFieldConstraintBottom.constant = pickecrViewHeightConstraint.constant
				
            }
            else if indexPath.row == 1 {
//                editTF.isHidden = true
				self.pickecrViewHeightConstraint.constant = self.heightOfComponent
				self.editTextFieldConstraintBottom.constant = self.pickecrViewHeightConstraint.constant
            UIView.animate(withDuration: 0.3) {
				
				self.view.layoutIfNeeded()
            }
			self.datePicker.frame.origin.y = self.view.bounds.height
            }
        }
    }
	
	// MARK: - Picker Delegate and DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 30
    }

	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		
		var label = UILabel()
		if let v = view as? UILabel { label = v }
		label.font = SMFonts.IranYekanRegular(14)
		let dic = stateList[row] as Dictionary<String, AnyObject>
		label.text =  dic["title"] as? String
		label.textAlignment = .center
		return label
	}
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            self.provinceId = 0
            
            return
        }
        let dic = stateList[row] as Dictionary<String, AnyObject>
        if let string = dic["title"] as? String {
                self.editTF.text = string
            self.provinceId = (dic["id"] as? Int)!
        }
        else {
            self.editTF.text = ""
            self.provinceId = 0
        }
    }

	/// Convert date string to date object
	///
	/// - Parameter string: Date string
	/// - Returns: date object
	func getDateFromString(string: String) -> Date {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from: accountInfo.birth_date ?? "")
		let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date ?? Date.init())
		let finalDate = calendar.date(from:components)
		
		return finalDate!
	}

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
