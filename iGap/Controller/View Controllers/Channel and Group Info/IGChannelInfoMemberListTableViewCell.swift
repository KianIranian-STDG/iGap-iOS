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

class IGChannelInfoMemberListTableViewCell: UITableViewCell {
    weak var delegate : cellWithMoreChannel?

    @IBOutlet weak var memberUserNameLabel: UILabel!
    @IBOutlet weak var memberAvatarView: IGAvatarView!
    @IBOutlet weak var adminOrModeratorLabel: UILabel!
    @IBOutlet weak var memberRecentlyStatusLabel: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    var user : IGChannelMember!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        adminOrModeratorLabel.isHidden = true
        memberRecentlyStatusLabel.textColor = UIColor.organizationalColor()
        memberUserNameLabel.textAlignment = memberUserNameLabel.localizedNewDirection
        initiconFonts()

    }
    private func initiconFonts() {
        adminOrModeratorLabel.font = UIFont.iGapFonticon(ofSize: 20)
        self.btnMore.titleLabel!.font = UIFont.iGapFonticon(ofSize: 28)
        self.btnMore.setTitle("", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUser(_ member: IGChannelMember,myRole: IGChannelMember.IGRole? = nil) {
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
                }
                else if myRole == .member {
                    self.btnMore.isHidden = true
                }
            else {
                self.btnMore.isHidden = false

            }
        if let memberUserDetail = member.user {
            memberUserNameLabel.text = memberUserDetail.displayName
            memberAvatarView.setUser(memberUserDetail)
            if member.role == .admin {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = ""
            }
            if member.role == .moderator {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = ""
            }
            if member.role == .owner {
                adminOrModeratorLabel.isHidden = false
                adminOrModeratorLabel.text = ""
                self.btnMore.isHidden = true
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
        @IBAction func btnMoreTaped(_ sender: UIButton) {
            delegate?.didPressMoreButton(member: user)
        }
        
    }

    protocol cellWithMoreChannel : class {
        func didPressMoreButton(member: IGChannelMember)
    }
