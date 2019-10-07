//
//  phoneBookCellTypeTwo.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 10/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit

class phoneBookCellTypeTwo: UITableViewCell {

    @IBOutlet weak var lblIcon : UILabel!
    @IBOutlet weak var lblText : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblText.textAlignment = lblText.localizedNewDirection
        lblIcon.textAlignment = .center
        lblIcon.font = UIFont.iGapFonticon(ofSize: 25)
    }
}
