//
//  IGPSBillDetailVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/15/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
class IGPSBillDetailVM : NSObject {
    weak var vc : IGPSBillDetailVC?
    
    init(viewController: IGPSBillDetailVC) {
        self.vc = viewController
    }
    func queryElecBill(billType: String, telNum: String? = nil, billID: String? = nil) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryElecBill(billType: billType, telNum: telNum!, billID: billID!)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: error!, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            } else {
                IGLoading.hideLoadingPage()
                sSelf.vc?.billPayNumber = response?.paymentIdentifier
                sSelf.vc?.billPayDeadLine = response?.paymentDeadLine
                sSelf.vc?.billPayAmount = response?.totalBillDebt
            }
            
        }
        
    }
    func queryGasBill(billType: String, billID: String? = nil) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryGasBill(billType: billType, billID: billID!)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: error!, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            } else {
                IGLoading.hideLoadingPage()
                sSelf.vc?.billNumber = response?.billIdentifier
                sSelf.vc?.billPayNumber = response?.paymentIdentifier
                sSelf.vc?.billPayDeadLine = response?.paymentDeadLine
                sSelf.vc?.billPayAmount = response?.totalBillDebt
            }
            
        }
        
    }
    
    func queryPhoneBill(billType: String, telNum: String) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryPhoneBill(billType: billType, telNum: telNum)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: error!, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            } else {
                IGLoading.hideLoadingPage()
                if response?.midTerm?.amount != nil {
                    
                }
                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billNumber = "\(response?.lastTerm?.billId ?? 0)".inLocalizedLanguage()
                    sSelf.vc?.billPayNumber = "\(response?.lastTerm?.payId ?? 0)".inLocalizedLanguage()
                } else {
                    sSelf.vc?.billNumber = "\(response?.midTerm?.billId ?? 0)"
                    sSelf.vc?.billPayNumber = "\(response?.midTerm?.payId ?? 0)"
                }
                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billPayAmount = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayAmount = "\(response?.midTerm?.amount ?? 0)".currencyFormat().inLocalizedLanguage()

                }
                if response?.lastTerm?.billId == nil {
                    sSelf.vc?.billPayDeadLine = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayDeadLine = "\(response?.lastTerm?.amount ?? 0)".currencyFormat().inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
                }


            }
            
        }
        
    }
    
    func queryMobileBill(billType: String, telNum: String) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryMobileBill(billType: billType, telNum: telNum)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: error!, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            } else {
                IGLoading.hideLoadingPage()
                if response?.midTerm?.amount != nil {
                    
                }
                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billNumber = "\(response?.lastTerm?.billId ?? 0)".inLocalizedLanguage()
                    sSelf.vc?.billPayNumber = "\(response?.lastTerm?.payId ?? 0)".inLocalizedLanguage()
                } else {
                    sSelf.vc?.billNumber = "\(response?.midTerm?.billId ?? 0)"
                    sSelf.vc?.billPayNumber = "\(response?.midTerm?.payId ?? 0)"
                }
                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billPayAmount = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayAmount = "\(response?.midTerm?.amount ?? 0)".currencyFormat().inLocalizedLanguage()

                }
                if response?.lastTerm?.billId == nil {
                    sSelf.vc?.billPayDeadLine = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayDeadLine = "\(response?.lastTerm?.amount ?? 0)".currencyFormat().inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
                }


            }
            
        }
        
    }
}
