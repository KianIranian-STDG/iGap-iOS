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

class IGHelperFinancial {
    
    private var viewController: UIViewController!
    
    private init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func getInstance(viewController: UIViewController) -> IGHelperFinancial {
        return IGHelperFinancial(viewController)
    }
    
    func manageFinancialServiceChoose(){
        let option = UIAlertController(title: "Financial Services", message: "Responsible for all financial services Parsian e-commerce company (top). \n Customer Support Center: 021-2318", preferredStyle: IGGlobal.detectAlertStyle())
        
        let mobileCharge = UIAlertAction(title: "Top Up SIM Card", style: .default, handler: { (action) in
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceCharge") as! IGFinancialServiceCharge
            self.viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let payBills = UIAlertAction(title: "Pay Bills", style: .default, handler: { (action) in
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = false
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
            self.viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let trafficOffenses = UIAlertAction(title: "Pay Traffic Tickets", style: .default, handler: { (action) in
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = true
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
            self.viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let mobileBillingInquiry = UIAlertAction(title: "Mobile Bills Inquiry", style: .default, handler: { (action) in
            IGFinancialServiceBillingInquiry.isMobile = true
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
            self.viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let phoneBillingInquiry = UIAlertAction(title: "Phone Bills Inquiry", style: .default, handler: { (action) in
            IGFinancialServiceBillingInquiry.isMobile = false
            
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
            self.viewController.navigationController!.pushViewController(messagesVc, animated:true)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        option.addAction(mobileCharge)
        option.addAction(payBills)
        option.addAction(trafficOffenses)
        option.addAction(mobileBillingInquiry)
        option.addAction(phoneBillingInquiry)
        option.addAction(cancel)
        
        self.viewController.present(option, animated: true, completion: {})
    }
    
    
}
