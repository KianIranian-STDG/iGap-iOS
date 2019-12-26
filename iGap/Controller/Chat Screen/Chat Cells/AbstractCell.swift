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
import RxSwift
import MarkdownKit
import IGProtoBuff
import Lottie
class AbstractCell: IGMessageGeneralCollectionViewCell, UIGestureRecognizerDelegate {
    
    var imgAvatarPay : UIImageViewX!

    var mainBubbleViewAbs: UIView!
    var forwardViewAbs: UIView!
    var replyViewAbs: UIView!
    var mediaContainerViewAbs: UIView?
    var messageViewAbs: UIView?
    var forwardLineViewAbs: UIView!
    var replyLineViewAbs: UIView!
    var viewInfoVideoAbs: UIView!
    var viewSenderNameAbs: UIView!
    var additionalViewAbs: UIView!
    var statusBackgroundViewAbs: UIView!
    
    var txtSenderNameAbs: UILabel!
    var txtStatusAbs: UILabel!
    var txtEditedAbs: UILabel!
    var txtTimeAbs: UILabel!
    var txtReplyDisplayNameAbs: UILabel!
    var txtReplyMessageAbs: UILabel!
    var txtForwardAbs: UILabel!
    var txtTimeVideoAbs: UILabel!
    var txtSizeVideoAbs: UILabel!
    var txtSeenCountAbs: UILabel!
    var txtVoteUpAbs: UILabel!
    var txtVoteDownAbs: UILabel!
    
    var imgFileAbs: UIImageView!
    var txtVideoPlayAbs: UILabel!
    var btnPlayAbs: UIButton!
    var btnReturnToMessageAbs: UIButton!
    
    var txtMessageHeightConstraintAbs: NSLayoutConstraint!
    var mainBubbleViewWidthAbs: NSLayoutConstraint!
    var mainBubbleViewHeightAbs: NSLayoutConstraint!
    var mediaHeightConstraintAbs: NSLayoutConstraint!
    
    var avatarViewAbs: IGAvatarView!
    var txtMessageAbs: ActiveLabel!
    var imgMediaAbs: IGImageView!
    var animationView : AnimationView!

    var indicatorViewAbs: IGProgress!

    var room: IGRoom!
    var realmRoomMessage: IGRoomMessage!
    var finalRoomMessage: IGRoomMessage!
    var messageSizes: MessageCalculatedSize!
    var isIncommingMessage: Bool!
    var shouldShowAvatar: Bool!
    var isPreviousMessageFromSameSender: Bool!
    var isRtl: Bool!
    var hasBottomOffset: Bool!
    
    var leadingAbs: Constraint?
    var trailingAbs: Constraint?
    var imgMediaTopAbs: Constraint!
    var imgMediaHeightAbs: Constraint!
    var swipeGesture: UIPanGestureRecognizer!
    var originalPoint: CGPoint!
    var imgReply: UIImageView!
    var imgMultiForward: UIImageView!
    var btnCheckMark: UIButton!

    let disposeBag = DisposeBag()
    var pan: UIPanGestureRecognizer!
    var tapMulti: UITapGestureRecognizer!
    var isForward = false
    var isReply = false
    
    let cornerRadius: CGFloat = 7.0
    let bubbleSubviewOffset: CGFloat = 3
    let bubbleShadowOffset: CGFloat = 0.6
    let bubbleShadowRadius: CGFloat = 0.3
    let bubbleShadowOpacity: Float = 0.2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        self.backgroundColor = UIColor.clear
        isAvatar = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if !(IGGlobal.shouldMultiSelect) {
            makeSwipeImage()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if !(IGGlobal.shouldMultiSelect) {
            makeSwipeImage()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !(IGGlobal.shouldMultiSelect) {
            swipePositionManager()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.frame = self.bounds
        removeImage()
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        if room.isInvalidated || message.isInvalidated { return }

        self.room = room
        self.realmRoomMessage = message
        self.isIncommingMessage = isIncommingMessage
        self.shouldShowAvatar = shouldShowAvatar
        self.messageSizes = messageSizes
        self.isPreviousMessageFromSameSender = isPreviousMessageFromSameSender

        detectFinalMessage()
        detectRtlAndBottomOffset()
        manageCellBubble()
        manageReceivedOrIncommingMessage()
        manageReply()
        manageForward()
        manageTextMessage()
        manageViewPosition()
        manageLink()
        manageVoteActions()
        manageAttachment()
        manageAdditional()
        manageAvatarPay()
        manageReturnToMessage()
        manageGustureRecognizers()
        showMultiSelect()
    }
    /*
     ******************************************************************
     ********************** Detect Final Message **********************
     ******************************************************************
     */
    
    /* check that exist forward/reply and fill finalMessage with correct value */
    private func detectFinalMessage(){
        if let message = realmRoomMessage.forwardedFrom {
            isForward = true
            isReply = false
            finalRoomMessage = message
        } else if realmRoomMessage.repliedTo != nil {
            isForward = false
            isReply = true
            finalRoomMessage = realmRoomMessage
        } else {
            isForward = false
            isReply = false
            finalRoomMessage = realmRoomMessage
        }
    }
    
    /* check message that should be rtl OR has bottom offset */
    private func detectRtlAndBottomOffset() {

        if let message = finalRoomMessage.message, message.isRTL() {
            isRtl = true
            hasBottomOffset = true

        } else {
            isRtl = false
            if room.type == .channel {
                hasBottomOffset = true
            } else {
                hasBottomOffset = false
            }

        }
    }
    
    /*
     ******************************************************************
     ************************** Message Text **************************
     ******************************************************************
     */
    
    private func removeAvatarPay() {
        if imgAvatarPay != nil {
            imgAvatarPay.image = nil
            imgAvatarPay.backgroundColor = .clear
            imgAvatarPay.contentMode = .scaleAspectFit
            imgAvatarPay.borderColor = .clear
            imgAvatarPay.borderWidth = 0.0
            
        }
        
    }
    private func makeAvatarPay(){
        
        if imgAvatarPay == nil {
            imgAvatarPay = UIImageViewX()
            self.contentView.addSubview(imgAvatarPay)
            imgAvatarPay.image = UIImage(named: "debit-card")
            imgAvatarPay.layer.cornerRadius = 25
            imgAvatarPay.backgroundColor = .white
            imgAvatarPay.layer.masksToBounds = true
            imgAvatarPay.contentMode = .scaleAspectFit
            imgAvatarPay.borderColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
            imgAvatarPay.borderWidth = 2.0
        }
        
        imgAvatarPay.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerX.equalTo(mainBubbleViewAbs.snp.centerX)
            make.top.equalTo(self.contentView.snp.top).offset(0)
            
        }

        txtMessageAbs.snp.remakeConstraints{ (make) in
            make.top.equalTo((imgAvatarPay?.snp.bottom)!).offset(5)
        }
    }
    
    private func manageTextMessage() {

        if finalRoomMessage.type == .sticker {
            return
        }

        if finalRoomMessage.message != nil && finalRoomMessage.message != "" {
            txtMessageAbs?.isHidden = false
            if isIncommingMessage {
                txtMessageAbs?.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

            } else {
                txtMessageAbs?.textColor = ThemeManager.currentTheme.MessageTextColor
            }

            txtMessageHeightConstraintAbs?.constant = messageSizes.bubbleSize.height

            if let additionalData = finalRoomMessage.additional?.data, finalRoomMessage.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue,
                let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncommingMessage || (self.room.type == .chat && !(self.room.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)){
                var messageText = finalRoomMessage.message?.replacingOccurrences(of: "⁣", with: "") // replace with invisible character if exist
                messageText = messageText?.replacingOccurrences(of: "⁣", with: "") // replace with invisible character if exist
                
                let t = finalRoomMessage.additional?.data
                let tmpJsonB = IGHelperJson.parseAdditionalButton(data: t)
                
                let b = tmpJsonB![0][0].valueJson
                let tmpJson = IGHelperJson.parseAdditionalCardToCardInChat(data: b!)
                
                let tt = tmpJson?.amount
                let tmpAmount : Int! = tt
                let attrsRegular = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 14 , weight: .regular)]
                let normalString = NSMutableAttributedString(string: IGStringsManager.Amount.rawValue.localized + " " + String(tmpAmount).inRialFormat().inLocalizedLanguage() + IGStringsManager.Currency.rawValue.localized  + "\n_________________________\n", attributes:attrsRegular)
                let attributedString = NSMutableAttributedString(string: IGStringsManager.Desc.rawValue.localized + " " + messageText!, attributes:  attrsRegular)
                normalString.append(attributedString)
                
                txtMessageAbs.numberOfLines = 0
                txtMessageAbs.lineBreakMode = NSLineBreakMode.byWordWrapping
                txtMessageAbs.attributedText = normalString
                
            } else if let additionalData = finalRoomMessage.additional?.data, finalRoomMessage.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
                let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncommingMessage || (self.room.type == .chat && !(self.room.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
                
                var messageText = finalRoomMessage.message?.replacingOccurrences(of: "⁣", with: "") // replace with invisible character if exist
                messageText = messageText?.replacingOccurrences(of: "⁣", with: "") // replace with invisible character if exist
                txtMessageAbs.numberOfLines = 0
                txtMessageAbs.lineBreakMode = NSLineBreakMode.byWordWrapping
                txtMessageAbs?.text = messageText!
            } else {
                let messageText = finalRoomMessage.message?.replacingOccurrences(of: "⁣", with: "") // replace with invisible character if exist
                if messageText!.contains("**") {
                    txtMessageAbs?.text = messageText?.replacingOccurrences(of: "**", with: "⁣") // replace '**' with invisible character
                } else {
                    txtMessageAbs.font = UIFont.igFont(ofSize: fontDefaultSize)
                    txtMessageAbs?.text = messageText!
                }
            }
            
            if isRtl {
                txtMessageAbs.textAlignment = NSTextAlignment.right
            } else {
                txtMessageAbs.textAlignment = NSTextAlignment.left
            }
        } else {
            txtMessageAbs?.isHidden = true
        }
    }
    
