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

class IGGroupAdminListTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var groupAdminLastRecentlyLabel: UILabel!
    @IBOutlet weak var groupAdminNameLabel: UILabel!
    @IBOutlet weak var groupAdminAvatarView: IGAvatarView!
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
            groupAdminNameLabel.text = memberUserDetail.displayName
            groupAdminAvatarView.setUser(memberUserDetail)
            switch memberUserDetail.lastSeenStatus {
            case .exactly:
                if let lastSeenTime = memberUserDetail.lastSeen {
                    groupAdminLastRecentlyLabel.text = "\(lastSeenTime.humanReadableForLastSeen())".inLocalizedLanguage()
                }

                break
            case .lastMonth:
                groupAdminLastRecentlyLabel.text = "LAST_MONTH".localizedNew
                break
            case .lastWeek:
                groupAdminLastRecentlyLabel.text = "LAST_WEAK".localizedNew
                break
            case .longTimeAgo:
                groupAdminLastRecentlyLabel.text = "A_LONG_TIME_AGO".localizedNew
                break
            case .online:
                groupAdminLastRecentlyLabel.text = "ONLINE".localizedNew
                break
            case .recently:
                groupAdminLastRecentlyLabel.text = "LAST_SEEN_RECENTLY".localizedNew
                break
            case .support:
                groupAdminLastRecentlyLabel.text = "IGAP_SUPPORT".localizedNew
                break
            case .serviceNotification:
                groupAdminLastRecentlyLabel.text = "SERVICE_NOTIFI".localizedNew
                
                break

                
                
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.setUser(member)
//            }

            
        }
    }

}
