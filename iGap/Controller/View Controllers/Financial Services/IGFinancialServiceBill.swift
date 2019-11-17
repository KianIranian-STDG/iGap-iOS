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

class IGFinancialServiceBill: BaseViewController, UITextFieldDelegate , BillMerchantResultObserver {

    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var edtBillingID: UITextField!
    @IBOutlet weak var edtPaymentCode: UITextField!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var imgCompany: UIImageView!
    
    var billId: String! = ""
    var payId: String! = ""
    var defaultBillInfo: IGStructBillInfo?
    
    internal static var isTrafficOffenses = false
    internal static var BillInfo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edtBillingID.delegate = self
        edtPaymentCode.delegate = self
        
        initNavigationBar()
        manageButtonsView(buttons: [btnPayment])
        manageEditTextsView(editTexts: [edtBillingID,edtPaymentCode])
        manageTextsView(labels: [txtAmount], grayLine: true)

        //manageImageViews(images: [imgCompany])
        
        if IGFinancialServiceBill.isTrafficOffenses {
            imgCompany.image = UIImage(named: "bill_jarime_pec")
            if defaultBillInfo != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.billId = self.defaultBillInfo?.BID
                    self.payId = self.defaultBillInfo?.PID
                    self.edtBillingID.text = self.billId
                    self.edtPaymentCode.text = self.payId
                }
            }
        } else {
            if defaultBillInfo != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let billId: String! = self.defaultBillInfo?.BID
                    let payId: String! = self.defaultBillInfo?.PID
                    self.fetchBillInfo(billInfo: "\(billId!)\(payId!)", setText: true)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let billInfo = IGFinancialServiceBill.BillInfo {
            fetchBillInfo(billInfo: billInfo)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLang()
    }
    func initChangeLang() {
        edtBillingID.placeholder = "BILLING_ID".localized
        edtPaymentCode.placeholder = "PAYMENT_CODE".localized
        btnPayment.setTitle(IGStringsManager.Buy.rawValue.localized, for: .normal)
        txtAmount.text = IGStringsManager.AmountPlaceHolder.rawValue.localized
    }
    
    func initNavigationBar(){
        
        var title = IGStringsManager.PayBills.rawValue.localized
        if IGFinancialServiceBill.isTrafficOffenses {
            title = IGStringsManager.PayTraficTicket.rawValue.localized
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: title, width: 200)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        if IGFinancialServiceBill.isTrafficOffenses {
            txtAmount.isHidden = true
            
            btnPayment.snp.makeConstraints { (make) in
                make.top.equalTo(edtPaymentCode.snp.bottom).offset(20)
            }
            
        } else {
            navigationItem.addModalViewRightItem(title: "", iGapFont: true, fontSize: 25.0, xPosition: 5.0)
            navigationItem.rightViewContainer?.addAction {
                self.performSegue(withIdentifier: "showFinancialServiceBillQrScanner", sender: self)
            }
        }
    }
    
    private func manageButtonsView(buttons: [UIButton]){
        for btn in buttons {
            //btn.removeUnderline()
            btn.layer.cornerRadius = 5
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
            btn.layer.backgroundColor = UIColor(named: themeColor.buttonBGColor.rawValue)?.cgColor
        }
    }
    
    private func manageEditTextsView(editTexts: [UITextField]){
        for edt in editTexts {
            edt.layer.cornerRadius = 5
            edt.layer.borderWidth = 1
            edt.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
        }
    }
    
    private func manageTextsView(labels: [UILabel], grayLine: Bool = false){
        for txt in labels {
            txt.layer.cornerRadius = 5
            txt.layer.borderWidth = 1
            if grayLine {
                txt.layer.borderColor = UIColor.gray.cgColor
            } else {
                txt.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
            }
        }
    }
    
    private func manageImageViews(images: [UIImageView]){
        for img in images {
            img.layer.cornerRadius = 5
            img.layer.borderWidth = 1
        }
    }
    
    private func fetchBillInfo(billInfo: String, setText: Bool = true){
        
        if IGFinancialServiceBill.isTrafficOffenses {
            return
        }
        
        billId = billInfo[0..<13]
        payId = billInfo[13..<30]
        let companyType : String = billInfo[11..<12]
        let price : String = billInfo[13..<21]
        if setText {
            edtBillingID.text = billId
            edtPaymentCode.text = payId
        }
        if !price.isEmpty {
            txtAmount.text = "\(Int(price)! * 1000) ".inLocalizedLanguage() + IGStringsManager.Currency.rawValue.localized
        }
        
        if !IGFinancialServiceBill.isTrafficOffenses {
            switch Int(companyType) {
            case 1:
                imgCompany.image = UIImage(named: "bill_water_pec")
                break
                
            case 2:
                imgCompany.image = UIImage(named: "bill_elc_pec")
                break
                
            case 3:
                imgCompany.image = UIImage(named: "bill_gaz_pec")
                break
                
            case 4:
                imgCompany.image = UIImage(named: "bill_telecom_pec")
                break
                
            case 5:
                imgCompany.image = UIImage(named: "bill_mci_pec")
                break
                
            case 6:
                imgCompany.image = UIImage(named: "bill_shahrdari_pec")
                break
                
            default:
                imgCompany.image = nil
                break
            }
        }
    }
    
    private func showErrorAlertView(title: String, message: String?, dismiss: Bool = false){
        let option = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .cancel, handler: { (action) in
            if dismiss {
                self.navigationController?.popViewController(animated: true)
            }
        })
        option.addAction(ok)
        self.present(option, animated: true, completion: {})
    }
    
    private func initBillPaymanet(token: String){
        let initpayment = InitPayment()
        initpayment.registerBill(merchant: self)
        initpayment.initBillPayment(Token: token, MerchantVCArg: self, TSPEnabled: 0)
    }
    
    /********************************************/
    /*************** User Actions ***************/
    /********************************************/
    
    @IBAction func edtBillingID(_ sender: UITextField) {
        if let billId = edtBillingID.text , let payId = edtPaymentCode.text {
            if billId.count > 3 && payId.count > 3 {
                self.billId = billId
                self.payId = payId
                fetchBillInfo(billInfo: "\(billId)\(payId)" , setText: false)
            }
        }
    }
    
    @IBAction func edtPaymentCode(_ sender: UITextField) {
        if let billId = edtBillingID.text, let payId = edtPaymentCode.text {
            if billId.count > 3 && payId.count > 3 {
                self.billId = billId
                self.payId = payId
                fetchBillInfo(billInfo: "\(billId)\(payId)", setText: false)
            }
        }
    }
    
    @IBAction func btnPayment(_ sender: UIButton) {
        
        if billId == nil || !billId.isNumber || payId == nil || !payId.isNumber{
            return
        }
        
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
            IGGlobal.prgHide()
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                break
            default:
                break
            }
        }).send()
    }
    
    /*********************************************************/
    /*************** Overrided Payment Mehtods ***************/
    /*********************************************************/
    
    func BillMerchantUpdate(encData: String, message: String, status: Int) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func BillMerchantError(errorType: Int) {
        showErrorAlertView(title: IGStringsManager.GlobalWarning.rawValue.localized, message: "MSG_ERROR_BILL_PAYMENT".localized, dismiss: true)
    }
    
    /********************************************/
    /************* Overrided Methods ************/
    /********************************************/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
