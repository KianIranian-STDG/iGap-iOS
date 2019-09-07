//
//  IGFavouriteChannelCVCell.swift
//  iGap
//
//  Created by hossein nazari on 9/1/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGFavouriteChannelCVCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageViewX!
    
    class func nib() -> UINib {
        return UINib(nibName: "IGFavouriteChannelCVCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let isEnglish = SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue
        self.contentView.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        imageView.layer.cornerRadius = 8
    }
}
