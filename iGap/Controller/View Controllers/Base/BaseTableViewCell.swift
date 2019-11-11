//
//  BaseTableViewCell.swift
//  iGap
//
//  Created by MacBook Pro on 7/14/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var isRTL: Bool {
        get {
            return LocaleManager.isRTL
        }
    }
    
    var appTransform: CGAffineTransform {
        get {
            return LocaleManager.transform
        }
    }
    
    var semantic: UISemanticContentAttribute {
        get {
            return LocaleManager.semantic
        }
    }
    
    var appTextAlignment: NSTextAlignment {
        get {
            return LocaleManager.TextAlignment
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
