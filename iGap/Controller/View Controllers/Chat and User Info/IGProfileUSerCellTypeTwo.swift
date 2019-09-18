//
//  IGProfileUSerCellTypeTwo.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/18/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGProfileUSerCellTypeTwo: UITableViewCell {
    @IBOutlet weak var lblActionName : UILabel!
    @IBOutlet weak var lblActionDetail : UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        defaultInitLabels()
    }
    func initLabels(nameLblString : String! = "") {
        
        lblActionName.text = nameLblString
    }
    private func defaultInitLabels() {
        lblActionName.textAlignment = lblActionName.localizedNewDirection
        lblActionName.font = UIFont.igFont(ofSize: 15)
        
    }
    override func prepareForReuse() {
        lblActionName.text = nil
    }

}
