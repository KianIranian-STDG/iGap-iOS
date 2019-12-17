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

class IGContactTableViewCell: UITableViewCell {
    
    var userRegister : IGRegisteredUser!
    
    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var contactNameLable: UILabel!
    @IBOutlet weak var contactPhoneNumber: UILabel!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnVideoCall: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        contactNameLable.textAlignment = contactNameLable.localizedDirection
        contactPhoneNumber.textAlignment = contactPhoneNumber.localizedDirection
        self.contentView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUser(_ user: IGRegisteredUser) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.btnCall.removeUnderline()
        }
        contactNameLable.text = user.displayName
        if currentTabIndex == TabBarTab.Contact.rawValue {

            switch user.lastSeenStatus {
            case .longTimeAgo:
                self.contactPhoneNumber.text =  IGStringsManager.LongTimeAgo.rawValue.localized
                break
            case .lastMonth:
                self.contactPhoneNumber.text = IGStringsManager.LastMonth.rawValue.localized
                break
            case .lastWeek:
                self.contactPhoneNumber.text = IGStringsManager.Lastweak.rawValue.localized
                break
            case .online:
                self.contactPhoneNumber.text  = IGStringsManager.Online.rawValue.localized
                break
            case .exactly:
                self.contactPhoneNumber.text = "\(user.lastSeen!.humanReadableForLastSeen())".inLocalizedLanguage()
                break
            case .recently:
                self.contactPhoneNumber.text = IGStringsManager.NavLastSeenRecently.rawValue.localized
                break
            case .support:
                self.contactPhoneNumber.text = IGStringsManager.IgapSupport.rawValue.localized
                break
            case .serviceNotification:
                self.contactPhoneNumber.text = IGStringsManager.NotificationServices.rawValue.localized
                break
            }

        } else {
            contactPhoneNumber.text = String(user.phone)
        }

        userAvatarView.setUser(user)
        self.userRegister = user
        self.contentView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        contactNameLable.textColor = ThemeManager.currentTheme.LabelColor
        contactPhoneNumber.textColor = ThemeManager.currentTheme.LabelColor

        btnCall.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnVideoCall.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
    }
    
    override func prepareForReuse() {
        contactNameLable.text = nil
        userAvatarView.avatarImageView?.image = nil
    }
    @IBAction func btnCall(_ sender: UIButton) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        if let delegate = IGPhoneBookTableViewController.callDelegate {
            delegate.call(user: userRegister,mode:"voiceCall")
        }
    }
    @IBAction func btnVideoCall(_ sender: UIButton) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        if let delegate = IGContactListTableViewController.callDelegate {
            delegate.call(user: userRegister,mode:"videoCall")
        }
    }
}
