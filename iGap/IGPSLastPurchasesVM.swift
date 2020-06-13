//
//  IGPSLastPurchasesVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/8/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
class IGPSLastPurchasesVM : NSObject,UITableViewDelegate,UITableViewDataSource {
    
    weak var vc : IGPSLastPurchasesVC?
    var TopUpPurchases = [IGPSLastTopUpPurchases]()
    var InternetPurchases = [IGPSLastInternetPackagesPurchases]()
    var delegate: chargeDelegate?
    var pageType : PaymentServicesType!

    init(viewController: IGPSLastPurchasesVC) {
        self.vc = viewController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch pageType {
        case .TopUp :
            return TopUpPurchases.count
        case .NetworkPackage :
            return InternetPurchases.count

        default : return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let v = (vc!).makeHeader()
            v.semanticContentAttribute = (UIApplication.topViewController() as! MainViewController).semantic
            return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGPSTOPUPLastPurchasesCell", for: indexPath) as! IGPSTOPUPLastPurchasesCell

        switch pageType {
        case .TopUp :
            cell.item = TopUpPurchases[indexPath.row]
        case .NetworkPackage :
            cell.itemInternet = InternetPurchases[indexPath.row]
        default : cell.item = TopUpPurchases[indexPath.row]
            
        }
        
        cell.delegate = delegate
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

    
    func updateTableView() {
        vc?.table.reloadData()
    }
    
}
