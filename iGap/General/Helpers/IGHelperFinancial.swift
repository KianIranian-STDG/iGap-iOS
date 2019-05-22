/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff
import RealmSwift
import PecPayment

class IGHelperFinancial: NSObject, CardToCardResult,MerchantResultObserver {
    
    static let shared = IGHelperFinancial()
    
    private var uiViewController: UIViewController!
    
    override init() {}
    
    private init(_ viewController: UIViewController) {
        self.uiViewController = viewController
    }
    
    static func getInstance(viewController: UIViewController) -> IGHelperFinancial {
        return IGHelperFinancial(viewController)
    }
    
    func manageFinancialServiceChoose(){
        
        var viewController: UIViewController! = self.uiViewController
        if viewController == nil {
            viewController = UIApplication.topViewController()
        }
        
        let option = UIAlertController(title: "SETTING_PAGE_FINANCIAL_SERVICES".localizedNew, message: "MSG_FINANCIAL_SERVICES".localizedNew, preferredStyle: IGGlobal.detectAlertStyle())
        
        let mobileCharge = UIAlertAction(title: "SETTING_FS_TOP_UP".localizedNew, style: .default, handler: { (action) in
           
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceCharge") as! IGFinancialServiceCharge
            viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let cardToCard = UIAlertAction(title: "SETTING_FS_CARD_TO_CARD_BILLS".localizedNew, style: .default, handler: { (action) in
            self.sendCardToCardRequest()
        })
        
        let payBills = UIAlertAction(title: "SETTING_FS_PAY_BILLS".localizedNew, style: .default, handler: { (action) in
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = false
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
            viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let trafficOffenses = UIAlertAction(title: "SETTING_FS_PAY_TRAFFIC_TICKETS".localizedNew, style: .default, handler: { (action) in
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = true
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
            viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let mobileBillingInquiry = UIAlertAction(title: "SETTING_FS_MBILL_INQUERY".localizedNew, style: .default, handler: { (action) in
            IGFinancialServiceBillingInquiry.isMobile = true
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
            viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let phoneBillingInquiry = UIAlertAction(title: "SETTING_FS_PHONE_INQUERY".localizedNew, style: .default, handler: { (action) in
            IGFinancialServiceBillingInquiry.isMobile = false
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
            viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
        option.addAction(cardToCard)
        option.addAction(mobileCharge)
        option.addAction(payBills)
        option.addAction(trafficOffenses)
        option.addAction(mobileBillingInquiry)
        option.addAction(phoneBillingInquiry)
        option.addAction(cancel)
        
        viewController.present(option, animated: true, completion: {})
    }
    
    
    public func sendCardToCardRequest(){
        IGGlobal.prgShow()
        IGMplGetCardToCardToken.Generator.generate().success({ (protoResponse) in
            IGGlobal.prgHide()
            
            if let mplGetCardToCardToken = protoResponse as? IGPMplGetCardToCardTokenResponse {
                InitCardToCard().initCardToCard(Token: mplGetCardToCardToken.igpToken,
                                                MerchantVCArg: UIApplication.topViewController()!,
                                                callback: self)
            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    public func sendPayDirectRequest(inquery: Bool, amount: Int64 , toUserId: Int64 , invoiceNUmber: Int64 , description: String ){
        IGGlobal.prgShow()
        IGMplGetSalesToken.Generator.generate(inquery: inquery, amount: amount , toUserId: toUserId , invoiceNUmber: invoiceNUmber , description: description).success({ (protoResponse) in
            IGGlobal.prgHide()

                    if let response = protoResponse as? IGPMplGetSalesTokenResponse {
                        let initpayment = InitPayment()
                        initpayment.registerPay(merchant: self)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                        initpayment.initPay(Token: response.igpToken, MerchantVCArg: UIApplication.topViewController()!, TSPEnabled: 0)

                        }
                    }
                }).error ({ (errorCode, waitTime) in
                                            IGGlobal.prgHide()

                }).send()
    }
    func ctcResult(encData: String, message: String, status: Int, resultCode: Int) {
        
    }
    func update(encData: String, message: String, status: Int) {
        IGMplSetSalesResult.sendRequest(data: encData)
    }
    
    func error(errorType: Int, orderID: Int) {
    }
    
    
}
