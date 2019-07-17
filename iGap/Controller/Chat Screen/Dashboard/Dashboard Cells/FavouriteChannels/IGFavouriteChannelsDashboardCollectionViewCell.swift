//
//  IGFavouriteChannelsDashboardCollectionViewCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/15/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGFavouriteChannelsDashboardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgBG : UIImageView!
    @IBOutlet weak var lbl : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .white
        self.layer.cornerRadius = 10.0
        
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 10.0

        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

    }

}
