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
        if SMLangUtil.lang == "fa" || SMLangUtil.lang == "ar"  {
            
            titleLabel.textAlignment = .right
            descLabel.textAlignment = .right
            timeLabel.textAlignment = .right
            amountLabel.textAlignment = .right
            currencyLabel.textAlignment = .right
        }
        else {
            titleLabel.textAlignment = .left
            descLabel.textAlignment = .left
            timeLabel.textAlignment = .left
            amountLabel.textAlignment = .left
            currencyLabel.textAlignment = .left
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

    }

}
