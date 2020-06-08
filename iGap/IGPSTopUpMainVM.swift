//
//  IGPSTopUpMainVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/6/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSTopUpMainVM : NSObject {
    weak var vc : IGPSTopUpMainVC?
    private var allLists = [IGPSLastTopUpPurchases]()
    var selectedAmount : String!
    var selectedPhone : String!
    var selectedOp : selectedOperator!
    var selectedType : String!

    init(viewController: IGPSTopUpMainVC) {
        self.vc = viewController
    }
    
    //MARK: - Fetch Data
    
    func requestGetLastTopUpPurchases() {
        
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiTopup.shared.getLastPurchases {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: error!, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            }
            IGLoading.hideLoadingPage()
            if response!.count > 0 {
                sSelf.allLists = response!
                let vcc = IGPSLastPurchasesVC()
                vcc.TopUpPurchases = sSelf.allLists
                vcc.titlePage = IGStringsManager.PSLastPurchases.rawValue.localized
                vcc.delegate = sSelf.vc
                UIApplication.topViewController()?.navigationController?.pushViewController(vcc, animated: true)
            } else {

            }
        }
    }
    func buyRequest() {
        var userOperator : String!
        var chargeType : String!
        var title : String!
        switch selectedOp {
        case .MCI :
            userOperator = "MCI"
            title = IGStringsManager.MCI.rawValue.localized
        case .MTN :
            userOperator = "MTN"
            title = IGStringsManager.Irancell.rawValue.localized

        case .Rightel :
            userOperator = "RIGHTEL"
            title = IGStringsManager.Rightel.rawValue.localized

        default : break
        }

        let chargeAmount = Int64(selectedAmount.onlyDigitChars())

        IGApiTopup.shared.chargeSimCard(opType: userOperator!, telNum: selectedPhone!, cost: chargeAmount!, type: selectedType) { (success, token) in
            
            if success {
                guard let token = token else { return }
                IGApiPayment.shared.orderCheck(token: token, completion: { (success, payment, errorMessage) in
                    IGGlobal.prgHide()
                    let paymentView = IGPaymentView.sharedInstance
                    if success {
                        guard let paymentData = payment else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            return
                        }
                        paymentView.show(on: UIApplication.shared.keyWindow!, title: title, payToken: token, payment: paymentData)
                    } else {
                        
                        paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: title, message: errorMessage ?? "", payToken: token)
                    }
                })
                
            } else {
                IGGlobal.prgHide()
            }
        }
    }
}
