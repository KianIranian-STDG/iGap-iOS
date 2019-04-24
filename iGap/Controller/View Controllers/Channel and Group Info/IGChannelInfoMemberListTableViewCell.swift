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

class IGChannelInfoMemberListTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var memberUserNameLabel: UILabel!
    @IBOutlet weak var memberAvatarView: IGAvatarView!
    @IBOutlet weak var adminOrModeratorLabel: UILabel!
    @IBOutlet weak var memberRecentlyStatusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        adminOrModeratorLabel.isHidden = true
        memberRecentlyStatusLabel.textColor = UIColor.organizationalColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUser(_ member: IGChannelMember) {
        if member.isInvalidated {
            return
        }
        
        if let memberUserDetail = member.user {
            memberUserNameLabel.text = memberUserDetail.displayName
            memberAvatarView.setUser(memberUserDetail)
            if member.role == .admin {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = "(Admin)"
            }
            if member.role == .moderator {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = "(Moderator)"
            }
            if member.role == .owner {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = "(Owner)"
            }
            if member.role == .member {
                adminOrModeratorLabel.isHidden = true
            }
            switch memberUserDetail.lastSeenStatus {
                case .exactly:
                    if let lastSeenTime = memberUserDetail.lastSeen {
                        memberRecentlyStatusLabel.text = "\(lastSeenTime.humanReadableForLastSeen())".inLocalizedLanguage()
                    }
                    break
                case .lastMonth:
                memberRecentlyStatusLabel.text = "LAST_MONTH".localizedNew
                    break
                case .lastWeek:
                 memberRecentlyStatusLabel.text = "LAST_WEAK".localizedNew
                    break
                case .longTimeAgo:
                 memberRecentlyStatusLabel.text = "A_LONG_TIME_AGO".localizedNew
                    break
                case .online:
                 memberRecentlyStatusLabel.text = "ONLINE".localizedNew
                    break
                case .recently:
                 memberRecentlyStatusLabel.text = "LAST_SEEN_RECENTLY".localizedNew
                    break
                case .support:
                memberRecentlyStatusLabel.text = "IGAP_SUPPORT".localizedNew
                    break
                case .serviceNotification:
                memberRecentlyStatusLabel.text = "SERVICE_NOTIFI".localizedNew
                    break
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.setUser(member)
//            }

            
        }
    }

}
