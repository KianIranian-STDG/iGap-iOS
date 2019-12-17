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
        initChangeCellLang()
    }
    func initChangeCellLang() {
        titleLabel.textAlignment = titleLabel.localizedDirection
        descLabel.textAlignment = descLabel.localizedDirection
        timeLabel.textAlignment = timeLabel.localizedDirection
        amountLabel.textAlignment = amountLabel.localizedDirection
        currencyLabel.textAlignment = currencyLabel.localizedDirection
        
        
        titleLabel.textColor = ThemeManager.currentTheme.LabelColor
        descLabel.textColor = ThemeManager.currentTheme.LabelColor
        timeLabel.textColor = ThemeManager.currentTheme.LabelColor
        amountLabel.textColor = ThemeManager.currentTheme.LabelColor
        currencyLabel.textColor = ThemeManager.currentTheme.LabelColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

    }

}