    /*
     ******************************************************************
     ********************** Manage View Positions *********************
     ******************************************************************
     */
    
    private func manageViewPosition() {
        
        if txtMessageAbs == nil && finalRoomMessage.type != .sticker {
            return
        }
        
        if finalRoomMessage.attachment == nil && finalRoomMessage.type != .sticker {
            if isForward {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if hasBottomOffset {
                        make.top.equalTo((forwardViewAbs?.snp.bottom)!).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo((forwardViewAbs?.snp.bottom)!)
                    }
                }
            } else if isReply {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if hasBottomOffset {
                        make.top.equalTo((replyViewAbs?.snp.bottom)!).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo((replyViewAbs?.snp.bottom)!)
                    }
                }
            } else {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if hasBottomOffset {
                        make.top.equalTo(mainBubbleViewAbs.snp.top).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo(mainBubbleViewAbs.snp.top).offset(8)
                    }
                }
            }
            
            removeImage()
            
        } else {
            switch (finalRoomMessage.type) {
            case .sticker:
                if (finalRoomMessage.attachment?.name!.hasSuffix(".json") ?? false) {
                    print("YESS LIVE STICKER")
                    makeAnimationView(attachmentJson: finalRoomMessage.attachment! )
                } else {
                    print("YESS NORMAL STICKER")
                    makeImage(.sticker)

                }
                break
                
            case .image, .video, .gif:

                makeImage(finalRoomMessage.type)
                
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                }
                
                break
            case .imageAndText, .videoAndText, .gifAndText:

                makeImage(finalRoomMessage.type)
                
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if hasBottomOffset {
                        make.top.equalTo(imgMediaAbs.snp.bottom).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo(imgMediaAbs.snp.bottom)
                    }
                }
                break
                
                
            case .voice:
                break
            
                
            case .audio:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                }
                break
            case .audioAndText:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if hasBottomOffset {
                        make.top.equalTo(btnPlayAbs.snp.bottom).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo(btnPlayAbs.snp.bottom)
                    }
                }
                break
                
                
            case .file:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                }
                break
            case .fileAndText:
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if hasBottomOffset {
                        make.top.equalTo(imgFileAbs.snp.bottom).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo(imgFileAbs.snp.bottom)
                    }
                }
                break
                
                
            default:
                break
            }
        }
    }
    
    /*
     ******************************************************************
     ****************************** Time ******************************
     ******************************************************************
     */
    
    private func manageTime(statusExist: Bool){
        if let time = realmRoomMessage.creationTime {
            makeTime(statusExist: statusExist)
            txtTimeAbs?.text = time.convertToHumanReadable()
        }
        if isIncommingMessage {
            txtTimeAbs.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

        } else {
            txtTimeAbs.textColor = UIColor.chatTimeTextColor()
        }

    }
    
    /*
     ******************************************************************
     ****************************** Edit ******************************
     ******************************************************************
     */
    
    private func manageEdit() {
        if realmRoomMessage.isEdited {
            makeEdit()
        } else {
            removeEdit()
        }
    }
    
    /*
     ******************************************************************
     ************************* Status Manager *************************
     ******************************************************************
     */
    
    private func manageMessageStatus(){
        makeStatus()
        
        switch realmRoomMessage.status {
        case .sending:
            txtStatusAbs.text = ""
            if isIncommingMessage {
                txtStatusAbs.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

            } else {
                txtStatusAbs.textColor = ThemeManager.currentTheme.LabelColor
            }
            txtStatusAbs.backgroundColor = UIColor.clear
            break
        case .sent:
            txtStatusAbs.text = ""
            if isIncommingMessage {
                txtStatusAbs.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

            } else {
                txtStatusAbs.textColor = ThemeManager.currentTheme.LabelColor
            }
            txtStatusAbs.backgroundColor = UIColor.clear
            break
        case .delivered:
            txtStatusAbs.text = ""
            if isIncommingMessage {
                txtStatusAbs.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

            } else {
                txtStatusAbs.textColor = ThemeManager.currentTheme.LabelColor
            }
            txtStatusAbs.backgroundColor = UIColor.clear
            break
        case .seen,.listened:
            txtStatusAbs.text = ""
            if isIncommingMessage {
                txtStatusAbs.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

            } else {
                let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
                let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
                let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

                if currentTheme == "IGAPDay" || currentTheme == "IGAPNight" {
                    
                    if currentColorSetLight == "IGAPBlack" {
                        txtStatusAbs.textColor = .iGapGreen()
                    } else {
                        txtStatusAbs.textColor = .iGapGreen()
                    }

                } else {
                    txtStatusAbs.textColor = .iGapGreen()
                }
            }

            txtStatusAbs.backgroundColor = UIColor.clear
            break
        case .failed, .unknown:
            txtStatusAbs.text = ""
            txtStatusAbs.textColor = UIColor.white
            txtStatusAbs.layer.masksToBounds = true
            txtStatusAbs.layer.cornerRadius = 10
            txtStatusAbs.backgroundColor = UIColor.failedColor()
            break
        }
    }
    
    /** add background layout for message status and time if needed */
    private func manageStatusBackgroundLayout() {
        if finalRoomMessage.type == .sticker || finalRoomMessage.additional?.dataType == AdditionalType.STICKER.rawValue {
            makeStatusBackground()
            
            if txtStatusAbs != nil {
                if realmRoomMessage.status == .sending || realmRoomMessage.status == .sent || realmRoomMessage.status == .delivered {
                    if isIncommingMessage {
                        txtStatusAbs.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

                    } else {
                        txtStatusAbs.textColor = ThemeManager.currentTheme.LabelColor
                    }
                }
                mainBubbleViewAbs.bringSubviewToFront(txtStatusAbs)
            }
            
            if txtTimeAbs != nil {
                mainBubbleViewAbs.bringSubviewToFront(txtTimeAbs)
            }
            if isIncommingMessage {
                txtTimeAbs?.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

            } else {
                txtTimeAbs?.textColor = ThemeManager.currentTheme.LabelColor
                let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
                let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
                let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

                if currentTheme == "IGAPDay" || currentTheme == "IGAPNight" {
                    
                    if currentColorSetLight == "IGAPBlack" {
                        txtTimeAbs.textColor = .white
                    } else {
                        txtTimeAbs?.textColor = ThemeManager.currentTheme.LabelColor
                    }

                } else {
                    txtTimeAbs?.textColor = ThemeManager.currentTheme.LabelColor
                }

            }

            if txtEditedAbs != nil {
                txtEditedAbs?.textColor = UIColor.white
                mainBubbleViewAbs.bringSubviewToFront(txtEditedAbs)
            }
            
        } else {
            if isIncommingMessage {
                txtTimeAbs?.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

            } else {
                txtTimeAbs?.textColor = ThemeManager.currentTheme.LabelColor
            }

            txtEditedAbs?.textColor = UIColor.chatTimeTextColor()
        }
    }
    
    /*
     ******************************************************************
     *************************** Set Avatar ***************************
     ******************************************************************
     */
    
    private func setAvatar(){
        
        if shouldShowAvatar && !isPreviousMessageFromSameSender {
            
            makeAvatar()
            
            if let user = realmRoomMessage.authorUser?.user {
                avatarViewAbs.avatarImageView?.backgroundColor = UIColor.clear
                avatarViewAbs.setUser(user)
            } else if let userId = realmRoomMessage.authorUser?.userId {
                avatarViewAbs.avatarImageView?.backgroundColor = UIColor.white
                avatarViewAbs.avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
                IGMessageViewController.messageOnChatReceiveObserver.onFetchUserInfo(userId: userId)
            }
            
        } else {
            removeAvatar()
        }
    }
    
    /*
     ******************************************************************
     ********** Detect and Manage Received/Incomming Message **********
     ******************************************************************
     */
    
    private func manageReceivedOrIncommingMessage(){
        if self.room.type == .channel {
            
            manageTime(statusExist: false)
            if let signature = self.finalRoomMessage.channelExtra?.signature, !signature.isEmpty {
                makeSenderName()
                txtSenderNameAbs.text = signature
            } else {
                removeSenderName()
            }
            return
        }
        
        if isIncommingMessage {

            if isPreviousMessageFromSameSender {
                removeSenderName()
            } else if self.room.type != .chat {
                makeSenderName()

                if let user = realmRoomMessage.authorUser?.user {
                    txtSenderNameAbs.text = user.displayName
                } else if let sender = realmRoomMessage.authorRoom {
                    txtSenderNameAbs.text = sender.title
                } else {
                    txtSenderNameAbs.text = ""
                }
            }

            removeStatus()
            manageTime(statusExist: false)
            setAvatar()
            
        } else {
            
            removeAvatar()
            removeSenderName()
            manageTime(statusExist: true)
            manageMessageStatus()
        }
        
        manageEdit()
        manageStatusBackgroundLayout()
    }
    
    private func manageCellBubble() {
      
        /************ Bubble View ************/
        mainBubbleViewAbs.layer.cornerRadius = cornerRadius
        mainBubbleViewAbs.layer.shadowColor = UIColor.black.cgColor
        mainBubbleViewAbs.layer.shadowRadius = bubbleShadowRadius
        mainBubbleViewAbs.layer.shadowOpacity = bubbleShadowOpacity
        mainBubbleViewAbs.layer.masksToBounds = false
        
        if finalRoomMessage.type == .sticker || finalRoomMessage.type == .location {
            mainBubbleViewAbs.backgroundColor = UIColor.clear
        } else {
            mainBubbleViewAbs.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
        }
        
        /************ Bubble Size ************/
        mainBubbleViewWidthAbs.constant = messageSizes.bubbleSize.width
        mainBubbleViewHeightAbs.constant = messageSizes.bubbleSize.height - 18
        
        /********* Bubble Direction *********/
        mainBubbleViewAbs.snp.makeConstraints { (make) in
            
            if leadingAbs != nil { leadingAbs?.deactivate() }
            if trailingAbs != nil { trailingAbs?.deactivate() }
            
            if isIncommingMessage {
                mainBubbleViewAbs.layer.shadowOffset = CGSize(width: bubbleShadowOffset, height: bubbleShadowOffset)
                
                if #available(iOS 11.0, *) {
                    if room.type == .group {
                        if isPreviousMessageFromSameSender {
                            mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                        } else {
                            mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                        }
                    } else if room.type == .channel, let signature = self.finalRoomMessage.channelExtra?.signature, !signature.isEmpty {
                        mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    } else {
                        mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                    }
                }
                
                if shouldShowAvatar {
                    leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(66).priority(999).constraint
                } else {
                    if IGGlobal.shouldMultiSelect {
                        leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(36).priority(999).constraint
                    } else {
                        leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(16).priority(999).constraint
                    }
                }
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(250).constraint
                
            } else {
                mainBubbleViewAbs.layer.shadowOffset = CGSize(width: -bubbleShadowOffset, height: bubbleShadowOffset)
                
                if #available(iOS 11.0, *) {
                    mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(999).constraint
                leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(46).priority(250).constraint
            }
            
            if let additionalData = finalRoomMessage.additional?.data, finalRoomMessage.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue,
                let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncommingMessage || (self.room.type == .chat && !(self.room.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)){
                self.mainBubbleViewAbs.roundCorners(corners: [.layerMaxXMinYCorner,.layerMinXMinYCorner], radius: 10)
                
            } else if let additionalData = finalRoomMessage.additional?.data, finalRoomMessage.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
                let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncommingMessage || (self.room.type == .chat && !(self.room.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)){
            }
            
            if leadingAbs != nil {
                leadingAbs?.activate()
            }
            if trailingAbs != nil {
                trailingAbs?.activate()
            }
        }
        /************ Add multi Forward icon only in Rooms ************/
        if room.type == .channel {
            makeMultiForwardIconInRooms()
        }
    }
    
    /*
     ******************************************************************
     ************************** Link Manager **************************
     ******************************************************************
     */
    private func manageLink() {
        linkManager(txtMessage: txtMessageAbs)
    }
    
    private func linkManager(txtMessage: ActiveLabel?){
        if txtMessage == nil {
            return
        }
        txtMessage?.font = UIFont.igFont(ofSize: fontDefaultSize)
        txtMessage?.customize {(lable) in
            if isIncommingMessage {
                lable.EmailColor = ThemeManager.currentTheme.MessageTextReceiverColor
            } else {
                lable.EmailColor = UIColor.iGapLink()
            }
            if isIncommingMessage {
                lable.hashtagColor = ThemeManager.currentTheme.MessageTextReceiverColor
            } else {
                lable.hashtagColor = UIColor.iGapLink()
            }
            if isIncommingMessage {
                lable.mentionColor = ThemeManager.currentTheme.MessageTextReceiverColor
            } else {
                lable.mentionColor = UIColor.iGapLink()
            }
            if isIncommingMessage {
                lable.URLColor = ThemeManager.currentTheme.MessageTextReceiverColor
            } else {
                lable.URLColor = UIColor.iGapLink()
            }
            if isIncommingMessage {
                lable.botColor = ThemeManager.currentTheme.MessageTextReceiverColor
            } else {
                lable.botColor = UIColor.iGapLink()
            }

            

            if !IGGlobal.shouldMultiSelect {
                lable.handleURLTap { url in
                    self.delegate?.didTapOnURl(url: url)
                }
                
                lable.handleDeepLinkTap({ (deepLink) in
                     self.delegate?.didTapOnDeepLink(url: deepLink)
                })

                lable.handleEmailTap { email in
                    self.delegate?.didTapOnEmail(email: email.absoluteString)
                }

                lable.handleBotTap {bot in
                    self.delegate?.didTapOnBotAction(action: bot)
                }

                lable.handleMentionTap { mention in
                    self.delegate?.didTapOnMention(mentionText: mention )
                }

                lable.handleHashtagTap { hashtag in
                    self.delegate?.didTapOnHashtag(hashtagText: hashtag)
                }

            }
        }
    }
    
    /*
     ******************************************************************
     *********************** Gesture Recognizer ***********************
     ******************************************************************
     */
    
    func manageGustureRecognizers() {
        if !IGGlobal.shouldMultiSelect  {
            if mainBubbleViewAbs != nil {
                let tapAndHold = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnCell(_:)))
                tapAndHold.minimumPressDuration = 0.2
                mainBubbleViewAbs.addGestureRecognizer(tapAndHold)
                
                /*
                if self.attachment != nil {
                    let tapOnCell = UITapGestureRecognizer(target: self, action: #selector(didTapAttachmentOnCell(_:)))
                    mainBubbleViewAbs.addGestureRecognizer(tapOnCell)
                }
                */
                
                mainBubbleViewAbs.isUserInteractionEnabled = true
            }
            
            if replyViewAbs != nil {
                let onReplyClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnReply(_:)))
                replyViewAbs.addGestureRecognizer(onReplyClick)
                replyViewAbs.isUserInteractionEnabled = true
                if !(IGGlobal.shouldMultiSelect) {
                    replyViewAbs.isUserInteractionEnabled = true

                }
                else {
                    replyViewAbs.isUserInteractionEnabled = false

                }
            }
            
            if forwardViewAbs != nil {
                let onForwardClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnForward(_:)))
                forwardViewAbs.addGestureRecognizer(onForwardClick)
                if !(IGGlobal.shouldMultiSelect) {
                    forwardViewAbs.isUserInteractionEnabled = true
                }
                else {
                    forwardViewAbs.isUserInteractionEnabled = false
                }
            }
            
            if imgFileAbs != nil {
                let onFileClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                imgFileAbs.addGestureRecognizer(onFileClick)
                
                if !(IGGlobal.shouldMultiSelect) {
                    imgFileAbs.isUserInteractionEnabled = true
                }
                else {
                    imgFileAbs.isUserInteractionEnabled = false
                }
            }
            
            if mediaContainerViewAbs != nil {
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                mediaContainerViewAbs?.addGestureRecognizer(tap1)
                if !(IGGlobal.shouldMultiSelect) {
                    mediaContainerViewAbs?.isUserInteractionEnabled = true
                }
                else {
                    mediaContainerViewAbs?.isUserInteractionEnabled = false
                }
            }

            if imgMediaAbs != nil {
                let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                imgMediaAbs?.addGestureRecognizer(tap2)
                if !(IGGlobal.shouldMultiSelect) {
                    imgMediaAbs?.isUserInteractionEnabled = true
                }
                else {
                    imgMediaAbs?.isUserInteractionEnabled = false
                }
            }
            
            if btnReturnToMessageAbs != nil {
                let tapReturnToMessage = UITapGestureRecognizer(target: self, action: #selector(didTapOnReturnToMessage(_:)))
                btnReturnToMessageAbs?.addGestureRecognizer(tapReturnToMessage)
            }
            
            let statusGusture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFailedStatus(_:)))
            txtStatusAbs?.addGestureRecognizer(statusGusture)
            txtStatusAbs?.isUserInteractionEnabled = true
            
            let tap5 = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
            avatarViewAbs?.addGestureRecognizer(tap5)
            
            let tapVoteUp = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteUp(_:)))
            txtVoteUpAbs?.addGestureRecognizer(tapVoteUp)
            txtVoteUpAbs?.isUserInteractionEnabled = true
            
            let tapVoteDown = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteDown(_:)))
            txtVoteDownAbs?.addGestureRecognizer(tapVoteDown)
            txtVoteDownAbs?.isUserInteractionEnabled = true

        }
    }
    
    @objc func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if !(IGGlobal.shouldMultiSelect) {
                self.delegate?.didTapAndHoldOnMessage(cellMessage: realmRoomMessage!, cell: self)
            }
        default:
            break
        }
    }
    
    func didTapAttachmentOnCell(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            if finalRoomMessage.attachment != nil {
                didTapOnAttachment(gestureRecognizer)
            }
        }
    }
    
    @objc func onMultiForwardTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnMultiForward(cellMessage: realmRoomMessage!, cell: self)
    }

    @objc func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.delegate?.didTapOnAttachment(cellMessage: realmRoomMessage!, cell: self, imageView: imgMediaAbs)
        }
    }
    
    @objc func didTapOnReply(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.delegate?.didTapOnReply(cellMessage: realmRoomMessage!, cell: self)
        }
    }
    
    @objc func didTapOnForward(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForward(cellMessage: realmRoomMessage!, cell: self)
    }
    
    @objc func didTapOnReturnToMessage(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnReturnToMessage()
    }
    
    @objc func didTapOnFailedStatus(_ gestureRecognizer: UITapGestureRecognizer) {
        if realmRoomMessage.status == .failed {
            self.delegate?.didTapOnFailedStatus(cellMessage: realmRoomMessage!)
        }
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForwardedAttachment(cellMessage: realmRoomMessage!, cell: self)
        
    }
    
    @objc func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.delegate?.didTapOnSenderAvatar(cellMessage: realmRoomMessage!, cell: self)
        }
    }
    
    @objc func didTapOnVoteUp(_ gestureRecognizer: UITapGestureRecognizer) {
        var messageVote: IGRoomMessage! = self.realmRoomMessage
        if let forward = self.realmRoomMessage.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
            messageVote = forward
        }
        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsUp)
    }
    
    @objc func didTapOnVoteDown(_ gestureRecognizer: UITapGestureRecognizer) {
        var messageVote: IGRoomMessage! = self.realmRoomMessage
        if let forward = self.realmRoomMessage.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
            messageVote = forward
        }
        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsDown)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if pan != nil {
            let direction = pan.direction(in: superview!)
            if direction.contains(.Left) {
                return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
            } else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    /*
     ******************************************************************
     ************************** Swipe to Reply ************************
     ******************************************************************
     */
    
    private func makeSwipeImage() {
        self.backgroundColor = UIColor.clear
        imgReply = UIImageView()
        imgReply.contentMode = .scaleAspectFit
        imgReply.image = UIImage(named: "ig_message_reply")
        imgReply.alpha = 0.5
        if !(IGGlobal.shouldMultiSelect) {
            pan = UIPanGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
            pan.delegate = self
            self.addGestureRecognizer(pan)
        }
    }
    
    private func swipePositionManager(){
        if room.isInvalidated {
            return
        }
        if room.type == .chat || self.room.type == .group {
            if pan != nil {
                
                if (pan.state == UIGestureRecognizer.State.changed) {
                    self.insertSubview(imgReply, belowSubview: self.contentView)
                    let p: CGPoint = pan.translation(in: self)
                    let width = self.contentView.frame.width
                    let height = self.contentView.frame.height
                    self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height);
                    self.imgReply.frame = CGRect(x: p.x + width + imgReply.frame.size.width, y: (height/2) - (imgReply.frame.size.height) / 2 , width: CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT), height: CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT))
                    
                } else if (pan.state == UIGestureRecognizer.State.ended) || (pan.state == UIGestureRecognizer.State.cancelled) {
                    self.imgReply.removeFromSuperview()
                }
            }
            else {
                return
            }
        }
    }
    
    @objc func onSwipe(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizer.State.began {
            
        } else if pan.state == UIGestureRecognizer.State.changed {
            self.setNeedsLayout()
        } else {
            //let hasMovedToFarLeft = self.frame.maxX < UIScreen.main.bounds.width / 2
            let shouldReply = abs(pan.velocity(in: self).x) > UIScreen.main.bounds.width / 2
            let direction = pan.direction(in: superview!)
            
            if direction.contains(.Left) {
                switch realmRoomMessage.status {

                case .failed, .unknown , .sending:
                    UIView.animate(withDuration: 0.2, animations: {
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
                    })
                    break
                default :
                    if (shouldReply) {
                        let collectionView: UICollectionView = self.superview as! UICollectionView
                        let indexPath: IndexPath = collectionView.indexPathForItem(at: self.center)!
                        collectionView.delegate?.collectionView!(collectionView, performAction: #selector(onSwipe(_:)), forItemAt: indexPath, withSender: nil)
                        UIView.animate(withDuration: 0.2, animations: {
                            self.setNeedsLayout()
                            self.delegate?.swipToReply(cellMessage: self.realmRoomMessage!, cell: self)
                            self.layoutIfNeeded()
                        })
                        
                    } else {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.setNeedsLayout()
                            self.layoutIfNeeded()
                        })
                    }
                    break
                }

            } else if direction.contains(.Down) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func hideReplyImage() {
        self.imgReply.isHidden = true
    }
    
    func showReplyImage() {
        self.imgReply.isHidden = false
    }
    
    /*
     ******************************************************************
     ****************************** Reply *****************************
     ******************************************************************
     */
    
    private func manageReply(){
        if let repliedMessage = realmRoomMessage.repliedTo {
            
            makeReply()
            
            if let user = repliedMessage.authorUser?.user {
                txtReplyDisplayNameAbs.text = user.displayName
            } else if let room = repliedMessage.authorRoom {
                txtReplyDisplayNameAbs.text = room.title
            }
            
            let body = repliedMessage.message
            
            if repliedMessage.type == .contact {
                txtReplyMessageAbs.text = IGStringsManager.ContactMessage.rawValue.localized
            } else if repliedMessage.type == .location {
                txtReplyMessageAbs.text = IGStringsManager.LocationMessage.rawValue.localized
            } else if body != nil && !(body?.isEmpty)! {
                
                if repliedMessage.type == .sticker {
                    txtReplyMessageAbs.text = body! + IGStringsManager.Sticker.rawValue.localized
                } else {
                    let markdown = MarkdownParser()
                    markdown.enabledElements = MarkdownParser.EnabledElements.bold
                    txtReplyMessageAbs.attributedText = markdown.parse(body!)
                    txtReplyMessageAbs.textColor = UIColor.chatReplyToMessageBodyLabelTextColor(isIncommingMessage: isIncommingMessage)
                    txtReplyMessageAbs.font = UIFont.igFont(ofSize: 13.0)
                }
                
            } else if let media = repliedMessage.attachment {
                txtReplyMessageAbs.text = "\(IGFile.convertFileTypeToString(fileType: media.type))"
            } else {
                txtReplyMessageAbs.text = ""
            }
            
        } else {
            removeReply()
        }
    }
    
    /*
     ******************************************************************
     ***************************** Forward ****************************
     ******************************************************************
     */
    
    func manageForward(){
        
        if let originalMessage = realmRoomMessage.forwardedFrom {
            
            makeForward()
            
            if let authorUser = originalMessage.authorUser {
                if let user = authorUser.user {
                    txtForwardAbs.text = IGStringsManager.ForwardedFrom.rawValue.localized + " \(user.displayName)"
                } else {
                    IGMessageViewController.messageOnChatReceiveObserver.onFetchUserInfo(userId: authorUser.userId)
                }
            } else if let room = originalMessage.authorRoom {
                txtForwardAbs.text = IGStringsManager.ForwardedFrom.rawValue.localized + " \(room.title != nil ? room.title! : "")"
            } else {
                txtForwardAbs.text = IGStringsManager.ForwardedFrom.rawValue.localized
            }

            let text = originalMessage.message
            if text != nil && text != "" && originalMessage.type != .sticker {
                txtMessageAbs.text = text
            }

        } else {
            removeForward()
        }
    }
    
    /*
     ******************************************************************
     ************************ Manage Attachment ***********************
     ******************************************************************
     */
    
    private func manageAttachment(file: IGFile? = nil){
        
        if finalRoomMessage.type == .sticker || finalRoomMessage.additional?.dataType == AdditionalType.STICKER.rawValue {
            removeVoteAction()
            if let stickerStruct = IGHelperJson.parseStickerMessage(data: (finalRoomMessage.additional?.data)!) {
                //IGGlobal.imgDic[stickerStruct.token!] = self.imgMediaAbs
                DispatchQueue.main.async {
                    IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerStruct.token) { (file) in
                        
                        if (self.finalRoomMessage.attachment?.name!.hasSuffix(".json") ?? false) {
                            print("YESS LIVE STICKER")
                            self.animationView.setLiveSticker(for: file)
                        } else {
                            print("YESS NORMAL STICKER")
                            self.imgMediaAbs?.setSticker(for: file)

                        }

                        /*
                        if let imageView = IGGlobal.imgDic[stickerStruct.token!] {
                            imageView.setSticker(for: file)
                        }
                        */
                    }
                }
            }
            return
        }
        
        if var attachment = finalRoomMessage.attachment , !(attachment.isInvalidated) {
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                self.attachment = attachmentVariableInCache.value
            } else {
                //self.attachment = attachment.detach()
                //let attachmentRef = ThreadSafeReference(to: attachment)
                IGAttachmentManager.sharedManager.add(attachment: attachment)
                if let variable = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                    self.attachment = variable.value
                } else {
                    self.attachment = attachment
                }
            }
            
            /* Rx Start */
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                attachment = variableInCache.value
                
                if let disposable = IGGlobal.dispoasDic[self.realmRoomMessage.id] {
                    IGGlobal.dispoasDic.removeValue(forKey: self.realmRoomMessage.id)
                    disposable.dispose() 
                }
                let subscriber = variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                })
                IGGlobal.dispoasDic[self.realmRoomMessage.id] = subscriber
            }
            /* Rx End */
            
            switch (finalRoomMessage.type) {
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                if !(attachment.isInvalidated) {
                    imgMediaAbs.setThumbnail(for: attachment)
                    if attachment.status != .ready {
                        indicatorViewAbs?.delegate = self
                    }
                    break
                }
            default:
                break
            }
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if finalRoomMessage.isInvalidated || (self.attachment?.isInvalidated)! {
            return
        }
        
        if let attachment = self.attachment {
            let fileExist = IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size)
            if fileExist && !attachment.isInUploadLevels() {
                if finalRoomMessage.type == .video || finalRoomMessage.type == .videoAndText {
                    makeVideoPlayView()
                }
                
                indicatorViewAbs?.setState(.ready)
                if attachment.type == .gif {
                    attachment.loadData()
                    if let data = attachment.data {
                        imgMediaAbs?.prepareForAnimation(withGIFData: data)
                        imgMediaAbs?.startAnimatingGIF()
                    }
                } else if attachment.type == .image {
                    imgMediaAbs?.setThumbnail(for: attachment)
                }
                return
            }
            
            if self.isIncommingMessage || !fileExist {
                indicatorViewAbs?.setFileType(.download)
            } else {
                indicatorViewAbs?.setFileType(.upload)
            }
            indicatorViewAbs?.setState(attachment.status)
            if attachment.status == .downloading || attachment.status == .uploading {
                indicatorViewAbs?.setPercentage(attachment.downloadUploadPercent)
            }
        }
    }

    /*
     ******************************************************************
     ************************ Manage Additional ***********************
     ******************************************************************
     */
    
    private func manageAdditional(){
        
        if realmRoomMessage.forwardedFrom != nil {
            removeAdditionalView()
            return
        }
        
        if let additionalView = IGHelperBot.createdViewDic[realmRoomMessage.id] {
            DispatchQueue.main.async {
                self.makeAdditionalView(additionalView: additionalView, removeView: false,isBot: true)
            }
        } else if let additionalData = finalRoomMessage.additional?.data, finalRoomMessage.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
            let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncommingMessage || (self.room.type == .chat && !(self.room.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)){
            
            let additionalView = IGHelperBot.shared.makeBotView(additionalArrayMain: additionalStruct)
            IGHelperBot.createdViewDic[self.realmRoomMessage.id] = additionalView
            self.makeAdditionalView(additionalView: additionalView)
            
        } else if let additionalData = finalRoomMessage.additional?.data, finalRoomMessage.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue,
            let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncommingMessage || (self.room.type == .chat && !(self.room.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)){
            
            let additionalView = IGHelperBot.shared.makeBotView(additionalArrayMain: additionalStruct)
            IGHelperBot.createdViewDic[self.realmRoomMessage.id] = additionalView
            self.makeAdditionalView(additionalView: additionalView)
            
        } else {
            removeAdditionalView()
        }
    }
    
    /*
    ******************************************************************
    *************************** Avatar Pay ***************************
    ******************************************************************
    */
    
    private func manageAvatarPay(){
        if finalRoomMessage.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue {
            makeAvatarPay()
        } else {
            removeAvatarPay()
        }
    }
    
    /*
    ******************************************************************
    ******************** Manage Return To Message ********************
    ******************************************************************
    */
    
    /** after click of reply header and show message add a view for return to selected message again */
    private func manageReturnToMessage(){
        if IGMessageViewController.highlightMessageId == realmRoomMessage.id {
            makeReturnToMessageView()
        } else {
            removeReturnToMessageView()
        }
    }
    
    /*
     ******************************************************************
     ****************** Update Channel Message State ******************
     ******************************************************************
     */
    
    /* this method update message just for channel */
    private func manageVoteActions(){
        
        if self.finalRoomMessage.channelExtra != nil {
            var messageVote: IGRoomMessage! = self.realmRoomMessage
            if let forward = self.realmRoomMessage.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
               messageVote = forward
            }
            
            makeViewCount()
            let attributedString = NSMutableAttributedString(string: "\(messageVote.channelExtra?.viewsLabel ?? "1")", attributes: nil)
            let icon = (attributedString.string as NSString).range(of: "")
            attributedString.setAttributes([NSAttributedString.Key.baselineOffset: 0], range: icon)
            txtSeenCountAbs.attributedText = attributedString
            
            if let channel = messageVote.authorRoom?.channelRoom, channel.hasReaction {
                makeVoteAction()
                let attributedVoteUp = NSMutableAttributedString(string: "\(messageVote.channelExtra?.thumbsUpLabel ?? "0")", attributes: nil)
                let textVoteUp = (attributedVoteUp.string as NSString).range(of: "\(messageVote.channelExtra?.thumbsUpLabel ?? "0")")
                attributedVoteUp.addAttributes([NSAttributedString.Key.baselineOffset: 1], range: textVoteUp)
                txtVoteUpAbs.attributedText = attributedVoteUp
                //txtVoteUpAbs.text = "\(messageVote.channelExtra?.thumbsUpLabel ?? "0")"
                
                let attributedVoteDown = NSMutableAttributedString(string: "\(messageVote.channelExtra?.thumbsDownLabel ?? "0")", attributes: nil)
                let textVoteDown = (attributedVoteDown.string as NSString).range(of: "\(messageVote.channelExtra?.thumbsDownLabel ?? "0")")
                attributedVoteDown.addAttributes([NSAttributedString.Key.baselineOffset: 1], range: textVoteDown)
                txtVoteDownAbs.attributedText = attributedVoteDown
                //txtVoteDownAbs.text = "\(messageVote.channelExtra?.thumbsDownLabel ?? "0")"
            } else {
                removeVoteAction()
            }
            
            var roomId = messageVote.authorRoom?.id
            if roomId == nil {
                roomId = messageVote.roomId
            }
            IGHelperGetMessageState.shared.getMessageState(roomId: roomId!, messageId: messageVote.id)
        } else {
            removeVoteAction()
            removeSeenCount()
        }
    }
    
    /*
     ************************************************************************************************************************************
     ******************************* View Maker (all methods for programmatically create cell view is here) *****************************
     ************************************************************************************************************************************
     */
    private func makeMultiForwardIconInRooms() {
        if imgMultiForward == nil {
            imgMultiForward = UIImageView()
            imgMultiForward.contentMode = .scaleAspectFit
            imgMultiForward.image = UIImage(named: "ig_message_forward")
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.onMultiForwardTap(_:)))
            imgMultiForward.addGestureRecognizer(tap)
            imgMultiForward.isUserInteractionEnabled = true
            
            if room.type == .channel {
                imgMultiForward.alpha = 0.5
                
                self.contentView.addSubview(imgMultiForward)
                self.contentView.bringSubviewToFront(imgMultiForward)
                
                
                
                imgMultiForward.snp.makeConstraints{ (make) in
                    make.leading.equalTo(mainBubbleViewAbs.snp.trailing).offset(2)
                    make.bottom.equalTo(mainBubbleViewAbs.snp.bottom).offset(-5)
                    make.height.equalTo(CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT))
                    make.width.equalTo(CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT))
                }
                
            }
        }
        
    }
    func showMultiSelect() {
        
        if IGGlobal.shouldMultiSelect {
            makeMultiSelectButton()
        }
        else {
            removeMultySelect()
        }
    }
    func removeMultySelect() {
        if btnCheckMark != nil {
            
            self.btnCheckMark.removeFromSuperview()
            self.btnCheckMark = nil
        }

    }
    private func makeMultiSelectButton() {
        removeMultySelect()
        
        if btnCheckMark == nil {
            btnCheckMark = UIButton()
            btnCheckMark.setTitleColor(UIColor.iGapDarkGray(), for: .normal)
            btnCheckMark.titleLabel!.textAlignment = .center
            btnCheckMark.titleLabel?.font = UIFont.iGapFonticon(ofSize: 17.0)
            btnCheckMark.setTitle("", for: .normal)
            btnCheckMark.isUserInteractionEnabled = true
            self.contentView.addSubview(btnCheckMark)
        }
        
        btnCheckMark.snp.makeConstraints{ (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(0)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
            make.height.equalTo(CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT))
            make.width.equalTo(CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT))
        }

    }
    
    private func makeSenderName(){
        
        if viewSenderNameAbs == nil {
            viewSenderNameAbs = UIView()
            viewSenderNameAbs.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
            viewSenderNameAbs.layer.cornerRadius = cornerRadius
            if #available(iOS 11.0, *) {
                viewSenderNameAbs.layer.maskedCorners = [.layerMaxXMinYCorner]
            }
            self.contentView.addSubview(viewSenderNameAbs)

            txtSenderNameAbs = UILabel()
            txtSenderNameAbs.lineBreakMode = .byTruncatingMiddle
            txtSenderNameAbs.textColor = UIColor.messageText()
            txtSenderNameAbs.font = UIFont.igFont(ofSize: 8.0)
            self.contentView.addSubview(txtSenderNameAbs)
            
            txtSenderNameAbs.snp.makeConstraints { (make) in
                make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(8)
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
                make.top.equalTo(viewSenderNameAbs.snp.top)
                make.height.equalTo(9)
            }
            
            viewSenderNameAbs.snp.makeConstraints{ (make) in
                make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(-0.490)
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(0.490)
                make.bottom.equalTo(mainBubbleViewAbs.snp.top)
                make.height.equalTo(9.5)
            }
            
            self.contentView.bringSubviewToFront(mainBubbleViewAbs)
        }
    }
    
    private func removeSenderName(){
        txtSenderNameAbs?.removeFromSuperview()
        txtSenderNameAbs = nil
        
        viewSenderNameAbs?.removeFromSuperview()
        viewSenderNameAbs = nil
    }
    
    
    
    
    private func makeForward(){
        if forwardViewAbs == nil {
            forwardViewAbs = UIView()
            forwardViewAbs.layer.masksToBounds = true
            forwardViewAbs.layer.cornerRadius = cornerRadius
            mainBubbleViewAbs.addSubview(forwardViewAbs!)
            
            forwardLineViewAbs = UIView()
            forwardLineViewAbs.backgroundColor = UIColor.chatForwardToIndicatorViewColor(isIncommingMessage: isIncommingMessage)
            forwardViewAbs.addSubview(forwardLineViewAbs)
            
            txtForwardAbs = UILabel()
            txtForwardAbs.lineBreakMode = .byTruncatingMiddle
            txtForwardAbs.textAlignment = NSTextAlignment.right
            forwardViewAbs?.addSubview(txtForwardAbs)
            
            forwardViewAbs?.backgroundColor = UIColor.chatForwardedFromViewBackgroundColor(isIncommingMessage: isIncommingMessage)
            txtForwardAbs.textColor = UIColor.chatForwardedFromUsernameLabelColor(isIncommingMessage: isIncommingMessage)
            txtForwardAbs.font = UIFont.igFont(ofSize: 12.0, weight: .bold)
            
            forwardViewAbs?.snp.makeConstraints { (make) in
                make.top.equalTo(mainBubbleViewAbs.snp.top).offset(bubbleSubviewOffset).priority(.required)
                make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(bubbleSubviewOffset)
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-bubbleSubviewOffset)
                make.height.equalTo(30)
            }
            
            forwardLineViewAbs.snp.makeConstraints { (make) in
                make.trailing.equalTo(forwardViewAbs.snp.trailing).offset(-8)
                make.top.equalTo(forwardViewAbs.snp.top).offset(4)
                make.bottom.equalTo(forwardViewAbs.snp.bottom).offset(-4)
                make.width.equalTo(3)
            }
            
            txtForwardAbs.snp.makeConstraints { (make) in
                make.top.equalTo(forwardViewAbs.snp.top)
                make.leading.equalTo(forwardViewAbs.snp.leading).offset(8)
                make.trailing.equalTo(forwardLineViewAbs.snp.leading).offset(-8)
                make.centerY.equalTo(forwardViewAbs.snp.centerY).priority(.required)
            }
            //} else {
            /* set color always for avoid from reuse item color. for example: show incomming forward color for received forward color */
            //forwardViewAbs?.backgroundColor = UIColor.chatForwardedFromViewBackgroundColor(isIncommingMessage: isIncommingMessage)
        } else {
            forwardViewAbs?.backgroundColor = UIColor.chatForwardedFromViewBackgroundColor(isIncommingMessage: isIncommingMessage)

            forwardLineViewAbs.backgroundColor = UIColor.chatForwardToIndicatorViewColor(isIncommingMessage: isIncommingMessage)
            txtForwardAbs.textColor = UIColor.chatForwardedFromUsernameLabelColor(isIncommingMessage: isIncommingMessage)

        }
        
        if #available(iOS 11.0, *) {
            if isIncommingMessage {
                forwardViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            } else {
                forwardViewAbs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
    
    private func removeForward(){
        forwardViewAbs?.removeFromSuperview()
        forwardViewAbs = nil
        
        txtForwardAbs?.removeFromSuperview()
        txtForwardAbs = nil
    }
    
    
    
    
    private func makeReply(){
        
        if replyViewAbs == nil {
            replyViewAbs = UIView()
            replyViewAbs.layer.masksToBounds = true
            replyViewAbs.layer.cornerRadius = cornerRadius
            mainBubbleViewAbs.addSubview(replyViewAbs)
            
            replyLineViewAbs = UIView()
            replyViewAbs.addSubview(replyLineViewAbs)
            
            txtReplyDisplayNameAbs = UILabel()
            txtReplyDisplayNameAbs.lineBreakMode = .byTruncatingMiddle
            txtReplyDisplayNameAbs.textAlignment = NSTextAlignment.right
            replyViewAbs.addSubview(txtReplyDisplayNameAbs)
            
            txtReplyMessageAbs = UILabel()
            txtReplyMessageAbs.lineBreakMode = .byTruncatingMiddle
            txtReplyMessageAbs.textAlignment = NSTextAlignment.right
            replyViewAbs.addSubview(txtReplyMessageAbs)
            
            replyViewAbs.snp.makeConstraints { (make) in
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-bubbleSubviewOffset)
                make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(bubbleSubviewOffset)
                make.top.equalTo(mainBubbleViewAbs.snp.top).offset(bubbleSubviewOffset)
                make.height.equalTo(54)
            }
            
            replyLineViewAbs.snp.makeConstraints { (make) in
                make.trailing.equalTo(replyViewAbs.snp.trailing).offset(-8)
                make.top.equalTo(replyViewAbs.snp.top).offset(10)
                make.bottom.equalTo(replyViewAbs.snp.bottom).offset(-10)
                make.width.equalTo(3)
            }
            
            txtReplyDisplayNameAbs.snp.makeConstraints { (make) in
                make.leading.equalTo(replyViewAbs.snp.leading).offset(8)
                make.trailing.equalTo(replyLineViewAbs.snp.leading).offset(-8)
                make.top.equalTo(replyLineViewAbs.snp.top)
                make.height.equalTo(14)
            }
            
            txtReplyMessageAbs.snp.makeConstraints { (make) in
                make.leading.equalTo(replyViewAbs.snp.leading).offset(8)
                make.trailing.equalTo(replyLineViewAbs.snp.leading).offset(-8)
                make.bottom.equalTo(replyLineViewAbs.snp.bottom)
                make.height.equalTo(17)
            }
            
            replyViewAbs?.backgroundColor = UIColor.chatReplyToBackgroundColor(isIncommingMessage: isIncommingMessage)
            replyLineViewAbs.backgroundColor = UIColor.chatReplyToIndicatorViewColor(isIncommingMessage: isIncommingMessage)
            txtReplyDisplayNameAbs.textColor = UIColor.chatReplyToUsernameLabelTextColor(isIncommingMessage: isIncommingMessage)
            txtReplyMessageAbs.textColor = UIColor.chatReplyToMessageBodyLabelTextColor(isIncommingMessage: isIncommingMessage)
            
            txtReplyDisplayNameAbs.font = UIFont.igFont(ofSize: 12.0, weight: .bold)
            txtReplyMessageAbs.font = UIFont.igFont(ofSize: 13.0)
        } else {
            /* set color always for avoid from reuse item color. for example: show incomming reply color for received reply color */
            replyViewAbs?.backgroundColor = UIColor.chatReplyToBackgroundColor(isIncommingMessage: isIncommingMessage)

        }
        
        if #available(iOS 11.0, *) {
            if isIncommingMessage {
                replyViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            } else {
                replyViewAbs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
    
    private func removeReply(){
        replyViewAbs?.removeFromSuperview()
        replyViewAbs = nil
        
        replyLineViewAbs?.removeFromSuperview()
        replyLineViewAbs = nil
        
        txtReplyDisplayNameAbs?.removeFromSuperview()
        txtReplyDisplayNameAbs = nil
        
        txtReplyMessageAbs?.removeFromSuperview()
        txtReplyMessageAbs = nil
    }
    
    
    
    
    private func makeAvatar(){
        if avatarViewAbs == nil {
            let frame = CGRect(x:0 ,y:0 ,width:50 ,height:50)
            avatarViewAbs = IGAvatarView(frame: frame)
            self.contentView.addSubview(avatarViewAbs)
            
            avatarViewAbs.snp.makeConstraints { (make) in
                make.leading.equalTo(self.contentView.snp.leading).offset(8)
                make.top.equalTo(mainBubbleViewAbs.snp.top)
                make.width.equalTo(50)
                make.height.equalTo(50)
            }
        }
    }
    
    private func removeAvatar(){
        avatarViewAbs?.removeFromSuperview()
        avatarViewAbs = nil
    }
    
    
    
    
    private func makeStatus() {
        if txtStatusAbs == nil {
            txtStatusAbs = UILabel()
            txtStatusAbs.font = UIFont.iGapFonticon(ofSize: 20)
            mainBubbleViewAbs.addSubview(txtStatusAbs)
            
            txtStatusAbs.snp.makeConstraints { (make) in
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10)
                make.centerY.equalTo(txtTimeAbs.snp.centerY).offset(-1)
                make.height.equalTo(20)
                make.width.equalTo(20)
            }
        }
        if isIncommingMessage {
            txtStatusAbs?.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

        } else {
            txtStatusAbs?.textColor = ThemeManager.currentTheme.LabelColor
        }

    }
    
    private func removeStatus(){
        txtStatusAbs?.removeFromSuperview()
        txtStatusAbs = nil
    }
    
    
    
    
    private func makeTime(statusExist: Bool){
        if txtTimeAbs == nil {
            txtTimeAbs = UILabel()
            txtTimeAbs.font = UIFont.igFont(ofSize: 11.0, weight: .medium)
            mainBubbleViewAbs.addSubview(txtTimeAbs)
        }
        if isIncommingMessage {
            txtTimeAbs?.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

        } else {

            let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
            let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
            let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

            if currentTheme == "IGAPDay" || currentTheme == "IGAPNight" {
                
                if currentColorSetLight == "IGAPBlack" {
                    txtTimeAbs.textColor = .white
                } else {
                    txtTimeAbs?.textColor = ThemeManager.currentTheme.BackGroundColor
                }

            } else {
                txtTimeAbs?.textColor = ThemeManager.currentTheme.BackGroundColor
            }
        }

        txtTimeAbs.snp.removeConstraints()
        txtTimeAbs.snp.makeConstraints{ (make) in
            if statusExist {
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-25)
            } else {
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-2)
            }
            make.bottom.equalTo(mainBubbleViewAbs.snp.bottom).offset(-11)
            make.width.equalTo(35)
            make.height.equalTo(13)
        }
    }
    
    private func removeTime() {
        txtTimeAbs?.removeFromSuperview()
        txtTimeAbs = nil
    }
    
    
    
    
    private func makeEdit(){
        if txtEditedAbs == nil {
            txtEditedAbs = UILabel()
            txtEditedAbs.text = IGStringsManager.Edited.rawValue.localized
            txtEditedAbs.font = UIFont.igFont(ofSize: 9.0)
            if isIncommingMessage {
                txtEditedAbs.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
            } else {
                txtEditedAbs.textColor = UIColor.chatTimeTextColor()
            }
            mainBubbleViewAbs.addSubview(txtEditedAbs)
        }
        
        txtEditedAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(txtTimeAbs.snp.leading).offset(-3)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.width.equalTo(50)
            make.height.equalTo(11)
        }
    }
    
    private func removeEdit(){
        txtEditedAbs?.removeFromSuperview()
        txtEditedAbs = nil
    }
    
    
    
    private func makeStatusBackground(){
        statusBackgroundViewAbs?.removeFromSuperview()
        statusBackgroundViewAbs = nil
        
        if statusBackgroundViewAbs == nil {
            statusBackgroundViewAbs = UIView()
            statusBackgroundViewAbs.backgroundColor = ThemeManager.currentTheme.ReceiveMessageBubleBGColor
            statusBackgroundViewAbs.layer.masksToBounds = false
            statusBackgroundViewAbs.layer.cornerRadius = self.cornerRadius
            statusBackgroundViewAbs.layer.shadowColor = UIColor.black.cgColor
            statusBackgroundViewAbs.layer.shadowRadius = bubbleShadowRadius
            statusBackgroundViewAbs.layer.shadowOpacity = bubbleShadowOpacity
            mainBubbleViewAbs.addSubview(statusBackgroundViewAbs)
        }
        
        if isIncommingMessage {
            statusBackgroundViewAbs.layer.shadowOffset = CGSize(width: bubbleShadowOffset, height: bubbleShadowOffset)
        } else {
            statusBackgroundViewAbs.layer.shadowOffset = CGSize(width: -bubbleShadowOffset, height: bubbleShadowOffset)
        }
        
        statusBackgroundViewAbs.snp.makeConstraints { (make) in
            if isIncommingMessage {
                make.trailing.equalTo(txtTimeAbs.snp.trailing).offset(0)
            } else {
                make.trailing.equalTo(txtStatusAbs.snp.trailing).offset(10)
            }
            if finalRoomMessage.isEdited {
                make.leading.equalTo(txtEditedAbs.snp.leading).offset(-10)
            } else {
                make.leading.equalTo(txtTimeAbs.snp.leading).offset(-10)
            }
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.height.equalTo(22)
        }
    }
    
    
    
    private func makeViewCount(){
        if txtSeenCountAbs == nil {
            txtSeenCountAbs = UILabel()
            txtSeenCountAbs.font = UIFont.iGapFonticon(ofSize:14.0)
            txtSeenCountAbs.textColor = UIColor.messageText()
            mainBubbleViewAbs.addSubview(txtSeenCountAbs)
            
            txtSeenCountAbs.snp.makeConstraints { (make) in
                make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(10)
                make.centerY.equalTo(txtTimeAbs.snp.centerY)
                make.height.equalTo(35)
                make.width.greaterThanOrEqualTo(40)
            }
        }
    }
    
    //Hint: before call following method, alaways first call 'makeViewCount' method
    private func makeVoteAction(){
        
        if txtVoteUpAbs == nil {
            txtVoteUpAbs = UILabel()
            txtVoteUpAbs.font = UIFont.iGapFonticon(ofSize: 14.0)
            txtVoteUpAbs.textColor = UIColor.messageText()
            mainBubbleViewAbs.addSubview(txtVoteUpAbs)
            
            txtVoteDownAbs = UILabel()
            txtVoteDownAbs.font = UIFont.iGapFonticon(ofSize: 14.0)
            txtVoteDownAbs.textColor = UIColor.messageText()
            mainBubbleViewAbs.addSubview(txtVoteDownAbs)
        }
        
        txtVoteUpAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(txtSeenCountAbs.snp.trailing).offset(8)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.height.equalTo(35)
            make.width.greaterThanOrEqualTo(40)
        }
        
        txtVoteDownAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(txtVoteUpAbs.snp.trailing).offset(8)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.height.equalTo(35)
            make.width.greaterThanOrEqualTo(40)
        }
    }
    
    private func removeSeenCount(){
        txtSeenCountAbs?.removeFromSuperview()
        txtSeenCountAbs = nil
    }
    
    public func removeVoteAction(){
        txtVoteUpAbs?.removeFromSuperview()
        txtVoteUpAbs = nil
        
        txtVoteDownAbs?.removeFromSuperview()
        txtVoteDownAbs = nil
    }
    
    
    
    private func makeAnimationView(attachmentJson: IGFile) {
        animationView = AnimationView()
        animationView.layer.masksToBounds = true
//        animationView.layer.cornerRadius = cornerRadius
        let animation = Animation.filepath(attachmentJson.path()!.absoluteString)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .clear
        mainBubbleViewAbs.addSubview(animationView)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: mainBubbleViewAbs.topAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: mainBubbleViewAbs.leadingAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: mainBubbleViewAbs.trailingAnchor).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: messageSizes.messageAttachmentHeight-bubbleSubviewOffset).isActive = true


