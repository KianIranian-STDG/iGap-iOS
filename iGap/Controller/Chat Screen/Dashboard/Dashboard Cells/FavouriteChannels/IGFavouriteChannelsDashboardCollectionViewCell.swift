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
    
    var isInner: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .white
        self.layer.cornerRadius = 14.0
//        lbl.backgroundColor = .white
        self.contentView.layer.cornerRadius = 14.0
//        self.contentView.layer.borderWidth = 1.0
//        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 3.0

        self.layer.shadowOpacity = 0.12
        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
    }

}
