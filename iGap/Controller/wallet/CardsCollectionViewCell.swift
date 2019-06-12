//
//  CardsCollectionViewCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/14/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class CardsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgBankLogo: UIImageView!
    @IBOutlet weak var lblCardNum: UILabel!
    @IBOutlet weak var lblBankName: UILabel!

    
    override func awakeFromNib() {
        self.layer.cornerRadius = 20.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        lblCardNum.font = UIFont.igFont(ofSize: 20 , weight: .bold)
//        imgBackground.layer.cornerRadius = 15.0
//        imgBackground.layer.masksToBounds = true
    }
}

