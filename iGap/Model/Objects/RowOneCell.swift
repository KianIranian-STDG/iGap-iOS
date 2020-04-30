//
//  ListCardCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SwiftEventBus

class RowOneCell: BaseTableViewCell {
    private var btnCards: UIButton = {
        let btnCards = UIButton()
        btnCards.backgroundColor = .blue
        btnCards.titleLabel?.font = UIFont.igFont(ofSize: 14)
        btnCards.setTitleColor(.darkGray, for: .normal)
        btnCards.layer.cornerRadius = 10
        btnCards.backgroundColor = .clear
        return btnCards
    }()
    private let bgView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 10
        return view
    }()
    private let arrowIcon : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.iGapFonticon(ofSize: 10)
        lbl.text = ""
        return lbl

    }()
    let cardNumber : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 11)
        lbl.text = ""

        return lbl

    }()
    let cardText : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 14)
        lbl.text = IGStringsManager.CardNumber.rawValue.localized
        return lbl

    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addBGView()
        addSubview(btnCards)
        addButton()
        bgView.semanticContentAttribute = self.semantic
        arrowIcon.semanticContentAttribute = self.semantic
        cardText.semanticContentAttribute = self.semantic
        cardNumber.semanticContentAttribute = self.semantic
        if (cardText.text?.isRTL())! {
            cardNumber.textAlignment = .left
        } else {
            cardNumber.textAlignment = .right
        }
        
        
        
        btnCards.addTarget(self, action: #selector(didTapOnBtnShowCards), for: .touchUpInside)


    }
    @objc private func didTapOnBtnShowCards() {

    }

    private func addBGView() {

        addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        bgView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bgView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true

        
        addArrowIcon()
        addCardNumber()
        addCardText()

    }
    private func addArrowIcon() {
        bgView.addSubview(arrowIcon)
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false
        arrowIcon.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -10).isActive = true
        arrowIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        arrowIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        arrowIcon.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0).isActive = true

    }
    
    private func addCardText() {
        bgView.addSubview(cardText)
        cardText.translatesAutoresizingMaskIntoConstraints = false
        cardText.trailingAnchor.constraint(equalTo: cardNumber.leadingAnchor, constant: -5).isActive = true
        cardText.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 20).isActive = true
        cardText.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cardText.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0).isActive = true

    }
    
    private func addCardNumber() {
        bgView.addSubview(cardNumber)
        cardNumber.translatesAutoresizingMaskIntoConstraints = false
        cardNumber.trailingAnchor.constraint(equalTo: arrowIcon.leadingAnchor, constant: -10).isActive = true
        cardNumber.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant: 0).isActive = true
    }
    
    private func addButton() {
        btnCards.translatesAutoresizingMaskIntoConstraints = false
        btnCards.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        btnCards.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        btnCards.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnCards.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true

        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
