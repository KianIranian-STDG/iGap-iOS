//
//  SMBarCodeScannerViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/15/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import AMPopTip
import webservice
import SwiftyRSA

//enum SMBarcodeMode:String{
//    case Bills_Code128 = "org.iso.Code128";
//    case Payment_QR = "org.iso.QRCode";
//}


/// Type of product QR code
///
/// - khati: The taxi with source and destination and defined price
/// - gardeshi: the taxi without information about places and price
/// - Ajans: private taxi
enum SMTransportType: Int {
	case khati = 0;
	case gardeshi = 1;
	case Ajans	= 2;
}

/// Type of Payment pop up
///
/// - PopupNoProductTaxi: The taxi pop up shows the information of taxi and driver name, no price is provided at this type, so user must enter it
/// - PopupProductedTaxi: Taxi popup with product shows the information of taxi and driver name with price, the price could be increased by unit
/// - PopupUser: User popup is normal type to show receiver name and price
enum SMAmountPopupType: Int {
    case PopupNoProductTaxi = 0
    case PopupProductedTaxi = 1
    case PopupUser          = 2
}


/// At this class user scan a QR or enter the QR code, and pay to a normal user or a merchant
class SMBarCodeScannerViewController: QRCodeReaderViewController, SMPaymentPopupDelegate,HandleReciept{
	
    /// A custom view to enter QR code manually
    var manualInputView : SMSingleInputView!
    @IBOutlet var amountInfoLabel : UILabel!
    private var tipIndex: Int!
    private var userCards: [SMCard]?
	var finishDelegate : HandleDefaultCard?
	private var transportId : String?
	private var qrCode : String?
	
    /// The wallet amount of user
    private var currentAmount: String = "0" {
        didSet {
            amountInfoLabel.text = "\("AmountPayGear".localized)\(currentAmount) \("Currency".localized)"
        }
    }
    private var popup : SMPaymentPopup!
    private var targetAccountId: String!
    
    
    /// Add all needed components to QR view
    @IBOutlet weak var previewView: SMQRView!{
        didSet {
            previewView.setupComponents(showCancelButton: false, showSwitchCameraButton: false, showTorchButton: true, showOverlayView: true, reader: reader)
        }
    }
	
    /// QR Reader component
    lazy var reader: QRCodeReader = QRCodeReader()
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SMBarCodeScannerViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SMBarCodeScannerViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsetNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
	
	/// Setups notifications and load user carda and update current user amount
	override func viewDidAppear(_ animated: Bool) {
		
		setupNotifications()
		self.userCards = SMCard.getAllCardsFromDB()
		self.updateAmountOfPayGear()
		
		if  !(UIImagePickerController.isSourceTypeAvailable(.camera)){
			dismiss(animated: false, completion: nil)
			return
		}
   
//		amountInfoLabel.text = "\("AmountPayGear".localized)\(currentAmount) \("Currency".localized)"
	}
	
    /// Reset observer notifications
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsetNotifications()
        
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let window = UIApplication.shared.keyWindow!
		
