//
//  CallTypesCVCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/11/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class CallTypesCVCell: UICollectionViewCell {
    @IBOutlet weak var lbl: UILabel!
    
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
