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

class AbstractCell: IGMessageGeneralCollectionViewCell {
    
    var mainBubbleViewAbs: UIView!
    var forwardViewAbs: UIView!
    var replyViewAbs: UIView!
    var mediaContainerViewAbs: UIView?
    var messageViewAbs: UIView?
    var replyLineViewAbs: UIView!
    var viewInfoVideoAbs: UIView!
    var viewSenderNameAbs: UIView!
    var additionalViewAbs: UIView!
    
    var txtSenderNameAbs: UILabel!
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
    
    var imgStatusAbs: UIImageView!
    var imgFileAbs: UIImageView!
    var imgVideoPlayAbs: UIImageView!
    
    var txtMessageHeightConstraintAbs: NSLayoutConstraint!
    var mainBubbleViewWidthAbs: NSLayoutConstraint!
    var mainBubbleViewHeightAbs: NSLayoutConstraint!
    var mediaHeightConstraintAbs: NSLayoutConstraint!
    
    var avatarViewAbs: IGAvatarView!
    var txtMessageAbs: ActiveLabel!
    var imgMediaAbs: IGImageView!
    var indicatorViewAbs: IGDownloadUploadIndicatorView!

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
    
    let disposeBag = DisposeBag()
    
    var isForward = false
    var isReply = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        self.backgroundColor = UIColor.clear
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
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
        manageEdit()
        manageTextMessage()
        manageViewPosition()
        manageLink()
        manageVoteActions()
        manageGustureRecognizers()
        manageAttachment()
        manageAdditional()
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
    private func detectRtlAndBottomOffset(){
        
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
    
    private func manageTextMessage(){
        
        if finalRoomMessage.type == .sticker {
            return
        }
        
        if finalRoomMessage.message != nil && finalRoomMessage.message != "" {
            txtMessageAbs?.isHidden = false
            txtMessageHeightConstraintAbs?.constant = messageSizes.bubbleSize.height
            let messageText = finalRoomMessage.message?.replacingOccurrences(of: "⁣", with: "") // replace with invisible character if exist
            txtMessageAbs?.text = messageText?.replacingOccurrences(of: "**", with: "⁣") // replace '**' with invisible character
            
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
    
    private func manageViewPosition(){
        
        if txtMessageAbs == nil && finalRoomMessage.type != .sticker {
            return
        }
        
        if finalRoomMessage.attachment == nil && finalRoomMessage.type != .sticker {
            if isForward {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if (finalRoomMessage.message?.isRTL())! || self.room.type == .channel {
                        make.top.equalTo((forwardViewAbs?.snp.bottom)!).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo((forwardViewAbs?.snp.bottom)!).offset(10)
                    }
                }
            } else if isReply {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if (finalRoomMessage.message?.isRTL())! || self.room.type == .channel {
                        make.top.equalTo((replyViewAbs?.snp.bottom)!).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo((replyViewAbs?.snp.bottom)!).offset(10)
                    }
                }
            } else {
                txtMessageAbs.snp.remakeConstraints{ (make) in
                    if let rtl = finalRoomMessage.message?.isRTL(), rtl || self.room.type == .channel {
                        make.centerY.equalTo(mainBubbleViewAbs.snp.centerY).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.centerY.equalTo(mainBubbleViewAbs.snp.centerY)
                    }
                }
            }
            
            removeImage()
            
        } else {
            switch (finalRoomMessage.type) {
            case .sticker:
                makeImage(.sticker)
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
                    if (finalRoomMessage.message?.isRTL())! {
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
                    if (finalRoomMessage.message?.isRTL())! {
                        make.top.equalTo(imgFileAbs.snp.bottom).offset(CellSizeCalculator.RTL_OFFSET)
                    } else {
                        make.top.equalTo(imgFileAbs.snp.bottom)
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
                    if (finalRoomMessage.message?.isRTL())! {
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
            txtTimeAbs?.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
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
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Sending")
            imgStatusAbs.backgroundColor = UIColor.clear
            break
        case .sent:
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Sent")
            imgStatusAbs.backgroundColor = UIColor.clear
            break
        case .delivered:
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Delivered")
            imgStatusAbs.backgroundColor = UIColor.clear
            break
        case .seen,.listened:
            imgStatusAbs.image = UIImage(named: "IG_Message_Cell_State_Seen")
            imgStatusAbs.backgroundColor = UIColor.clear
            break
        case .failed, .unknown:
            imgStatusAbs.image = UIImage(named: "IG_Chat_List_Delivery_State_Failed")
            imgStatusAbs.backgroundColor = UIColor.red
            break
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
            if let user = realmRoomMessage.authorUser {
                avatarViewAbs.setUser(user)
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
            removeStatus()
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

                if let sender = realmRoomMessage.authorUser {
                    txtSenderNameAbs.text = sender.displayName
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
    }
    
    private func manageCellBubble(){
        
        /************ Bubble View ************/
        mainBubbleViewAbs.layer.cornerRadius = 18
        mainBubbleViewAbs.layer.masksToBounds = true
        if finalRoomMessage.type == .sticker {
            mainBubbleViewAbs.backgroundColor = UIColor.clear
        } else {
            mainBubbleViewAbs.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
        }
        
        /************ Bubble Size ************/
        mainBubbleViewWidthAbs.constant = messageSizes.bubbleSize.width //mainBubbleViewWidthAbs.priority = 1000
        mainBubbleViewHeightAbs.constant = messageSizes.bubbleSize.height - 18
        
        /********* Bubble Direction *********/
        mainBubbleViewAbs.snp.makeConstraints { (make) in
            
            if leadingAbs != nil { leadingAbs?.deactivate() }
            if trailingAbs != nil { trailingAbs?.deactivate() }
            
            if isIncommingMessage {
                
                if #available(iOS 11.0, *) {
                    mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                }
                
                if shouldShowAvatar {
                    leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(46).priority(999).constraint
                } else {
                    leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(16).priority(999).constraint
                }
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(250).constraint
                
            } else {
                
                if #available(iOS 11.0, *) {
                    mainBubbleViewAbs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
                
                trailingAbs = make.trailing.equalTo(self.contentView.snp.trailing).offset(-16).priority(999).constraint
                leadingAbs = make.leading.equalTo(self.contentView.snp.leading).offset(46).priority(250).constraint
            }
            
            if leadingAbs != nil { leadingAbs?.activate() }
            if trailingAbs != nil { trailingAbs?.activate() }
        }
    }
    
    /*
     ******************************************************************
     ************************** Link Manager **************************
     ******************************************************************
     */
    private func manageLink(){
        linkManager(txtMessage: txtMessageAbs)
    }
    
    private func linkManager(txtMessage: ActiveLabel?){
        if txtMessage == nil {
            return
        }
        
        txtMessage?.customize {(lable) in
            lable.hashtagColor = UIColor.iGapLink()
            lable.mentionColor = UIColor.iGapLink()
            lable.URLColor = UIColor.iGapLink()
            lable.botColor = UIColor.iGapLink()
            lable.EmailColor = UIColor.iGapLink()
            
            lable.handleURLTap { url in
                self.delegate?.didTapOnURl(url: url)
            }
            
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
    
    /*
     ******************************************************************
     *********************** Gesture Recognizer ***********************
     ******************************************************************
     */
    
    func manageGustureRecognizers() {
        
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
        }
        
        if forwardViewAbs != nil {
            let onForwardClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnForward(_:)))
            forwardViewAbs.addGestureRecognizer(onForwardClick)
            forwardViewAbs.isUserInteractionEnabled = true
        }
        
        if imgFileAbs != nil {
            let onFileClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
            imgFileAbs.addGestureRecognizer(onFileClick)
            imgFileAbs.isUserInteractionEnabled = true
        }
        
        if mediaContainerViewAbs != nil {
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
            mediaContainerViewAbs?.addGestureRecognizer(tap1)
            mediaContainerViewAbs?.isUserInteractionEnabled = true
        }

        if imgMediaAbs != nil {
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
            imgMediaAbs?.addGestureRecognizer(tap2)
            imgMediaAbs?.isUserInteractionEnabled = true
        }
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
        avatarViewAbs?.addGestureRecognizer(tap5)
        
        let tapVoteUp = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteUp(_:)))
        txtVoteUpAbs?.addGestureRecognizer(tapVoteUp)
        txtVoteUpAbs?.isUserInteractionEnabled = true
        
        let tapVoteDown = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteDown(_:)))
        txtVoteDownAbs?.addGestureRecognizer(tapVoteDown)
        txtVoteDownAbs?.isUserInteractionEnabled = true
    }
    
    @objc func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.delegate?.didTapAndHoldOnMessage(cellMessage: realmRoomMessage!, cell: self)
        default:
            break
        }
    }
    
