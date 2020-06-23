//
//  IGWalletTransferModal.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/26/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import SwiftEventBus
import IGProtoBuff
import KeychainSwift
import maincore
import RealmSwift

class IGWalletTransferModal: BaseTableViewController {

    var issecuredPass : Bool = false

    var mode : String = "WALLET_TRANSFER"
    var roomID : Int64 = 0
    var billType : IGBillType!
    var bill : parentBillModel!
    var index : Int!
    var isShortFormEnabled = true
    var isKeyboardPresented = false

    
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblAmount : UILabel!
    @IBOutlet weak var tfAmount : UITextField!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var tfDescription : UITextField!

    @IBOutlet weak var btnSend : UIButton!

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self,name: EventBusManager.sendCardToCardMessage)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        switch mode {
        case "WALLET_TRANSFER" :
            initView()
            tfAmount.keyboardType = .numberPad

            break
        case "EDIT_BILL" , "ADD_BILL" :
            initBillView()
            tfAmount.keyboardType = .default
            tfDescription.keyboardType = .numberPad

            
        default :
            break
        }
        initTheme()
        btnSend.addTarget(self, action: #selector(didTapOnSend), for: .touchUpInside)
    }
    
    var hasValue = false
    var userCards: [SMCard]?
    var sourceCard: SMCard!
    
    func finishDefault(isPaygear: Bool? ,isCard : Bool?) {
        IGLoading.showLoadingPage(viewcontroller: self)
        SMCard.getAllCardsFromServer({ cards in
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0 {
                        //                        self.walletView.dismissPresentedCardView(animated: true)
                        //                        self.walletHeaderView.alpha = 1.0
                        self.userCards = SMCard.getAllCardsFromDB()
                        self.hasValue = true
                        
                        if self.hasValue  {
                        }
                        if isPaygear!{
                            self.preparePayGearCard()
                        }
                    }
                }
            }
            needToUpdate = true
        }, onFailed: {err in
        })
    }
    
    func preparePayGearCard(){
        
        if let cards = userCards {
            for card in cards {
                
                if card.type == 1 && card.pan!.contains("پیگیر"){
                    self.sourceCard = card
                    SMUserManager.payGearToken = card.token
                    SMUserManager.isProtected = card.protected
                    SMUserManager.userBalance = card.balance
                }
            }
        }
    }
    func transferToWallet(pbKey: String!,token: String)  {
        
        IGLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: IGStringsManager.EnterWalletPin.rawValue.localized, yesPressed: { pin in
            self.payFromSingleCard(card: self.sourceCard , pin : (pin as! String))
        }, forgotPin: {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)
            
            let walletSettingPage = (storyboard.instantiateViewController(withIdentifier: "walletSettingPage") as! IGWalletSettingTableViewController)
            walletSettingPage.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(walletSettingPage, animated: true)
        })
        
    }
    
    private func payFromSingleCard(card: SMCard,pin: String) {
        
        
        let para  = NSMutableDictionary()
        para.setValue(card.token, forKey: "c")
        para.setValue((pin).onlyDigitChars().inEnglishNumbersNew(), forKey: "p2")
        para.setValue(card.type, forKey: "type")
        para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
        para.setValue(card.bankCode, forKey: "bc")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey) {
            SMCard.payPayment(enc: enc, enc2: nil, onSuccess: { resp in
                if let result = resp as? NSDictionary{
                    SMUserManager.callBackUrl = (result.allValues[1]) as! String
                    SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                }
            }, onFailed: {err in
                if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
                    IGLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
                }
            })
        }
    }
    @objc func didTapOnSend() {
        if mode == "WALLET_TRANSFER" {
            if tfAmount.text == "" ||  tfAmount.text == nil {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AmountNotValid.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            }
            else {
                self.dismiss(animated: true, completion: {
                    let tmpJWT : String! =  KeychainSwift().get("accesstoken")!
                    IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
                    IGRequestWalletPaymentInit.Generator.generate(jwt: tmpJWT, amount: (Int64((self.tfAmount.text!).inEnglishNumbersNew().onlyDigitChars())!), userID: tmpUserID, description: "", language: IGPLanguage(rawValue: IGPLanguage.faIr.rawValue)!).success ({ [weak self] (protoResponse) in
                        IGLoading.hideLoadingPage()
                        if let response = protoResponse as? IGPWalletPaymentInitResponse {
                            SMUserManager.publicKey = response.igpPublicKey
                            SMUserManager.payToken = response.igpToken
                            self?.transferToWallet(pbKey: SMUserManager.publicKey, token: SMUserManager.payToken!)
                        }
                    }).error ({ [weak self] (errorCode, waitTime) in
                        switch errorCode {
                        case .timeout:
                            IGLoading.hideLoadingPage()
                            self?.didTapOnSend()
                        default:
                            IGLoading.hideLoadingPage()

                            break
                        }
                    }).send()
                })

            }
        } else {
            
            var billID : String!
            var subCode : String!
            var telNum : String!
            switch billType {
            case .Elec :
                billID = tfDescription.text!.inEnglishNumbersNew()
                subCode = nil
                telNum = nil
                
            case .Gas :
                billID = nil
                subCode = tfDescription.text!.inEnglishNumbersNew()
                telNum = nil
                
            case .Phone, .Mobile :
                billID = nil
                subCode = nil
                telNum = tfDescription.text!.inEnglishNumbersNew()
            default: break
                
            }
            if mode == "ADD_BILL" {
                let realm = try! Realm()
                let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
                let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first
                let userPhoneNumber =  IGGlobal.validaatePhoneNUmber(phone: userInDb?.phone)

                IGApiBills.shared.addBill(billType: bill.billType ?? "ELECTRICITY", billIdentifier: billID, billTitle: tfAmount.text ?? "", subCode: subCode, telNum: telNum, userPhoneNumber: userPhoneNumber) {[weak self] (response, error) in
                    guard let sSelf = self else {
                        return
                    }
                    if error != nil {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: error, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                        sSelf.dismiss(animated: true, completion: nil)
                        
                        return
                    } else {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: response?.message, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                        sSelf.dismiss(animated: true, completion: nil)

                    }
                    
                }
            } else {
                IGApiBills.shared.editBill(billType: bill.billType!, ID: bill.id!, billIdentifier: billID, billTitle: tfAmount.text!, subCode: subCode, telNum: telNum) {[weak self] (response, error) in
                    guard let sSelf = self else {
                        return
                    }
                    if error != nil {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: error, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                        sSelf.dismiss(animated: true, completion: nil)
                        
                        return
                    } else {
                        sSelf.dismiss(animated: true, completion: {
                            (UIApplication.topViewController() as! IGPSBillMyBillsTVC).vm.getAllBills()
                        })
                    }
                    
                }
            }

        }
        
    }
    
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        lblAmount.textColor = ThemeManager.currentTheme.LabelColor
        lblDescription.textColor = ThemeManager.currentTheme.LabelColor
        tfAmount.textColor = ThemeManager.currentTheme.LabelColor
        tfDescription.textColor = ThemeManager.currentTheme.LabelColor
        btnSend.setTitleColor(.white, for: .normal)
        btnSend.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    @objc func keyboardWillShow(notification: NSNotification) {
        //Do something here
        print("KEYBOARD DID APPEAR")
        
        isKeyboardPresented = true
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification) {
        //Do something here
        print("KEYBOARD DID DISAPPEAR")
        isKeyboardPresented = false
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
  
    
    

    
    private func initBillView() {
        
        lblHeader.text = IGStringsManager.PSBillInfo.rawValue.localized
        switch billType {
        case .Elec :
            lblDescription.text = IGStringsManager.BillId.rawValue.localized
            tfDescription.text = bill.billIdentifier?.inLocalizedLanguage()
        case .Gas:
            lblDescription.text = IGStringsManager.PSSubscriptionCode.rawValue.localized
            tfDescription.text = bill.subsCriptionCode?.inLocalizedLanguage()
        case .Mobile :
            lblDescription.text = IGStringsManager.PhoneNumber.rawValue.localized
            if (bill.billPhone?.inEnglishNumbersNew().starts(with: "0"))! {
                tfDescription.text = bill.billPhone
            } else {
                tfDescription.text = "0".inLocalizedLanguage() + bill.billPhone!.inLocalizedLanguage()
            }
        case .Phone :
            lblDescription.text = IGStringsManager.PhoneNumber.rawValue.localized
            if (bill.billPhone?.inEnglishNumbersNew().starts(with: "0"))! {
                tfDescription.text = bill.billPhone
            } else {
                tfDescription.text = "0".inLocalizedLanguage() + bill.billPhone!.inLocalizedLanguage()
            }


        default : break
        }
        lblAmount.text = IGStringsManager.BillName.rawValue.localized
        tfAmount.text = bill.billTitle
        if mode == "ADD_BILL" {
            btnSend.setTitle(IGStringsManager.Add.rawValue.localized, for: .normal)
        } else {
            btnSend.setTitle(IGStringsManager.Edit.rawValue.localized, for: .normal)
        }
        btnSend.layer.cornerRadius = 10

    }
    private func initView() {
        lblHeader.text = IGStringsManager.MBEnterAmount.rawValue.localized
        lblAmount.text = IGStringsManager.AmountInRial.rawValue.localized
        lblDescription.text = IGStringsManager.Desc.rawValue.localized + ":"
        btnSend.setTitle(IGStringsManager.Send.rawValue.localized, for: .normal)
        btnSend.layer.cornerRadius = 10
    }
    private func initFont() {

        lblHeader.font = UIFont.igFont(ofSize: 13)
        lblAmount.font = UIFont.igFont(ofSize: 13)
        lblDescription.font = UIFont.igFont(ofSize: 13)
        tfAmount.font = UIFont.igFont(ofSize: 15)
        tfDescription.font = UIFont.igFont(ofSize: 15)
        btnSend.titleLabel!.font = UIFont.igFont(ofSize: 15)

        
        lblHeader.textAlignment = lblHeader.localizedDirection
        lblAmount.textAlignment = lblHeader.localizedDirection
        lblDescription.textAlignment = lblHeader.localizedDirection
        tfAmount.textAlignment = .center
        tfDescription.textAlignment = .center
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }


}

extension IGWalletTransferModal: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(250)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(600)
        } else {
            return .contentHeight(250)
        }

    }
    var anchorModalToLongForm: Bool {
        return false
    }


    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    
}
