//
//  IGPSBillMyBillsTVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/16/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGPSBillMyBillsTVC: MainViewController {
    var vm : IGPSBillMyBillsTVM!
    var table = UITableView()
    var items = [parentBillModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        initCustomtNav(title: IGStringsManager.MyBills.rawValue.localized)
        addTableView()
        table.register(IGPSBillMyBillsCell.self, forCellReuseIdentifier: "IGPSBillMyBillsCell")
        vm = IGPSBillMyBillsTVM(viewController: self)
        table.delegate = vm
        table.dataSource = vm
        table.separatorStyle = .none
        vm.items = items
        table.reloadData()
        vm.queryInnerData()

    

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
