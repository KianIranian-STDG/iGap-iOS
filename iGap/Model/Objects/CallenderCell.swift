//
//  CallenderCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/29/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class CallenderCell: UICollectionViewCell {
    let lblTop : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.textAlignment = .center

        return lbl
    }()
    let lblDate : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 12)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    let lblBottom : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 10)
        lbl.textAlignment = .center

        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        initView()
    }
    private func initView() {
        addSubview(lblTop)
        addSubview(lblBottom)
//        addSubview(lblDate)

        lblTop.translatesAutoresizingMaskIntoConstraints = false
        lblTop.topAnchor.constraint(equalTo: self.topAnchor,constant: 5).isActive = true
        lblTop.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 5).isActive = true
        lblTop.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5).isActive = true

        lblBottom.translatesAutoresizingMaskIntoConstraints = false
        lblBottom.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 5).isActive = true
        lblBottom.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5).isActive = true
        lblBottom.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -5).isActive = true

        
//        lblTop.translatesAutoresizingMaskIntoConstraints = false
//        lblTop.centerYAnchor.constraint(equalTo: self.centerYAnchor,constant: -10).isActive = true
//        lblTop.centerXAnchor.constraint(equalTo: self.centerXAnchor,constant: 10).isActive = true
//
//
//        lblBottom.translatesAutoresizingMaskIntoConstraints = false
//        lblBottom.centerYAnchor.constraint(equalTo: self.centerYAnchor,constant: 10).isActive = true
//        lblBottom.centerXAnchor.constraint(equalTo: self.centerXAnchor,constant: -10).isActive = true


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
