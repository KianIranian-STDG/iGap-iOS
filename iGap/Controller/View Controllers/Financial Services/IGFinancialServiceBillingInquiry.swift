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
import SnapKit

class IGFinancialServiceBillingInquiry: BaseViewController, UITextFieldDelegate, BillMerchantResultObserver {

    @IBOutlet weak var edtPhoneNumber: UITextField!
    @IBOutlet weak var edtProvisionCode: UITextField!
    @IBOutlet weak var btnInquiry: UIButton!
    
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var txtLastTerm: UILabel!
    @IBOutlet weak var txtBillingID: UILabel!
    @IBOutlet weak var txtPaymentCode: UILabel!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var btnPayment: UIButton!
    
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var txtMidTerm: UILabel!
    @IBOutlet weak var txtBillingIDMid: UILabel!
    @IBOutlet weak var txtPaymentCodeMid: UILabel!
    @IBOutlet weak var txtAmountMid: UILabel!
    @IBOutlet weak var btnPaymentMid: UIButton!

    var billingId: String!
    var paymentCode: String!
    var billingIdMid: String!
    var paymentCodeMid: String!
    
    internal static var isMobile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edtPhoneNumber.delegate = self
        if IGFinancialServiceBillingInquiry.isMobile {
            edtPhoneNumber.snp.makeConstraints { (make) in
                make.leading.equalTo(self.view.snp.leading).offset(12)
            }
            edtProvisionCode.isHidden = true
            edtPhoneNumber.placeholder = IGStringsManager.MobileNumber.rawValue.localized
        } else {
            edtPhoneNumber.placeholder = IGStringsManager.PhoneNumber.rawValue.localized
        }
        
