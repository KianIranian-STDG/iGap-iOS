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
import SnapKit
import RealmSwift
import IGProtoBuff
import MarkdownKit
import MGSwipeTableCell

class IGRoomListtCell: BaseTableViewCell {
    
    var showStateImage : Bool!
    
    var width: Int = 0
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 14,weight: .bold)
        label.textColor = ThemeManager.currentTheme.LabelColor
        label.textAlignment = label.localizedDirection
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 13,weight: .light)
        label.textColor = ThemeManager.currentTheme.LabelColor
        label.textAlignment = NSTextAlignment.center
        label.text = label.text?.inLocalizedLanguage()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var lastMsgLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 13, weight: .light)
        label.textColor = ThemeManager.currentTheme.LabelColor
        label.textAlignment = label.localizedDirection
        label.text = ""
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 13, weight: .light)
        label.textColor = .white
        label.textAlignment = .center
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var unreadView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var initialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 16,weight: .bold)
        label.textColor = .white
        label.textAlignment = NSTextAlignment.center
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 27
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var avatarImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 27
        img.clipsToBounds = true
        return img
    }()
    
    var bgImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = true // enable autolayout
        img.image = UIImage(named:"bgCellPin")
        return img
    }()
    
    var bgPinTagImage: UIImageView = {
        let img = UIImageView()

        img.translatesAutoresizingMaskIntoConstraints = true // enable autolayout
        if Locale.userPreferred.languageCode == SMLangUtil.SMLanguage.English.rawValue {
            img.image = UIImage(named:"bgCellPinTag-Default")

        } else {
            let tmpImg = UIImage(named:"bgCellPinTag-Default")
            img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

            
        }
        return img
    }()
    
    var muteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.iGapFonticon(ofSize: 16)
        label.textColor = ThemeManager.currentTheme.LabelGrayColor
        label.text = ""
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var typeImage = UILabel()
    
    var nameAndTypeStackView = UIStackView()
    var chatDetailsStackView = UIStackView()
    
    var checkImage = UIImageView()
    var stateImage = UIImageView()
    var lastMessageStateImage :UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        return img
    }()
    
    var roomII: IGRoom? {
        didSet {
            guard let item = roomII else { return }
            
            if let time = item.lastMessage?.creationTime! {
                
                DispatchQueue.global(qos: .userInteractive).async {
                    let t = time.convertToHumanReadable(onlyTimeIfToday: true)
                    
                    DispatchQueue.main.async {
                        self.timeLabel.text = t
                    }
                }
            }
            
            let unread = String(item.unreadCount)
            if unread == "0" {
                unreadView.isHidden = true
                
            } else {
                unreadView.isHidden = false
                unreadCountLabel.text = unread.inLocalizedLanguage()
            }
            self.initialLabel.text = item.initilas
            let color = UIColor.hexStringToUIColor(hex: item.colorString)
            self.initialLabel.backgroundColor = color
            
            //
            if item.pinId > 0 {
                self.contentView.backgroundColor = ThemeManager.currentTheme.RecentTVCellColor
                bgImage.isHidden = false
                bgPinTagImage.isHidden = false

            } else {
                self.contentView.backgroundColor = ThemeManager.currentTheme.RecentTVCellColor
                bgImage.isHidden = true
                bgPinTagImage.isHidden = true

            }
            
            if item.pinId > 0 && !IGHelperPromote.isPromotedRoom(room: item) {
                self.unreadView.isHidden = true
                self.lastMessageStateImage.backgroundColor = UIColor.clear
            } else {
                if let lastMessage = item.lastMessage {
                    switch lastMessage.status {
                    case .sending:
                        self.lastMessageStateImage.image = UIImage(named: "IG_Chat_List_Delivery_State_Pending")
                        self.lastMessageStateImage.backgroundColor = UIColor.clear
                        break
                    case .sent:
                        self.lastMessageStateImage.image = UIImage(named: "IG_Chat_List_Delivery_State_Sent")
                        self.lastMessageStateImage.backgroundColor = UIColor.clear
                        break
                    case .delivered:
                        self.lastMessageStateImage.image = UIImage(named: "IG_Chat_List_Delivery_State_Delivered")
                        self.lastMessageStateImage.backgroundColor = UIColor.clear
                        break
                    case .seen:
                        self.lastMessageStateImage.image = UIImage(named: "IG_Chat_List_Delivery_State_Seen")
                        self.lastMessageStateImage.backgroundColor = UIColor.clear
                        break
                    case .failed:
                        self.lastMessageStateImage.image = UIImage(named: "IG_Chat_List_Delivery_State_Failed")
                        self.lastMessageStateImage.backgroundColor = UIColor.red
                        break
                    default:
                        break
                    }
                }
            }
            
            switch item.type {
                
            case .chat:
                self.typeImage.isHidden = true
                
                if (item.chatRoom?.peer?.isVerified)! {
                    self.checkImage.isHidden = false
                    
                } else {
                    self.checkImage.isHidden = true
                    
                }
            case .group:
                self.typeImage.isHidden = false
                self.typeImage.text = ""
                self.typeImage.font = UIFont.iGapFonticon(ofSize: 15)
                self.checkImage.isHidden = true
                
            case .channel:
                
                self.typeImage.isHidden = false
                
                self.typeImage.text = ""
                self.typeImage.font = UIFont.iGapFonticon(ofSize: 15)

                if (item.channelRoom?.isVerified)! {
                    self.checkImage.isHidden = false
                    
                } else {
                    self.checkImage.isHidden = true
                    
                }
            }
            
            switch item.mute {
                
            case .unmute:
                self.muteLabel.isHidden = true
                unreadView.backgroundColor = ThemeManager.currentTheme.BadgeColor
            case .mute:
                self.muteLabel.isHidden = false
                unreadView.backgroundColor = UIColor.darkGray
                
            }
            
            self.nameLabel.text = item.title
            
            switch item.type {
            case .chat:
                if let avatar = item.chatRoom?.peer?.avatar {
                    if let avatarChat = IGAvatar.getLastAvatar(ownerId: item.chatRoom!.peer!.id), let avatarFile = avatarChat.file {
                        self.avatarImage.setAvatar(avatar: avatarFile)
                    } else {
                        self.avatarImage.setAvatar(avatar: avatar.file!)
                    }
                }
            case .group:
                if let avatar = item.groupRoom?.avatar {
                    if let avatarGroup = IGAvatar.getLastAvatar(ownerId: item.groupRoom!.id), let avatarFile = avatarGroup.file {
                        self.avatarImage.setAvatar(avatar: avatarFile)
                    } else {
                        self.avatarImage.setAvatar(avatar: avatar.file!)
                    }
                }
                
            case .channel:
                if let avatar = item.channelRoom?.avatar {
                    if let avatarChannel = IGAvatar.getLastAvatar(ownerId: item.channelRoom!.id), let avatarFile = avatarChannel.file {
                        self.avatarImage.setAvatar(avatar: avatarFile)
                    } else {
                        self.avatarImage.setAvatar(avatar: avatar.file!)
                    }
                }
            }
            
            if showStateImage {
                self.lastMessageStateImage.isHidden = false
                self.unreadView.isHidden = true
            } else {
                self.lastMessageStateImage.isHidden = true
                self.unreadView.isHidden = false
            }
            
            switch item.type {
                
            case .chat:
                self.lastMessageStateImage.isHidden = false
                break
                
            case .group:
                self.lastMessageStateImage.isHidden = false
                break
                
            case .channel:
                self.lastMessageStateImage.isHidden = true
                break
            }
            
            if (item.lastMessage?.message) != nil {
                setLastMessage(for: item)
            } else {
                self.lastMsgLabel.text = ""
            }
            
            let img = UIImageView()
            let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
            let currentThemeColorLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
            let currentThemeColorDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"

            img.translatesAutoresizingMaskIntoConstraints = true // enable autolayout
            if Locale.userPreferred.languageCode == SMLangUtil.SMLanguage.English.rawValue {
                img.image = UIImage(named:"bgCellPinTag-Default")

                switch currentTheme {
                case "IGAPClassic" :
                    img.image = UIImage(named:"bgCellPinTag-Default")
                case "IGAPDay" :
                    if currentThemeColorLight == "IGAPBlue" {
                        img.image = UIImage(named:"bgCellPinTag-Blue")
                    } else if currentThemeColorLight == "IGAPTorquoise" {
                        img.image = UIImage(named:"bgCellPinTag-Torquoise")
                    } else if currentThemeColorLight == "IGAPGreen" {
                        img.image = UIImage(named:"bgCellPinTag-Green")
                    } else if currentThemeColorLight == "IGAPPink" {
                        img.image = UIImage(named:"bgCellPinTag-Pink")
                    }  else if currentThemeColorLight == "IGAPOrange" {
                        img.image = UIImage(named:"bgCellPinTag-Orange")
                    }  else if currentThemeColorLight == "IGAPPurple" {
                        img.image = UIImage(named:"bgCellPinTag-Purple")
                    } else if currentThemeColorLight == "IGAPRed" {
                        img.image = UIImage(named:"bgCellPinTag-Red")
                    } else if currentThemeColorLight == "IGAPGold" {
                        img.image = UIImage(named:"bgCellPinTag-Gold")
                    } else {
                        img.image = UIImage(named:"bgCellPinTag-LightGray")
                    }
                    
                case "IGAPDark" :
                    if currentThemeColorDark == "IGAPBlue" {
                        img.image = UIImage(named:"bgCellPinTag-Blue")
                    } else if currentThemeColorDark == "IGAPTorquoise" {
                        img.image = UIImage(named:"bgCellPinTag-Torquoise")
                    } else if currentThemeColorDark == "IGAPGreen" {
                        img.image = UIImage(named:"bgCellPinTag-Green")
                    } else if currentThemeColorDark == "IGAPPink" {
                        img.image = UIImage(named:"bgCellPinTag-Pink")
                    }  else if currentThemeColorDark == "IGAPOrange" {
                        img.image = UIImage(named:"bgCellPinTag-Orange")
                    }  else if currentThemeColorDark == "IGAPPurple" {
                        img.image = UIImage(named:"bgCellPinTag-Purple")
                    } else if currentThemeColorDark == "IGAPRed" {
                        img.image = UIImage(named:"bgCellPinTag-Red")
                    } else if currentThemeColorDark == "IGAPGold" {
                        img.image = UIImage(named:"bgCellPinTag-Gold")
                    } else {
                        img.image = UIImage(named:"bgCellPinTag-LightGray")
                    }
                default : break
                }
            } else {
                
                switch currentTheme {
                case "IGAPClassic" :
                    let tmpImg = UIImage(named:"bgCellPinTag-Default")
                    img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                case "IGAPDay" :
                    if currentThemeColorLight == "IGAPBlue" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Blue")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorLight == "IGAPTorquoise" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Torquoise")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorLight == "IGAPGreen" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Green")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorLight == "IGAPPink" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Pink")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    }  else if currentThemeColorLight == "IGAPOrange" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Orange")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    }  else if currentThemeColorLight == "IGAPPurple" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Purple")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorLight == "IGAPRed" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Red")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorLight == "IGAPGold" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Gold")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else {
                        let tmpImg = UIImage(named:"bgCellPinTag-LightGray")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    }
                    
                case "IGAPDark" :
                    if currentThemeColorDark == "IGAPBlue" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Blue")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorDark == "IGAPTorquoise" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Torquoise")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorDark == "IGAPGreen" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Green")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorDark == "IGAPPink" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Pink")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    }  else if currentThemeColorDark == "IGAPOrange" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Orange")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    }  else if currentThemeColorDark == "IGAPPurple" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Purple")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorDark == "IGAPRed" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Red")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else if currentThemeColorDark == "IGAPGold" {
                        let tmpImg = UIImage(named:"bgCellPinTag-Gold")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    } else {
                        let tmpImg = UIImage(named:"bgCellPinTag-LightGray")
                        img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

                    }
                default : break
                }
            }
            self.bgPinTagImage.image = img.image
            self.nameLabel.textColor = ThemeManager.currentTheme.LabelColor
            self.timeLabel.textColor = ThemeManager.currentTheme.LabelColor
            self.lastMsgLabel.textColor = ThemeManager.currentTheme.LabelColor
            self.typeImage.textColor = ThemeManager.currentTheme.LabelColor
            self.backgroundColor = ThemeManager.currentTheme.TableViewCellColor
            unreadView.layer.borderColor = UIColor.white.cgColor
            unreadView.layer.borderWidth = 1.0

        }
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        unreadView.backgroundColor = .red
        
        timeLabel.text = "..."
        checkImage.image = UIImage(named:"IG_Verify")
        
        self.nameAndTypeStackView.axis = .horizontal
        self.nameAndTypeStackView.distribution = .fill
        self.nameAndTypeStackView.alignment = .center
        self.nameAndTypeStackView.spacing = 6
        self.nameAndTypeStackView.addArrangedSubview(typeImage)
        self.nameAndTypeStackView.addArrangedSubview(nameLabel)
        self.nameAndTypeStackView.semanticContentAttribute = self.semantic
        
        self.chatDetailsStackView.axis = .horizontal
        self.chatDetailsStackView.distribution = .fill
        self.chatDetailsStackView.alignment = .center
        self.chatDetailsStackView.spacing = 6
        self.chatDetailsStackView.addArrangedSubview(muteLabel)
        self.chatDetailsStackView.addArrangedSubview(checkImage)
        self.chatDetailsStackView.addArrangedSubview(timeLabel)
        self.chatDetailsStackView.semanticContentAttribute = self.semantic
        
        self.contentView.addSubview(bgImage)
        self.contentView.addSubview(bgPinTagImage)
        self.contentView.addSubview(nameAndTypeStackView)
        self.contentView.addSubview(chatDetailsStackView)
        self.contentView.addSubview(lastMsgLabel)
        self.contentView.addSubview(unreadView)
        self.unreadView.addSubview(unreadCountLabel)
        self.contentView.addSubview(initialLabel)
        self.contentView.addSubview(avatarImage)
        self.contentView.addSubview(stateImage)
        self.contentView.addSubview(lastMessageStateImage)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    private func initView() {
        makeAvatar()
        makeBGImage()
        makeBGPinTagImage()
        makeInitialLabel()
        
        // detail stackview
        makeChatDetailsStackView()
        makeMuteLabel()
        makeCheckImage()
        makeTimeLabel()
        
        // name and type icon stackview
        makeNameAndTypeStackView()
        makeTypeImage()
        makeNameLabel()
        
        makeLastMessageLabel()
        makeUnreadView()
        makeUnreadCountLabel()
        
        makelastMessageStateImage()

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImage.image = nil
        self.nameLabel.text = nil
        self.stateImage.image = nil
        self.unreadCountLabel.text = nil
        self.lastMessageStateImage.image = nil
        self.avatarImage.image = UIImage()
        showStateImage = nil
    }
    
    
    private func setLastMessage(for room: IGRoom) {
        DispatchQueue.main.async {
            if room.isInvalidated {
                return
            }
            self.lastMsgLabel.textAlignment = self.lastMsgLabel.localizedDirection
            
            if let draft = room.draft, (room.draft?.message != "" || room.draft?.replyTo != -1) {
                
                self.lastMsgLabel.text = IGStringsManager.Draft.rawValue.localized + " \(draft.message)"
            } else if let lastMessage = room.lastMessage {
                if lastMessage.isDeleted {
                    self.lastMsgLabel.text = IGStringsManager.DeletedMessage.rawValue.localized
                    self.lastMessageStateImage.isHidden = true
                    self.unreadView.isHidden = true
                    
                    return
                } else {
                    if self.showStateImage {
                        self.lastMessageStateImage.isHidden = true
                        self.unreadView.isHidden = true
                    } else {
                        self.lastMessageStateImage.isHidden = true
                        self.unreadView.isHidden = false
                    }
                    
                }
                
                var finalMessage = lastMessage
                if let forwardMessage = lastMessage.forwardedFrom {
                    finalMessage = forwardMessage
                }
                
                switch finalMessage.type {
                case .audioAndText, .gifAndText, .fileAndText, .imageAndText, .videoAndText, .text:
                    self.lastMsgLabel.text = finalMessage.message
                    break
                    
                case .image:
                    self.lastMsgLabel.text = IGStringsManager.ImageMessage.rawValue.localized
                    break
                    
                case .video:
                    self.lastMsgLabel.text = IGStringsManager.VideoMessage.rawValue.localized
                    break
                    
                case .gif:
                    self.lastMsgLabel.text = IGStringsManager.GifMessage.rawValue.localized
                    break
                    
                case .audio:
                    self.lastMsgLabel.text = IGStringsManager.AudioMessage.rawValue.localized
                    break
                    
                case .voice:
                    self.lastMsgLabel.text = IGStringsManager.VoiceMessage.rawValue.localized
                    break
                    
                case .file:
                    self.lastMsgLabel.text = IGStringsManager.FileMessage.rawValue.localized
                    break
                    
                case .sticker:
                    self.lastMsgLabel.text = IGStringsManager.StickerMessage.rawValue.localized
                    break
                    
                case .log:
                    self.lastMsgLabel.text = IGRoomMessageLog.textForLogMessage(lastMessage)
                    break
                    
                case .contact:
                    self.lastMsgLabel.text = IGStringsManager.ContactMessage.rawValue.localized
                    break
                    
                case .location:
                    self.lastMsgLabel.text = IGStringsManager.LocationMessage.rawValue.localized
                    break
                    
                case .wallet:
                    if finalMessage.wallet?.type == IGPRoomMessageWallet.IGPType.moneyTransfer.rawValue {
                        self.lastMsgLabel.text = IGStringsManager.WalletMessage.rawValue.localized
                    } else if finalMessage.wallet?.type == IGPRoomMessageWallet.IGPType.payment.rawValue {
                        self.lastMsgLabel.text = IGStringsManager.PaymentMessage.rawValue.localized
                    } else if finalMessage.wallet?.type == IGPRoomMessageWallet.IGPType.cardToCard.rawValue {
                        self.lastMsgLabel.text = IGStringsManager.CardToCardMessage.rawValue.localized
                    } else if finalMessage.wallet?.type == IGPRoomMessageWallet.IGPType.topup.rawValue {
                        self.lastMsgLabel.text = IGStringsManager.TopupMessage.rawValue.localized
                    } else if finalMessage.wallet?.type == IGPRoomMessageWallet.IGPType.bill.rawValue {
                        self.lastMsgLabel.text = IGStringsManager.BillMessage.rawValue.localized
                    }
                default:
                    self.lastMsgLabel.text = IGStringsManager.UnknownMessage.rawValue.localized
                    break
                }
            } else {
                self.timeLabel.text = ""
                self.lastMsgLabel.text  = ""
            }
            if let lastMessage = room.lastMessage {
                if let senderUser = lastMessage.authorUser {
                    if senderUser.userId == IGAppManager.sharedManager.userID() {
                        if self.showStateImage {
                            self.lastMessageStateImage.isHidden = false
                            self.unreadView.isHidden = true
                        } else {
                            self.lastMessageStateImage.isHidden = true
                            self.unreadView.isHidden = false
                        }
                    } else {
                        switch room.type {
                            
                        case .chat:
                            if self.showStateImage {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadView.isHidden = true
                            } else {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadView.isHidden = false
                                
                            }
                            
                            break
                            
                        case .group:
                            if self.showStateImage {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadView.isHidden = true
                            } else {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadView.isHidden = false
                                
                            }
                            break
                            
                        case .channel:
                            if self.showStateImage {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadView.isHidden = true
                            } else {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadView.isHidden = false
                                
                            }
                            break
                            
                            
                        }
                        
                    }
                }
            } else {
                self.lastMsgLabel.text  = ""
            }

        }
    }
    
    private func makeAvatar() {
        avatarImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(8)
            make.width.equalTo(54)
            make.height.equalTo(54)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        if avatarImage.image == UIImage(named : "2") {
            avatarImage.image = nil
            avatarImage.backgroundColor = .clear
        }
    }
    
    private func makeBGImage() {
        bgImage.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImage.snp.centerX).offset(0)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-8)
            make.top.equalTo(self.contentView.snp.top).offset(5)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
        }
        bgImage.contentMode = .scaleToFill // image will never be strecthed vertially or horizontally
    }
    
    private func makeBGPinTagImage() {
        bgPinTagImage.snp.makeConstraints { (make) in
            make.trailing.equalTo(bgImage.snp.trailing).offset(0)
            make.top.equalTo(self.bgImage.snp.top).offset(0)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        bgPinTagImage.contentMode = .scaleToFill // image will never be strecthed vertially or horizontally
    }
    
    private func makeInitialLabel() {
        initialLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(8)
            make.width.equalTo(54)
            make.height.equalTo(54)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
    }
    
    private func makeChatDetailsStackView() {
        chatDetailsStackView.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(self.contentView.snp.trailing).offset(-15)
            maker.top.equalTo(self.avatarImage.snp.top).offset(3)
            maker.height.equalTo(22)
        }
    }
    
    private func makeMuteLabel() {
        muteLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.chatDetailsStackView.snp.leading)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
    }
    
    private func makeCheckImage() {
        checkImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.muteLabel.snp.trailing).offset(6)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
    }
    
    private func makeTimeLabel() {
        timeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.chatDetailsStackView.snp.trailing).offset(0)
            make.width.greaterThanOrEqualTo(30)
            make.top.equalTo(self.chatDetailsStackView.snp.top).offset(0)
            make.bottom.equalTo(self.chatDetailsStackView.snp.bottom).offset(0)
            make.leading.equalTo(self.checkImage.snp.trailing).offset(6)
        }
    }
    
    private func makeNameAndTypeStackView() {
        nameAndTypeStackView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(self.avatarImage.snp.trailing).offset(8)
            maker.trailing.lessThanOrEqualTo(self.chatDetailsStackView.snp.leading).offset(-4)
            maker.centerY.equalTo(self.chatDetailsStackView.snp.centerY)
            maker.height.equalTo(22)
        }
    }
    
    private func makeTypeImage() {
        typeImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.nameAndTypeStackView.snp.leading)
            make.height.equalTo(15)
            make.width.equalTo(15)
        }
    }
    
    private func makeNameLabel() {
        nameLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.nameAndTypeStackView.snp.trailing)
            make.leading.equalTo(self.typeImage.snp.trailing).offset(6)
            make.top.equalTo(self.nameAndTypeStackView.snp.top)
            make.bottom.equalTo(self.nameAndTypeStackView.snp.bottom)
        }
    }
    
    private func makestateImage() {
        stateImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.avatarImage.snp.trailing).offset(2)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.top.equalTo(self.avatarImage.snp.top)
        }
    }
    
    private func makelastMessageStateImage() {
        lastMessageStateImage.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-12)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.bottom.equalTo(self.avatarImage.snp.bottom)
        }
    }
    
    private func makeLastMessageLabel() {
        lastMsgLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.avatarImage.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(self.unreadCountLabel.snp.leading).offset(-8)
            make.bottom.equalTo(self.avatarImage.snp.bottom).offset(-3)
        }
    }
    
    private func makeUnreadView() {
        unreadView.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(self.contentView.snp.trailing).offset(-15)
            maker.bottom.equalTo(self.avatarImage.snp.bottom)
            maker.width.equalTo(30)
            maker.height.equalTo(20)
        }
    }
    
    private func makeUnreadCountLabel() {
        unreadCountLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.unreadView.snp.trailing).offset(-3)
            make.bottom.equalTo(self.unreadView.snp.bottom)
            make.leading.equalTo(self.unreadView.snp.leading).offset(3)
            make.top.equalTo(self.unreadView.snp.top)
        }
        unreadCountLabel.text =  unreadCountLabel.text?.inLocalizedLanguage()
    }
    
}
