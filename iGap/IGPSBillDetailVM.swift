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
}
