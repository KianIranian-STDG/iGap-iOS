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

class IGGroupInfoMemberListTableViewCell: UITableViewCell {
    weak var delegate : cellWithMore?

    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var groupMemberRecentlyStatus: UILabel!
    @IBOutlet weak var groupMemberAvatarView: IGAvatarView!
    @IBOutlet weak var groupMemberRoleInGroupLabel: UILabel!
    @IBOutlet weak var groupMemberNameLabel: UILabel!
    var user : IGGroupMember!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        groupMemberNameLabel.textAlignment = groupMemberNameLabel.localizedNewDirection
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

        // Configure the view for the selected state
    }
    
    private func initiconFonts() {
        groupMemberRoleInGroupLabel.font = UIFont.iGapFonticon(ofSize: 20)
        self.btnMore.titleLabel!.font = UIFont.iGapFonticon(ofSize: 28)
        self.btnMore.setTitle("", for: .normal)
    }
    func setUser(_ member: IGGroupMember,myRole: IGGroupMember.IGRole? = nil) {
        if member.isInvalidated {
            return
        }
        user = member
            if myRole == .owner {
                if member.role == .owner {
                    self.btnMore.isHidden = true
                }
                if member.role == .admin {
                    self.btnMore.isHidden = false
                }
                if member.role == .moderator {
                    self.btnMore.isHidden = false
                }
                if member.role == .member {
                    self.btnMore.isHidden = false

                }
            } else if myRole == .admin {
                if member.role == .owner {
                    self.btnMore.isHidden = true
                }
                if member.role == .admin {
                    self.btnMore.isHidden = true
                }
                if member.role == .moderator {
                    self.btnMore.isHidden = false
                }
                if member.role == .member {
                    self.btnMore.isHidden = false

                }
            } else if myRole == .moderator {
                if member.role == .owner {
                    self.btnMore.isHidden = true
                }
                if member.role == .admin {
                    self.btnMore.isHidden = true
                }
                if member.role == .moderator {
                    self.btnMore.isHidden = true
                }
                if member.role == .member {
                    self.btnMore.isHidden = false

                }
            } else {
                self.btnMore.isHidden = true

            }
        
        if let memberUserDetail = member.user {
            groupMemberNameLabel.text = memberUserDetail.displayName
            groupMemberAvatarView.setUser(memberUserDetail)
            if member.role == .admin {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = ""

            }
            if member.role == .moderator {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = ""

            }
            if member.role == .owner {
                groupMemberRoleInGroupLabel.isHidden = false
                groupMemberRoleInGroupLabel.text = ""
                self.btnMore.isHidden = true
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

  
    @IBAction func btnMoreTaped(_ sender: UIButton) {
        delegate?.didPressMoreButton(member: user)
    }
    
}

protocol cellWithMore : class {
    func didPressMoreButton(member: IGGroupMember)
}
