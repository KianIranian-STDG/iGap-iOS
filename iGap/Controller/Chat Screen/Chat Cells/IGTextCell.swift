//
//  IGTextCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 8/5/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGTextCell: UICollectionViewCell {
    static let reuseId = "IGTextCell"
    
    private let label: UILabel = UILabel(frame: .zero)
    

    
    func configure(text: String?) {
        initialize()
        label.text = text
    }
    func initialize() {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        let labelInset = UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10)
        contentView.addSubview(label)
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: labelInset.top).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: labelInset.left).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: labelInset.right).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: labelInset.bottom).isActive = true
        
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
    }
    

}
