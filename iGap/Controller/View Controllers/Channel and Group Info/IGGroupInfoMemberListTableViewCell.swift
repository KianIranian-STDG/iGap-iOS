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

class IGGroupInfoMemberListTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var groupMemberRecentlyStatus: UILabel!
    @IBOutlet weak var groupMemberAvatarView: IGAvatarView!
    @IBOutlet weak var groupMemberRoleInGroupLabel: UILabel!
    @IBOutlet weak var groupMemberNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUser(_ member: IGGroupMember) {
        if member.isInvalidated {
            return
        }
        
        if let memberUserDetail = member.user {
            groupMemberNameLabel.text = memberUserDetail.displayName
            groupMemberAvatarView.setUser(memberUserDetail)
            if member.role == .admin {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = "(Admin)"
            }
            if member.role == .moderator {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = "(Moderator)"
            }
            if member.role == .owner {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = "(Owner)"
            }
            if member.role == .member {
                groupMemberRoleInGroupLabel.isHidden = true
            }
            switch memberUserDetail.lastSeenStatus {
            case .exactly:
                if let lastSeenTime = memberUserDetail.lastSeen {
                    groupMemberRecentlyStatus.text = "\(lastSeenTime.humanReadableForLastSeen())".inLocalizedLanguage()
                }
                break
            case .lastMonth:
                groupMemberRecentlyStatus.text = "LAST_MONTH".localizedNew
                break
            case .lastWeek:
                groupMemberRecentlyStatus.text = "LAST_WEAK".localizedNew
                break
            case .longTimeAgo:
                groupMemberRecentlyStatus.text = "A_LONG_TIME_AGO".localizedNew
                break
            case .online:
                groupMemberRecentlyStatus.text = "ONLINE".localizedNew
                break
            case .recently:
                groupMemberRecentlyStatus.text = "LAST_SEEN_RECENTLY".localizedNew
                break
            case .support:
                groupMemberRecentlyStatus.text = "IGAP_SUPPORT".localizedNew
                break
            case .serviceNotification:
                groupMemberRecentlyStatus.text = "SERVICE_NOTIFI".localizedNew
                
                break
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                self.setUser(member)
            }

        }
    }


}
