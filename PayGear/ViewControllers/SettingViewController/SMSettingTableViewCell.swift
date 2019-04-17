//
//  SMSettingTableViewCell.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/8/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMSettingTableViewCell: UITableViewCell {

	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var titleIcon: UIImageView!
	
	class func loadFromNib() -> SMSettingTableViewCell {
		return UINib(nibName: "SMSettingTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMSettingTableViewCell
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		titleLbl.textAlignment = SMDirection.TextAlignment()
		self.transform = SMDirection.PageAffineTransform()
		self.titleLbl.transform = SMDirection.PageAffineTransform()

	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
