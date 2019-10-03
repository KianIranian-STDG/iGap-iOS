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

class IGRoomListtCell: UITableViewCell {
    
    var showStateImage : Bool!
    
    var width: Int = 0
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 13,weight: .bold)
        label.textColor = UIColor(named: themeColor.TVCellTitleColor.rawValue)
        label.textAlignment = label.localizedNewDirection
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 10,weight: .light)
        label.textColor = UIColor(named: themeColor.TVCellTitleColor.rawValue)
        label.textAlignment = NSTextAlignment.center
        label.text = label.text?.inLocalizedLanguage()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var lastMsgLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 14,weight: .light)
        label.textColor = UIColor(named: themeColor.TVCellTitleColor.rawValue)
        label.textAlignment = label.localizedNewDirection
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 10,weight: .light)
        label.textColor = .white
        label.textAlignment = NSTextAlignment.center
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
            img.image = UIImage(named:"bgCellPin")
        }
        else{
            let tmpImg = UIImage(named:"bgCellPin")
            img.image = UIImage(cgImage: (tmpImg?.cgImage)! ,scale: 1.0 , orientation: .upMirrored)

        }

        
        return img
    }()
    var muteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.iGapFonticon(ofSize: 16)
        label.textColor = UIColor(named: themeColor.labelGrayColor.rawValue)
        label.text = ""
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var typeImage = UILabel()
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
                unreadCountLabel.isHidden = true
                
            } else {
                unreadCountLabel.isHidden = false
                unreadCountLabel.text = unread
            }
            self.initialLabel.text = item.initilas
            let color = UIColor.hexStringToUIColor(hex: item.colorString)
            self.initialLabel.backgroundColor = color
            
            //
            if item.pinId > 0 {
                self.contentView.backgroundColor = UIColor(named: themeColor.recentTVCellColor.rawValue)
                bgImage.isHidden = false
                
            } else {
                self.contentView.backgroundColor = UIColor(named: themeColor.recentTVCellColor.rawValue)
                bgImage.isHidden = true
            }
            
            if item.pinId > 0 && !IGHelperPromote.isPromotedRoom(room: item) {
                self.unreadCountLabel.isHidden = true
                
//                self.lastMessageStateImage.image = UIImage(named: "IG_Chat_List_Pin")
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
                
                if (item.chatRoom?.peer!.isVerified)! {
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
                unreadCountLabel.backgroundColor = UIColor.unreadLable()
                
            case .mute:
                self.muteLabel.isHidden = false
                unreadCountLabel.backgroundColor = UIColor.darkGray
                
            }
            
            self.nameLabel.text = item.title
            
            switch item.type {
            case .chat:
                if let avatar = item.chatRoom?.peer?.avatar {
                    self.avatarImage.setImage(avatar: avatar, showMain: false)
                }
            case .group:
                if let avatar = item.groupRoom?.avatar {
                    self.avatarImage.setImage(avatar: avatar, showMain: false)
                }
                
            case .channel:
                if let avatar = item.channelRoom?.avatar {
                    self.avatarImage.setImage(avatar: avatar, showMain: false)
                }
            }
            
            if showStateImage {
                self.lastMessageStateImage.isHidden = false
                self.unreadCountLabel.isHidden = true
            } else {
                self.lastMessageStateImage.isHidden = true
                self.unreadCountLabel.isHidden = false
            }
            
//            nameLabel.snp.removeConstraints()
            
            switch item.type {
                
            case .chat:
//                nameLabel.snp.remakeConstraints { (make) in
//                    make.leading.equalTo(self.typeImage.snp.trailing).offset(-20)
//                    make.trailing.equalTo(self.checkImage.snp.leading).offset(-10)
//                    make.top.equalTo(self.avatarImage.snp.top)
//
//                }
                self.lastMessageStateImage.isHidden = false
                
                break
                
            case .group:
//                nameLabel.snp.makeConstraints { (make) in
//                    make.leading.equalTo(self.typeImage.snp.trailing).offset(10)
//                    make.trailing.equalTo(self.checkImage.snp.leading).offset(-10)
//                    make.top.equalTo(self.avatarImage.snp.top)
//
//                }
                self.lastMessageStateImage.isHidden = false
                
                break
                
            case .channel:
//                nameLabel.snp.makeConstraints { (make) in
//                    make.leading.equalTo(self.typeImage.snp.trailing).offset(10)
//                    make.trailing.equalTo(self.checkImage.snp.leading).offset(-10)
//                    make.top.equalTo(self.avatarImage.snp.top)
//
//                }
                self.lastMessageStateImage.isHidden = true
                
                break
            }
            
            if (item.lastMessage?.message) != nil {
                setLastMessage(for: item)
            }
            
            //end
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        unreadCountLabel.backgroundColor = UIColor.red
        
        timeLabel.text = "..."
        nameLabel.text = "..."
        checkImage.image = UIImage(named:"IG_Verify")
        
        self.contentView.addSubview(bgImage)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(lastMsgLabel)
        self.contentView.addSubview(unreadCountLabel)
        self.contentView.addSubview(initialLabel)
        self.contentView.addSubview(avatarImage)
        self.contentView.addSubview(typeImage)
        self.contentView.addSubview(stateImage)
        self.contentView.addSubview(lastMessageStateImage)
        self.contentView.addSubview(checkImage)
        self.contentView.addSubview(muteLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeAvatar()
        makeBGImage()
        makeInitialLabel()
        makeTypeImage()
        makeTimeLabel()
        makeCheckImage()
        makeMuteLabel()
        makeNameLabel()
        makeUnreadCountLabel()
        makeLastMessageLabel()
        
        makelastMessageStateImage()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImage.cancelImageDownloadTask()
        self.avatarImage.sd_cancelCurrentAnimationImagesLoad()
        self.avatarImage.image = nil
        self.nameLabel.text = nil
        self.stateImage.image = nil
        self.unreadCountLabel.text = nil
        self.lastMessageStateImage.image = nil
        self.lastMsgLabel.text = nil
        self.avatarImage.image = UIImage()
        showStateImage = nil
        
        // remove imageview from download list on t on cell reuse
        DispatchQueue.main.async {
            let keys = (imagesMap as NSDictionary).allKeys(for: self.avatarImage) as! [String]
            keys.forEach { (key) in
                imagesMap.removeValue(forKey: key)
            }
        }
    }
    
    
    private func setLastMessage(for room: IGRoom) {
        DispatchQueue.main.async {
            self.lastMsgLabel.textAlignment = self.lastMsgLabel.localizedNewDirection
            
            if let draft = room.draft, (room.draft?.message != "" || room.draft?.replyTo != -1) {
                
                self.lastMsgLabel.text = "DRAFT".localizedNew + " \(draft.message)"
            } else if let lastMessage = room.lastMessage {
                if lastMessage.isDeleted {
                    self.lastMsgLabel.text = "DELETED_MESSAGE".MessageViewlocalizedNew
                    self.lastMessageStateImage.isHidden = true
                    self.unreadCountLabel.isHidden = true
                    
                    return
                } else {
                    if self.showStateImage {
                        self.lastMessageStateImage.isHidden = true
                        self.unreadCountLabel.isHidden = true
                    } else {
                        self.lastMessageStateImage.isHidden = true
                        self.unreadCountLabel.isHidden = false
                    }
                    
                }
                if let forwarded = lastMessage.forwardedFrom {
                    let type = forwarded.type
                    
                    switch type {
                    case .text:
                        self.lastMsgLabel.text = forwarded.message
                        
                    case .audioAndText, .gifAndText, .fileAndText, .imageAndText, .videoAndText:
                        self.lastMsgLabel.text = forwarded.message
//                        if let message = forwarded.message {
//
//                            let markdown = MarkdownParser()
//                            markdown.enabledElements = MarkdownParser.EnabledElements.bold
//                            self.lastMsgLabel.attributedText = markdown.parse(message)
//                            self.lastMsgLabel.font = UIFont.igFont(ofSize: 14.0)
//                            self.lastMsgLabel.textColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
//                        }
                    case .image:
                        self.lastMsgLabel.text = "IMAGES_MESSAGE".MessageViewlocalizedNew
                    case .video:
                        self.lastMsgLabel.text = "VIDEOS_MESSAGE".MessageViewlocalizedNew
                    case .gif:
                        self.lastMsgLabel.text = "GIFS_MESSAGE".MessageViewlocalizedNew
                    case .audio:
                        self.lastMsgLabel.text = "AUDIOS_MESSAGE".MessageViewlocalizedNew
                    case .voice:
                        self.lastMsgLabel.text = "VOICES_MESSAGE".MessageViewlocalizedNew
                    case .file:
                        self.lastMsgLabel.text = "FILES_MESSAGE".MessageViewlocalizedNew
                    case .sticker:
                        self.lastMsgLabel.text = "STICKERS_MESSAGE".MessageViewlocalizedNew
                    case .wallet:
                        if lastMessage.wallet?.type == IGPRoomMessageWallet.IGPType.moneyTransfer.rawValue {
                            self.lastMsgLabel.text = "WALLET_MESSAGE".MessageViewlocalizedNew
                        } else if lastMessage.wallet?.type == IGPRoomMessageWallet.IGPType.payment.rawValue {
                            self.lastMsgLabel.text = "PAYMENT_MESSAGE".MessageViewlocalizedNew
                        } else if lastMessage.wallet?.type == IGPRoomMessageWallet.IGPType.cardToCard.rawValue {
                            self.lastMsgLabel.text = "CARD_TO_CARD_MESSAGE".MessageViewlocalizedNew
                        }
                    default:
                        self.lastMsgLabel.text = "UNKNOWN_MESSAGE".MessageViewlocalizedNew
                        break
                    }
                    
                } else {
                    switch lastMessage.type {
                    case .audioAndText, .gifAndText, .fileAndText, .imageAndText, .videoAndText, .text:
                        self.lastMsgLabel.text = lastMessage.message
//                        if let message = lastMessage.message {
//
//                            let markdown = MarkdownParser()
//                            markdown.enabledElements = MarkdownParser.EnabledElements.bold
//                            self.lastMsgLabel.attributedText = markdown.parse(message)
//                            self.lastMsgLabel.font = UIFont.igFont(ofSize: 14.0)
//                            self.lastMsgLabel.textColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
//                        }
                    case .image:
                        self.lastMsgLabel.text = "IMAGES_MESSAGE".MessageViewlocalizedNew
                    case .video:
                        self.lastMsgLabel.text = "VIDEOS_MESSAGE".MessageViewlocalizedNew
                    case .gif:
                        self.lastMsgLabel.text = "GIFS_MESSAGE".MessageViewlocalizedNew
                    case .audio:
                        self.lastMsgLabel.text = "AUDIOS_MESSAGE".MessageViewlocalizedNew
                    case .voice:
                        self.lastMsgLabel.text = "VOICES_MESSAGE".MessageViewlocalizedNew
                    case .file:
                        self.lastMsgLabel.text = "FILES_MESSAGE".MessageViewlocalizedNew
                    case .sticker:
                        self.lastMsgLabel.text = "STICKERS_MESSAGE".MessageViewlocalizedNew
                    case .wallet:
                        if lastMessage.wallet?.type == IGPRoomMessageWallet.IGPType.moneyTransfer.rawValue {
                            self.lastMsgLabel.text = "WALLET_MESSAGE".MessageViewlocalizedNew
                        } else if lastMessage.wallet?.type == IGPRoomMessageWallet.IGPType.payment.rawValue {
                            self.lastMsgLabel.text = "PAYMENT_MESSAGE".MessageViewlocalizedNew
                        } else if lastMessage.wallet?.type == IGPRoomMessageWallet.IGPType.cardToCard.rawValue {
                            self.lastMsgLabel.text = "CARD_TO_CARD_MESSAGE".MessageViewlocalizedNew
                        }
                    default:
                        self.lastMsgLabel.text = "UNKNOWN_MESSAGE".MessageViewlocalizedNew
                        break
                    }
                }
                if lastMessage.type == .log {
                    self.lastMsgLabel.text = IGRoomMessageLog.textForLogMessage(lastMessage)
                } else if lastMessage.type == .contact {
                    self.lastMsgLabel.text = "CONTACT_MESSAGE".MessageViewlocalizedNew
                } else if lastMessage.type == .location {
                    self.lastMsgLabel.text = "LOCATION_MESSAGE".MessageViewlocalizedNew
                }
            } else {
                self.timeLabel.text = ""
                
                self.lastMsgLabel.text  = ""
            }
            if let lastMessage = room.lastMessage {
                if let senderUser = lastMessage.authorUser {
                    if senderUser.id == IGAppManager.sharedManager.userID() {
                        if self.showStateImage {
                            self.lastMessageStateImage.isHidden = false
                            self.unreadCountLabel.isHidden = true
                        } else {
                            self.lastMessageStateImage.isHidden = true
                            self.unreadCountLabel.isHidden = false
                        }
                    } else {
                        switch room.type {
                            
                        case .chat:
                            if self.showStateImage {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadCountLabel.isHidden = true
                            } else {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadCountLabel.isHidden = false
                                
                            }
                            
                            break
                            
                        case .group:
                            if self.showStateImage {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadCountLabel.isHidden = true
                            } else {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadCountLabel.isHidden = false
                                
                            }
                            break
                            
                        case .channel:
                            if self.showStateImage {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadCountLabel.isHidden = true
                            } else {
                                self.lastMessageStateImage.isHidden = true
                                self.unreadCountLabel.isHidden = false
                                
                            }
                            break
                            
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    private func makeAvatar() {
        avatarImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
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
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-5)
            make.top.equalTo(self.contentView.snp.top).offset(5)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
        }
        bgImage.contentMode = .scaleToFill // image will never be strecthed vertially or horizontally

    }
    private func makeInitialLabel() {
        initialLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
            make.width.equalTo(54)
            make.height.equalTo(54)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
    }
    
    private func makeTypeImage() {
        typeImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.avatarImage.snp.trailing).offset(2)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.top.equalTo(self.avatarImage.snp.top)
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
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-5)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.bottom.equalTo(self.avatarImage.snp.bottom)
        }
    }
    //hide
    
    private func makeTimeLabel() {
        timeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-5)
            make.width.equalTo(50)
            make.top.equalTo(self.avatarImage.snp.top).offset(10)
        }
        
    }
    private func makeCheckImage() {
        checkImage.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.muteLabel.snp.leading).offset(-5)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.top.equalTo(self.avatarImage.snp.top).offset(10)
        }
        
    }
    private func makeMuteLabel() {
        muteLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.timeLabel.snp.leading).offset(-5)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.top.equalTo(self.avatarImage.snp.top).offset(10)
        }
        
    }
    private func makeNameLabel() {
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.typeImage.snp.trailing).offset(10)
            make.trailing.equalTo(self.checkImage.snp.leading).offset(-10)
            make.top.equalTo(self.avatarImage.snp.top)
        }
        
    }
    private func makeUnreadCountLabel() {
        
        
        unreadCountLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            make.bottom.equalTo(self.avatarImage.snp.bottom)
            make.width.equalTo(20)
            make.height.equalTo(15)
            
        }
        unreadCountLabel.text =  unreadCountLabel.text?.inLocalizedLanguage()
        
    }
    
    private func makeLastMessageLabel() {
        lastMsgLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.avatarImage.snp.trailing).offset(5)
            make.trailing.equalTo(self.unreadCountLabel.snp.leading).offset(0)
            make.bottom.equalTo(self.avatarImage.snp.bottom)
        }
        
        
    }
    
    
}
