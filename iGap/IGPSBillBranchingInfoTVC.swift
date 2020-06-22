//
//  IGPSBillBranchingInfo.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/22/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation


class IGPSBillBranchingInfoTVC: MainViewController {
    var vm : IGPSBillBranchingInfoTVM!
    var billType : IGBillType!
    var bill : parentBillModel!
    var table = UITableView()
    
//    var items = [parentBillModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        initCustomtNav(title: IGStringsManager.BillBranchingInfo.rawValue.localized)
        addTableView()
        table.register(IGPSBillBranchInfoCell.self, forCellReuseIdentifier: "IGPSBillBranchInfoCell")
        vm = IGPSBillBranchingInfoTVM(viewController: self)
        table.delegate = vm
        table.dataSource = vm
        vm.billType = billType
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        vm.items = items
        vm.getBillBranchInfo(billType: bill.billType!, billIdentifier: bill.billIdentifier, subscriptionCode: bill.subsCriptionCode)

    

    }
    
    
    func addTableView() {
        table.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(table)
        table.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 0).isActive = true
        table.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 0).isActive = true
        table.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: 0).isActive = true
        table.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: 0).isActive = true
    }
    

}

