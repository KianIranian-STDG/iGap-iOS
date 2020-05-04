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
import IGProtoBuff
import PecPayment
import RealmSwift
import SwiftEventBus

class IGElecBillTableViewCell: BaseTableViewCell,BillMerchantResultObserver {
    
    // MARK: - Outlets
    @IBOutlet weak var lblBillName : UILabel!
    @IBOutlet weak var lblTTlBillNumber : UILabel!
    @IBOutlet weak var lblDataBillNumber : UILabel!
    @IBOutlet weak var lblTTlBillPayNumber : UILabel!
    @IBOutlet weak var lblDataBillPayNumber : UILabel!
    @IBOutlet weak var lblTTlBillPayAmount : UILabel!
    @IBOutlet weak var lblDataBillPayAmount : UILabel!
    @IBOutlet weak var lblTTlBillPayDate : UILabel!
    @IBOutlet weak var lblDataBillPayDate : UILabel!
    @IBOutlet weak var btnDelete : UIButton!
    @IBOutlet weak var btnEdite : UIButton!
    @IBOutlet weak var btnPay : UIButton!
    @IBOutlet weak var btnDetail : UIButton!
    @IBOutlet weak var topViewHolder : UIViewX!
    @IBOutlet weak var stackHolder : UIStackView!
    @IBOutlet var stackHolderInner : [UIStackView]!
    
    // MARK: - Variables
    var billIsInvalid : Bool = false
    var myBillListInnerData : InqueryDataStruct!
    var payAmount : String!
    var userPhoneNumber : String!
    // MARK: - View LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }
    // MARK: - Development Funcs
    private func initView() {
        initFont()
        initAlignments()
        initColors()
        initStrings()
        customiseView()
    }
    
    
    private func customiseView() {
        self.topViewHolder.borderWidth = 0.5
        self.topViewHolder.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btnPay.layer.cornerRadius = 15
        btnDetail.layer.cornerRadius = 15
        
        self.semanticContentAttribute = self.semantic
        self.stackHolder.semanticContentAttribute = self.semantic
        for stk in stackHolderInner {
            stk.semanticContentAttribute = self.semantic
        }
        
    }
    
    private func initFont() {
        lblBillName.font = UIFont.igFont(ofSize: 15,weight: .bold)
        lblTTlBillNumber.font = UIFont.igFont(ofSize: 14)
        lblTTlBillPayDate.font = UIFont.igFont(ofSize: 14)
        lblTTlBillPayAmount.font = UIFont.igFont(ofSize: 14)
        lblTTlBillPayNumber.font = UIFont.igFont(ofSize: 14)
        lblDataBillNumber.font = UIFont.igFont(ofSize: 14)
        lblDataBillPayDate.font = UIFont.igFont(ofSize: 14)
        lblDataBillPayAmount.font = UIFont.igFont(ofSize: 14)
        lblDataBillPayNumber.font = UIFont.igFont(ofSize: 14)
        btnPay.titleLabel?.font = UIFont.igFont(ofSize: 14)
        btnDelete.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btnEdite.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btnDetail.titleLabel?.font = UIFont.igFont(ofSize: 14)
    }
    
    private func initStrings() {
        lblBillName.text = IGStringsManager.ElecBillID.rawValue.localized
        lblTTlBillNumber.text = IGStringsManager.ElecBillID.rawValue.localized
        lblTTlBillPayDate.text = IGStringsManager.BillPayDate.rawValue.localized
        lblTTlBillPayAmount.text = IGStringsManager.BillPrice.rawValue.localized
        lblTTlBillPayNumber.text = IGStringsManager.PayIdentifier.rawValue.localized
        lblDataBillNumber.text = "..."
        lblDataBillPayDate.text = "..."
        lblDataBillPayAmount.text = "..."
        lblDataBillPayNumber.text = "..."
        btnPay.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
        btnDetail.setTitle(IGStringsManager.Details.rawValue.localized, for: .normal)
        btnEdite.setTitle("", for: .normal)
        btnDelete.setTitle("", for: .normal)
    }
    