        initNavigationBar()
        manageEditTextsView(editTexts: [edtPhoneNumber, edtProvisionCode])
        manageViews(views: [viewOne, viewTwo], enable: false)
        manageButtonsView(buttons: [btnInquiry])
        manageButtonsView(buttons: [btnPayment,btnPaymentMid], enable: false)
        manageTextsView(labels: [txtLastTerm,txtMidTerm], grayLine: true)
        manageTextsView(labels: [txtBillingID,txtPaymentCode,txtAmount,txtBillingIDMid,txtPaymentCodeMid,txtAmountMid])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLang()
    }
    func initChangeLang() {
        if IGFinancialServiceBillingInquiry.isMobile {
            edtPhoneNumber.placeholder = IGStringsManager.MobileNumber.rawValue.localized
        } else {
            edtPhoneNumber.placeholder = IGStringsManager.PhoneNumber.rawValue.localized
        }
        edtProvisionCode.placeholder = ""
        btnInquiry.setTitle(IGStringsManager.Inquiry.rawValue.localized, for: .normal)
        btnPayment.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
        btnPaymentMid.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
        txtAmount.text = IGStringsManager.AmountPlaceHolder.rawValue.localized
        txtMidTerm.text = IGStringsManager.MidTerm.rawValue.localized
        txtLastTerm.text = IGStringsManager.LastTerm.rawValue.localized
        txtAmountMid.text = IGStringsManager.AmountPlaceHolder.rawValue.localized
        txtBillingID.text = IGStringsManager.ElecBillID.rawValue.localized
        txtPaymentCode.text = IGStringsManager.PayIdentifier.rawValue.localized
        txtBillingIDMid.text = IGStringsManager.ElecBillID.rawValue.localized
        txtPaymentCodeMid.text = IGStringsManager.PayIdentifier.rawValue.localized
        
    }
    func initNavigationBar(){
        var title = IGStringsManager.HomeBillsInquiry.rawValue.localized
        if IGFinancialServiceBillingInquiry.isMobile {
            title = IGStringsManager.HamrahAvalBillsInquiry.rawValue.localized
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: title, width: 200)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    private func manageButtonsView(buttons: [UIButton], enable: Bool = true){
        if enable {
            for btn in buttons {
                //btn.removeUnderline()
                btn.layer.cornerRadius = 5
                btn.layer.borderWidth = 0.4
                btn.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
                btn.layer.backgroundColor = UIColor(named: themeColor.buttonBGColor.rawValue)?.cgColor
                btn.isEnabled = true
            }
        } else {
            for btn in buttons {
                //btn.removeUnderline()
                btn.layer.cornerRadius = 5
                btn.layer.borderWidth = 0.4
                btn.layer.borderColor = UIColor.gray.cgColor
                btn.layer.backgroundColor = UIColor.lightGray.cgColor
                btn.isEnabled = false
            }
        }
    }
    
    private func manageEditTextsView(editTexts: [UITextField]){
        for edt in editTexts {
            edt.layer.cornerRadius = 5
            edt.layer.borderWidth = 0.5
            edt.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
        }
    }
    
    private func manageTextsView(labels: [UILabel], grayLine: Bool = false){
        for txt in labels {
            txt.layer.cornerRadius = 5
            txt.layer.borderWidth = 0.5
            if grayLine {
                txt.layer.borderColor = UIColor.gray.cgColor
            } else {
                txt.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
            }
        }
    }
    
    private func manageViews(views: [UIView], enable: Bool = true){
        
        for view in views {
            view.layer.cornerRadius = 5
            view.layer.borderWidth = 0.3
            view.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
            
            if enable {
                view.isHidden = false
                view.layer.backgroundColor = UIColor(named: themeColor.selectedChannelsCellBGColor.rawValue)?.cgColor
            } else {
                view.isHidden = true
//                view.layer.backgroundColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).cgColor
            }
        }
    }
    
    private func showErrorAlertView(title: String, message: String?, dismiss: Bool = false){
        let option = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            if dismiss {
                self.navigationController?.popViewController(animated: true)
            }
        })
        option.addAction(ok)
        self.present(option, animated: true, completion: {})
    }
    
    private func fetchPaymentToken(billId: String, payId: String){
        IGGlobal.prgShow(self.view)
        IGMplGetBillToken.Generator.generate(billId: Int64(billId.inEnglishNumbersNew())!, payId: Int64(payId.inEnglishNumbersNew())!).success({ (protoResponse) in
            IGGlobal.prgHide()
            if let mplGetBillTokenResponse = protoResponse as? IGPMplGetBillTokenResponse {
                if mplGetBillTokenResponse.igpStatus == 0 { //success
                    self.initBillPaymanet(token: mplGetBillTokenResponse.igpToken)
                } else {
                    self.showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: mplGetBillTokenResponse.igpMessage)
                }
            }
            
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
            }
        }).send()
    }
    
    private func initBillPaymanet(token: String){
        let initpayment = InitPayment()
        initpayment.registerBill(merchant: self)
        initpayment.initBillPayment(Token: token, MerchantVCArg: self, TSPEnabled: 0)
    }
    
    private func manageInquiryMci(lastTerm: IGPBillInquiryMciResponse.IGPBillInfo, midTerm: IGPBillInquiryMciResponse.IGPBillInfo){
        DispatchQueue.main.async {
            self.billingId = "\(lastTerm.igpBillID)"
            self.paymentCode = "\(lastTerm.igpPayID)"
            self.txtBillingID.text = "\(lastTerm.igpBillID)"
            self.txtPaymentCode.text = "\(lastTerm.igpPayID)"
            self.txtAmount.text = "\(lastTerm.igpAmount) " + IGStringsManager.Currency.rawValue.localized
            
            if lastTerm.igpAmount != 0 {
                self.manageButtonsView(buttons: [self.btnPayment])
                self.manageViews(views: [self.viewOne])
                self.btnPayment.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            } else {
                self.manageButtonsView(buttons: [self.btnPayment],enable: false)
                self.manageViews(views: [self.viewOne], enable: false)
                self.btnPayment.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            }
            
            self.billingIdMid = "\(midTerm.igpBillID)"
            self.paymentCodeMid = "\(midTerm.igpPayID)"
            self.txtBillingIDMid.text = "\(midTerm.igpBillID)"
            self.txtPaymentCodeMid.text = "\(midTerm.igpPayID)"
            self.txtAmountMid.text = "\(midTerm.igpAmount) " + IGStringsManager.Currency.rawValue.localized
            
            if midTerm.igpAmount != 0 {
                self.manageButtonsView(buttons: [self.btnPaymentMid])
                self.manageViews(views: [self.viewTwo])
                self.btnPaymentMid.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            } else {
                self.manageButtonsView(buttons: [self.btnPaymentMid],enable: false)
                self.manageViews(views: [self.viewTwo], enable: false)
                self.btnPaymentMid.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            }
        }
    }
    
    private func manageInquiryTelecom(lastTerm: IGPBillInquiryTelecomResponse.IGPBillInfo, midTerm: IGPBillInquiryTelecomResponse.IGPBillInfo){
        DispatchQueue.main.async {
            self.billingId = "\(lastTerm.igpBillID)"
            self.paymentCode = "\(lastTerm.igpPayID)"
            self.txtBillingID.text = "\(lastTerm.igpBillID)"
            self.txtPaymentCode.text = "\(lastTerm.igpPayID)"
            self.txtAmount.text = "\(lastTerm.igpAmount) " + IGStringsManager.Currency.rawValue.localized
            
            if lastTerm.igpAmount != 0 {
                self.manageButtonsView(buttons: [self.btnPayment])
                self.manageViews(views: [self.viewOne])
                self.btnPayment.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            } else {
                self.manageButtonsView(buttons: [self.btnPayment],enable: false)
                self.manageViews(views: [self.viewOne], enable: false)
                self.btnPayment.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            }
            
            self.billingIdMid = "\(midTerm.igpBillID)"
            self.paymentCodeMid = "\(midTerm.igpPayID)"
            self.txtBillingIDMid.text = "\(midTerm.igpBillID)"
            self.txtPaymentCodeMid.text = "\(midTerm.igpPayID)"
            self.txtAmountMid.text = "\(midTerm.igpAmount) " + IGStringsManager.Currency.rawValue.localized
            
            if midTerm.igpAmount != 0 {
                self.manageButtonsView(buttons: [self.btnPaymentMid])
                self.manageViews(views: [self.viewTwo])
                self.btnPaymentMid.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            } else {
                self.manageButtonsView(buttons: [self.btnPaymentMid],enable: false)
                self.manageViews(views: [self.viewTwo], enable: false)
                self.btnPaymentMid.setTitle(IGStringsManager.Pay.rawValue.localized, for: UIControl.State.normal)
            }
        }
    }
    
    /*********************************************************/
    /********************* User Actions **********************/
    /*********************************************************/
    
    
    @IBAction func btnInquiry(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if IGFinancialServiceBillingInquiry.isMobile {
            
            guard let phoneNumber: String = edtPhoneNumber.text?.inEnglishNumbersNew() else {
                return
            }
            
            if (phoneNumber.count != 11 || !phoneNumber.isNumber) {
                showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.WrongPhoneNUmber.rawValue.localized)
                return
            }
            
            IGGlobal.prgShow(self.view)
            IGBillInquiryMci.Generator.generate(mobileNumber: Int64(phoneNumber)!).success({ (protoResponse) in
                IGGlobal.prgHide()
                if let billInquiryMciResponse = protoResponse as? IGPBillInquiryMciResponse {
                    self.manageInquiryMci(lastTerm: billInquiryMciResponse.igpLastTerm, midTerm: billInquiryMciResponse.igpMidTerm)
                }
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                
            }).send()
        } else {
            
            guard let phoneNumber: String = edtPhoneNumber.text?.inEnglishNumbersNew() else {
                return
            }
            
            if (phoneNumber.count < 5 || !phoneNumber.isNumber) {
                showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.WrongPhoneNUmber.rawValue.localized)
                return
            }
            
            
            guard let provisionCode: String = edtProvisionCode.text?.inEnglishNumbersNew() else {
                return
            }
            
            if (provisionCode.count < 1 || !provisionCode.isNumber) {
                showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.WrongPhoneNUmber.rawValue.localized)
                return
            }
            
            IGGlobal.prgShow(self.view)
            IGBillInquiryTelecom.Generator.generate(provinceCode: Int32(provisionCode.inEnglishNumbersNew())!, telephoneNumber: Int64(phoneNumber.inEnglishNumbersNew())!).success({ (protoResponse) in
                IGGlobal.prgHide()
                if let billInquiryMciResponse = protoResponse as? IGPBillInquiryTelecomResponse {
                    self.manageInquiryTelecom(lastTerm: billInquiryMciResponse.igpLastTerm, midTerm: billInquiryMciResponse.igpMidTerm)
                }
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                
            }).send()
        }
    }
    
    @IBAction func btnPayment(_ sender: UIButton) {
        fetchPaymentToken(billId: billingId.inEnglishNumbersNew(), payId: paymentCode.inEnglishNumbersNew())
    }
    
    @IBAction func btnPaymentMid(_ sender: UIButton) {
        fetchPaymentToken(billId: billingIdMid.inEnglishNumbersNew(), payId: paymentCodeMid.inEnglishNumbersNew())
    }
    
    /*********************************************************/
    /*************** Overrided Payment Mehtods ***************/
    /*********************************************************/
    
    func BillMerchantUpdate(encData: String, message: String, status: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func BillMerchantError(errorType: Int) {
        showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalTryAgain.rawValue.localized, dismiss: true)
    }
    
    /*********************************************************/
    /******************* Overrided Method ********************/
    /*********************************************************/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
