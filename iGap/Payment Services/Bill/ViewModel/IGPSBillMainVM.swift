//
//  IGPSBillMainVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/14/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
class IGPSBillMainVM : NSObject {
    weak var vc : IGPSBillMainVC?

    
    var items = [IGPSAllBillsBillQuery]()

    init(viewController: IGPSBillMainVC) {
        self.vc = viewController
    }
    

    func getAllBills() {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.getAllBills(){[weak self] (response, error) in
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
                  let vc = IGPSBillMyBillsTVC()
                vc.items = response!
                UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)

            } else {

            }
            IGLoading.hideLoadingPage()

        }
    }
    

    

    

    

}