    private func initColors() {
        self.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        self.topViewHolder.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        btnPay.setTitleColor(ThemeManager.currentTheme.BackGroundColor, for: .normal)
        btnDetail.setTitleColor(ThemeManager.currentTheme.BackGroundColor, for: .normal)
        btnDelete.setTitleColor(UIColor.iGapRed(), for: .normal)
        btnEdite.setTitleColor(ThemeManager.currentTheme.LabelGrayColor, for: .normal)
        
        btnPay.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        btnDetail.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        
        lblBillName.textColor = ThemeManager.currentTheme.LabelColor
        lblTTlBillNumber.textColor = ThemeManager.currentTheme.LabelColor
        lblTTlBillPayNumber.textColor = ThemeManager.currentTheme.LabelColor
        lblTTlBillPayDate.textColor = ThemeManager.currentTheme.LabelColor
        lblTTlBillPayAmount.textColor = ThemeManager.currentTheme.LabelColor
        lblDataBillNumber.textColor = ThemeManager.currentTheme.LabelColor
        lblDataBillPayDate.textColor = ThemeManager.currentTheme.LabelColor
        lblDataBillPayAmount.textColor = ThemeManager.currentTheme.LabelColor
        lblDataBillPayNumber.textColor = ThemeManager.currentTheme.LabelColor
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
          let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
          let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

        if currentTheme == "IGAPDay" {
                    
                    if currentColorSetLight == "IGAPBlack" {
                        
                      btnPay.setTitleColor(.white, for: .normal)
                      self.btnPay.layer.borderColor = UIColor.white.cgColor
                      self.btnPay.layer.borderWidth = 2.0

                      btnDetail.setTitleColor(.white, for: .normal)
                      self.btnDetail.layer.borderColor = UIColor.white.cgColor
                      self.btnDetail.layer.borderWidth = 2.0

                        
                    }
                } else if currentTheme == "IGAPNight" {
                  
                  if currentColorSetDark == "IGAPBlack" {
                      
                    btnPay.setTitleColor(.white, for: .normal)
                    self.btnPay.layer.borderColor = UIColor.white.cgColor
                    self.btnPay.layer.borderWidth = 2.0

                    btnDetail.setTitleColor(.white, for: .normal)
                    self.btnDetail.layer.borderColor = UIColor.white.cgColor
                    self.btnDetail.layer.borderWidth = 2.0
                      
                  }

                }
    }
    
    private func initAlignments() {
        lblBillName.textAlignment = lblBillName.localizedDirection
        lblTTlBillPayNumber.textAlignment = lblTTlBillPayNumber.localizedDirection
        lblTTlBillPayAmount.textAlignment = lblTTlBillPayNumber.localizedDirection
        lblTTlBillPayDate.textAlignment = lblTTlBillPayNumber.localizedDirection
        lblTTlBillNumber.textAlignment = lblTTlBillPayNumber.localizedDirection
    }
    
