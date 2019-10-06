//
//  BaseTableViewCell.swift
//  iGap
//
//  Created by MacBook Pro on 7/14/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var isAppEnglish: Bool {
        get {
            return SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        }
    }
    
    var appTransform: CGAffineTransform {
        get {
            return isAppEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    var semantic: UISemanticContentAttribute {
        get {
            return isAppEnglish ? .forceLeftToRight : .forceRightToLeft
        }
    }
    
    var appTextAlignment: NSTextAlignment {
        get {
            return isAppEnglish ? .left : .right
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
