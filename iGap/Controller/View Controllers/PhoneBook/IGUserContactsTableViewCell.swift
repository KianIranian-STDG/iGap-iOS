//
//  IGUserContactsTableViewCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/14/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGUserContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: IGLabel!
    @IBOutlet weak var phoneNumberLbl: IGLabel!
    @IBOutlet weak var avatarView: IGAvatarView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLbl.textAlignment = nameLbl.localizedNewDirection
        phoneNumberLbl.textAlignment = phoneNumberLbl.localizedNewDirection
        avatarView.setImage(UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")!)
        avatarView.avatarImageView?.tintColor = UIColor(named: themeColor.labelGrayColor.rawValue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
