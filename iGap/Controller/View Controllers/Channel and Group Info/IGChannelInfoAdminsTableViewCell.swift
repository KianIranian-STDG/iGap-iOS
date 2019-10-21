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
import MGSwipeTableCell

class IGChannelInfoAdminsTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var adminRecentlyStatusLabel: UILabel!
    
    @IBOutlet weak var adminAvatarView: IGAvatarView!
    @IBOutlet weak var adminUserNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUser(_ member: IGRealmMember) {
        if let memberUserDetail = member.user {
            adminUserNameLabel.text = memberUserDetail.displayName
            adminAvatarView.setUser(memberUserDetail)
            switch memberUserDetail.lastSeenStatus {
            case .exactly:
                if let lastSeenTime = memberUserDetail.lastSeen {
                    adminRecentlyStatusLabel.text = "\(lastSeenTime.humanReadableForLastSeen())".inLocalizedLanguage()
                }
                break
            case .lastMonth:
                adminRecentlyStatusLabel.text = "LAST_MONTH".localizedNew
                break
            case .lastWeek:
                adminRecentlyStatusLabel.text = "LAST_WEAK".localizedNew
                break
            case .longTimeAgo:
                adminRecentlyStatusLabel.text = "A_LONG_TIME_AGO".localizedNew
                break
            case .online:
                adminRecentlyStatusLabel.text = "ONLINE".localizedNew
                break
            case .recently:
                adminRecentlyStatusLabel.text = "LAST_SEEN_RECENTLY".localizedNew
                break
            case .support:
                adminRecentlyStatusLabel.text = "IGAP_SUPPORT".localizedNew
                break
            case .serviceNotification:
                adminRecentlyStatusLabel.text = "SERVICE_NOTIFI".localizedNew

                break
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.setUser(member)
//            }

            
        }
    }

}
