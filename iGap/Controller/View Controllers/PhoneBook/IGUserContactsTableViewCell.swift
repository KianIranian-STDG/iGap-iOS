/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import UIKit

class IGUserContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: IGLabel!
    @IBOutlet weak var phoneNumberLbl: IGLabel!
    @IBOutlet weak var avatarIconLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLbl.textAlignment = nameLbl.localizedDirection
        phoneNumberLbl.textAlignment = phoneNumberLbl.localizedDirection
        avatarIconLbl.text = ""
        avatarIconLbl.layer.cornerRadius = self.avatarIconLbl.frame.height
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
