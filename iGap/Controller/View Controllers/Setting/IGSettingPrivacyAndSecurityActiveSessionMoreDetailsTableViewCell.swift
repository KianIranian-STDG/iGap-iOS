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

class IGSettingPrivacyAndSecurityActiveSessionMoreDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var moreDetailsLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        moreDetailsLable.text = IGStringsManager.MoreDetails.rawValue.localized
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func setSession(_ session : IGSession) {
        moreDetailsLable.text = IGStringsManager.MoreDetails.rawValue.localized
        self.accessoryType = .disclosureIndicator
    }
}
