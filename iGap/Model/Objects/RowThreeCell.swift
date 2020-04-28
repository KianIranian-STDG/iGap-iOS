//
//  RowThreeCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class RowThreeCell :  BaseTableViewCell {
    


    let lblTitle : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.text = IGStringsManager.Inventory.rawValue.localized
        return lbl

    }()
    let lblAmount : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 20)
        lbl.text = "..."
        return lbl

    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        addBGView()
        addSubview(lblTitle)
        addSubview(lblAmount)

        addLblTitle()
        addLblAmount()
        
        lblAmount.semanticContentAttribute = self.semantic
        lblTitle.semanticContentAttribute = self.semantic


    }
  
    
    private func addLblTitle() {

        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20).isActive = true
        lblTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true

    }
    private func addLblAmount() {
        lblAmount.translatesAutoresizingMaskIntoConstraints = false
        lblAmount.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 20).isActive = true
        lblAmount.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true

    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
