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
import SnapKit
import MBProgressHUD
import SwiftProtobuf
import IGProtoBuff
import webservice


var hasShownQrCode = false
var isfromPacket = false
var isUser : Bool! = false
var isHyperMe : Bool! = false

var toID = ""
class SMBarcodeMainViewController: BaseViewController, HandleReciept, HandleGiftView, HandlePassBalance, HandlePayModal, walletPayHandler{
    func payTaped() {
        print("TESTTING BENJI")
    }
    
    func sendBalanceToScannerVC(cardBalance: String) {
        //
    }
    func closeAll() {
        hasShownQrCode = false
        self.dismiss(animated: true, completion: nil)

    }
    func close() {
        hasShownQrCode = false
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    func screenView() {
        print("test")
    }
    
    var SequenceNumber: String?
    var hyperMePrice = ""
    var hyperMeShomareFactor: String? = nil

    
    @IBOutlet weak var heightConstants: NSLayoutConstraint!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var mianView:UIView!
    @IBOutlet weak var QRHolder:UIImageView!
    @IBOutlet weak var previewView: UIView!
    private var userCards: [SMCard]?
    private var userMerchants: [SMMerchant]?
    private var targetAccountId: String!
    private var transportId : String?
    private var qrCode : String?
    var manualInputView : SMSingleInputView!
    var ManualCodeActive = false

    var scanner: MTBBarcodeScanner?
    private var currentAmount: String = IGStringsManager.GlobalUpdating.rawValue.localized {
        didSet {
            
            lblCurrency.text = IGStringsManager.UserWalletBalance.rawValue.localized + "\(" \n")\(merchantBalance.inRialFormat()) \(" ")" + IGStringsManager.Currency.rawValue.localized
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCurrency.backgroundColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
        lblCurrency.textColor = .white
        QRHolder.image = UIImage(named: "SCAN_HOLDER_QR".Imagelocalized)

        initView()
        

        self.hideKeyboardWhenTappedAround()
        self.lblCurrency.font = UIFont.igFont(ofSize: 18)
        self.userCards = SMCard.getAllCardsFromDB()
        self.userMerchants = SMMerchant.getAllMerchantsFromDB()
        lblCurrency.text = IGStringsManager.GlobalUpdating.rawValue.localized

        if isfromPacket {
            switch currentBussinessType {
            case 0 :
                lblCurrency.text = IGStringsManager.UserWalletBalance.rawValue.localized + "\(" \n")\(merchantBalance.inRialFormat()) \(" ")" + IGStringsManager.Currency.rawValue.localized
                
                break
            case 2 :
                lblCurrency.text = IGStringsManager.UserWalletBalance.rawValue.localized + "\(" \n")\(merchantBalance.inRialFormat()) \(" ")" + IGStringsManager.Currency.rawValue.localized
                
                break
            case 3 :
                lblCurrency.text = IGStringsManager.UserWalletBalance.rawValue.localized + "\(" \n")\(merchantBalance.inRialFormat()) \(" ")" + IGStringsManager.Currency.rawValue.localized
                self.updateAmountOfPayGear()
                
                break
                
            default :
                
                break
                
            }
            
            
        }
        else {
            initCards()
        }
       
    }


    private func updateAmountOfPayGear() {
        if let cards = userCards {
            if cards.count > 0 {
                
                for card in cards {
                    if card.type == 1{
                        currentAmount = String.init(describing: card.balance ?? 0).inRialFormat()
                    }
                    else {
                        currentAmount = String.init(describing: card.balance ?? 0).inRialFormat()
                        
                    }
                }
            }
            else {
                currentAmount = "0".inRialFormat()

            }
        }
    }
    
    func initView() {

//        previewView.backgroundColor = .orange
        scanner = MTBBarcodeScanner(previewView: previewView)
        callQR()

    }
    func callQR() {
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            for code in codes {
                                if let stringValue = code.stringValue {
//                                    self.scanner?.stopScanning()
                                    self.resolveScannedQrCode(stringValue)
//                                    self.showPayModal()
                                    return
                                }
                            }
                        }
                    })
                } catch {
                    NSLog("Unable to start scanning")
                }
            } else {
                // no access to camera
            }
        })
    }
    @IBAction func btnTorch(_ sender: Any) {
        if self.scanner?.torchMode == .off {
            
        self.scanner?.torchMode = .on
        }
        else {
            self.scanner?.torchMode = .off

        }
    }
    @IBAction func btnModalTap(_ sender: Any)
    {
        self.ManualCodeActive = true

        if manualInputView == nil {
            manualInputView = SMSingleInputView.loadFromNib()
            manualInputView.confirmBtn.addTarget(self, action: #selector(confirmManualButtonSelected), for: .touchUpInside)
            manualInputView!.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: manualInputView.frame.height)
            
            manualInputView.confirmBtn.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
            manualInputView.infoLbl.text = IGStringsManager.EnterRecieverCode.rawValue.localized
            manualInputView.inputTF.placeholder = IGStringsManager.EnterCode.rawValue.localized
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(SMBarcodeMainViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            manualInputView.addGestureRecognizer(swipeDown)
            self.view.addSubview(manualInputView!)
            
        }
        else {
            manualInputView.confirmBtn.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
            manualInputView.infoLbl.text = IGStringsManager.EnterRecieverCode.rawValue.localized
            manualInputView.inputTF.placeholder = IGStringsManager.EnterCode.rawValue.localized
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
            self.view.endEditing(true)
            if manualInputView != nil {

            hideManualInputView()
            }
        }
    }
    @objc func handleGesture(gesture: UITapGestureRecognizer) {
        // handling code
        if manualInputView != nil {
            
            hideManualInputView()
        }
    }
    func showPayModal(type: SMAmountPopupType, name:String , subTitle : String , imgUser : String, discount_percent: Int? = nil, discount_value: Int? = nil) {
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "payModal") as! walletModalViewController? {
            presentedViewController.delegateHandler = self
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            let _ : [String: String]!
            presentedViewController.name = nil
            presentedViewController.name = name
            if (type == SMAmountPopupType.PopupNoProductTaxi) ||  (type == SMAmountPopupType.PopupProductedTaxi) {
                isTaxi = true
            }
            else {
               isTaxi = false

            }
            if isHyperMe {
                presentedViewController.tfAmountToPy.text = (self.hyperMePrice).inLocalizedLanguage().currencyFormat()
                presentedViewController.isEditing = false
            }
            else {
                presentedViewController.tfAmountToPy.text = ""

                presentedViewController.isEditing = true
            }
            presentedViewController.profilePicUrl = imgUser
            UserDefaults.standard.setValue(imgUser, forKey: "modalUserPic")
            UserDefaults.standard.setValue(name, forKey: "modalUserName")
            UserDefaults.standard.setValue(merchantBalance, forKey: "modalUserAmount")
            UserDefaults.standard.setValue(self.targetAccountId!, forKey: "modalTargetAccountID")
            UserDefaults.standard.setValue(discount_percent ?? 0, forKey: "modalDiscountPercent")
            UserDefaults.standard.setValue(discount_value ?? 0, forKey: "modalDiscountValue")
            if discount_value != nil {
                presentedViewController.shouldUsePercent = false

            }
            else {
                presentedViewController.shouldUsePercent = true

            }
//            UserDefaults.standard.setValue(String(self.qrCode!).onlyDigitChars().inEnglishNumbers(), forKey: "modalQRCode")

            print (self.transportId)
            if (self.transportId)  != nil {
                UserDefaults.standard.setValue(self.transportId!, forKey: "modalTrasnportID")
            }


            presentedViewController.type = 2//user Type nuber
            
            self.present(presentedViewController, animated: true, completion: nil)
        }
    }
    @objc func confirmManualButtonSelected() {
        
        if manualInputView != nil {
            
            hideManualInputView()
        }        //go to process info
        
        if manualInputView.inputTF.text! == "" {
            SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalErrorForm.rawValue.localized, leftButtonTitle: "", rightButtonTitle: IGStringsManager.GlobalOK.rawValue.localized,yesPressed: { yes in
                return
            })
        } else {
            if !hasShownQrCode {
//                hasShownQrCode = true
                isUser = false
                getQRCodeInformation(barcodeValue: (manualInputView.inputTF.text!).inEnglishNumbersNew().onlyDigitChars())

            }
            
        }
        
    }
    
    func hideManualInputView() {
        self.ManualCodeActive = false

        hasShownQrCode = false
        UIView.animate(withDuration: 0.3, animations: {
            self.manualInputView.frame.origin.y = self.view.frame.height
            self.manualInputView.inputTF.endEditing(true)
            
        }) { (true) in
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotifications()

        if (scanner?.isScanning())! {
//            scanner?.stopScanning()
            initView()
        }
        else {
            initView()

        }
        
//        try! self.scanner?.startScanning()
       
        
    }
    
    // MARK : - init View elements
    func initNavigationBar() {
       
//        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.white]
//        self.navigationController!.navigationBar.topItem!.title = IGStringsManager.QrCodeScanner.rawValue.localized
        self.initNavigationBar(title: IGStringsManager.QrCodeScanner.rawValue.localized) { }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TAB0")
        
        self.hideKeyboardWhenTappedAround()

        initNavigationBar()
        setupNotifications()
        if isfromPacket {
            
        }
        else {
            initCards()

        }

    }
    func initCards() {
        
        SMCard.getAllCardsFromServer({ cards in
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0
                    {
                        let amount = ((cards as! [SMCard])[0]).balance!
                        let strAsNSString = String.init(describing: amount).inRialFormat()
                        self.lblCurrency.text = IGStringsManager.UserWalletBalance.rawValue.localized + "\(" \n")\(strAsNSString) \(" ")" + IGStringsManager.Currency.rawValue.localized
                    }
                }
            }
            needToUpdate = true
        }, onFailed: {err in
            //            SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.scanner?.stopScanning()
        unsetNotifications()
        
        super.viewWillDisappear(animated)
    }
    func setupNotifications() {
        unsetNotifications()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SMBarcodeMainViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SMBarcodeMainViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsetNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let window = UIApplication.shared.keyWindow!
        
        if ManualCodeActive {
            if let manualInput = manualInputView {
                window.addSubview(manualInput)
                UIView.animate(withDuration: 0.3) {
                    
                    var frame = manualInput.frame
                    frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight - frame.size.height)
                    manualInput.frame = frame
                    
                }
            }
        }else {
            if manualInputView != nil {
                
                self.hideManualInputView()
            }
            
        }
        
        
        
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
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
    

    func resolveScannedQrCode(_ code: String) {
        print("Found code: \(code)")
        let urlComponents = URLComponents(string: code)

        if let range = code.range(of: "?jj=") {

            isUser = true
            let value = String(code[range.upperBound...])
        if let json = value.toJSON() as? Dictionary<String, AnyObject> {
            print(json)
            if !hasShownQrCode {
                hasShownQrCode = true
                isHyperMe = false
                isUser = true
                UserDefaults.standard.setValue(String(value).inEnglishNumbersNew(), forKey: "modalQRCode")

            self.getUserInformation(accountId: json["H"] as! String, qrType: Int(json["T"] as! String)!)
            }
        }
        else {
            if !hasShownQrCode {
                hasShownQrCode = true
                isHyperMe = false
                isUser = false
            self.getQRCodeInformation(barcodeValue: String(value))
            }
        }
        }
        else if urlComponents!.host == "www.hyperme.ir" {
            if !hasShownQrCode {
                hasShownQrCode = true

//        else if let range = code.range(of: "hyperme") {
            isUser = false

            let pathes = urlComponents!.path
            let pathesArray = pathes.components(separatedBy: "/")
            self.hyperMePrice = pathesArray[1]
            self.hyperMeShomareFactor = pathesArray[2]
            let code = pathesArray[3]
//
            isHyperMe = true
            
            self.getQRCodeInformation(barcodeValue: code)
            }
        }
        
        
    }
    
    func getAccountInformation (accountId: String, closure: @escaping (_ name: String, _ subTitle: String, _ imagePath: String, _ acountType: Int ,_ discount_percent: Int?, _ discount_value: Int?) -> ()) {
        
        
        let account = PU_obj_account()
        account.account_id = String(describing: accountId)
        
        let request = WS_methods(delegate: self, failedDialog: false)
        
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                SMLoading.hideLoadingPage()
                var name: String = ""
                var subTitle: String = ""
                var imagePath: String = ""
                var acountType: Int = 2
                var discount_percent: Int?
                var discount_value: Int?

                if let n = jsonResult["name"] { name = n as! String }
                if let s = jsonResult["sub_title"] { subTitle = s as! String }
                if let i = jsonResult["profile_picture"] { imagePath = i as! String }
                if let at = jsonResult["account_type"] { acountType = at as! Int }

                if let dp = jsonResult["discount_percent"] as? Int, dp != 0 { discount_percent = dp }
                if let dv = jsonResult["discount_value"] as? Int, dv != 0 { discount_value = dv }

                closure(name , subTitle, imagePath, acountType, discount_percent, discount_value)
            }
            
        }
        request.addFailedHandler({ (response: Any) in
            SMLoading.hideLoadingPage()
            //show popup
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
            }
            
        })
        
        request.pu_getaccountinfo(account, mod: 1)
        
        
    }
    func getUserInformation(accountId: String, qrType: Int, productId: String? = "") {
        
        SMLoading.showLoadingPage(viewcontroller: self, text: IGStringsManager.GlobalLoading.rawValue.localized)
        
        self.targetAccountId = String(describing:accountId)
        UserDefaults.standard.setValue(self.targetAccountId!, forKey: "modalTargetAccountID")

        self.getAccountInformation(accountId:  String(describing:accountId), closure: {name, subTitle, imagePath, acountType, discount_percent, discount_value  in
            
            let tmpVal : Int? = discount_value
            let tmpPercent : Int? = discount_percent

            
            if qrType == Int(SMQRCode.SMAccountType.User.rawValue) || qrType == Int(SMQRCode.SMAccountType.HyperMe.rawValue) {
                SMLoading.hideLoadingPage()
                if isHyperMe {
                    let tmp = self.hyperMePrice
                    UserDefaults.standard.setValue(self.hyperMePrice, forKey: "modalHyperPrice")
                }

//                self.showPopup(type: .PopupUser, value:["name": name, "subTitle": subTitle, "imagePath": imagePath])

                    switch acountType {
                    case 0 :
                        DispatchQueue.main.async {
                            
                            if discount_percent != nil {
                            self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath,discount_percent:tmpPercent)
                            }
                            else if discount_value != nil {
                                self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath,discount_value:tmpVal)

                            }
                            else {
                                self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath)

                            }
                        }
                        break
                    case 1 :
                        DispatchQueue.main.async {
                            if discount_percent != nil {
                                self.showPayModal(type: .PopupProductedTaxi, name: name, subTitle: subTitle, imgUser: imagePath,discount_percent:tmpPercent)
                            }
                            else if discount_value != nil {
                                self.showPayModal(type: .PopupProductedTaxi, name: name, subTitle: subTitle, imgUser: imagePath,discount_value:tmpVal)
                                
                            }
                            else {
                                self.showPayModal(type: .PopupProductedTaxi, name: name, subTitle: subTitle, imgUser: imagePath)
                                
                            }
                        }

                        break
                    case 2 :
                        DispatchQueue.main.async {
                            
                            if discount_percent != nil {
                                self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath,discount_percent:tmpPercent)
                            }
                            else if discount_value != nil {
                                self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath,discount_value:tmpVal)
                                
                            }
                            else {
                                self.showPayModal(type: .PopupUser, name: name, subTitle: subTitle, imgUser: imagePath)
                                
                            }
                        }

                        break
                    default :
                        break
                    }
                    
                
            }
            else {

                switch acountType {
                case 0 :
                    DispatchQueue.main.async {
                        self.showPayModal(type: .PopupNoProductTaxi, name: name, subTitle: subTitle, imgUser: imagePath)
                        
                    }
                    break
                case 1 :
                    DispatchQueue.main.async {
                        self.showPayModal(type: .PopupProductedTaxi, name: name, subTitle: subTitle, imgUser: imagePath)
                        
                    }
                    break
                case 2 :
                    break
                default :
                    break
                }
                
            }
        })
    }
    
    /// API call to fetch QR infromation according qr code
    ///
    /// - Parameter barcodeValue: qr code
    func getQRCodeInformation(barcodeValue: String) {

        self.qrCode = barcodeValue.inEnglishNumbersNew()
        UserDefaults.standard.setValue(String(self.qrCode!).onlyDigitChars().inEnglishNumbersNew(), forKey: "modalQRCode")

        SMLoading.showLoadingPage(viewcontroller: self, text: IGStringsManager.GlobalLoading.rawValue.localized)
        let request = WS_methods(delegate: self, failedDialog: true)
        
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                if let id = jsonResult["_id"] as? String , id == "" {
                    SMLoading.hideLoadingPage()
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.QrNotRecognised.rawValue.localized, rightButtonTitle: IGStringsManager.GlobalOK.rawValue.localized)
                }
                else if let accountId = jsonResult["account_id"], !accountId.isKind(of: NSNull.self) {
                    SMLoading.hideLoadingPage()
                    self.targetAccountId = String(describing:accountId)
                    self.transportId = jsonResult["value"] as? String
                    if jsonResult["qr_type"]! as! NSNumber != 10 {
                        self.getUserInformation(accountId: accountId as! String, qrType: Int(truncating: jsonResult["qr_type"]! as! NSNumber), productId: jsonResult["value"] as? String)
                    } else {
                        SMLoading.hideLoadingPage()
                        self.GetGift(Response: jsonResult as NSDictionary)
                    }

                }
                else {
                    SMLoading.hideLoadingPage()
                    try! self.scanner?.startScanning()
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled:false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.QrNotRecognised.rawValue.localized, rightButtonTitle: IGStringsManager.GlobalOK.rawValue.localized)
                }
            }
        }
        request.addFailedHandler { (response: Any) in
            SMLoading.hideLoadingPage()
            try! self.scanner?.startScanning()
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
            }
            SMMessage.showWithMessage(SMCard.testConvert(response))
        }
        request.mc_getqrcodewithid(barcodeValue.inEnglishNumbersNew())
    }
    //HINT : QR GIFT Data
    private func GetGift(Response: NSDictionary) {
        //SMClubsMerchantInfo.getInstance().showInfo(viewcontroller: self, infoDic: Information)
        if Response.value(forKey: "disable") as! Int64 == 0 {
            let Temp = Response.value(forKey: "sequence_number") as? String
            //self.SequenceNumber = String(Temp)
            self.SequenceNumber = "\(Temp ?? "0")"
//            self.scanner?.stopScanning()

            
            SMGetGift.getInstance().showInfo(viewcontroller: self, id: Response.value(forKey: "_id") as! String, value: Response.value(forKey: "value") as! String, isFaild: false)
        } else {
//            self.scanner?.stopScanning()

            // not active\
            SMGetGift.getInstance().showInfo(viewcontroller: self, id: IGStringsManager.GlobalWarning.rawValue.localized, value: IGStringsManager.GiftIsUsedAlready.rawValue.localized, isFaild: true)
        }
    }
    func confirmGift() {
        hasShownQrCode = false

        SMLoading.showLoadingPage(viewcontroller: self)
        let request = WS_methods(delegate: self, failedDialog: false)
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                let message = (jsonResult as NSDictionary).value(forKey: "message") as! String
                SMLoading.hideLoadingPage()
                self.closeGift()
                SMGetGift.getInstance().showSuccess(viewcontroller: self, Message: message)
            }
            
        }
        request.addFailedHandler({ (response: Any) in
            SMLoading.hideLoadingPage()
            self.closeGift()
            //show popup
            SMGetGift.getInstance().showInfo(viewcontroller: self, id: "Oops!", value: IGStringsManager.GlobalWarning.rawValue.localized, isFaild: true)
            //SMGetGift.getInstance().showSuccess(viewcontroller: self)
        })
        
        request.mc_GetQrCodeGift(self.SequenceNumber)
    }
    
    func closeGift() {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.dismiss(animated: false, completion: {
                hasShownQrCode = false
                
                self.view.endEditing(true)
                //            try! self.scanner?.startScanning()
                DispatchQueue.main.async {
                }
            })
            
        })


    }

}