    // MARK: - Actions
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setBillsData(bill: billObject,userPhoneNumber: String!) {
        lblBillName.text = bill.billTitle!.inLocalizedLanguage()
        lblDataBillNumber.text = bill.billIdentifier?.inLocalizedLanguage()
        self.userPhoneNumber = userPhoneNumber
        queryMultiBills(billNumber: bill.billIdentifier, userPhoneNumber: userPhoneNumber)
    }
    func setBillsDataInner(billDataInner: InqueryDataStruct) {
    }
    private func queryMultiBills(billNumber: String!,userPhoneNumber: String!) {
        
        IGApiElectricityBill.shared.queryBill(billNumber: billNumber, phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
            IGLoading.hideLoadingPage()
            if success {
                self.myBillListInnerData = response?.data
                if self.myBillListInnerData != nil {
                    self.billIsInvalid = false
                    self.lblDataBillPayNumber.text = response?.data?.paymentIdentifier?.inLocalizedLanguage()
                    self.payAmount = response?.data?.totalBillDebt
                    
                    self.lblDataBillPayAmount.text = (response?.data?.totalBillDebt?.inLocalizedLanguage())! + IGStringsManager.Currency.rawValue.localized
                    let paydate = response?.data?.paymentDeadLine!
                    let dateFormatter = ISO8601DateFormatter()
                    let date = dateFormatter.date(from:paydate!)!
                    self.lblDataBillPayDate.text = date.completeHumanReadableTime().inLocalizedLanguage()
                } else {
                    self.billIsInvalid = true
                    self.lblDataBillPayDate.text = ""
                    self.lblDataBillPayAmount.text = "0".inLocalizedLanguage()
                    self.lblDataBillPayNumber.text = "0".inLocalizedLanguage()
                }
            } else {
                self.billIsInvalid = true
                self.lblDataBillPayDate.text = ""
                self.lblDataBillPayAmount.text = "0".inLocalizedLanguage()
                self.lblDataBillPayNumber.text = "0".inLocalizedLanguage()

            }
        })
    }
    @IBAction func didTapOnDetails(_ sender: UIButton) {
        if self.myBillListInnerData == nil && self.billIsInvalid == true {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.InvalidBill.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            
        } else if self.myBillListInnerData == nil && self.billIsInvalid == false {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.WaitDataFetch.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
        }
        else {
            let billDataVC = IGElecBillDetailPageTableViewController.instantiateFromAppStroryboard(appStoryboard: .ElectroBill)
            billDataVC.billNumber = (self.myBillListInnerData.billIdentifier!.inEnglishNumbersNew())
            billDataVC.canEditBill = true
            billDataVC.billTittle = self.lblBillName.text
            billDataVC.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()?.navigationController!.pushViewController(billDataVC, animated:true)
            
        }
        
    }
    @IBAction func didTapOnPay(_ sender: UIButton) {
        if self.myBillListInnerData == nil {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.WaitDataFetch.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
        } else {
            paySequence()
        }
    }
    @IBAction func didTapOnDelete(_ sender: UIButton) {
        IGApiElectricityBill.shared.deleteBill(billNumber: (lblDataBillNumber.text?.inEnglishNumbersNew())!, phoneNumber: self.userPhoneNumber, completion: {(success, response, errorMessage) in
            IGLoading.hideLoadingPage()
            if success {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.SuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized , cancel: {
                    SwiftEventBus.post(EventBusManager.updateBillsName)
                })
            }
        })
    }
    
    @IBAction func didTapOnEdite(_ sender: UIButton) {
        let addEditVC = IGElecAddEditBillTableViewController.instantiateFromAppStroryboard(appStoryboard: .ElectroBill)
        addEditVC.hidesBottomBarWhenPushed = true
        addEditVC.billNumber = (lblDataBillNumber.text)?.inEnglishNumbersNew()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first
        
        let userPhoneNumber =  IGGlobal.validaatePhoneNUmber(phone: userInDb?.phone)
        
        addEditVC.userNumber = userPhoneNumber
        addEditVC.canEditBill = true
        addEditVC.billTitle = self.lblBillName.text
        UIApplication.topViewController()?.navigationController!.pushViewController(addEditVC, animated:true)
        
    }
    private func initBillPaymanet(token: String){
        let initpayment = InitPayment()
        initpayment.registerBill(merchant: self)
        initpayment.initBillPayment(Token: token, MerchantVCArg: UIApplication.topViewController()!, TSPEnabled: 0)
    }
    private func paySequence() {
        let tmpPaymentAmount:Int? = Int(self.payAmount!) // firstText is UITextField
        
        if tmpPaymentAmount! < 10000 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.LessThan10000.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            
        } else {
            IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
            IGMplGetBillToken.Generator.generate(billId: Int64(lblDataBillNumber.text!.inEnglishNumbersNew())!, payId: Int64(lblDataBillPayNumber.text!.inEnglishNumbersNew())!).success({ (protoResponse) in
                IGLoading.hideLoadingPage()
                if let mplGetBillTokenResponse = protoResponse as? IGPMplGetBillTokenResponse {
                    if mplGetBillTokenResponse.igpStatus == 0 { //success
                        self.initBillPaymanet(token: mplGetBillTokenResponse.igpToken)
                    } else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: mplGetBillTokenResponse.igpMessage, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    }
                }
                
            }).error ({ (errorCode, waitTime) in
                IGLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    
                    break
                default:
                    break
                }
            }).send()
            
            
        }
    }
    /*********************************************************/
    /*************** Overrided Payment Mehtods ***************/
    /*********************************************************/
    
    func BillMerchantUpdate(encData: String, message: String, status: Int) {
        UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
    }
    
    func BillMerchantError(errorType: Int) {
    }
}
