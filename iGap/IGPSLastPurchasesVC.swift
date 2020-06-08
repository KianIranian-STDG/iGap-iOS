//
//  IGPSLastPurchasesTVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/8/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSLastPurchasesVC : MainViewController {

    private var vm : IGPSLastPurchasesVM!
    var table = UITableView()
    var TopUpPurchases = [IGPSLastTopUpPurchases]()
    var titlePage : String = ""
    var delegate: chargeDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(IGPSTOPUPLastPurchasesCell.self, forCellReuseIdentifier: "IGPSTOPUPLastPurchasesCell")

        vm = IGPSLastPurchasesVM(viewController: self)
        vm.TopUpPurchases =  TopUpPurchases
        vm.delegate = delegate
        table.delegate = vm
        table.dataSource = vm
        table.separatorStyle = .none
        initView()
        vm.updateTableView()
        initCustomtNav(title: titlePage)
        self.view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))

        
    }
    private func initView() {
        addTableView()
    }
    private func addTableView() {
        table.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(table)
        table.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        table.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        table.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    @objc private func tapAction() {
        view.endEditing(true)
    }

}
