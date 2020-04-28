//
//  RowTwoCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class RowTwoCell: BaseTableViewCell {
    
    private var btnShowHistory: UIButton = {
        let btnCards = UIButton()
        btnCards.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
        btnCards.titleLabel?.font = UIFont.igFont(ofSize: 14)
        btnCards.setTitleColor(.white, for: .normal)
        btnCards.layer.cornerRadius = 15
        btnCards.setTitle(IGStringsManager.TransactionHistory.rawValue.localized, for: .normal)
        return btnCards
    }()


    let transactionText : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.text = IGStringsManager.CardNumber.rawValue.localized
        return lbl

    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        addBGView()
        addSubview(btnShowHistory)
        addSubview(transactionText)

        addButtonHistory()
        addLBLTransactions()
        
        btnShowHistory.semanticContentAttribute = self.semantic
        transactionText.semanticContentAttribute = self.semantic

        btnShowHistory.addTarget(self, action: #selector(didTapOnBtnShowHistory), for: .touchUpInside)


    }
    @objc private func didTapOnBtnShowHistory() {

    }

  
    
    private func addButtonHistory() {

        btnShowHistory.translatesAutoresizingMaskIntoConstraints = false
        btnShowHistory.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        btnShowHistory.widthAnchor.constraint(equalToConstant: 120).isActive = true
        btnShowHistory.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnShowHistory.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
//        btnShowHistory.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true

    }
    private func addLBLTransactions() {
        transactionText.translatesAutoresizingMaskIntoConstraints = false
        transactionText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        transactionText.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true

    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