    func didTapAttachmentOnCell(_ gestureRecognizer: UITapGestureRecognizer) {
        if finalRoomMessage.attachment != nil {
            didTapOnAttachment(gestureRecognizer)
        }
    }
    
    @objc func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnAttachment(cellMessage: realmRoomMessage!, cell: self, imageView: imgMediaAbs)
    }
    
    @objc func didTapOnReply(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnReply(cellMessage: realmRoomMessage!, cell: self)
    }
    
    @objc func didTapOnForward(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForward(cellMessage: realmRoomMessage!, cell: self)
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForwardedAttachment(cellMessage: realmRoomMessage!, cell: self)
        
    }
    
    @objc func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnSenderAvatar(cellMessage: realmRoomMessage!, cell: self)
    }
    
    func didTapOnVoteUp(_ gestureRecognizer: UITapGestureRecognizer) {
        var messageVote: IGRoomMessage! = self.realmRoomMessage
        if let forward = self.realmRoomMessage.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
            messageVote = forward
        }
        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsUp)
    }
    
    func didTapOnVoteDown(_ gestureRecognizer: UITapGestureRecognizer) {
        var messageVote: IGRoomMessage! = self.realmRoomMessage
        if let forward = self.realmRoomMessage.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
            messageVote = forward
        }
        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsDown)
    }
    
    /*
     ******************************************************************
     ****************************** Reply *****************************
     ******************************************************************
     */
    
    private func manageReply(){
        if let repliedMessage = realmRoomMessage.repliedTo {
            
            makeReply()
            
            if let user = repliedMessage.authorUser {
                txtReplyDisplayNameAbs.text = user.displayName
            } else if let room = repliedMessage.authorRoom {
                txtReplyDisplayNameAbs.text = room.title
            }
            
            let body = repliedMessage.message
            
            if repliedMessage.type == .contact {
                txtReplyMessageAbs.text = "contact message"
            } else if repliedMessage.type == .location {
                txtReplyMessageAbs.text = "location message"
            } else if body != nil && !(body?.isEmpty)! {
                
                if repliedMessage.type == .sticker {
                    txtReplyMessageAbs.text = body! + " Sticker"
                } else {
                    let markdown = MarkdownParser()
                    markdown.enabledElements = MarkdownParser.EnabledElements.bold
                    txtReplyMessageAbs.attributedText = markdown.parse(body!)
                    txtReplyMessageAbs.textColor = UIColor.chatReplyToMessageBodyLabelTextColor(isIncommingMessage: isIncommingMessage)
                    txtReplyMessageAbs.font = UIFont.igFont(ofSize: 13.0)
                }
                
            } else if let media = repliedMessage.attachment {
                txtReplyMessageAbs.text = "\(IGFile.convertFileTypeToString(fileType: media.type)) message"
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
            
            if let user = originalMessage.authorUser {
                txtForwardAbs.text = "Forwarded from: \(user.displayName)"
            } else if let room = originalMessage.authorRoom {
                txtForwardAbs.text = "Forwarded from: \(room.title != nil ? room.title! : "")"
            } else {
                txtForwardAbs.text = "Forwarded from: "
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
                        self.imgMediaAbs?.setSticker(for: file)
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
        
        if var attachment = finalRoomMessage.attachment {
            
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                self.attachment = attachmentVariableInCache.value
            } else {
                self.attachment = attachment.detach()
                let attachmentRef = ThreadSafeReference(to: attachment)
                IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
                if let variable = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                    self.attachment = variable.value
                } else {
                    self.attachment = attachment
                }
            }
            
            /* Rx Start */
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
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
                
                imgMediaAbs.setThumbnail(for: attachment)
                if attachment.status != .ready {
                    indicatorViewAbs?.size = attachment.sizeToString()
                    indicatorViewAbs?.delegate = self
                }
                
                /**** seems to not need ****
                if finalRoomMessage.type == .gif || finalRoomMessage.type == .gifAndText {
                    attachment.loadData()
                    if let data = attachment.data {
                        imgMediaAbs.prepareForAnimation(withGIFData: data)
                        imgMediaAbs.startAnimatingGIF()
                    } else {
                        self.downloadUploadIndicatorDidTap(indicatorViewAbs)
                    }
                }
                */
                indicatorViewAbs?.shouldShowSize = true
                break
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
                        imgMediaAbs.prepareForAnimation(withGIFData: data)
                        imgMediaAbs.startAnimatingGIF()
                    }
                } else if attachment.type == .image {
                    imgMediaAbs.setThumbnail(for: attachment)
                }
                return
            }
            
            if self.isIncommingMessage || !fileExist {
                indicatorViewAbs?.setFileType(.downloadFile)
            } else {
                indicatorViewAbs?.setFileType(.uploadFile)
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
                self.makeAdditionalView(additionalView: additionalView, removeView: false)
            }
        } else if let additionalData = finalRoomMessage.additional?.data,
            finalRoomMessage.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
            let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData),
            isIncommingMessage {
            let additionalView = IGHelperBot.shared.makeBotView(additionalArrayMain: additionalStruct)
            IGHelperBot.createdViewDic[self.realmRoomMessage.id] = additionalView
            self.makeAdditionalView(additionalView: additionalView)
            
        } else {
            removeAdditionalView()
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
            let attributedString = NSMutableAttributedString(string: " \(messageVote.channelExtra?.viewsLabel ?? "1")", attributes: nil)
            let icon = (attributedString.string as NSString).range(of: "")
            attributedString.setAttributes([NSAttributedString.Key.baselineOffset: -2], range: icon)
            txtSeenCountAbs.attributedText = attributedString
            
            if let channel = messageVote.authorRoom?.channelRoom, channel.hasReaction {
                makeVoteAction()
                txtVoteUpAbs.text = " \(messageVote.channelExtra?.thumbsUpLabel ?? "0")"
                
                let attributedVoteDown = NSMutableAttributedString(string: " \(messageVote.channelExtra?.thumbsDownLabel ?? "0")", attributes: nil)
                let textVoteDown = (attributedVoteDown.string as NSString).range(of: "\(messageVote.channelExtra?.thumbsDownLabel ?? "0")")
                attributedVoteDown.addAttributes([NSAttributedString.Key.baselineOffset: 3], range: textVoteDown)
                txtVoteDownAbs.attributedText = attributedVoteDown
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
    
    private func makeSenderName(){
        
        if viewSenderNameAbs == nil {
            viewSenderNameAbs = UIView()
            viewSenderNameAbs.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
            viewSenderNameAbs.layer.cornerRadius = 3.5
            if #available(iOS 11.0, *) {
                viewSenderNameAbs.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            self.contentView.addSubview(viewSenderNameAbs)
        }
        
        if txtSenderNameAbs == nil {
            txtSenderNameAbs = UILabel()
            txtSenderNameAbs.textColor = UIColor.messageText()
            txtSenderNameAbs.font = UIFont.igFont(ofSize: 8.0)
            self.contentView.addSubview(txtSenderNameAbs)
        }
        
        txtSenderNameAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(8)
            make.width.greaterThanOrEqualTo(5)
            make.centerY.equalTo(viewSenderNameAbs.snp.centerY)
            make.height.equalTo(9)
        }
        
        viewSenderNameAbs.snp.makeConstraints{ (make) in
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            make.trailing.equalTo(txtSenderNameAbs.snp.trailing).offset(8)
            make.bottom.equalTo(mainBubbleViewAbs.snp.top).offset(-0.5)
            make.height.equalTo(9.5)
        }
    }
    
    private func removeSenderName(){
        if txtSenderNameAbs != nil {
            txtSenderNameAbs.removeFromSuperview()
            txtSenderNameAbs = nil
        }
        
        if viewSenderNameAbs != nil {
            viewSenderNameAbs.removeFromSuperview()
            viewSenderNameAbs = nil
        }
    }
    
    
    
    
    private func makeForward(){
        if forwardViewAbs == nil {
            forwardViewAbs = UIView()
            mainBubbleViewAbs.addSubview(forwardViewAbs!)
        }
        
        if txtForwardAbs == nil {
            txtForwardAbs = UILabel()
            forwardViewAbs?.addSubview(txtForwardAbs)
        }
        
        /* set color always for avoid from reuse item color. for example: show incomming forward color for received forward color */
        forwardViewAbs?.backgroundColor = UIColor.chatForwardedFromViewBackgroundColor(isIncommingMessage: isIncommingMessage)
        txtForwardAbs.textColor = UIColor.chatForwardedFromUsernameLabelColor(isIncommingMessage: isIncommingMessage)
        txtForwardAbs.font = UIFont.igFont(ofSize: 9.0)
        
        forwardViewAbs?.snp.makeConstraints { (make) in
            make.top.equalTo(mainBubbleViewAbs.snp.top).priority(.required)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.height.equalTo(30)
        }
        
        txtForwardAbs.snp.makeConstraints { (make) in
            make.top.equalTo(forwardViewAbs.snp.top)
            make.leading.equalTo(forwardViewAbs.snp.leading).offset(8)
            make.trailing.equalTo(forwardViewAbs.snp.trailing).offset(-8)
            make.centerY.equalTo(forwardViewAbs.snp.centerY).priority(.required)
        }
    }
    
    private func removeForward(){
        if forwardViewAbs != nil {
            forwardViewAbs?.removeFromSuperview()
            forwardViewAbs = nil
        }
        
        if txtForwardAbs != nil {
            txtForwardAbs?.removeFromSuperview()
            txtForwardAbs = nil
        }
    }
    
    
    
    
    private func makeReply(){
        
        if replyViewAbs == nil {
            replyViewAbs = UIView()
            mainBubbleViewAbs.addSubview(replyViewAbs)
        }
        
        if replyLineViewAbs == nil {
            replyLineViewAbs = UIView()
            replyViewAbs.addSubview(replyLineViewAbs)
        }
        
        if txtReplyDisplayNameAbs == nil {
            txtReplyDisplayNameAbs = UILabel()
            replyViewAbs.addSubview(txtReplyDisplayNameAbs)
        }
        
        if txtReplyMessageAbs == nil {
            txtReplyMessageAbs = UILabel()
            replyViewAbs.addSubview(txtReplyMessageAbs)
        }
        
        replyViewAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            make.top.equalTo(mainBubbleViewAbs.snp.top)
            make.height.equalTo(54)
        }
        
        replyLineViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(replyViewAbs.snp.leading).offset(16)
            make.top.equalTo(replyViewAbs.snp.top).offset(10)
            make.bottom.equalTo(replyViewAbs.snp.bottom).offset(-10)
            make.width.equalTo(3)
        }
        
        txtReplyDisplayNameAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(replyViewAbs.snp.trailing)
            make.leading.equalTo(replyLineViewAbs.snp.trailing).offset(8)
            make.top.equalTo(replyLineViewAbs.snp.top)
            make.height.equalTo(14)
        }
        
        txtReplyMessageAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(replyViewAbs.snp.trailing)
            make.leading.equalTo(replyLineViewAbs.snp.trailing).offset(8)
            make.bottom.equalTo(replyLineViewAbs.snp.bottom)
            make.height.equalTo(17)
        }
        
        replyViewAbs?.backgroundColor         = UIColor.chatReplyToBackgroundColor(isIncommingMessage: isIncommingMessage)
        replyLineViewAbs.backgroundColor      = UIColor.chatReplyToIndicatorViewColor(isIncommingMessage: isIncommingMessage)
        txtReplyDisplayNameAbs.textColor      = UIColor.chatReplyToUsernameLabelTextColor(isIncommingMessage: isIncommingMessage)
        txtReplyMessageAbs.textColor          = UIColor.chatReplyToMessageBodyLabelTextColor(isIncommingMessage: isIncommingMessage)
        
        txtReplyDisplayNameAbs.font = UIFont.igFont(ofSize: 10.0)
        txtReplyMessageAbs.font = UIFont.igFont(ofSize: 13.0)
    }
    
    private func removeReply(){
        if replyViewAbs != nil {
            replyViewAbs?.removeFromSuperview()
            replyViewAbs = nil
        }
        
        if replyLineViewAbs != nil {
            replyLineViewAbs?.removeFromSuperview()
            replyLineViewAbs = nil
        }
        
        if txtReplyDisplayNameAbs != nil {
            txtReplyDisplayNameAbs?.removeFromSuperview()
            txtReplyDisplayNameAbs = nil
        }
        
        if txtReplyMessageAbs != nil {
            txtReplyMessageAbs?.removeFromSuperview()
            txtReplyMessageAbs = nil
        }
    }
    
    
    
    
    private func makeAvatar(){
        if avatarViewAbs == nil {
            let frame = CGRect(x:0 ,y:0 ,width:30 ,height:30)
            avatarViewAbs = IGAvatarView(frame: frame)
            self.contentView.addSubview(avatarViewAbs)
        }

        avatarViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(8)
            make.top.equalTo(mainBubbleViewAbs.snp.top)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    private func removeAvatar(){
        if avatarViewAbs != nil {
            avatarViewAbs.removeFromSuperview()
            avatarViewAbs = nil
        }
    }
    
    
    
    
    private func makeStatus(){
        let size:CGFloat = 15
        if imgStatusAbs == nil {
            imgStatusAbs = UIImageView()
            imgStatusAbs.layer.cornerRadius = size/2
            mainBubbleViewAbs.addSubview(imgStatusAbs)
        }
        
        imgStatusAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10)
            make.centerY.equalTo(txtTimeAbs.snp.centerY).offset(-1)
            make.height.equalTo(size)
            make.width.equalTo(size)
        }
    }
    
    private func removeStatus(){
        if imgStatusAbs != nil {
            imgStatusAbs.removeFromSuperview()
            imgStatusAbs = nil
        }
    }
    
    
    
    
    private func makeTime(statusExist: Bool){
        removeTime()
        
        if txtTimeAbs == nil {
            txtTimeAbs = UILabel()
            txtTimeAbs.font = UIFont.igFont(ofSize: 11.0)
            mainBubbleViewAbs.addSubview(txtTimeAbs)
        }
        
        txtTimeAbs.snp.makeConstraints{ (make) in
            if statusExist {
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-20)
            } else {
                make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-2)
            }
            make.bottom.equalTo(mainBubbleViewAbs.snp.bottom).offset(-11)
            make.width.equalTo(35)
            make.height.equalTo(13)
        }
    }
    
    private func removeTime(){
        if txtTimeAbs != nil {
            txtTimeAbs.removeFromSuperview()
            txtTimeAbs = nil
        }
    }
    
    
    
    
    private func makeEdit(){
        if txtEditedAbs == nil {
            txtEditedAbs = UILabel()
            txtEditedAbs.text = "edited"
            txtEditedAbs.font = UIFont.igFont(ofSize: 9.0)
            txtEditedAbs.textColor = UIColor.chatTimeTextColor(isIncommingMessage: isIncommingMessage)
            mainBubbleViewAbs.addSubview(txtEditedAbs)
        }
        
        txtEditedAbs.snp.makeConstraints { (make) in
            make.trailing.equalTo(txtTimeAbs.snp.leading).offset(-3)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(11)
        }
    }
    
    private func removeEdit(){
        if txtEditedAbs != nil {
            txtEditedAbs.removeFromSuperview()
            txtEditedAbs = nil
        }
    }
    
    
    
    private func makeViewCount(){
        if txtSeenCountAbs == nil {
            txtSeenCountAbs = UILabel()
            txtSeenCountAbs.font = UIFont.iGapFontico(ofSize:11.0)
            txtSeenCountAbs.textColor = UIColor.messageText()
            mainBubbleViewAbs.addSubview(txtSeenCountAbs)
        }
        
        txtSeenCountAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(10)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.height.equalTo(35)
            make.width.greaterThanOrEqualTo(40)
        }
    }
    
    //Hint: before call following method, alaways first call 'makeViewCount' method
    private func makeVoteAction(){
        
        if txtVoteUpAbs == nil {
            txtVoteUpAbs = UILabel()
            txtVoteUpAbs.font = UIFont.iGapFontico(ofSize: 11.0)
            txtVoteUpAbs.textColor = UIColor.messageText()
            mainBubbleViewAbs.addSubview(txtVoteUpAbs)
        }
        
        if txtVoteDownAbs == nil {
            txtVoteDownAbs = UILabel()
            txtVoteDownAbs.font = UIFont.iGapFontico(ofSize: 11.0)
            txtVoteDownAbs.textColor = UIColor.messageText()
            mainBubbleViewAbs.addSubview(txtVoteDownAbs)
        }
        
        txtVoteUpAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(txtSeenCountAbs.snp.trailing).offset(5)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.height.equalTo(35)
            make.width.greaterThanOrEqualTo(40)
        }
        
        txtVoteDownAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(txtVoteUpAbs.snp.trailing).offset(5)
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.height.equalTo(35)
            make.width.greaterThanOrEqualTo(40)
        }
    }
    
    private func removeSeenCount(){
        if txtSeenCountAbs != nil {
            txtSeenCountAbs.removeFromSuperview()
            txtSeenCountAbs = nil
        }
    }
    
    public func removeVoteAction(){
        
        if txtVoteUpAbs != nil {
            txtVoteUpAbs.removeFromSuperview()
            txtVoteUpAbs = nil
        }
        
        if txtVoteDownAbs != nil {
            txtVoteDownAbs.removeFromSuperview()
            txtVoteDownAbs = nil
        }
    }
    
    
    
    
    private func makeImage(_ messageType: IGRoomMessageType){
        
        removeVideoInfo()
        removeVideoPlayView()
        
        if imgMediaAbs != nil {
            imgMediaAbs.removeFromSuperview()
            imgMediaAbs = nil
        }
        
        if indicatorViewAbs != nil {
            indicatorViewAbs.removeFromSuperview()
            indicatorViewAbs = nil
        }
        
        if imgMediaAbs == nil {
            imgMediaAbs = IGImageView()
            mainBubbleViewAbs.addSubview(imgMediaAbs)
        }
        
        if indicatorViewAbs == nil && messageType != .sticker {
            indicatorViewAbs = IGDownloadUploadIndicatorView()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
        }

        if IGGlobal.isFileExist(path: self.finalRoomMessage.attachment!.path(), fileSize: self.finalRoomMessage.attachment!.size) {
            indicatorViewAbs?.isHidden = true
        } else {
            indicatorViewAbs?.isHidden = false
        }
        
        if messageType == .video || messageType == .videoAndText {
            makeVideoInfo()
        }
        
        imgMediaAbs.snp.makeConstraints { (make) in

            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.deactivate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.deactivate() }
            
            if isForward {
                imgMediaTopAbs = make.top.equalTo(forwardViewAbs.snp.bottom).constraint
            } else if isReply {
                imgMediaTopAbs = make.top.equalTo(replyViewAbs.snp.bottom).constraint
            } else {
                imgMediaTopAbs = make.top.equalTo(mainBubbleViewAbs.snp.top).constraint
            }
            imgMediaHeightAbs = make.height.equalTo(messageSizes.messageAttachmentHeight).constraint
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.activate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.activate() }
        }
        
        if messageType != .sticker {
            indicatorViewAbs?.snp.makeConstraints { (make) in
                make.top.equalTo(imgMediaAbs.snp.top)
                make.bottom.equalTo(imgMediaAbs.snp.bottom)
                make.trailing.equalTo(imgMediaAbs.snp.trailing)
                make.leading.equalTo(imgMediaAbs.snp.leading)
            }
        }
    }
    
    private func removeImage(){
        if imgMediaAbs != nil {
            imgMediaAbs.removeFromSuperview()
            imgMediaAbs = nil
        }
        
        if indicatorViewAbs != nil {
            indicatorViewAbs.removeFromSuperview()
            indicatorViewAbs = nil
        }
    }
    
    
    
    
    private func makeVideoInfo(){
        
        if viewInfoVideoAbs == nil {
            viewInfoVideoAbs = UIView()
            viewInfoVideoAbs.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            viewInfoVideoAbs.layer.cornerRadius = 10
            viewInfoVideoAbs.layer.borderWidth = 1
            viewInfoVideoAbs.layer.borderColor = UIColor.chatBubbleBorderColor().cgColor
            mainBubbleViewAbs.addSubview(viewInfoVideoAbs)
        }
        
        if txtTimeVideoAbs == nil {
            txtTimeVideoAbs = UILabel()
            txtTimeVideoAbs?.textColor = UIColor.white
            txtTimeVideoAbs!.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
            viewInfoVideoAbs.addSubview(txtTimeVideoAbs)
        }
        
        if txtSizeVideoAbs == nil {
            txtSizeVideoAbs = UILabel()
            txtSizeVideoAbs?.textColor = UIColor.white
            txtSizeVideoAbs!.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
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
        if viewInfoVideoAbs != nil {
            viewInfoVideoAbs.removeFromSuperview()
            viewInfoVideoAbs = nil
        }
        
        if txtTimeVideoAbs != nil {
            txtTimeVideoAbs.removeFromSuperview()
            txtTimeVideoAbs = nil
        }
        
        if txtSizeVideoAbs != nil {
            txtSizeVideoAbs.removeFromSuperview()
            txtSizeVideoAbs = nil
        }
    }
    
    private func makeVideoPlayView(){
        if imgVideoPlayAbs == nil {
            imgVideoPlayAbs = UIImageView()
            imgVideoPlayAbs.image = UIImage(named: "IG_Music_Player_Play")
            imgVideoPlayAbs.image = imgVideoPlayAbs.image!.withRenderingMode(.alwaysTemplate)
            
            imgVideoPlayAbs.tintColor = UIColor.white.withAlphaComponent(0.8)
            imgVideoPlayAbs.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            imgVideoPlayAbs.layer.cornerRadius = 10
            imgMediaAbs.addSubview(imgVideoPlayAbs)
        }
        
        imgVideoPlayAbs?.snp.makeConstraints { (make) in
            make.width.equalTo(35)
            make.height.equalTo(35)
            make.centerX.equalTo(imgMediaAbs.snp.centerX)
            make.centerY.equalTo(imgMediaAbs.snp.centerY)
        }
    }
    
    private func removeVideoPlayView(){
        if imgVideoPlayAbs != nil {
            imgVideoPlayAbs.removeFromSuperview()
            imgVideoPlayAbs = nil
        }
    }
    
    
    
    private func makeAdditionalView(additionalView: UIView, removeView: Bool = true){
        removeAdditionalView()
        
        if self.additionalViewAbs == nil {
            self.additionalViewAbs = UIView()
            self.additionalViewAbs.addSubview(additionalView)
            self.additionalViewAbs.layer.cornerRadius = 10.0
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
        }
    }
    
    private func removeAdditionalView(){
        if additionalViewAbs != nil {
            additionalViewAbs.removeFromSuperview()
            additionalViewAbs = nil
        }
    }
}

/*
 ******************************************************************
 **************************** extensions **************************
 ******************************************************************
 */

extension AbstractCell: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGDownloadUploadIndicatorView) {
        
        if let attachment = self.attachment {
            if attachment.status == .uploading {
                IGUploadManager.sharedManager.cancelUpload(attachment: attachment)
            } else if attachment.status == .uploadFailed || attachment.status == .uploadPause {
                if let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", self.realmRoomMessage.roomId)).first {
                    IGMessageSender.defaultSender.resend(message: self.finalRoomMessage, to: room)
                }
            } else {
                IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
            }
        }
    }
}

