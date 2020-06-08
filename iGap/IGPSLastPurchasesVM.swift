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
    var delegate: chargeDelegate?

    init(viewController: IGPSLastPurchasesVC) {
        self.vc = viewController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TopUpPurchases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let vc = vc as? IGPSLastPurchasesVC {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IGPSTOPUPLastPurchasesCell", for: indexPath) as! IGPSTOPUPLastPurchasesCell
            cell.item = TopUpPurchases[indexPath.row]
            cell.delegate = delegate
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

    
    func updateTableView() {
        vc?.table.reloadData()
    }
    
}
