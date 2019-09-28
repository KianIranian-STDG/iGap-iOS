//
//  addMemberCellTypeTwoCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/28/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class addMemberCellTypeTwoCell: UITableViewCell {
    @IBOutlet weak var lblText : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func initCell(text: String!) {
        lblText.font = UIFont.igFont(ofSize: 15)
        lblText.textAlignment = lblText.localizedNewDirection
        lblText.text = text
    }

}