		if let manualInput = manualInputView {
			window.addSubview(manualInput)
			UIView.animate(withDuration: 0.3) {
				
				var frame = manualInput.frame
				frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight - frame.size.height)
				manualInput.frame = frame
				
			}
		}
		
        self.view.layoutIfNeeded()
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        
		if let manualInput = manualInputView {
        	self.view.addSubview(manualInput)
			UIView.animate(withDuration: 0.3) {
				if manualInput.frame.origin.y < self.view.frame.size.height {
					manualInput.frame = CGRect(x: 0, y: self.view.frame.height - manualInput.frame.height - 45, width: self.view.frame.width, height: manualInput.frame.height)
				}
			}
		}
		
        self.view.layoutIfNeeded()
    }
    
	/// If any actions needed to shortcut actions we provide here
	@objc
	func gotToSubPage(page: Int) {
		
	}
	
    /// Load wallet amount
    private func updateAmountOfPayGear() {
        if let cards = userCards {
            for card in cards {
                if card.type == 1{
                    currentAmount = String.init(describing: card.balance ?? 0).inRialFormat().inLocalizedLanguage()
                }
            }
        }
    }
	
    /// Shows alert to get permission of camera if it is not provided and return permission status if it is provided before
    ///
    /// - Returns: permision status
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    /// load view and subviews and handle Initial actions and reader scan code result in callback
    override func viewDidLoad() {
		
		let qrButton = UIButton(frame: CGRect(x: 0, y: 0, width: 61, height: 40))
		qrButton.setTitle("MyQRCode".localized, for: .normal)
        qrButton.addTarget(self, action: #selector(myQRCodeIsSelected), for: .touchUpInside)
		qrButton.titleLabel?.font = SMFonts.IranYekanBold(18)
        qrButton.contentHorizontalAlignment = .right
        version_check()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: qrButton)
        NotificationCenter.default.addObserver(self, selector: #selector(self.ipg_success(notification:)), name: Notification.Name("ipg_success"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.barcodeStartScaning(notification:)), name: Notification.Name("barcode"), object: nil)


        SMInitialInfos.AllUpdatedSuccessfully = {
            SMLoading.hideLoadingPage()
            self.userCards = SMCard.getAllCardsFromDB()
			self.updateAmountOfPayGear()
            
        }
        SMInitialInfos.AtLeastOneFailedDelegate = {
            
            SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
            SMLoading.hideLoadingPage()
            self.userCards = SMCard.getAllCardsFromDB()
            
        }
        guard checkScanPermissions(), !reader.isRunning else { return }
        
        reader.didFindCode = { result in
            SMLog.SMPrint("Completion with result: \(result.value) of type \(result.metadataType)")
			
			if let range = result.value.range(of: "?jj=") {
				let value = String(result.value[range.upperBound...])
				if let json = value.toJSON() as? Dictionary<String, AnyObject> {
					self.getUserInformation(accountId: json["H"] as! String, qrType: Int(json["T"] as! String)!)
				}
				else {
					
					self.getQRCodeInformation(barcodeValue: String(value).onlyDigitChars())
					
				}
			}
            else {
                
                //show invalid product
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "error".localized, message: "Invalid.QR".localized, rightButtonTitle: "OK".localized)
                self.reader.startScanning()
            }
        }
        
		
        if !SMUserManager.barcodeTipIsShown {
            showHelpTip()
            SMUserManager.barcodeTipIsShown = true
        }
        
        //        previewView.manualInputButton!.addTarget(self, action: #selector(manualInput), for: .touchUpInside)
        //darbare button bala be moshkel khordam, az tarighe previewView nashod action behesh add konam, banabarin roye storyboard ye button gozashtam to hamin frame va action morede nazaram ro behesh add kardam, bayad in bakhsh dorost eshe
        previewView.toggleTorchButton!.addTarget(self, action: #selector(torchAction), for: .touchUpInside)
        reader.startScanning()


    }
	
	@objc func barcodeStartScaning(notification: Notification) {
		
		if popup != nil && (popup?.isDescendant(of: self.view))! {
			return
		}
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
			self.reader.startScanning()
		}
	}
    
    /// Call API to check app version and new update
    ///
    /// - Parameters:
    ///   - onSuccess: call back to success action
    ///   - onFailed: call back to fail action
    func version_check(onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
        
        let updateObj = UP_obj_checker()
        updateObj.os = "iOS"
        updateObj.os_version = UIDevice.current.systemVersion
        updateObj.device_model = UIDevice.current.model
        updateObj.locality = UserDefaults.standard.string(forKey: "lang")
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String , let bundle = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
            updateObj.app_version = version + "." + bundle
        }
        
        let versionCheckRequest = WS_methods(delegate: self, failedDialog: true)
        versionCheckRequest.addSuccessHandler { (response : Any) in
            if let dic = response as? NSDictionary , let state = dic["state"] as? Int  ,let link = dic["link"] as? String {
                if state == 1{
					
					//is update available
					SMUserManager.isUpdateAvailable = true
                    //optional
                    SMLoading.shared.showUpdateDialog(viewController: self, height: 200, title: "updateTitle".localized, message: "updateMessage".localized , leftButtonTitle : "close".localized, rightButtonTitle : "updateok".localized , yesPressed : { yes in
                        if let url = URL(string: link) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    })
                }else if state == 2{
                    //force
                    SMLoading.shared.showUpdateDialog(viewController: self, height: 200 ,isleftButtonEnabled : false , title: "updateTitle".localized, message: "updateMessage".localized, leftButtonTitle : "close".localized,rightButtonTitle : "updateok".localized, yesPressed : { yes in
                        if let url = URL(string: link) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    })
                }else{
                    //nothing
                    SMUserManager.isUpdateAvailable = false
                    
                }
                onSuccess?(response)
            }
        }
        
        
        versionCheckRequest.addFailedHandler({ (response: Any) in
            print("faild")
            onFailed?(response)
        })
        versionCheckRequest.pc_version(updateObj)
        
        
    }
    
    /// Get success response of ipg request, and handle response to show recipt
    ///
    /// - Parameter notification: user info object
    @objc func ipg_success (notification : AnyObject ){
        let orderId = notification.userInfo["order_id"] as! String
        if self.tabBarController?.selectedIndex == 1 {
            SMLoading.showFullPageLoading(viewcontroller: self)
            SMHistory.getHistoryFromServer(last: "", itemCount: 5, {
                success in
                SMLoading.hideFullPageLoading()
                print(success ?? "no success")
                if let rowData = (success as? [PAY_obj_history])
                {
                    var row : PAY_obj_history = PAY_obj_history()
                    for item in rowData{
                        if orderId == item._id{ row = item; break;}
                    }
                    
                    let date = Date.init(timeIntervalSince1970: TimeInterval((row.pay_date != 0 ? row.pay_date: row.created_at_timestamp)/1000)).localizedDateTime()
                    let dic = ["recieveName".localized : row.receiver.name ,"transType".localized : SMStringUtil.getTransType(type: (row.transaction_type.rawValue)), "status".localized :  (row.is_paid) == IS_PAID_STATUS.PAID ? "success.payment".localized : "history.paygear.receive.waiting".localized , "amount".localized : row.amount  ,"invoice_number".localized : row.invoice_number,"date".localized : date] as [String : Any]
                    let result = ["result" : dic ] as NSDictionary
					
                    SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                }
            }, onFailed: { error in
                print(error)
                SMLoading.hideFullPageLoading()
                
            })
        }
    }
    
    
    /// show info help tips on manual, torch and ... items
    func showHelpTip() {
        
        let deadlineTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            
            self.tipIndex = 0
            let overlayMappedFrame = self.previewView.convert((self.previewView.overlayView as! SMQROverlayView).borderImageView!.frame, to: self.view)
            let torchMappedFrame = self.previewView.convert(self.previewView.toggleTorchButton!.frame, to: self.view)
            let manualMappedFrame = self.previewView.convert(self.previewView.manualInputButton!.frame, to: self.view)
            
            let sortOfTip : [String] =  ["ScanTip".localized, "TorchTip".localized, "ManualTip".localized]
            let sortOfFrame : [CGRect] = [overlayMappedFrame, torchMappedFrame, manualMappedFrame]
            let popTip = PopTip()
            popTip.font = SMFonts.IranYekanRegular(15)
            popTip.bubbleColor = UIColor(netHex: 0x2196f3)
            popTip.show(text: sortOfTip[self.tipIndex], direction: .down, maxWidth: 200, in: self.view, from: sortOfFrame[self.tipIndex], duration: 3.0)
            
            
            popTip.tapHandler = { _ in
                SMLog.SMPrint("tap")
                self.tipIndex = self.tipIndex + 1
                if self.tipIndex < sortOfTip.count {
                    popTip.show(text: sortOfTip[self.tipIndex], direction: .up, maxWidth: 200, in: self.view, from: sortOfFrame[self.tipIndex], duration: 3.0)
                }
            }
            popTip.dismissHandler = { _ in
                SMLog.SMPrint("dismiss")
                self.tipIndex = self.tipIndex + 1
                if self.tipIndex < sortOfTip.count {
                    popTip.show(text: sortOfTip[self.tipIndex], direction: .up, maxWidth: 200, in: self.view, from: sortOfFrame[self.tipIndex], duration: 3.0)
                }
            }
        }
    }
    @IBAction func onBackTapped(_ sender: SMBottomButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Show manual input to get QRcode
    @IBAction func manualInput() {
		
		if manualInputView == nil {
			manualInputView = SMSingleInputView.loadFromNib()
			manualInputView.confirmBtn.addTarget(self, action: #selector(confirmManualButtonSelected), for: .touchUpInside)
			manualInputView!.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: manualInputView.frame.height)
			
			manualInputView.confirmBtn.setTitle("OK".localized, for: .normal)
			manualInputView.infoLbl.text = "EnterReceiverCode".localized
			manualInputView.inputTF.placeholder = "ReceiverCode".localized
			
			manualInputView.inputTF.inputView =  LNNumberpad.default()
			
			let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(SMBarCodeScannerViewController.handleGesture(gesture:)))
			swipeDown.direction = .down
			
			manualInputView.addGestureRecognizer(swipeDown)
			self.view.addSubview(manualInputView!)

		}
		else {
			manualInputView.confirmBtn.setTitle("OK".localized, for: .normal)
			manualInputView.infoLbl.text = "EnterReceiverCode".localized
			manualInputView.inputTF.placeholder = "ReceiverCode".localized
		}
		
		if #available(iOS 11.0, *) {
			let window = UIApplication.shared.keyWindow
			let topPadding = window?.safeAreaInsets.top
			let bottomPadding = window?.safeAreaInsets.bottom
			
			UIView.animate(withDuration: 0.3) {
				self.manualInputView!.frame = CGRect(x: 0, y: self.view.frame.height - self.manualInputView.frame.height - 45 -  bottomPadding!, width: self.view.frame.width, height: self.manualInputView.frame.height)
				
			}
		}
		else {
			UIView.animate(withDuration: 0.3) {
			self.manualInputView!.frame = CGRect(x: 0, y: self.view.frame.height - self.manualInputView.frame.height - 45, width: self.view.frame.width, height: self.manualInputView.frame.height)
			}
		}
        
    }
    
    /// On or of back light
    @objc func torchAction() {
        
        let defaultDevice: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
        
        do {
            try defaultDevice?.lockForConfiguration()
            
            defaultDevice?.torchMode = defaultDevice?.torchMode == .on ? .off : .on
            
            defaultDevice?.unlockForConfiguration()
        }
        catch _ { }
    }
	
	@objc func handleGesture(gesture: UITapGestureRecognizer) {
		// handling code
		hideManualInputView()
		
	}
    @objc func confirmManualButtonSelected() {
        
		hideManualInputView()
		//go to process info
        
        if manualInputView.inputTF.text! == ""{
         SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "fill".localized, leftButtonTitle: "", rightButtonTitle: "ok".localized,yesPressed: { yes in return;})
        }else{
			
			getQRCodeInformation(barcodeValue: manualInputView.inputTF.text!)
        }
        
    }
	
	func hideManualInputView() {
		UIView.animate(withDuration: 0.3, animations: {
			self.manualInputView.frame.origin.y = self.view.frame.height
			self.manualInputView.inputTF.endEditing(true)

		}) { (true) in
		}
	}
    @objc func myQRCodeIsSelected() {
		
		SMNavigationController.shared.style = .SMMainPageStyle
		SMMainTabBarController.qrTabNavigationController.pushNewViewController(page: .MyQR)
    }
    
    /// Payment popup to get confirm payment
    ///
    /// - Parameters:
    ///   - type: specify type of popup (khati, gardeshi, ajansh)
    ///   - value: information needed to fill popup fields
    func showPopup(type: SMAmountPopupType, value:[String: String]) {
        
        unsetNotifications()
        DispatchQueue.main.async {
            self.popup = SMPaymentPopup.loadFromNib()
            self.popup.confirmBtn.addTarget(self, action: #selector(self.confirmPopupButtonSelected), for: .touchUpInside)
            self.popup.delegate = self
            self.popup.type = type
            self.popup.value = value
//            self.popup.paymentTypeSwitch.switchChangeType = .tap
			self.popup.currentAmount = Int(self.currentAmount.onlyDigitChars())!
            
            if type == SMAmountPopupType.PopupProductedTaxi {
                if Int(self.currentAmount.onlyDigitChars().inEnglishNumbers())! > Int(value["price"]!)! {
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
						
					}                }
            }
            self.popup.showPopup(viewController: self)
        }
    }
    
    func dismissPopup() {
        reader.startScanning()
        setupNotifications()
    }
    
    
    func finishedPayment(){
        self.popup.dismiss()
        self.popup.endEditing(true)
        self.tabBarController?.selectedIndex = 0
        (self.tabBarController as! SMMainTabBarController).setCurrentTapFocusLine(index: 0)
    }
    
    
    
	
	//MARK: - Get Data Info
	
	/// API Call to get qr owner of user
	///
	/// - Parameters:
	///   - accountId: account id of owner
	///   - qrType: type of QR code (user or merchant)
	///   - productId: qr product id
	func getUserInformation(accountId: String, qrType: Int, productId: String? = "") {
		
		SMLoading.showLoadingPage(viewcontroller: self, text: "loading.text".localized)

		self.targetAccountId = String(describing:accountId)
		self.getAccountInformation(accountId:  String(describing:accountId), closure: {name, subTitle, imagePath in
			
			if qrType == Int(SMQRCode.SMAccountType.User.rawValue) {
				SMLoading.hideLoadingPage()
				self.showPopup(type: .PopupUser, value:["name": name, "subTitle": subTitle, "imagePath": imagePath])
			}
			else {
				
				self.handleMerchantQR(accountId: accountId, name: name, subTitle: subTitle, imagePath: imagePath, qrType: qrType, productId: productId!)
			}
		})
	}
	
	/// API Call to get product information and show popup form according to product and qr type
	///
	/// - Parameters:
	///   - accountId: Owner account id
	///   - name: Owner name
	///   - subTitle: Owner sub information
	///   - imagePath: Owner image path
	///   - qrType: qr type
	///   - productId: product id
	func handleMerchantQR(accountId: String, name: String, subTitle: String, imagePath: String, qrType: Int, productId: String) {
		
			if  String(describing: productId) != "" {
				//load product
				self.getProductInformation(productId: String(describing:productId), accountId: String(describing:accountId), transportEnabled: qrType == 50 ? true : false, closure: {productName, price, transportType in
					SMLoading.hideLoadingPage()
					if transportType == .khati && price == "" {
						//show invalid product
						SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "error".localized, message: "Invalid.QR".localized, rightButtonTitle: "OK".localized)
					}
					
					if transportType == .khati {
						self.showPopup(type: .PopupProductedTaxi, value:["name": name, "subTitle": subTitle, "productName": productName, "price": price, "imagePath": imagePath])
					}
					else  {
						self.showPopup(type: .PopupNoProductTaxi, value:["name": name, "subTitle": productName, "imagePath": imagePath])
					}
				})
			}
			else {
				
				SMLoading.hideLoadingPage()
					if qrType == Int(SMQRCode.SMAccountType.Merchant.rawValue) {
						self.showPopup(type: .PopupNoProductTaxi, value:["name": name, "subTitle": subTitle, "imagePath": imagePath])
					}
					else {
						self.showPopup(type: .PopupUser, value:["name": name, "subTitle": subTitle, "imagePath": imagePath])
					}
			}
		}
    
    /// API call to fetch QR infromation according qr code
    ///
    /// - Parameter barcodeValue: qr code
    func getQRCodeInformation(barcodeValue: String) {
		
		self.qrCode = barcodeValue.inEnglishNumbers()
        SMLoading.showLoadingPage(viewcontroller: self, text: "loading.text".localized)
        let request = WS_methods(delegate: self, failedDialog: true)
		
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
				if let id = jsonResult["_id"] as? String , id == "" {
					
					SMLoading.hideLoadingPage()
					self.reader.startScanning()
					SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "error".localized, message: "Invalid.Data".localized, rightButtonTitle: "OK".localized)
				}
				else if let accountId = jsonResult["account_id"], !accountId.isKind(of: NSNull.self) {
                    SMLoading.hideLoadingPage()
                    self.targetAccountId = String(describing:accountId)
					self.transportId = jsonResult["value"] as? String
					self.getUserInformation(accountId: accountId as! String, qrType: Int(truncating: jsonResult["qr_type"]! as! NSNumber), productId: jsonResult["value"] as? String)
                }
                else {
					
                    SMLoading.hideLoadingPage()
					self.reader.startScanning()
					SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "error".localized, message: "Invalid.Data".localized, rightButtonTitle: "OK".localized)
                }
            }
            
        }
        request.addFailedHandler { (response: Any) in
			
			SMLoading.hideLoadingPage()
			self.reader.startScanning()
			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
			
        }

        request.mc_getqrcodewithid(barcodeValue.inEnglishNumbers())
        
    }
    
	/// API Call to fetch product information or transport information
	///
	/// - Parameters:
	///   - productId: product id
	///   - accountId: product owner id
	///   - transportEnabled: is transport enabled on product
	///   - closure: call back response
	func getProductInformation(productId: String, accountId:String, transportEnabled:Bool,  closure: @escaping (_ productName: String, _ price: String, _ transportType: SMTransportType) -> ()) {
        
        let account = PU_obj_account()
        account.account_id = String(describing: accountId)

        let request = WS_methods(delegate: self, failedDialog: false)

        request.addSuccessHandler { (response : Any) in

			if transportEnabled {
				if let jsonResult = response as? Dictionary<String, AnyObject> {
					if let transportType = jsonResult["transport_type"]  {

						
					closure(String(describing:jsonResult["name"] ?? "" as AnyObject) ,
							String(describing: jsonResult["value"] ?? "" as AnyObject),
							SMTransportType.init(rawValue: transportType as! Int)!)
					}
				}
			}
			else {
            if let jsonResult = response as? Dictionary<String, AnyObject> {
				if jsonResult["skus"] != nil  {
                closure(jsonResult["product_name"]! as! String,
						String(describing: jsonResult["price"]!),
						SMTransportType.init(rawValue: 0)!)
				}
				else {
					SMLoading.hideLoadingPage()
					self.reader.startScanning()
					
					SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: "error".localized, message: "Invalid.QR".localized, rightButtonTitle: "OK".localized)
				}
            }
			}
			
            
        }
        request.addFailedHandler({ (response: Any) in
			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
			SMLoading.hideLoadingPage()
			self.reader.startScanning()
        })

		if transportEnabled {
			request.cp_gettransport(productId)
		}
		else {
        	request.cp_getproduct(productId, ownerid: accountId)
		}

    }
	
    
    /// API call to fetch user owner information
    ///
    /// - Parameters:
    ///   - accountId: user owner id
    ///   - closure: callback method
    func getAccountInformation (accountId: String, closure: @escaping (_ name: String, _ subTitle: String, _ imagePath: String) -> ()) {
		
		
        let account = PU_obj_account()
        account.account_id = String(describing: accountId)
        
        let request = WS_methods(delegate: self, failedDialog: false)

        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                
                var name: String = ""
                var subTitle: String = ""
                var imagePath: String = ""
                if let n = jsonResult["name"] { name = n as! String }
                if let s = jsonResult["sub_title"] { subTitle = s as! String }
                if let i = jsonResult["profile_picture"] { imagePath = i as! String }
                
                closure(name , subTitle, imagePath)
            }
            
        }
        request.addFailedHandler({ (response: Any) in
			SMLoading.hideLoadingPage()
            //show popup
			if SMValidation.showConnectionErrorToast(response) {
				SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
			}
            self.reader.startScanning()
        })

        request.pu_getaccountinfo(account, mod: 1)


    }

	//MARK: - Pay Action
    /// Handle payment and it scenario
	/// Check input amount
	/// Check payment type (by wallet
	/// 						check amount of user is equal or more than transfer amount)
	///							check payment pin (if not set, rout to set, else get pin)
	/// 						init and pay
	///						, by card)
	///							routh to bank gatway
	/// show receipt
    @objc func confirmPopupButtonSelected() {

		if self.popup.amountTF.text == "" ||
			self.popup.amountTF.text?.inEnglishNumbers() == "0" {
            SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "fill.amount".localized, leftButtonTitle: "", rightButtonTitle: "OK".localized,yesPressed: { yes in return;})
        }
            
        else {
        
		//popup.confirmBtn.gotoLoadingState()
        if popup.paymentTypeSwitch.index == 0 {
			
			if Int(self.popup.amountTF.text!.onlyDigitChars())! > Int(self.currentAmount.onlyDigitChars())! {
				//show message about your amount is not enough
				SMMessage.showWithMessage("AmountIsNotEnough".localized)
				return
			}
                                                                                                                                                                                                                                                                                    
			if SMUserManager.pin != nil, SMUserManager.pin == true {

				//show get pin popup
				SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: "enterpin".localized, yesPressed: { pin in
					
                    self.gotoLoadingState()
					
					SMCard.initPayment(amount: Int(self.popup.amountTF.text!.onlyDigitChars()), accountId: self.targetAccountId, transportId : self.transportId, qrCode: self.qrCode , onSuccess: { response in
						
						let json = response as? Dictionary<String, AnyObject>
						SMUserManager.publicKey = json?["pub_key"] as? String
						SMUserManager.payToken = json?["token"] as? String
						
						if self.userCards!.count == 0 {
                            self.gotobuttonState()
						}
						
						for card in self.userCards! {
							if card.type == 1 {
								
								let para  = NSMutableDictionary()
								
								para.setValue(card.token, forKey: "c")
								para.setValue((pin as! String).onlyDigitChars(), forKey: "p2")
								para.setValue(card.type, forKey: "type")
								para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
								para.setValue(card.bankCode, forKey: "bc")
								
								let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
								let jsonString = String(data: jsonData, encoding: .utf8)
								
								if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey) {
									self.popup.endEditing(true)
//                                    self.showReciept(response: NSDictionary())
									SMCard.payPayment(enc: enc, onSuccess: { resp in
										
										self.gotobuttonState()
										if let result = resp as? NSDictionary{
											
                                            SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
										}
									}, onFailed: {err in
										SMLog.SMPrint(err)

											if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
											SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
										}
										self.gotobuttonState()
									})
								}
							}
						}
					}, onFailed: { (err) in
						SMLog.SMPrint(err)
						self.gotobuttonState()
					})
					
				}, noPressed: { value in 
					
				})
			} else {
				//show SMWalletPasswordViewController
				let viewController = SMWalletPasswordViewController(style: .grouped)
				SMMainTabBarController.qrTabNavigationController.pushViewController(viewController, animated: true)
				//TODO: show modally and in dismiss action continue action
			}
        }
        else if popup.paymentTypeSwitch.index == 1 {
            //pay by card
            popup.endEditing(true)
            SMLoading.showLoadingPage(viewcontroller: self)
            SMCard.initPayment(amount: Int((self.popup.amountTF.text?.onlyDigitChars())!),accountId: self.targetAccountId, transportId: self.transportId, qrCode: self.qrCode, onSuccess: { response in
                SMLoading.hideLoadingPage()
                let json = response as? Dictionary<String, AnyObject>
                if let ipg = json?["ipg_url"] as? String ,ipg != "" {
                    if let url = URL(string: ipg) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                else{
                    SMUserManager.publicKey = json?["pub_key"] as? String
                    SMUserManager.payToken = json?["token"] as? String
                    let vc = SMNavigationController.shared.findViewController(page: .ChooseCard) as! SMChooseCardViewController
                    vc.toAccountId = self.targetAccountId
                    vc.amount = self.popup.amountTF.text!.onlyDigitChars()
                    SMMainTabBarController.qrTabNavigationController.pushViewController(vc, animated: true)
                }
            }, onFailed: {err in
                SMLoading.hideLoadingPage()
                SMLog.SMPrint(err)
            })
            }
        }
   }
	
    func gotoLoadingState(){
        self.view.endEditing(true)
        popup?.confirmBtn.gotoLoadingState()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func gotobuttonState(){
        popup.confirmBtn.gotoButtonState()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    
    
    func close() {
        self.dismiss(animated: false, completion: {
            self.view.endEditing(true)
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
            self.finishDelegate?.finishDefault(isPaygear: true, isCard: false)
            if let barcode = SMMainTabBarController.currentSubNavNavigation.viewControllers[0] as? SMBarCodeScannerViewController{
                barcode.finishedPayment()
            }
            DispatchQueue.main.async {
//                self.popup.dismiss()
                (self.tabBarController as! SMMainTabBarController).setCurrentTapFocusLine(index: 0)
                self.tabBarController?.selectedIndex = 0
            }
            
        })
        
    }
    
    func screenView() {
        SMReciept.getInstance().screenReciept(viewcontroller: self)
    }
	
}

