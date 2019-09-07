//
//  slideImageCVCell.swift
//  iGap
//
//  Created by hossein nazari on 9/3/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class slideImageCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
