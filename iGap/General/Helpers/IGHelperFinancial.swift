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
var cardToCardTapCount : Int!

class IGHelperFinancial: NSObject, CardToCardResult,MerchantResultObserver {
    
    static let shared = IGHelperFinancial()
    
    private var uiViewController: UIViewController!
    private var cardToCardUserId: Int64!
    
    override init() {}
    
    private init(_ viewController: UIViewController) {
        self.uiViewController = viewController
    }
    
    static func getInstance(viewController: UIViewController) -> IGHelperFinancial {
        return IGHelperFinancial(viewController)
    }
    
    func manageFinancialServiceChoose() {
        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_FINANCIAL_SERVICES)
        
        var viewController: UIViewController! = self.uiViewController
        if viewController == nil {
            viewController = UIApplication.topViewController()
        }
        
        let option = UIAlertController(title: IGStringsManager.FinancialServices.rawValue.localized, message: "مسیولیت کلیه خدمات مالی بر عهده شرکت تجارت الکترونیک پارسیان ( تاپ ) می باشد مرکز پاسخگویی مشتریان  =  2318-021", preferredStyle: IGGlobal.detectAlertStyle())
        
        let mobileCharge = UIAlertAction(title: IGStringsManager.ChargeSimCard.rawValue.localized, style: .default, handler: { (action) in
            let messagesVc = IGFinancialServiceCharge.instantiateFromAppStroryboard(appStoryboard: .Setting)
            messagesVc.hidesBottomBarWhenPushed = true
            viewController.navigationController!.pushViewController(messagesVc, animated: true)
        })
        
        let cardToCard = UIAlertAction(title: IGStringsManager.CardToCard.rawValue.localized, style: .default, handler: { (action) in
            self.sendCardToCardRequest()
        })
        
        let payBills = UIAlertAction(title: IGStringsManager.PayBills.rawValue.localized, style: .default, handler: { (action) in
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = false
            
            let messagesVc =  IGFinancialServiceBill.instantiateFromAppStroryboard(appStoryboard: .Setting)
            messagesVc.hidesBottomBarWhenPushed = true
            viewController.navigationController!.pushViewController(messagesVc, animated: true)
        })
        
        let trafficOffenses = UIAlertAction(title: IGStringsManager.PayTraficTicket.rawValue.localized, style: .default, handler: { (action) in
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = true
            
            let messagesVc =  IGFinancialServiceBill.instantiateFromAppStroryboard(appStoryboard: .Setting)
            messagesVc.hidesBottomBarWhenPushed = true
            viewController.navigationController!.pushViewController(messagesVc, animated: true)
        })
        
        let mobileBillingInquiry = UIAlertAction(title: IGStringsManager.HamrahAvalBillsInquiry.rawValue.localized, style: .default, handler: { (action) in
            IGFinancialServiceBillingInquiry.isMobile = true
            
            let messagesVc =  IGFinancialServiceBillingInquiry.instantiateFromAppStroryboard(appStoryboard: .Setting)
            messagesVc.hidesBottomBarWhenPushed = true
            viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let phoneBillingInquiry = UIAlertAction(title: IGStringsManager.HomeBillsInquiry.rawValue.localized, style: .default, handler: { (action) in
            IGFinancialServiceBillingInquiry.isMobile = false
            
            let messagesVc =  IGFinancialServiceBillingInquiry.instantiateFromAppStroryboard(appStoryboard: .Setting)
            messagesVc.hidesBottomBarWhenPushed = true
            viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        option.addAction(cardToCard)
        option.addAction(mobileCharge)
        option.addAction(payBills)
        option.addAction(trafficOffenses)
        option.addAction(mobileBillingInquiry)
        option.addAction(phoneBillingInquiry)
        option.addAction(cancel)
        
        viewController.present(option, animated: true, completion: {})
    }
    
    
    public func sendCardToCardRequest(toUserId: Int64 = 0){
        
        IGGlobal.prgShow()
        IGMplGetCardToCardToken.Generator.generate(toUserId: toUserId).successPowerful({ (protoResponse, requestWrapper) in
            IGGlobal.prgHide()
            if let toUserId = requestWrapper.identity as? Int64, toUserId != 0 {
                self.cardToCardUserId = toUserId
            } else {
                self.cardToCardUserId = 0
            }
            
            if let mplGetCardToCardToken = protoResponse as? IGPMplGetCardToCardTokenResponse {
                DispatchQueue.main.async {
                    InitCardToCard().initCardToCard(Token: mplGetCardToCardToken.igpToken,
                                                    MerchantVCArg: UIApplication.topViewController()!,
                                                    callback: self)
                }
            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    public func sendCardToCardRequestWithAmount(toUserId: Int64 = 0,amount:Int!,destinationCard: String?){
        IGGlobal.prgShow()
        IGMplGetCardToCardTokenWithAmount.Generator.generate(toUserId: toUserId , amount:(amount) , destinationCard: destinationCard).successPowerful({ (protoResponse, requestWrapper) in
            let dc = destinationCard

            IGGlobal.prgHide()
                self.cardToCardUserId = toUserId
            
            if let mplGetCardToCardToken = protoResponse as? IGPMplGetCardToCardTokenResponse {
                DispatchQueue.main.async {
                    InitCardToCard().initCardToCard(Token: mplGetCardToCardToken.igpToken,
                                                    MerchantVCArg: UIApplication.topViewController()!,
                                                    callback: self, amount:(((amount))!) , destinationCard: destinationCard!)
                }
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
        IGMplSetCardToCardResult.sendRequest(data: encData, toUserId: self.cardToCardUserId)
    }
    
    func update(encData: String, message: String, status: Int) {
        IGMplSetSalesResult.sendRequest(data: encData)
    }
    
    func error(errorType: Int, orderID: Int) {}
}
