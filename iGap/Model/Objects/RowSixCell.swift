//
//  RowSixCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/29/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class RowSixCell: BaseTableViewCell,UITableViewDataSource,UITableViewDelegate {
    


    let lblHeader : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.text = IGStringsManager.Bills.rawValue.localized
        return lbl

    }()
    let viewHeader : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view

    }()

    private var myTableView: UITableView!
    var listBills : [String] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        addBGView()
        addSubview(lblHeader)
        addSubview(viewHeader)

        addHeader()
        
        lblHeader.semanticContentAttribute = self.semantic
        viewHeader.semanticContentAttribute = self.semantic
        initTableView()


    }
    private func initTableView() {
        myTableView = UITableView()
        myTableView.register(BillCellInner.self, forCellReuseIdentifier: "BillCellInner")

        myTableView.dataSource = self
        myTableView.delegate = self
        self.addSubview(myTableView)
        myTableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        myTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        myTableView.topAnchor.constraint(equalTo: lblHeader.bottomAnchor, constant: 10).isActive = true
        
        if listBills.count > 0 {
            
        } else {
            myTableView.setEmptyMessage(IGStringsManager.GlobalNoHistory.rawValue.localized)
        }
    }
  
    
    private func addHeader() {
        lblHeader.translatesAutoresizingMaskIntoConstraints = false
        lblHeader.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        lblHeader.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true

        viewHeader.translatesAutoresizingMaskIntoConstraints = false
        viewHeader.leadingAnchor.constraint(equalTo: lblHeader.trailingAnchor, constant: 10).isActive = true
        viewHeader.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        viewHeader.centerYAnchor.constraint(equalTo: lblHeader.centerYAnchor, constant: 0).isActive = true
        viewHeader.heightAnchor.constraint(equalToConstant: 1).isActive = true

        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listBills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillCellInner", for: indexPath) as! BillCellInner

        return cell

    }
    

}
