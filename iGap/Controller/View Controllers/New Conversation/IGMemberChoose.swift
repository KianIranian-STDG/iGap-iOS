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

class IGMemberChoose: UITableViewCell {
    
    
    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var lastSeenStatusLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    var user : IGMemberAddOrUpdateState.User!{
        didSet{
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contactNameLabel.textAlignment = contactNameLabel.localizedDirection
    }
    
    func updateUI() {
        
        contactNameLabel.text = user.registredUser.displayName
      
        switch user!.registredUser.lastSeenStatus {
        case .longTimeAgo:
            self.lastSeenStatusLabel.text =  IGStringsManager.LongTimeAgo.rawValue.localized
            break
        case .lastMonth:
            self.lastSeenStatusLabel.text = IGStringsManager.LastMonth.rawValue.localized
            break
        case .lastWeek:
            self.lastSeenStatusLabel.text = IGStringsManager.Lastweak.rawValue.localized
            break
        case .online:
            self.lastSeenStatusLabel.text  = IGStringsManager.Online.rawValue.localized
            break
        case .exactly:
            self.lastSeenStatusLabel.text = "\(user!.registredUser.lastSeen!.humanReadableForLastSeen())".inLocalizedLanguage()
            break
        case .recently:
            self.lastSeenStatusLabel.text = IGStringsManager.NavLastSeenRecently.rawValue.localized
            break
        case .support:
            self.lastSeenStatusLabel.text = IGStringsManager.IgapSupport.rawValue.localized
            break
        case .serviceNotification:
            self.lastSeenStatusLabel.text = IGStringsManager.NotificationServices.rawValue.localized
            break
        }
        userAvatarView.setUser(user.registredUser)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
