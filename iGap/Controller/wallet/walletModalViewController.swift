//
//  walletModalViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import webservice
import SnapKit


public var isTaxi : Bool! = false


protocol HandlePayModal {
    func payTaped()
}
protocol walletPayHandler {
    func closeAll()
}
class walletModalViewController: UIViewController , UITextFieldDelegate ,HandleReciept {
    
    
    struct _mutual_club_card_info {
        var club_revoked = Int()
        var id = String()
        var max = Int()
        var member_expire_at = String()
        var member_id = String()
        var member_revoked = Int()
        var merchant_expire_at = String()
        var merchant_id = String()
        var merchant_revoked = Int()
        var min = Int()
    }
    
    func close() {
        hasShownQrCode = false
        self.dismiss(animated: true, completion: {
            self.delegateHandler?.closeAll()
        })
        //        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)

    }
    

    func screenView() {
        close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            SMReciept.getInstance().screenReciept(viewcontroller: self)
        }
    }
    
    
    
    ////
    var shouldUsePercent : Bool! = true
    var selectedCardTpPay: SMCard!
    var paygearCard: SMCard!
    var hypermePrice : String! = ""
    var currentStep = 0
    var payFromBoth : Bool! = false
    var payableAmount : String = "0"
    var payableAmountWithoutDisc : String = "0"
    @IBOutlet weak var mainView: UIViewX!
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    var MutualClubCards: [Any]!
    var MutualClubCard: NSDictionary!

    var FinalMutualCards = [SMCard()]
    var serverCards = [_mutual_club_card_info()]
    var disCountPercent  : Int = 0
    var discount_price : String = "0"
    
    @IBOutlet weak var btnPickClub: UIButton!
    
    @IBOutlet weak var holder0: UIView!
    @IBOutlet weak var lblTTL0: UILabel!
    @IBOutlet weak var lblVALUE0: UILabel!
    @IBOutlet weak var holder1: UIView!
    @IBOutlet weak var lblTTL1: UILabel!
    @IBOutlet weak var lblVALUE1: UILabel!
    @IBOutlet weak var holder3: UIView!
    @IBOutlet weak var lblTTL3: UILabel!
    @IBOutlet weak var lblVALUE3: UILabel!
    @IBOutlet weak var holder4: UIView!
    @IBOutlet weak var holderStepCounter: UIView!
    @IBOutlet weak var stepHolderPicker: UIView!
    @IBOutlet weak var stepHolderAmount: UIView!
    @IBOutlet weak var holderPin: UIView!
    @IBOutlet weak var holderButton: UIView!
    
    ///
    var dismissBtn : UIButton!
    var delegate : HandlePayModal?
    var delegateHandler : walletPayHandler?
    @IBOutlet weak var lblPersonesCount: UILabel!
    @IBOutlet weak var lblPaidToTitle: UILabel!
    @IBOutlet weak var stepperPersons: UIStepper!
    @IBOutlet weak var verticalConstraints: NSLayoutConstraint!
    @IBOutlet weak var imgProfile: UIImageViewX!
    @IBOutlet weak var tfPin: UITextField!
    @IBOutlet weak var tfAmountToPy : customUITextField!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var segmentPick: UISegmentedControl!
    @IBOutlet weak var btnPay: UIButton!
    private var userCards: [SMCard]?
    private var targetAccountId: String!
    private var transportId : String?
    var keyboardHeight : CGFloat?
    var keyBoardIsOpen = false
    
    public var type: Int = 2
    
    
    
    /// Dictionary contains name, productName, subTitle, price, imagePath
    var value: [String: String]!{
        didSet {
            if type == 0 {
            }else if type == 1 {
            }else if type == 2 {
                lblDescription.text = name
                if let price = price {
                    //                    tfAmountToPy.text = price as String
                    //                    tfAmount.isEnabled = false
                }
            }
            DispatchQueue.main.async {
                let request = WS_methods(delegate: self, failedDialog: true)
                let str = request.fs_getFileURL(self.profilePicUrl)
                self.imgProfile.downloadedFrom(link: str!.filter { !" \\ \n \" \t\r".contains($0) },contentMode : .scaleAspectFill)
            }
        }
    }
    
    var username : String!
    var phoneNum : String!
    var amount : String!
    var name : String!
    var id : String!
    var price : String!
    var currentAmount : String!
    var profilePicUrl : String!
    private var qrCode : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mainView.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        
        lblPersonesCount.font = UIFont.igFont(ofSize: 20)
        self.userCards = SMCard.getAllCardsFromDB()
        
        
        initView()
        handleUIChange()
        initUI(stepCount: 0)
        //        btnPay.addTarget(self, action: #selector(btnPayTaped), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 15)]
        segmentPick.setTitleTextAttributes((font as! [NSAttributedString.Key : Any]), for: .normal)
        
        name = UserDefaults.standard.string(forKey: "modalUserName")
        
        lblDescription.text = name
        
        if isTaxi {
            lblPersonesCount.isHidden = true
            stepperPersons.isHidden = true
            self.view.layoutIfNeeded()
        }
        else {
            lblPersonesCount.isHidden = true
            stepperPersons.isHidden = true
            self.view.layoutIfNeeded()
            
            
        }
    }
    func initView() {
        self.hideKeyboardWhenTappedAround()
        
        //        tfAmount.inputView =  LNNumberpad.default()
        //        self.tfAmountToPy.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        self.tfAmountToPy.delegate = self
        self.btnPickClub.backgroundColor = .clear
        self.btnPickClub.layer.cornerRadius = 15
        self.btnPickClub.layer.borderWidth = 1
        self.btnPickClub.layer.borderColor = UIColor.black.cgColor
        
        self.btnPay.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.tfAmountToPy.font = UIFont.igFont(ofSize: 15)
        self.tfPin.attributedPlaceholder = NSAttributedString(string: "enterpin".localizedNew, attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.igFont(ofSize: 15)
            ])
        disCountPercent = UserDefaults.standard.integer(forKey: "modalDiscountPercent")
        disCountPercent = UserDefaults.standard.integer(forKey: "modalDiscountValue")
        let tmp = disCountPercent
        profilePicUrl = UserDefaults.standard.string(forKey: "modalUserPic")
        currentAmount = UserDefaults.standard.string(forKey: "modalUserAmount")
        transportId = UserDefaults.standard.string(forKey: "modalTrasnportID")
        targetAccountId = UserDefaults.standard.string(forKey: "modalTargetAccountID")
        qrCode = UserDefaults.standard.string(forKey: "modalQRCode")
        
        if type == 2 {
            
            lblDescription.text = name
            
            if let price = price {
            }
        }
        
        DispatchQueue.main.async {
            let request = WS_methods(delegate: self, failedDialog: true)
            let str = request.fs_getFileURL(self.profilePicUrl)
            self.imgProfile.downloadedFrom(link: str!.filter { !" \\ \n \" \t\r".contains($0) },contentMode : .scaleAspectFill)
            self.imgProfile.layer.cornerRadius = self.imgProfile.bounds.width/2
            self.imgProfile.layer.borderWidth = 1
            self.imgProfile.layer.borderColor = UIColor.black.cgColor
            self.imgProfile?.layer.shadowRadius = 10
            self.imgProfile?.layer.shadowColor = UIColor.black.cgColor
            self.imgProfile?.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.imgProfile?.layer.shadowOpacity = 0.5
            
        }
        segmentPick.setTitle("SETTING_PAGE_WALLET".localizedNew, forSegmentAt: 0)
        segmentPick.setTitle("SETTING_PAGE_CARD".localizedNew, forSegmentAt: 1)
        btnPay.setTitle("BTN_PAY_CASHOUT".localizedNew, for: .normal)
        lblPaidToTitle.text = "PAIED_TO_LBL".localizedNew
        lblPaidToTitle.textAlignment = lblPaidToTitle.localizedNewDirection
        lblDescription.textAlignment = lblDescription.localizedNewDirection
        
        if isHyperMe {
            print((UserDefaults.standard.string(forKey: "modalHyperPrice")))
            //            self.tfAmountToPy.text = (UserDefaults.standard.string(forKey: "modalHyperPrice"))!.inLocalizedLanguage().inRialFormat()
            self.tfAmountToPy.isEnabled = false
            hypermePrice = (UserDefaults.standard.string(forKey: "modalHyperPrice"))?.inRialFormat().inLocalizedLanguage()
            self.tfAmountToPy.placeholder = (UserDefaults.standard.string(forKey: "modalHyperPrice"))?.inRialFormat().inLocalizedLanguage()

            self.tfAmountToPy.isUserInteractionEnabled = false
        }
        else {
            self.tfAmountToPy.text = ""
            self.tfAmountToPy.placeholder = ""
            self.tfAmountToPy.isUserInteractionEnabled = true

            self.tfAmountToPy.isEnabled = true
            
        }
    }
    func initUI(stepCount : Int = 0) {
        creatBtnDismiss()
        
        switch stepCount {
        case 0 :
            self.mainViewHeight.constant = 200
            UIView.animate(withDuration: 0.3, animations: {
                self.holder0.isHidden = true
                self.holder1.isHidden = true
                self.holder3.isHidden = true
                self.holder4.isHidden = false
                self.holderStepCounter.isHidden = true
                self.stepHolderPicker.isHidden = true
                self.stepHolderAmount.isHidden = false
                self.holderPin.isHidden = true
                self.tfPin.isHidden = true
                
                self.holderButton.isHidden = false
                
                self.lblTTL0.text  = "WALLET_PAY_LBL0".localizedNew
                self.lblTTL1.text  = "WALLET_PAY_LBL1".localizedNew
                self.lblTTL3.text  = "WALLET_PAY_LBL3".localizedNew
                if isHyperMe {
                    self.lblVALUE0.text  = self.tfAmountToPy.placeholder

                }
                else {
                    self.lblVALUE0.text  = self.tfAmountToPy.text

                }
                
                self.lblVALUE1.text  = "0".inLocalizedLanguage()
                
                self.lblVALUE3.text  = "0".inLocalizedLanguage()
                self.mainView.layoutIfNeeded()
            })
            self.view.layoutIfNeeded()
            
            
            break
        case 1 :
            self.mainViewHeight.constant = 350
            UIView.animate(withDuration: 0.3, animations: {
                self.holder0.isHidden = false
                self.holder1.isHidden = false
                self.holder3.isHidden = false
                self.holder4.isHidden = false
                self.holderStepCounter.isHidden = true
                if self.segmentPick.selectedSegmentIndex == 1 {
                    self.stepHolderPicker.isHidden = true
                    
                }
                else {
                    self.stepHolderPicker.isHidden = false
                    
                }
                
                self.stepHolderAmount.isHidden = true
                self.holderPin.isHidden = true
                self.tfPin.isHidden = true
                self.holderButton.isHidden = false
                
                self.lblTTL0.text  = "WALLET_PAY_LBL0".localizedNew
                self.lblTTL1.text  = "WALLET_PAY_LBL1".localizedNew
                self.lblTTL3.text  = "WALLET_PAY_LBL3".localizedNew
                if isHyperMe {
                    self.lblVALUE0.text  = self.tfAmountToPy.placeholder
                }
                else {
                    self.lblVALUE0.text  = self.tfAmountToPy.text
                }
                let tmp = UserDefaults.standard.integer(forKey: "modalDiscountPercent")
                let tmpVal = UserDefaults.standard.integer(forKey: "modalDiscountValue")
                let tmpAmountToPay = self.lblVALUE0.text
                let tmppP = tmpAmountToPay?.onlyDigitChars()
                if tmp == 0 && tmpVal == 0 {
                    
                    self.lblVALUE1.text  = "0".inLocalizedLanguage()
                    
                }
                    
                else {
                    if self.shouldUsePercent {
                        if tmp == 0 {
                            self.lblVALUE1.text  = "0".inLocalizedLanguage()
                            
                        }
                        else {
                            let tmpPercent = Int((tmp))
                            let tmpSum = Int(tmppP!)
                            var tmpValue = tmpSum! * tmpPercent
                            tmpValue = tmpValue / 100
                            self.lblVALUE1.text  = (String(tmpValue)).inRialFormat().inLocalizedLanguage()
                            
                        }
                    }
                    else {
                        if tmpVal == 0 {
                            self.lblVALUE1.text  = "0".inLocalizedLanguage()
                            
                        }
                        else {
                            let tmpValue = Int((tmpVal))
                            let tmpSum = Int(tmppP!)
//                            tmpValue = tmpSum! - tmpValue
                            self.lblVALUE1.text  = (String(tmpValue)).inRialFormat().inLocalizedLanguage()
                            
                        }
                    }
 
                }
                
                
                self.lblVALUE3.text  = String(Int(((self.lblVALUE0.text)?.onlyDigitChars())!)! - Int(((self.lblVALUE1.text)?.onlyDigitChars())!)!).inRialFormat()
                
                self.btnPickClub.setTitle("BTN_CASHOUT".localizedNew, for: .normal)
                self.btnPay.setTitle("GLOBAL_OKGO".localizedNew, for: .normal)
                self.mainView.layoutIfNeeded()
            })
            self.view.layoutIfNeeded()
            
            break
        case 2 :
            self.mainViewHeight.constant = 300
            UIView.animate(withDuration: 0.3, animations: {
                self.holder0.isHidden = false
                if self.selectedCardTpPay?.bankCode == 69 && self.selectedCardTpPay?.clubID == nil {
                    self.holder1.isHidden = true
                    self.payFromBoth = false
                    self.lblVALUE1.text  = String(self.selectedCardTpPay.balance!).inRialFormat().inLocalizedLanguage()
                    
                }
                else {
                    self.payFromBoth = true
                    self.holder1.isHidden = false
                    let tmppppp = String(self.CalculateClubCardDiscount()).inRialFormat().inLocalizedLanguage()
                    self.lblVALUE1.text  = String(self.CalculateClubCardDiscount()).inRialFormat().inLocalizedLanguage()
                }
                self.holder3.isHidden = false
                self.holder4.isHidden = true
                self.holderStepCounter.isHidden = true
                self.stepHolderPicker.isHidden = true
                self.stepHolderAmount.isHidden = true
                self.holderPin.isHidden = false
                self.tfPin.isHidden = false
                
                self.holderButton.isHidden = false
                
                self.lblTTL0.text  = "WALLET_PAY_LBL3".localizedNew
                self.lblTTL1.text  = "TTL_WALLET_CLUB_USER".localizedNew
                self.lblTTL3.text  = "TTL_WALLET_BALANCE_USER".localizedNew
                if isHyperMe {
                    self.lblVALUE0.text  = self.tfAmountToPy.placeholder
                    
                }
                else {
                    self.lblVALUE0.text  = self.tfAmountToPy.text
                    
                }
                if isHyperMe {
                    self.lblVALUE0.text  = self.tfAmountToPy.placeholder
                    
                }
                else {
                    self.lblVALUE0.text  = self.tfAmountToPy.text
                    
                }
                let tmpAmountToPayy = (self.lblVALUE0.text)?.inEnglishNumbers()
                let tmpAmountToPay = self.lblVALUE0.text
                let tmppP = tmpAmountToPay?.onlyDigitChars()
                if self.shouldUsePercent {
                    let tmp = UserDefaults.standard.integer(forKey: "modalDiscountPercent")

                    if tmp == 0 {
                        
                        self.discount_price = "0"
                        if isHyperMe  {
                            self.lblVALUE0.text  = self.tfAmountToPy.placeholder
                            self.payableAmountWithoutDisc = self.lblVALUE0.text!
                            
                        }
                        else {
                            self.lblVALUE0.text  = self.tfAmountToPy.text
                            self.payableAmountWithoutDisc = self.lblVALUE0.text!
                            
                        }
                        
                    }
                    else {
                        let tmpPercent = Int((tmp))
                        let tmpSum = Int(tmppP!)
                        self.payableAmountWithoutDisc = String(tmpSum!)
                        var tmpValue = tmpSum! * tmpPercent
                        tmpValue = tmpValue / 100
                        self.discount_price = String(tmpValue)
                        self.lblVALUE0.text  = String(Int(((tmpAmountToPayy)?.onlyDigitChars())!)! - Int((tmpValue))).inRialFormat()
                        
                    }
                    self.payableAmount = tmppP!
                    self.payableAmountWithoutDisc = tmppP!
                    self.lblVALUE3.text  = merchantBalance.inLocalizedLanguage()
                    
                    self.holderPin.layoutIfNeeded()
                    
                    self.btnPickClub.setTitle("BTN_CASHOUT".localizedNew, for: .normal)
                    self.btnPay.setTitle("PU_PAYMENT".localizedNew, for: .normal)
                    self.mainView.layoutIfNeeded()

                }
                else {
                    let tmp = UserDefaults.standard.integer(forKey: "modalDiscountValue")

                    if tmp == 0 {
                        
                        self.discount_price = "0"
                        if isHyperMe  {
                            self.lblVALUE0.text  = self.tfAmountToPy.placeholder
                            self.payableAmountWithoutDisc = self.lblVALUE0.text!
                            
                        }
                        else {
                            self.lblVALUE0.text  = self.tfAmountToPy.text
                            self.payableAmountWithoutDisc = self.lblVALUE0.text!
                            
                        }
                        
                    }
                    else {
                        let tmpValue = Int((tmp))
                        let tmpSum = Int(tmppP!)

                        self.discount_price = String(tmpValue)
                        self.lblVALUE0.text  = String(Int(((tmpAmountToPayy)?.onlyDigitChars())!)! - Int((tmpValue))).inRialFormat()
                        
                    }
                    self.payableAmount = tmppP!
                    self.payableAmountWithoutDisc = tmppP!
                    self.lblVALUE3.text  = merchantBalance.inLocalizedLanguage()
                    
                    self.holderPin.layoutIfNeeded()
                    
                    self.btnPickClub.setTitle("BTN_CASHOUT".localizedNew, for: .normal)
                    self.btnPay.setTitle("PU_PAYMENT".localizedNew, for: .normal)
                    self.mainView.layoutIfNeeded()
                    

                }

            }, completion: {res in
                self.holderPin.isHidden = false
                self.tfPin.isHidden = false
                
                self.holderButton.isHidden = false
            })
            self.view.layoutIfNeeded()
            
            
            break
            
        default :
            break
        }
    }
    
    func creatBtnDismiss() {
        dismissBtn = UIButton()
        dismissBtn.backgroundColor = UIColor.clear
        self.view.insertSubview(dismissBtn, at: 2)
        dismissBtn.addTarget(self, action: #selector(didtapOutSide), for: .touchUpInside)
        
        dismissBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.mainView.snp.top)
            make.right.equalTo(self.view.snp.right)
            make.left.equalTo(self.view.snp.left)
        }
        
    }
    @objc func didtapOutSide() {
        if dismissBtn != nil {
            UserDefaults.standard.setValue(0, forKey: "modalDiscountPercent")
            
            currentStep = 0
            name = nil
            lblDescription.text = ""
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNoticationDismissWalletPay),
                                            object: nil,
                                            userInfo: nil)
            hasShownQrCode = false
            dismissBtn.removeFromSuperview()
            dismissBtn = nil
            
            self.dismiss(animated: true)
            
        }
        
        
    }
    
    //    @IBAction func payBtnTapedDows(_ sender: Any) {
    //
    //        tfAmountToPy.resignFirstResponder()
    //
    //        if self.tfAmountToPy.text == "" ||
    //            self.tfAmountToPy.text?.inEnglishNumbers() == "0" {
    //            SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "GLOBAL_WARNING".localizedNew, message: "FILL_AMOUNT".localizedNew, leftButtonTitle: "", rightButtonTitle: "GLOBAL_OK".localizedNew,yesPressed: { yes in return;})
    //        }
    //
    //        else {
    //
    //            self.GetMutualClubList(MerchantCode: self.targetAccountId, UserCode: merchantID) { response in
    //                //                self.getAmountPopup.removeFromSuperview()
    //                self.paySequence(ClubList: response)
    //
    //            }
    //        }
    //    }
    
    
    @IBAction func payBtnTapedDows(_ sender: Any) {
        print("CURRENTSTEP IS:",currentStep)
        switch currentStep {
        case 0:
            self.currentStep = 1
            
            tfAmountToPy.resignFirstResponder()
            if (self.tfAmountToPy.text == "" && (self.tfAmountToPy!.placeholder == "" || self.tfAmountToPy!.placeholder == nil)) ||
                self.tfAmountToPy.text?.inEnglishNumbers() == "0" {
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "GLOBAL_WARNING".localizedNew, message: "FILL_AMOUNT".localizedNew, leftButtonTitle: "", rightButtonTitle: "GLOBAL_OK".localizedNew,yesPressed: { yes in return;})
            }
            else {
                if segmentPick.selectedSegmentIndex == 1 {
                    stepHolderPicker.isHidden = true
                    
                }
                else {
                    stepHolderPicker.isHidden = false

                }
                self.GetMutualClubList(MerchantCode: self.targetAccountId, UserCode: merchantID) { response in
                    self.initUI(stepCount: self.currentStep)
                    self.getCardMutralClubs(cards: response)
                    //                self.getAmountPopup.removeFromSuperview()
                    //                    self.paySequence(ClubList: response)
                }
            }
            
        case 1:
            if segmentPick.selectedSegmentIndex == 1 {
                paySequence()
                
            }
            else {
                if !((btnPickClub.currentTitle)! == "BTN_CASHOUT".localizedNew) || !((btnPickClub.currentTitle?.contains("BTN_CASHOUT".localizedNew))!) {
                    self.currentStep = 2
                    self.initUI(stepCount: self.currentStep)

                }
                else {
                    btnPickClub.shake()
                }
                
            }
            
            break
        case 2 :
            
            print(btnPickClub.titleLabel!.text)
            if !((btnPickClub.currentTitle)! == "BTN_CASHOUT".localizedNew) || !((btnPickClub.currentTitle?.contains("BTN_CASHOUT".localizedNew))!) {
//                self.initUI(stepCount: self.currentStep)
                self.currentStep = 3
                if ((tfPin.text == "") || (tfPin.text == nil)) {
                    
                }
                else {
                    paySequence()
                }

                
            }
            
            break

        case 3 :
       
            if ((tfPin.text == "") || (tfPin.text == nil)) {
                
            }
            else {
                paySequence()
            }
            break
        default:
            break
        }
    }
    func getCardMutralClubs(cards:[Any]) {
        MutualClubCards = cards
        for item in MutualClubCards {
            let cardItem = item as! NSDictionary
            var card = _mutual_club_card_info()
            card.club_revoked = cardItem.value(forKey: "club_revoked") as! Int
            card.id = cardItem.value(forKey: "id") as! String
            card.max = cardItem.value(forKey: "max") as! Int
            card.member_expire_at = cardItem.value(forKey: "member_expire_at") as! String
            card.member_id = cardItem.value(forKey: "member_id") as! String
            card.member_revoked = cardItem.value(forKey: "member_revoked") as! Int
            card.merchant_expire_at = cardItem.value(forKey: "merchant_expire_at") as! String
            card.merchant_id = cardItem.value(forKey: "merchant_id") as! String
            card.merchant_revoked = cardItem.value(forKey: "merchant_revoked") as! Int
            card.min = cardItem.value(forKey: "min") as! Int
            serverCards.append(card)
        }
        self.FetchClubCardList(RecivedClubsCardDataFromWeb: serverCards)
        
    }
    
    func FetchClubCardList(RecivedClubsCardDataFromWeb: [_mutual_club_card_info]) {
        var FinalCards = [SMCard()]
        FinalMutualCards.removeAll()
        FinalCards.removeAll()
        
        let tmpCards = SMCard.getAllCardsFromDB()
        let tmp = tmpCards
        for i in 0..<tmp.count{
            if tmp[i].bankCode == 69 && tmp[i].clubID == nil {
                FinalCards.append(tmp[i])
            }
            for j in 0..<RecivedClubsCardDataFromWeb.count {
                if tmp[i].clubID == RecivedClubsCardDataFromWeb[j].id {
                    FinalCards.append(tmp[i])
                }
            }
        }
        self.FinalMutualCards = FinalCards
    }
    @IBAction func cardPickTap(_ sender: Any) {
        
        SMLoading.shared.showClubCardDialog(viewController: self, icon: nil, title: "SAVED_CARDS".localizedNew, cards: self.FinalMutualCards,yesPressed: { card, saveDefault in
            
            let tmp = self.FinalMutualCards
            let selectCard = (card as! SMCard)
            self.selectedCardTpPay = selectCard
            for item in tmp {
                if item.bankCode == 69 && item.clubID == nil {
                    self.paygearCard = item
                }
            }
            if let pan = selectCard.pan {
                var newStr = pan
                if newStr == "پیگیر کارت" {
                    newStr = "کیف پول کاربر"
                }
                self.btnPickClub.setTitle(("BTN_CASHOUT".localizedNew) + "     " + newStr, for: .normal)
                
            }
            if self.selectedCardTpPay.clubID != nil {
                self.payFromBoth = true
            }
            else {
                self.payFromBoth = false

            }
            
        },noPressed: {
            
        })
        
    }
    @IBAction func stepperTaped(_ sender: Any) {
        lblPersonesCount.text = String(Int(stepperPersons.value))
        if let tmpCount = Float(lblPersonesCount.text!) {
            
        }
    }
    @IBAction func segPickedTap(_ sender: Any) {
        if segmentPick.selectedSegmentIndex == 0 {
            print("wallet")
            self.stepHolderPicker.isHidden = false
            if currentStep == 1 {
                self.initUI(stepCount: currentStep)
                self.btnPay.setTitle("GLOBAL_OKGO".localizedNew, for: .normal)
            }
            else if currentStep == 0 {
                self.stepHolderPicker.isHidden = true
                self.btnPay.setTitle("PU_PAYMENT".localizedNew, for: .normal)
                
            }
            else {
                self.initUI(stepCount: currentStep)
                self.btnPay.setTitle("PU_PAYMENT".localizedNew, for: .normal)
                
            }
            
        }
        else {
            print("Card")
            self.stepHolderPicker.isHidden = true
            self.btnPay.setTitle("PU_PAYMENT".localizedNew, for: .normal)
            
        }
    }
    func AnimateMainViewHeight() {
        UIView.animate(withDuration: 0.5, animations: {
            self.mainViewHeight.constant = 600 // heightCon is the IBOutlet to the constraint
            self.mainView.layoutIfNeeded()
        })
    }
    
    
    func paySequence() {
        SMLoading.showLoadingPage(viewcontroller: self)
        
        self.tfPin.resignFirstResponder()
        if segmentPick.selectedSegmentIndex == 0 {
            if isTaxi {
                if isUser {
                    self.qrCode?.removeAll()
                    
                }
            }
            else {
                if isHyperMe{
                    self.qrCode = merchantID

                }else
                {
                    self.qrCode = self.targetAccountId

                }

            }
            let t = self.currentAmount
            let tmp1 = Int(self.payableAmount.inEnglishNumbers().onlyDigitChars())!
            let tmp2 = Int(self.currentAmount.inEnglishNumbers().onlyDigitChars())!
            if Int(tmp1) > Int(tmp2) {
                SMLoading.hideLoadingPage()

                //show message about your amount is not enough
                SMMessage.showWithMessage("AMOUNT_IS_NOT_ENOUGH".localizedNew)
                return
            }
            if payFromBoth {
                
                
                SMCard.initPayment(amount: Int(payableAmountWithoutDisc), accountId: self.targetAccountId, transportId : self.transportId, qrCode: self.qrCode, discount_price : self.discount_price, isCredit: true, transaction_type: 1, hyperme_invoice_number: nil, onSuccess: { response in
                    SMLoading.hideLoadingPage()
                    SMLoading.showLoadingPage(viewcontroller: self)

                    let json = response as? Dictionary<String, AnyObject>
                    SMUserManager.publicKey = json?["pub_key"] as? String
                    SMUserManager.payToken = json?["token"] as? String
                    
                    if self.selectedCardTpPay.balance == 0 {
                        self.payFromSingleCard(card: self.paygearCard)
                    } else {
                        let tmpI = Int(self.lblVALUE0.text!.onlyDigitChars().inEnglishNumbers())

                        if Int64(self.payableAmount.onlyDigitChars().inEnglishNumbers())! >= Int64(tmpI!) {
                            self.payFromSplitCards(card1: self.paygearCard, card2: self.selectedCardTpPay ,amount: Int64(tmpI!) )

                        }
                        else {
                            self.payFromSingleCard(card: self.selectedCardTpPay)

                        }
                    }

                    
                    
                }, onFailed: { (err) in
                    SMLog.SMPrint(err)
                    SMLoading.hideLoadingPage()

                    if (err as! Dictionary<String, AnyObject>)["message"] != nil {
                        SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)

                    } else if (err as! Dictionary<String, AnyObject>)["server serror"] != nil {
                        SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "serverDown".localized)
                    }
                })
                
                

            }
            else {
                
                SMCard.initPayment(amount: Int(self.tfAmountToPy.text!.onlyDigitChars().inEnglishNumbers()), accountId: self.targetAccountId, transportId : self.transportId, qrCode: self.qrCode, discount_price : self.discount_price, isCredit: true, transaction_type: 1, hyperme_invoice_number: nil, onSuccess: { response in
                    SMLoading.hideLoadingPage()

                    let json = response as? Dictionary<String, AnyObject>
                    SMUserManager.publicKey = json?["pub_key"] as? String
                    SMUserManager.payToken = json?["token"] as? String
                    self.payFromSingleCard(card: self.paygearCard)

                    
                    
                }, onFailed: { (err) in
                    SMLog.SMPrint(err)
                    SMLoading.hideLoadingPage()

                    if (err as! Dictionary<String, AnyObject>)["message"] != nil {
                        SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
                        
                    } else if (err as! Dictionary<String, AnyObject>)["server serror"] != nil {
                        SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "serverDown".localized)
                        
                    }
                })

            }
            
        }
        else {
            //pay by card
            SMLoading.showLoadingPage(viewcontroller: self)
            SMCard.initPayment(amount: Int((self.lblVALUE3.text?.inEnglishNumbers().onlyDigitChars())!), accountId: self.targetAccountId,from : merchantID, transportId: self.transportId, qrCode: "", discount_price: self.discount_price, onSuccess: { response in
                
//                self.dismiss(animated: true, completion: nil)

                SMLoading.hideLoadingPage()
                let json = response as? Dictionary<String, AnyObject>
                if let ipg = json?["ipg_url"] as? String ,ipg != "" {
                    if let url = URL(string: ipg) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                else{
                }
            }, onFailed: {err in
                SMLoading.hideLoadingPage()
                SMLog.SMPrint(err)
            })
        }
    }
    
    private func CalculateClubCardDiscount() -> Int{
        // First we check Merchant's Discount for club if its zero then we check Club's Discount, actually Merchant's Discount (in this Campign) is higher priority than Club's
        var FinalDiscount = 0
        var MerchantDiscount = 0
        var ClubsDiscount = 0
        let tmp = self.MutualClubCard
        var MaxMerchant : Int!
        if self.MutualClubCard.value(forKey: "merchant_max") as! Int != 0{
            MaxMerchant = (self.MutualClubCard.value(forKey: "merchant_max") as! Int)
            if self.MutualClubCard.value(forKey: "merchant_is_percentage") as? Int == 1 { // Calculate as Percent
                let tmpI = Int(self.lblVALUE3.text!.onlyDigitChars().inEnglishNumbers())
                let tmpII = MaxMerchant

                MerchantDiscount = tmpI! * tmpII! / 100
            }else {
                MerchantDiscount = Int(MaxMerchant)
            }
        }else { // Calculate from Clubs

            if let ClubsMax = (self.MutualClubCard.value(forKey: "max") as? Int) {
                if self.MutualClubCard.value(forKey: "is_percentage") as? Int == 1 { // Calculate as Percent
                    let tmpI = Int(self.lblVALUE3.text!.onlyDigitChars().inEnglishNumbers())
                    let tmpII = ClubsMax
                    ClubsDiscount = tmpI! * tmpII / 100
                }else {
                    ClubsDiscount = ClubsMax
                }
            }
            
        }
        if MerchantDiscount >= ClubsDiscount {
            FinalDiscount = MerchantDiscount
        }else {
            FinalDiscount = ClubsDiscount
        }
        
        return FinalDiscount
        
    }
    //from paygear only
    
    private func payFromSingleCard(card: SMCard) {
        let para  = NSMutableDictionary()
        para.setValue(card.token, forKey: "c")
        para.setValue((self.tfPin.text!).onlyDigitChars(), forKey: "p2")
        para.setValue(card.type, forKey: "type")
        para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
        para.setValue(card.bankCode, forKey: "bc")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey) {
            //                                    self.showReciept(response: NSDictionary())
            SMLoading.showLoadingPage(viewcontroller: self)

            SMCard.payPayment(enc: enc, enc2: nil, onSuccess: { resp in
                SMLoading.hideLoadingPage()
                if let result = resp as? NSDictionary{
//                    self.dismiss(animated: true, completion: nil)

                    SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                    
                }
            }, onFailed: {err in
                SMLog.SMPrint(err)
                SMLoading.hideLoadingPage()

                let message = (err as! NSDictionary).value(forKey: "message") as! String
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "GLOBAL_WARNING".localizedNew, message: message)

              
                
            })
        }
    }
    //from both
    private func payFromSplitCards(card1: SMCard, card2: SMCard , amount : Int64) {
        let para1  = NSMutableDictionary()
        let para2  = NSMutableDictionary()
        
        para1.setValue(card1.token, forKey: "c")
        para1.setValue((self.tfPin.text!).onlyDigitChars(), forKey: "p2")
        para1.setValue(card1.type, forKey: "type")
        para1.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
        para1.setValue(card1.bankCode, forKey: "bc")
        let tmpII = Int64(amount)
        let tmpIII = Int64(lblVALUE1.text!.onlyDigitChars().inEnglishNumbers())!
        para1.setValue(tmpII - tmpIII , forKey: "a")
//        para1.setValue(Int64(95 - 7) , forKey: "a")

        para2.setValue(card2.token, forKey: "c")
        para2.setValue((self.tfPin.text!).onlyDigitChars(), forKey: "p2")
        para2.setValue(card2.type, forKey: "type")
        para2.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
        para2.setValue(card2.bankCode, forKey: "bc")
        //        para2.setValue(Int64(7), forKey: "a")
        para2.setValue(tmpIII, forKey: "a")

        let jsonData1 = try! JSONSerialization.data(withJSONObject: para1, options: [])
        let jsonString1 = String(data: jsonData1, encoding: .utf8)
        
        let jsonData2 = try! JSONSerialization.data(withJSONObject: para2, options: [])
        let jsonString2 = String(data: jsonData2, encoding: .utf8)
        
        if let enc1 = RSA.encryptString(jsonString1, publicKey: SMUserManager.publicKey) {
            if let enc2 = RSA.encryptString(jsonString2, publicKey: SMUserManager.publicKey) {
                SMLoading.showLoadingPage(viewcontroller: self)

                SMCard.payPayment(enc: enc1, enc2: enc2, onSuccess: { resp in
                    SMLoading.hideLoadingPage()

                    if let result = resp as? NSDictionary{
//                        self.dismiss(animated: true, completion: nil)

                        SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                    }
                }, onFailed: { err in
                    SMLog.SMPrint(err)
                    SMLoading.showToast(viewcontroller: self, text: "error".localized)
                    SMLoading.hideLoadingPage()
                    let message = (err as! NSDictionary).value(forKey: "message") as! String
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "GLOBAL_WARNING".localizedNew, message: message)

                })
            }
        }
    }
    //touch handler
    
    //call merchants cards available list for pay
    
    func GetMutualClubList(MerchantCode: String, UserCode: String, completed: @escaping ([Any])->()) {
        
        self.qrCode = MerchantCode.inEnglishNumbers()
        SMLoading.showLoadingPage(viewcontroller: self, text: "Loading ...".localizedNew)
        let request = WS_methods(delegate: self, failedDialog: true)
        request.addSuccessHandler { (response : Any) in

          
            if let jsonResult = response as? NSArray { // here check for mututal club
                for item in jsonResult {
                    let tmp = item as! NSDictionary
                    self.MutualClubCard = tmp
                    
                }
                SMLoading.hideLoadingPage()
                completed(jsonResult as! [Any])
                
            }
            
        }
        request.addFailedHandler { (response: Any) in
            
            SMLoading.hideLoadingPage()
            //            self.reader.startScanning()
            if SMValidation.showConnectionErrorToast(response) {
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: "serverDown".localized)
            } else if (response as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
                SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((response as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
            }
        }
        
        request.pc_availablelistcard(MerchantCode.inEnglishNumbers(), userID: UserCode.inEnglishNumbers())
    }
    func handleUIChange() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    /// Change position of popup by keyboard size
    func refreshPopupPosition(){
        print(keyBoardIsOpen)
        if !keyBoardIsOpen {
            verticalConstraints.constant += (keyboardHeight!)
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        refreshPopupPosition()
        keyBoardIsOpen = true
        
        self.view.layoutIfNeeded()
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        keyBoardIsOpen = false
        
        verticalConstraints.constant = 0
        self.view.layoutIfNeeded()
        
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        
        textField.text = textField.text?.inLocalizedLanguage()
        if let amountString = textField.text?.currencyFormat() {
            
            textField.text = amountString.trimmingCharacters(in: .whitespaces)
            
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newStr = string
        
        newStr = (textField.text! as NSString).replacingCharacters(in: range, with: newStr).onlyDigitChars()
        textField.text = newStr == "" ? "" : newStr.onlyDigitChars().inRialFormat().inLocalizedLanguage()
        
        if string == "" && range.location < textField.text!.length{
            let position = textField.position(from: textField.beginningOfDocument, offset: range.location)!
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        if newStr.length > 8 {
            
            self.tfAmountToPy.text = "30000000".currencyFormat().inLocalizedLanguage()
        }
        return false
    }
}