//        playANimation(animationView: animationView)

    }
    private func playANimation(animationView: AnimationView) {
        animationView.play(fromProgress: 0,
                           toProgress: 1,
                           loopMode: LottieLoopMode.loop,
                           completion: { (finished) in
                            if finished {
                              print("Animation Complete")
                                animationView.play(fromProgress: 0,
                                toProgress: 1,
                                loopMode: LottieLoopMode.loop)
                            } else {
                              print("Animation cancelled")
                            }
        })

    }
    private func makeImage(_ messageType: IGRoomMessageType){
        
        removeVideoInfo()
        removeVideoPlayView()
        
        imgMediaAbs?.removeFromSuperview()
        imgMediaAbs = nil
        
        indicatorViewAbs?.removeFromSuperview()
        indicatorViewAbs = nil
        
        imgMediaAbs = IGImageView()
        imgMediaAbs.layer.masksToBounds = true
        imgMediaAbs.layer.cornerRadius = cornerRadius
        mainBubbleViewAbs.addSubview(imgMediaAbs)
        
        if messageType != .sticker {
            indicatorViewAbs = IGProgress()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
            
            indicatorViewAbs?.snp.makeConstraints { (make) in
                make.top.equalTo(imgMediaAbs.snp.top)
                make.bottom.equalTo(imgMediaAbs.snp.bottom)
                make.trailing.equalTo(imgMediaAbs.snp.trailing)
                make.leading.equalTo(imgMediaAbs.snp.leading)
            }
            
            if IGGlobal.isFileExist(path: self.finalRoomMessage.attachment!.path(), fileSize: self.finalRoomMessage.attachment!.size) {
                indicatorViewAbs?.isHidden = true
            } else {
                indicatorViewAbs?.isHidden = false
            }
        }
        
        if messageType == .video || messageType == .videoAndText {
            makeVideoInfo()
        }
        
        imgMediaAbs.snp.makeConstraints { (make) in

            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-bubbleSubviewOffset)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(bubbleSubviewOffset)
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.deactivate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.deactivate() }
            
            if isForward {
                imgMediaTopAbs = make.top.equalTo(forwardViewAbs.snp.bottom).offset(bubbleSubviewOffset).constraint
            } else if isReply {
                imgMediaTopAbs = make.top.equalTo(replyViewAbs.snp.bottom).offset(bubbleSubviewOffset).constraint
            } else {
                imgMediaTopAbs = make.top.equalTo(mainBubbleViewAbs.snp.top).offset(bubbleSubviewOffset).constraint
                if #available(iOS 11.0, *) {
                    if isIncommingMessage {
                        imgMediaAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                    } else {
                        imgMediaAbs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    }
                }
            }
            imgMediaHeightAbs = make.height.equalTo(messageSizes.messageAttachmentHeight-bubbleSubviewOffset).constraint
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.activate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.activate() }
        }
    }
    
    private func removeImage(){
        imgMediaAbs?.removeFromSuperview()
        imgMediaAbs = nil
        
        indicatorViewAbs?.removeFromSuperview()
        indicatorViewAbs = nil
    }
    
    
    
    
    private func makeVideoInfo(){
        
        if viewInfoVideoAbs == nil {
            viewInfoVideoAbs = UIView()
            viewInfoVideoAbs.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            viewInfoVideoAbs.layer.cornerRadius = 10
            viewInfoVideoAbs.layer.borderWidth = 1
            viewInfoVideoAbs.layer.borderColor = UIColor.chatBubbleBorderColor().cgColor
            mainBubbleViewAbs.addSubview(viewInfoVideoAbs)
            
            txtTimeVideoAbs = UILabel()
            txtTimeVideoAbs?.textColor = UIColor.white
            txtTimeVideoAbs!.font = UIFont.igFont(ofSize: 10)
            viewInfoVideoAbs.addSubview(txtTimeVideoAbs)
            
            txtSizeVideoAbs = UILabel()
            txtSizeVideoAbs?.textColor = UIColor.white
            txtSizeVideoAbs!.font = UIFont.igFont(ofSize: 10)
            viewInfoVideoAbs.addSubview(txtSizeVideoAbs)
        }
        
        viewInfoVideoAbs?.snp.makeConstraints { (make) in
            make.leading.equalTo(imgMediaAbs.snp.leading).offset(10)
            make.top.equalTo(imgMediaAbs.snp.top).offset(10)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(40)
        }
        
        txtTimeVideoAbs?.snp.makeConstraints { (make) in
            make.leading.equalTo(viewInfoVideoAbs.snp.leading).offset(4)
            make.centerY.equalTo(viewInfoVideoAbs.snp.centerY)
        }
        
        txtSizeVideoAbs?.snp.makeConstraints { (make) in
            make.leading.equalTo(txtTimeVideoAbs.snp.trailing).offset(3)
            make.trailing.equalTo(viewInfoVideoAbs.snp.trailing).offset(-4)
            make.centerY.equalTo(viewInfoVideoAbs.snp.centerY)
        }
    }
    
    private func removeVideoInfo(){
        viewInfoVideoAbs?.removeFromSuperview()
        viewInfoVideoAbs = nil
        
        txtTimeVideoAbs?.removeFromSuperview()
        txtTimeVideoAbs = nil
        
        txtSizeVideoAbs?.removeFromSuperview()
        txtSizeVideoAbs = nil
    }
    
    private func makeVideoPlayView(){
        if txtVideoPlayAbs == nil {
            txtVideoPlayAbs = UILabel()
            txtVideoPlayAbs.font = UIFont.iGapFonticon(ofSize: 40)
            txtVideoPlayAbs.textAlignment = NSTextAlignment.center
            txtVideoPlayAbs.text = ""
            txtVideoPlayAbs.textColor = UIColor.white
            txtVideoPlayAbs.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            txtVideoPlayAbs.layer.masksToBounds = true
            txtVideoPlayAbs.layer.cornerRadius = 27.5
            imgMediaAbs.addSubview(txtVideoPlayAbs)
        }
        
        txtVideoPlayAbs?.snp.makeConstraints { (make) in
            make.width.equalTo(55)
            make.height.equalTo(55)
            make.centerX.equalTo(imgMediaAbs.snp.centerX)
            make.centerY.equalTo(imgMediaAbs.snp.centerY)
        }
    }
    
    private func removeVideoPlayView(){
        txtVideoPlayAbs?.removeFromSuperview()
        txtVideoPlayAbs = nil
    }
    
    
    
    
    private func makeAdditionalView(additionalView: UIView, removeView: Bool = true, isBot: Bool = false){
        removeAdditionalView()
        
        if self.additionalViewAbs == nil {
            self.additionalViewAbs = UIView()
            let avatarPayViewAbs = UIView()

            self.additionalViewAbs.addSubview(additionalView)
            if isBot {
                self.additionalViewAbs.layer.cornerRadius = 18.0
            } else {
                self.additionalViewAbs.layer.cornerRadius = 18.0
            }
            self.contentView.addSubview(self.additionalViewAbs)
            
            self.additionalViewAbs?.snp.makeConstraints { (make) in
                make.leading.equalTo(self.mainBubbleViewAbs.snp.leading)
                make.trailing.equalTo(self.mainBubbleViewAbs.snp.trailing)
                make.top.equalTo(self.mainBubbleViewAbs.snp.bottom).offset(5)
                make.height.equalTo(additionalView.frame.size.height)
            }
            
            additionalView.snp.makeConstraints { (make) in
                make.leading.equalTo(self.additionalViewAbs.snp.leading)
                make.trailing.equalTo(self.additionalViewAbs.snp.trailing)
                make.top.equalTo(self.additionalViewAbs.snp.top)
                make.bottom.equalTo(additionalViewAbs.snp.bottom)
            }
            avatarPayViewAbs.backgroundColor = .red
        }
    }
    
    private func removeAdditionalView(){
        additionalViewAbs?.removeFromSuperview()
        additionalViewAbs = nil
    }
    
    
    
    
    private func makeReturnToMessageView(){
        if btnReturnToMessageAbs == nil {
            btnReturnToMessageAbs = UIButton()
            btnReturnToMessageAbs.setTitleColor(UIColor.iGapGreen(), for: .normal)
            btnReturnToMessageAbs.titleLabel!.textAlignment = .center
            btnReturnToMessageAbs.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25.0)
            btnReturnToMessageAbs.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            btnReturnToMessageAbs.setTitle("", for: .normal)
            btnReturnToMessageAbs.isUserInteractionEnabled = true
            self.contentView.addSubview(btnReturnToMessageAbs)
            
            btnReturnToMessageAbs.layer.cornerRadius = 17.5
            btnReturnToMessageAbs.layer.masksToBounds = false
            btnReturnToMessageAbs.layer.shadowColor = UIColor.black.cgColor
            btnReturnToMessageAbs.layer.shadowOffset = CGSize(width: 0, height: 0)
            btnReturnToMessageAbs.layer.shadowRadius = 4.0
            btnReturnToMessageAbs.layer.shadowOpacity = 0.15
            btnReturnToMessageAbs.layer.borderWidth = 0.2
            btnReturnToMessageAbs.layer.borderColor = #colorLiteral(red: 0.4477736669, green: 0.4477736669, blue: 0.4477736669, alpha: 1)
            btnReturnToMessageAbs.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.animate(withDuration: 0.5, animations: {
                self.btnReturnToMessageAbs?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (finished) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.btnReturnToMessageAbs?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                })
            }
        }
        
        btnReturnToMessageAbs.snp.makeConstraints{ (make) in
            if isIncommingMessage {
                make.trailing.equalTo(self.contentView.snp.trailing).offset(-15)
            } else {
                make.leading.equalTo(self.contentView.snp.leading).offset(15)
            }
            make.top.equalTo(self.contentView.snp.top).offset(10)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }
    }
    
    private func removeReturnToMessageView(){
        btnReturnToMessageAbs?.removeFromSuperview()
        btnReturnToMessageAbs = nil
    }
}

/*
 ******************************************************************
 **************************** extensions **************************
 ******************************************************************
 */

extension AbstractCell: IGProgressDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGProgress) {
        if !IGGlobal.shouldMultiSelect {///if not in multiSelectMode

            if let attachment = self.attachment {
                if attachment.status == .uploading {
                    IGMessageViewController.messageOnChatReceiveObserver.onMessageDelete(roomId: self.room.id, messageId: self.finalRoomMessage.id)
                    IGUploadManager.sharedManager.cancelUpload(attachment: attachment)
                } else if attachment.status == .uploadFailed {
                    if let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", self.realmRoomMessage.roomId)).first {
                        IGMessageSender.defaultSender.resend(message: self.finalRoomMessage, to: room)
                    }
                } else {
                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
                }
            }
            
        }
    }
}

extension String {
    func withBoldText(text: String, font: UIFont? = nil) -> NSAttributedString {
        let _font = font ?? UIFont.systemFont(ofSize: 14, weight: .regular)
        let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: _font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: _font.pointSize)]
        let range = (self as NSString).range(of: text)
        fullString.addAttributes(boldFontAttribute, range: range)
        return fullString
    }}
