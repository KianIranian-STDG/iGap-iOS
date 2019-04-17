//
//  SMRefferalViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice

/// Get name and provience in first login of user
class SMRefferalViewController: SMBaseFormViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    var confirmBtn : SMGradientButton!
    var cancelBtn : SMBottomButton!
    var buttonContainerView : UIView!

	/// Provience picker
    @IBOutlet var statePickerView: UIPickerView!
    var nameTF : SMTextField!
    var stateBtn : UIButton!
    @IBOutlet var pickerDoneButton: UIButton!

    ///Constraint Instances
    @IBOutlet var pickecrViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    var cancelBtnConstraintLeading : NSLayoutConstraint!
    var cancelBtnConstraintTrailing : NSLayoutConstraint!
    var confirmBtnConstraintLeading : NSLayoutConstraint!
    
    var stateList : [Dictionary<String, AnyObject>] = []
    var provinceId : Int = 0
	
	// MARK: - Load View
	/// Setup view and component delegate, call get provience list
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        statePickerView.delegate = self
        statePickerView.dataSource = self
        self.pickecrViewHeightConstraint.constant = 0
		pickerDoneButton.isHidden = true
        pickerDoneButton.setTitle("pickerDoneButton".localized, for: .normal)
		self.SMSignupTitle = "refferal.title".localized
		
        SMNavigationController.shared.navigationItem.hidesBackButton = true
        createForm()
        getState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
	
	func createForm() {
		
		
		//        let recommenderInfolbl = UILabel()
		//        recommenderInfolbl.text = "enterRecommender".localized
		//        recommenderInfolbl.font = SMFonts.IranYekanBold(16)
		//        recommenderInfolbl.textAlignment = SMDirection.TextAlignment()
		//        recommenderInfolbl.translatesAutoresizingMaskIntoConstraints = false
		//
		//        contentView.addSubview(recommenderInfolbl)
		//
		//        NSLayoutConstraint(item: recommenderInfolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
		//        NSLayoutConstraint(item: recommenderInfolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
		//        NSLayoutConstraint(item: recommenderInfolbl, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 50).isActive = true
		//        NSLayoutConstraint(item: recommenderInfolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
		//
		//        recommenderTF = SMTextField()
		//        recommenderTF.font = SMFonts.IranYekanBold(16)
		//        recommenderTF.placeholder = "RecommenderCodePH".localized
		//        recommenderTF.textAlignment = SMDirection.TextAlignment()
		//        recommenderTF.borderStyle = .none
		//        recommenderTF.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
		//        recommenderTF.layer.cornerRadius = 12
		//        recommenderTF.layer.borderWidth = 1
		//        recommenderTF.translatesAutoresizingMaskIntoConstraints = false
		//        contentView.addSubview(recommenderTF)
		
		
		let namelbl = UILabel()
		namelbl.text = "enterName".localized
		namelbl.font = SMFonts.IranYekanBold(16)
		namelbl.textAlignment = SMDirection.TextAlignment()
		namelbl.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(namelbl)
		
		NSLayoutConstraint(item: namelbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
		NSLayoutConstraint(item: namelbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
		NSLayoutConstraint(item: namelbl, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 50).isActive = true
		NSLayoutConstraint(item: namelbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
		
		nameTF = SMTextField()
		nameTF.font = SMFonts.IranYekanBold(16)
		nameTF.placeholder = "NameAndFamily".localized
		nameTF.textAlignment = SMDirection.TextAlignment()
		nameTF.borderStyle = .none
		nameTF.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
		nameTF.layer.cornerRadius = 12
		nameTF.layer.borderWidth = 1
		nameTF.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(nameTF)
		
		
		NSLayoutConstraint(item: nameTF, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
		NSLayoutConstraint(item: nameTF, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
		NSLayoutConstraint(item: nameTF, attribute: .top, relatedBy: .equal, toItem: namelbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
		NSLayoutConstraint(item: nameTF, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
		
		
		let stateInfolbl = UILabel()
		stateInfolbl.text = "enterState".localized
		stateInfolbl.font = SMFonts.IranYekanBold(16)
		stateInfolbl.textAlignment = SMDirection.TextAlignment()
		stateInfolbl.translatesAutoresizingMaskIntoConstraints = false
		
		contentView.addSubview(stateInfolbl)
		
		NSLayoutConstraint(item: stateInfolbl, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
		NSLayoutConstraint(item: stateInfolbl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
		NSLayoutConstraint(item: stateInfolbl, attribute: .top, relatedBy: .equal, toItem: nameTF, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
		NSLayoutConstraint(item: stateInfolbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 21).isActive = true
		
		stateBtn = UIButton()
		stateBtn.titleLabel?.font = SMFonts.IranYekanBold(16)
		stateBtn.setTitle("stateNamePH".localized, for: .normal)
		stateBtn.setTitleColor(UIColor(netHex: 0x979797), for: .normal)
		stateBtn.contentHorizontalAlignment = .right
		stateBtn.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
		stateBtn.layer.cornerRadius = 12
		stateBtn.layer.borderWidth = 1
		stateBtn.translatesAutoresizingMaskIntoConstraints = false
		stateBtn.addTarget(self, action: #selector(self.showPickerView(_:)),      for: .touchUpInside)
		//        stateBtn.backgroundColor = .red
		stateBtn.setImage(UIImage(named:"arrow_back_white"), for: .normal)
		stateBtn.imageEdgeInsets = UIEdgeInsets(top: 6,left: 0,bottom: 6,right: self.view.frame.width - 60)
		stateBtn.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 10)
		
		contentView.addSubview(stateBtn)
		
		NSLayoutConstraint(item: stateBtn, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
		NSLayoutConstraint(item: stateBtn, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
		NSLayoutConstraint(item: stateBtn, attribute: .top, relatedBy: .equal, toItem: stateInfolbl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
		NSLayoutConstraint(item: stateBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
		
		
		buttonContainerView = UIView()
		//		buttonContainerView.backgroundColor = .red
		buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(buttonContainerView)
		
		
		NSLayoutConstraint(item: buttonContainerView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: buttonContainerView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
		NSLayoutConstraint(item: buttonContainerView, attribute: .top, relatedBy: .equal, toItem: stateBtn, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
		NSLayoutConstraint(item: buttonContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
		
		
		confirmBtn = SMGradientButton()
		confirmBtn.enable()
		
		confirmBtn.setTitle("confirm".localized, for: .normal)
		confirmBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
		confirmBtn.contentMode = .center
		confirmBtn.contentHorizontalAlignment = .center
		confirmBtn.colors = [UIColor(netHex: 0x00e676), UIColor(netHex: 0x2ecc71)]
		confirmBtn.addTarget(self, action: #selector(self.callSetMoreInfoAPI(_:)),         for: .touchUpInside)
		confirmBtn.translatesAutoresizingMaskIntoConstraints = false
		confirmBtn.layer.cornerRadius = 24
		
		buttonContainerView.addSubview(confirmBtn)
		
		cancelBtn = SMBottomButton()
		cancelBtn.enable()
		
		cancelBtn.layer.borderColor = UIColor(netHex: 0x00e676).cgColor
		cancelBtn.layer.borderWidth = 2
		cancelBtn.setTitle("cancel".localized, for: .normal)
		cancelBtn.titleLabel?.font = SMFonts.IranYekanBold(15)
		cancelBtn.contentMode = .center
		cancelBtn.contentHorizontalAlignment = .center
		cancelBtn.addTarget(self, action: #selector(self.cancel(_:)),         for: .touchUpInside)
		cancelBtn.translatesAutoresizingMaskIntoConstraints = false
		cancelBtn.layer.cornerRadius = 24
		cancelBtn.setTitleColor(UIColor(netHex: 0x00e676), for: .normal)
		
		cancelBtn.tintColor = .clear
		//        buttonContainerView.addSubview(cancelBtn)
		
		
		confirmBtnConstraintLeading = NSLayoutConstraint(item: confirmBtn, attribute: .leading, relatedBy: .equal, toItem: buttonContainerView, attribute: .leading, multiplier: 1, constant: 15)
		confirmBtnConstraintLeading.isActive = true
		NSLayoutConstraint(item: confirmBtn, attribute: .trailing, relatedBy: .equal, toItem: buttonContainerView, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
		
		NSLayoutConstraint(item: confirmBtn, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .top, multiplier: 1, constant: 1).isActive = true
		NSLayoutConstraint(item: confirmBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
		
		
		//        cancelBtnConstraintLeading = NSLayoutConstraint(item: cancelBtn, attribute: .leading, relatedBy: .equal, toItem: confirmBtn, attribute: .trailing, multiplier: 1, constant: 15)
		//        cancelBtnConstraintLeading.isActive = true
		//        cancelBtnConstraintTrailing = NSLayoutConstraint(item: cancelBtn, attribute: .trailing, relatedBy: .equal, toItem: buttonContainerView, attribute: .trailing, multiplier: 1, constant: -15)
		//        cancelBtnConstraintTrailing.isActive = true
		//        NSLayoutConstraint(item: cancelBtn, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .top, multiplier: 1, constant: 1).isActive = true
		//        NSLayoutConstraint(item: cancelBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48).isActive = true
		//
		//
		//        NSLayoutConstraint(item: cancelBtn, attribute: .width, relatedBy: .equal, toItem: confirmBtn, attribute: .width, multiplier: 1, constant: 0).isActive = true
		
		
	}

	// MARK:- Keyboard notification handler
    override
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        contentViewHeightConstraint.constant = contentViewHeightConstraint.constant + keyboardHeight;
        
        UIView.animate(withDuration: 0.3) {
            
            self.buttonContainerView.removeFromSuperview()

            self.confirmBtn.layer.cornerRadius = 0
            
            self.cancelBtn.layer.cornerRadius = 0
            self.cancelBtn.layer.borderWidth = 0
            self.cancelBtn.colors = [.red, .red]
            self.cancelBtn.setTitleColor(UIColor(netHex: 0xffffff), for: .normal)

            let window = UIApplication.shared.keyWindow!
            window.addSubview(self.buttonContainerView)
            
            //container view constraint
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .leading, relatedBy: .equal, toItem: window, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1, constant: -keyboardHeight).isActive = true
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .trailing, relatedBy: .equal, toItem: window, attribute: .trailing, multiplier: 1, constant: 0).isActive = true

            
            self.confirmBtnConstraintLeading.constant = 0
//            self.cancelBtnConstraintTrailing.constant = 0
//            self.cancelBtnConstraintLeading.constant = 0


        }
        self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }
    
    override
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        contentViewHeightConstraint.constant = contentViewHeightConstraint.constant - keyboardHeight;
        
        UIView.animate(withDuration: 0.3) {
            //define code to showw button on scroll view, if needed
            self.buttonContainerView.removeFromSuperview()
            self.contentView.addSubview(self.buttonContainerView)
            
            
            self.confirmBtn.layer.cornerRadius = 24

            self.cancelBtn.layer.borderColor = UIColor(netHex: 0x00e676).cgColor
            self.cancelBtn.layer.borderWidth = 2
            self.cancelBtn.layer.cornerRadius = 24
            
            self.cancelBtn.colors = [.white, .white]

            NSLayoutConstraint(item: self.buttonContainerView, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.buttonContainerView, attribute: .top, relatedBy: .equal, toItem: self.stateBtn, attribute: .bottom, multiplier: 1, constant: 10).isActive = true


            self.confirmBtnConstraintLeading.constant = 15
//            self.cancelBtnConstraintTrailing.constant = -15
//            self.cancelBtnConstraintLeading.constant = 15
        }
        self.view.layoutIfNeeded();
        
        SMLog.SMPrint(keyboardHeight);
    }
    
	//MARK:- API Calls and other actions
	
	/// Update profile to save name and provience items
    @objc
    func callSetMoreInfoAPI(_ sender: SMBottomButton) {
		
		if (nameTF.text?.isEmpty)! {
			//show message
			
			return
		}
		confirmBtn.gotoLoadingState()
        let accountInfo = PU_obj_account()
        accountInfo.account_id = SMUserManager.accountId
        accountInfo.account_type = ACCOUNT_TYPE(rawValue: 2)
		accountInfo.name = nameTF.text
		
        if provinceId != 0 {
            accountInfo.province_id = provinceId
        }
		
        
        let request = WS_methods(delegate: self, failedDialog: true)
        request.addSuccessHandler { (response : Any) in
            //goto next page
            let navigation = SMNavigationController.shared
			SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Main.rawValue
			
			SMUserManager.firstName = self.nameTF.text!
			SMUserManager.saveDataToKeyChain()
			
            navigation.pushNewViewController(page: .Main)
        }
        request.addFailedHandler({ (response: Any) in

			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
			self.confirmBtn.gotoButtonState()
        })
		
//		if (recommenderTF.text?.isEmpty)! {
			request.pu_updateaccount(accountInfo.account_id!, fields: accountInfo.returnJSON_UpdateProfile())
//		}
//		else {
//        	request.pu_updateaccount(accountInfo.account_id!, fields: accountInfo.returnJSON_UpdateProfile(), withRefCode: recommenderTF.text!)
//		}
    }

    @objc
    func cancel(_ sender: SMBottomButton) {

        let navigation = SMNavigationController.shared
        navigation.pushNewViewController(page: .Main)
    }
	
	/// Show picker view to select province
    @objc
    func showPickerView(_ sender: UIButton) {
    
//        recommenderTF.resignFirstResponder()
		nameTF.resignFirstResponder()
		pickerDoneButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.pickecrViewHeightConstraint.constant = 260
			
        }
    }
	
	/// Call api to fetch proviences
    func getState() {
//        ST_provincelist
        let request = WS_methods(delegate: self, failedDialog: true)
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? [Dictionary<String, AnyObject>] {
                
                self.stateList = jsonResult
                self.stateList.insert(["title": "SelectState".localized  as AnyObject,"id": 0 as AnyObject], at: 0)
                self.statePickerView.reloadAllComponents()
            }
        }
        request.addFailedHandler({ (response: Any) in
//            SMMessage.showWithMessage("error")
        })
        //
        request.st_provincelist()
    }
    
    /// Picker view done button is selected
    @IBAction func doneButtonSelected (_ sender: UIButton) {
		
		pickerDoneButton.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.pickecrViewHeightConstraint.constant = 0
			
        }
    }
	
	//MARK: - Picker Delegate and Datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateList.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 30
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let dic = stateList[row] as Dictionary<String, AnyObject>
        return dic["title"] as? String
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        if row == 0 {
            return
        }
        let dic = stateList[row] as Dictionary<String, AnyObject>
        stateBtn.setTitle( dic["title"]! as? String, for: .normal)
        self.provinceId = (dic["id"] as? Int)!
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
