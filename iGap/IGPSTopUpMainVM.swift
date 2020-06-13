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
    private var allListsPackages = [IGPSLastInternetPackagesPurchases]()
    var selectedAmount : String!
    var selectedPhone : String!
    var selectedOp : selectedOperator!
    var selectedType : String!
    var pageType  : PaymentServicesType!
    var selectedPackage : IGPSLastInternetPackagesPurchases!
    init(viewController: IGPSTopUpMainVC) {
        self.vc = viewController
    }
    
    //MARK: - Fetch Data
    
    func requestGetLastTopUpPurchases(type : PaymentServicesType) {
        switch type {
        case .NetworkPackage :
            getNetworkPackagesLastPurchases()
        case .TopUp :
            getTopUpLastPurchases()
        default : break
        }
    }
    private func getTopUpLastPurchases() {
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
                vcc.TopUpPurchases = response!
                vcc.titlePage = IGStringsManager.PSLastPurchases.rawValue.localized
                vcc.delegate = sSelf.vc
                vcc.pageType = sSelf.pageType
                UIApplication.topViewController()?.navigationController?.pushViewController(vcc, animated: true)
                
            } else {

            }
        }

    }
    private func getNetworkPackagesLastPurchases() {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiInternetPackage.shared.getLastPurchases {[weak self] (response, error) in
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
                sSelf.allListsPackages = response!
                let vcc = IGPSLastPurchasesVC()
                vcc.InternetPurchases = sSelf.allListsPackages
                vcc.titlePage = IGStringsManager.PSLastPurchases.rawValue.localized
                vcc.delegate = sSelf.vc
                vcc.pageType = sSelf.pageType!
                UIApplication.topViewController()?.navigationController?.pushViewController(vcc, animated: true)
            } else {

            }
        }

    }
    func addToHistory() {
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

        let chargeAmount = (selectedAmount.onlyDigitChars())

        IGApiTopup.shared.saveToHistory(opType: userOperator!, telNum: selectedPhone!.inEnglishNumbersNew(), cost: chargeAmount, type: selectedType) { (success) in
            
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.PSAdeddSuccessFully.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                })

            } else {
                IGGlobal.prgHide()
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

        IGApiTopup.shared.chargeSimCard(opType: userOperator!, telNum: selectedPhone!.inEnglishNumbersNew(), cost: chargeAmount!, type: selectedType) { (success, token) in
            
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
                        IGGlobal.isTopUpResult = true

                    } else {
                        
                        paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: title, message: errorMessage ?? "", payToken: token)
                    }
                })
                
            } else {
                IGGlobal.prgHide()
            }
        }
    }
    func getInternetPackages() {
        IGApiInternetPackage.shared.getPackages(opType: selectedOp, type: selectedType) {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: error!, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            }
            if response!.count > 0 {
                sSelf.getCategories(packages: response!)
            } else {
                IGLoading.hideLoadingPage()
            }
        }
    }
    func getCategories(packages: [IGPSInternetPackages]) {
        IGApiInternetPackage.shared.getCategories(opType: selectedOp) {[weak self] (response, error) in
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
                let vcc = IGPSInternetPackagesVC()
                vcc.internetPackages = packages
                if sSelf.selectedPackage != nil {
                    vcc.selectedPackage = sSelf.selectedPackage
                }
                vcc.internetCategories = response
                vcc.selectedOp = sSelf.selectedOp ?? selectedOperator.MTN
                vcc.selectedPhone = sSelf.selectedPhone
                UIApplication.topViewController()?.navigationController?.pushViewController(vcc, animated: true)
            }
        }
        
    }
}
