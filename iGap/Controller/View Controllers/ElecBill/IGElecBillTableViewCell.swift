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
        self.topViewHolder.layer.borderColor = UIColor(named: themeColor.labelColor.rawValue)?.cgColor
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
        lblBillName.text = "BILL_NAME".localizedNew
        lblTTlBillNumber.text = "BILL_ID".localizedNew
        lblTTlBillPayDate.text = "BILL_PAY_DATE".localizedNew
        lblTTlBillPayAmount.text = "BILL_PAY_AMOUNT".localizedNew
        lblTTlBillPayNumber.text = "TRANSACTIONS_HISTORY_ORDER_ID".localizedNew
        lblDataBillNumber.text = "..."
        lblDataBillPayDate.text = "..."
        lblDataBillPayAmount.text = "..."
        lblDataBillPayNumber.text = "..."
        btnPay.setTitle("PU_PAYMENT".localizedNew, for: .normal)
        btnDetail.setTitle("BILL_DETAIL".localizedNew, for: .normal)
        btnEdite.setTitle("", for: .normal)
        btnDelete.setTitle("", for: .normal)
    }
    
    private func initColors() {
        self.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.topViewHolder.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        btnPay.setTitleColor(.white, for: .normal)
        btnDetail.setTitleColor(.white, for: .normal)
        btnDelete.setTitleColor(UIColor.iGapRed(), for: .normal)
        btnEdite.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        
        btnPay.backgroundColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
        btnDetail.backgroundColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
        
        lblBillName.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlBillNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlBillPayNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlBillPayDate.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlBillPayAmount.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillPayDate.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillPayAmount.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillPayNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
    }
    
    private func initAlignments() {
        lblBillName.textAlignment = lblBillName.localizedNewDirection
        lblTTlBillPayNumber.textAlignment = lblTTlBillPayNumber.localizedNewDirection
        lblTTlBillPayAmount.textAlignment = lblTTlBillPayNumber.localizedNewDirection
        lblTTlBillPayDate.textAlignment = lblTTlBillPayNumber.localizedNewDirection
        lblTTlBillNumber.textAlignment = lblTTlBillPayNumber.localizedNewDirection
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
            SMLoading.hideLoadingPage()
            if success {
                self.myBillListInnerData = response?.data
                self.lblDataBillPayNumber.text = response?.data?.paymentIdentifier?.inLocalizedLanguage()
                self.payAmount = response?.data?.totalBillDebt
                self.lblDataBillPayAmount.text = (response?.data?.totalBillDebt?.inLocalizedLanguage())! + "CURRENCY".localizedNew
                let paydate = response?.data?.paymentDeadLine!
                let dateFormatter = ISO8601DateFormatter()
                let date = dateFormatter.date(from:paydate!)!
                self.lblDataBillPayDate.text = date.completeHumanReadableTime().inLocalizedLanguage()
            } else {
                print(errorMessage)
            }
        })
    }
    @IBAction func didTapOnDetails(_ sender: UIButton) {
        if self.myBillListInnerData == nil {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "PLEASE_WAIT_DATA_LOAD".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
            
        } else {
            print("TAPPED ON DETAIL FOR :" , self.myBillListInnerData.billIdentifier)
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
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "PLEASE_WAIT_DATA_LOAD".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
        } else {
            paySequence()
        }
    }
    @IBAction func didTapOnDelete(_ sender: UIButton) {
        IGApiElectricityBill.shared.deleteBill(billNumber: (lblDataBillNumber.text?.inEnglishNumbersNew())!, phoneNumber: self.userPhoneNumber, completion: {(success, response, errorMessage) in
            SMLoading.hideLoadingPage()
            if success {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: "SUCCESS".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "SUCCESS_OPERATION".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew , cancel: {
                    SwiftEventBus.post(EventBusManager.updateBillsName)
                })
                
            } else {
                print(errorMessage)
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
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "LESS_THAN_1000".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
            
        } else {
            SMLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
            IGMplGetBillToken.Generator.generate(billId: Int64(lblDataBillNumber.text!.inEnglishNumbersNew())!, payId: Int64(lblDataBillPayNumber.text!.inEnglishNumbersNew())!).success({ (protoResponse) in
                SMLoading.hideLoadingPage()
                if let mplGetBillTokenResponse = protoResponse as? IGPMplGetBillTokenResponse {
                    if mplGetBillTokenResponse.igpStatus == 0 { //success
                        self.initBillPaymanet(token: mplGetBillTokenResponse.igpToken)
                    } else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: mplGetBillTokenResponse.igpMessage, cancelText: "GLOBAL_CLOSE".localizedNew)
                    }
                }
                
            }).error ({ (errorCode, waitTime) in
                SMLoading.hideLoadingPage()
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
        //        showErrorAlertView(title: "GLOBAL_WARNING".localizedNew, message: "MSG_ERROR_BILL_PAYMENT".localizedNew, dismiss: true)
    }
}
