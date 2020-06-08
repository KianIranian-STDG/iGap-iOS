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
        table.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 20).isActive = true
        table.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20).isActive = true
        table.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20).isActive = true
        table.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -20).isActive = true
    }
    
    func makeHeader() -> UIView {
        let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        v.backgroundColor = (ThemeManager.currentTheme.NavigationSecondColor).lighter(by: 10)
        v.layer.cornerRadius = 10
        let stk = UIStackView()
        stk.translatesAutoresizingMaskIntoConstraints = false
        stk.distribution = .fillEqually
        stk.alignment = .fill
        stk.axis = .horizontal
        stk.semanticContentAttribute = (UIApplication.topViewController() as! IGPSLastPurchasesVC).semantic
        v.addSubview(stk)
        
            let lblPhoneNumber = UILabel()
            lblPhoneNumber.font = UIFont.igFont(ofSize: 12)
            lblPhoneNumber.textColor = .white
            lblPhoneNumber.textAlignment = .center
            lblPhoneNumber.text = IGStringsManager.PhoneNumber.rawValue.localized
            lblPhoneNumber.translatesAutoresizingMaskIntoConstraints = false
            let lblOperator = UILabel()
            lblOperator.font = UIFont.igFont(ofSize: 12)
            lblOperator.textColor = .white
            lblOperator.textAlignment = .center
            lblOperator.text = IGStringsManager.PSOperator.rawValue.localized
            lblOperator.translatesAutoresizingMaskIntoConstraints = false

        let lblAmount = UILabel()
        lblAmount.font = UIFont.igFont(ofSize: 12)
        lblAmount.textColor = .white
        lblAmount.textAlignment = .center
        lblAmount.text = IGStringsManager.KAmount.rawValue.localized
        lblAmount.translatesAutoresizingMaskIntoConstraints = false

        stk.addArrangedSubview(lblPhoneNumber)
        stk.addArrangedSubview(lblOperator)
        stk.addArrangedSubview(lblAmount)


        
        stk.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        stk.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        stk.heightAnchor.constraint(equalTo: v.heightAnchor,multiplier: 0.9).isActive = true

        stk.leadingAnchor.constraint(equalTo: v.leadingAnchor,constant: 10).isActive = true
        stk.trailingAnchor.constraint(equalTo: v.trailingAnchor,constant: -10).isActive = true
        return v
    }
    @objc private func tapAction() {
        view.endEditing(true)
    }

}
