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
import IGProtoBuff

class IGMemberCell: UITableViewCell {
    
    weak var delegate : cellWithMore?
    var user : IGRealmMember!
    
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var groupMemberRecentlyStatus: UILabel!
    @IBOutlet weak var groupMemberAvatarView: IGAvatarView!
    @IBOutlet weak var groupMemberRoleInGroupLabel: UILabel!
    @IBOutlet weak var groupMemberNameLabel: UILabel!
    
    @IBAction func btnMoreTaped(_ sender: UIButton) {
        delegate?.didPressMoreButton(member: user)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupMemberNameLabel.textAlignment = groupMemberNameLabel.localizedDirection
        initiconFonts()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.groupMemberAvatarView.avatarImageView?.image = nil
        groupMemberNameLabel.text = nil
        groupMemberRecentlyStatus.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func initiconFonts() {
        groupMemberRoleInGroupLabel.font = UIFont.iGapFonticon(ofSize: 20)
        self.btnMore.titleLabel!.font = UIFont.iGapFonticon(ofSize: 28)
        self.btnMore.setTitle("", for: .normal)
    }
    
    func setUser(_ member: IGRealmMember, myRole: Int) {
        if member.isInvalidated {
            return
        }
        user = member
        
        self.btnMore.isHidden = true
        if myRole == IGPChannelRoom.IGPRole.owner.rawValue {
            if member.role == IGPChannelRoom.IGPRole.admin.rawValue || member.role == IGPChannelRoom.IGPRole.moderator.rawValue || member.role == IGPChannelRoom.IGPRole.member.rawValue {
                self.btnMore.isHidden = false
            }
        } else if myRole == IGPChannelRoom.IGPRole.admin.rawValue {
            if member.role == IGPChannelRoom.IGPRole.moderator.rawValue || member.role == IGPChannelRoom.IGPRole.member.rawValue {
                self.btnMore.isHidden = false
            }
        } else if myRole == IGPChannelRoom.IGPRole.moderator.rawValue {
            if member.role == IGPChannelRoom.IGPRole.member.rawValue {
                self.btnMore.isHidden = false // TODO - for public group set isHidden to true
            }
        }
        
        if let memberUserDetail = member.user {
            groupMemberNameLabel.text = memberUserDetail.displayName
            groupMemberAvatarView.avatarImageView?.backgroundColor = UIColor.clear
            groupMemberAvatarView.setUser(memberUserDetail)
            
            if member.role == IGPChannelRoom.IGPRole.admin.rawValue {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = ""

            }
            if member.role == IGPChannelRoom.IGPRole.moderator.rawValue {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = ""

            }
            if member.role == IGPChannelRoom.IGPRole.owner.rawValue {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = ""
                self.btnMore.isHidden = true
            }
            if member.role == IGPChannelRoom.IGPRole.member.rawValue {
                groupMemberRoleInGroupLabel.isHidden = true
            }
            
            
            switch memberUserDetail.lastSeenStatus {
            case .exactly:
                if let lastSeenTime = memberUserDetail.lastSeen {
                    groupMemberRecentlyStatus.text = "\(lastSeenTime.humanReadableForLastSeen())".inLocalizedLanguage()
                }
                break
            case .lastMonth:
                groupMemberRecentlyStatus.text = "LAST_MONTH".localized
                break
            case .lastWeek:
                groupMemberRecentlyStatus.text = "LAST_WEAK".localized
                break
            case .longTimeAgo:
                groupMemberRecentlyStatus.text = "A_LONG_TIME_AGO".localized
                break
            case .online:
                groupMemberRecentlyStatus.text = "ONLINE".localized
                break
            case .recently:
                groupMemberRecentlyStatus.text = "LAST_SEEN_RECENTLY".localized
                break
            case .support:
                groupMemberRecentlyStatus.text = "IGAP_SUPPORT".localized
                break
            case .serviceNotification:
                groupMemberRecentlyStatus.text = "SERVICE_NOTIFI".localized
                break
            }
        } else { // when user info not exist yet!
            groupMemberAvatarView.avatarImageView?.backgroundColor = UIColor.white
            groupMemberAvatarView.avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
            groupMemberNameLabel.text = "fetching info..."
            groupMemberRecentlyStatus.text = ""
        }
    }
}

protocol cellWithMore : class {
    func didPressMoreButton(member: IGRealmMember)
}
