//
//  SMProfileTableViewCell.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/17/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Cell of profile table view
class SMProfileTableViewCell: UITableViewCell {

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    
    /// Load view directions according localized system
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		titleLbl.textAlignment = SMDirection.TextAlignment()
		descriptionLbl.textAlignment = SMDirection.TextAlignment()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
