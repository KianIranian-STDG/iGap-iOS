//
//  SMFormTableViewCell.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMFormTableViewCell: UITableViewCell {

	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var titleField: UITextField!
	
	
	class func loadFromNib() -> SMFormTableViewCell {
		return UINib(nibName: "SMFormTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMFormTableViewCell
	}
	
    /// Handle left to right/ right to left of cell according language
    override func awakeFromNib() {
        super.awakeFromNib()
        let alignment = SMDirection.TextAlignment()
        // Initialization code
        titleLbl.textAlignment = alignment
        titleField.textAlignment = alignment
		titleField.inputView =  LNNumberpad.default()
		titleField.isSecureTextEntry = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
