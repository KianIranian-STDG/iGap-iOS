//
//  SMHistoryTableViewCell.swift
//  PayGear
//
//  Created by amir soltani on 5/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		currencyLabel.text = "Currency".localized
		let direction =  SMDirection.PageAffineTransform()
		self.transform = direction
		profileImage.transform = direction
		titleLabel.transform = direction
		titleImage.transform = direction
		descLabel.transform = direction
		timeLabel.transform = direction
		amountLabel.transform = direction
		currencyLabel.transform = direction
		
		let alignment = SMDirection.TextAlignment()
		titleLabel.textAlignment = alignment
		descLabel.textAlignment = alignment
		timeLabel.textAlignment = alignment
		amountLabel.textAlignment = alignment
		currencyLabel.textAlignment = (alignment == .right) ? .left : .right
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

    }

}
