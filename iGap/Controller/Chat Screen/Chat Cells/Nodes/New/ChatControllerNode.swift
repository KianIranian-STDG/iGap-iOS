//
//  ChatControllerNode.swift
//  iGap
//
//  Created by ahmad mohammadi on 2/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import AsyncDisplayKit
import IGProtoBuff
import SwiftEventBus
import Lottie

class ChatControllerNode: ASCellNode {
    
    var ASbuttonActionDic: [ASButtonNode : IGStructAdditionalButton] = [:]
    var ASbuttonViewDic: [ASButtonNode : ASDisplayNode] = [:]
    // Check if isOnlyemoji and Count is One(One Emoji)
    var isOneCharEmoji : Bool = false

    // Message Needed Data
    private(set) var message : IGRoomMessage?
    private var finalRoomType: IGRoom.IGType!
    private var finalRoom: IGRoom?
    private var isIncomming: Bool!
    private var shouldShowAvatar : Bool!
    private var isFromSameSender : Bool!
    private var isTextMessageNode: Bool = false
    private var bubbleImgNode : ASImageNode?
    private var shadowImgNode : ASImageNode?
    private var imgNode : ASImageNode?
    private var gifNode : ASDisplayNode?
    private var LiveStickerView : ASDisplayNode?
    private var NormalGiftStickerView : ASDisplayNode?
    private var btnPlay : ASButtonNode?
    
    //filenode
    private var txtTitleNode : ASTextNode?
    private var txtSizeNode : ASTextNode?
    private var txtAttachmentNode : ASTextNode?
    
    //contactnode
    private var contact: IGRoomMessageContact?
    private var txtPhoneNumbers : ASTextNode?
    private var txtPhoneIcon : ASTextNode?
    private var txtContactName : ASTextNode?
    private var txtEmails : ASTextNode?
    private var txtEmailIcon : ASTextNode?
    private var imgCover : ASImageNode?
    private var btnViewContact : ASButtonNode?
    //MusicNode
    private var txtMusicName : ASTextNode?
    private var txtMusicArtist : ASTextNode?
    private var btnStateNode : ASButtonNode?
    
    //lognode
    private var txtLogMessage : ASTextNode?
    private var progressNode : ASDisplayNode?
    private var bgTextNode : ASDisplayNode?
    private var bgProgressNode : ASDisplayNode?
    private var bgNode : ASDisplayNode?
    
    //voicenode
    private var txtCurrentTimeNode : ASTextNode?
    private var txtVoiceTimeNode : ASTextNode?
    var sliderNode : ASDisplayNode?
    
    //CardToCardReceipt
    private var txtTypeIcon: ASTextNode?
    private var txtTypeTitle : ASTextNode?
    private var txtAmount : ASTextNode?
    private var testNode : ASDisplayNode?
    private var hasShownMore : Bool = false
    // Date and Time
    private var txtTTLDate : ASTextNode?
    private var txtVALUEDate : ASTextNode?
    // Source Card Number
    private var txtTTLSourceCardNumber : ASTextNode?
    private var txtVALUESourceCardNumber : ASTextNode?
    // Destination Card Number
    private var txtTTLDestinationCardNumber : ASTextNode?
    private var txtVALUEDestinationCardNumber : ASTextNode?
    // Destination Bank Name
    private var txtTTLDestinationBankName : ASTextNode?
    private var txtVALUEDestinationBankName : ASTextNode?
    // Card Owner Name
    private var txtTTLCardOwnerName : ASTextNode?
    private var txtVALUECardOwnerName : ASTextNode?
    // Trace Number
    private var txtTTLTraceNumber : ASTextNode?
    private var txtVALUETraceNumber : ASTextNode?
    // Refrence Number
    private var txtTTLRefrenceNumber : ASTextNode?
    private var txtVALUERefrenceNumber : ASTextNode?
    // Seprators
    private var viewSepratorCardNum : ASDisplayNode?
    private var viewSepratorDesCardNum : ASDisplayNode?
    private var viewSepratorDesBankName : ASDisplayNode?
    private var viewSepratorOwnerName : ASDisplayNode?
    private var viewSepratorTraceNum : ASDisplayNode?
    private var viewSepratorTop : ASDisplayNode?
    private var viewSepratorDate : ASDisplayNode?
    // btnShowMore
    private var btnShowMore : ASButtonNode?
    
    //MoneyTransfer
    // Sender Name
    private var txtTTLSenderName : ASTextNode?
    private var txtVALUESenderName : ASTextNode?
    // Receiver Name
    private var txtTTLReciever : ASTextNode?
    private var txtVALUEReciever : ASTextNode?
    // Description
    private var txtTTLDesc : ASTextNode?
    private var txtVALUEDesc : ASTextNode?
    
    private var viewSepratorThree : ASDisplayNode?
    private var viewSepratorFour : ASDisplayNode?
    private var viewSepratorFive : ASDisplayNode?
    private var viewSepratorSix : ASDisplayNode?
    private var viewSepratorSeven : ASDisplayNode?
    private var viewSepratorOne : ASDisplayNode?
    private var viewSepratorTwo : ASDisplayNode?
    
    //TopUp
    private var viewSepratorEight : ASDisplayNode?
    private var viewSepratorNine : ASDisplayNode?
    private var viewSepratorTen : ASDisplayNode?
    private var txtTTLSenderPhoneNumber : ASTextNode?
    private var txtVALUESenderPhoneNumber : ASTextNode?
    private var txtTTLRecieverPhoneNumber : ASTextNode?
    private var txtVALUERecieverPhoneNumber : ASTextNode?
    private var txtTTLTopUpOperator : ASTextNode?
    private var txtVALUETopUpOperator : ASTextNode?
    private var txtTTLGateWay : ASTextNode?
    private var txtVALUEGateWay : ASTextNode?
    private var txtTTLOrderNumber : ASTextNode?
    private var txtVALUEOrderNumber : ASTextNode?
    
    
    
    
    private var avatarNode : ASAvatarView?
    
    private var indicatorViewAbs : ASDisplayNode?
    
    //only in channel
    private var lblEyeIcon : ASTextNode?
    private var lblEyeText : ASTextNode?
    private var lblLikeIcon : ASTextNode?
    private var lblLikeText : ASTextNode?
    private var lblDisLikeIcon : ASTextNode?
    private var lblDisLikeText : ASTextNode?
    
    // multiselect check node
    public var checkNode : ASTextNode?
    
    private var attachment: IGFile?
    private var subNode : ASDisplayNode?
    //    public var checkNode : ASTextNode?
    var hasReAction : Bool = false
    private var replyForwardViewNode : ASReplyForwardNode?
    private var txtNameNode : ASTextNode?
    
    private var txtTimeNode : ASTextNode?
    private var txtStatusNode : ASTextNode?
    private var index: IndexPath!
    
    
    // View Items
    private var nodeText : ASTextNode?
    private var nodeOnlyText : OnlyTextNode?
    
    private var imgPinMarker: ASImageNode?
    
    var pan: UIPanGestureRecognizer!
    var tapMulti: UITapGestureRecognizer!
    
    private var currentSwipeToReplyTranslation: CGFloat = 0.0
    private var swipeToReplyNode: ChatMessageSwipeToReplyNode?
    private var swipeToReplyFeedback: HapticFeedback?
    
    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?
    
    private var actorUsernameTitle: String?
    private var targetUserNameTitle: String?
    private var actorUser: IGRegisteredUser?
    private var targetUser: IGRegisteredUser?
    
    private var editTextNode: ASTextNode?
    
    private var channelForwardBtnNode : ASImageNode?
    
    override func didLoad() {
        super.didLoad()
    }
    override init() {
        super.init()
    }
//    deinit {
////        ForceFreeUPMemory()
//        recursivelyClearContents()
//        print("deinit is being called fr chatcontrollerNode")
//    }
    private func ForceFreeUPMemory() {
        if finalRoom != nil {
            finalRoom = nil
        }
        if message != nil {
            message = nil
        }
        if attachment != nil {
            attachment = nil
        }
        if imgNode != nil {
            imgNode = nil
        }
        if gifNode != nil {
            gifNode = nil
        }
        if bubbleImgNode != nil {
            bubbleImgNode = nil
        }
        if shadowImgNode != nil {
            shadowImgNode = nil
        }
        if txtNameNode != nil {
            txtNameNode = nil
        }
        if txtStatusNode != nil {
            txtStatusNode = nil
        }
        if nodeOnlyText != nil {
            nodeOnlyText = nil
        }
        if nodeText != nil {
            nodeText = nil
        }
        if replyForwardViewNode != nil {
            replyForwardViewNode = nil
        }
        if txtTimeNode != nil {
            txtTimeNode = nil
        }
        if LiveStickerView != nil {
            LiveStickerView = nil
        }
        if NormalGiftStickerView != nil {
            NormalGiftStickerView = nil
        }
        if btnPlay != nil {
            btnPlay = nil
        }
        if txtTitleNode != nil {
            txtTitleNode = nil
        }
        if txtSizeNode != nil {
            txtSizeNode = nil
        }
        if txtAttachmentNode != nil {
            txtAttachmentNode = nil
        }
        if txtPhoneNumbers != nil {
            txtPhoneNumbers = nil
        }
        if txtPhoneIcon != nil {
            txtPhoneIcon = nil
        }
        if txtContactName != nil {
            txtContactName = nil
        }
        if txtEmails != nil {
            txtEmails = nil
        }
        if txtEmailIcon != nil {
            txtEmailIcon = nil
        }
        if imgCover != nil {
            imgCover = nil
        }
        if btnViewContact != nil {
            btnViewContact = nil
        }
        if txtMusicName != nil {
            txtMusicName = nil
        }
        if txtMusicArtist != nil {
            txtMusicArtist = nil
        }
        if btnStateNode != nil {
            btnStateNode = nil
        }
        if txtLogMessage != nil {
            txtLogMessage = nil
        }
        if progressNode != nil {
            progressNode = nil
        }
        if bgTextNode != nil {
            bgTextNode = nil
        }
        if bgProgressNode != nil {
            bgProgressNode = nil
        }
        if bgNode != nil {
            bgNode = nil
        }
        if txtCurrentTimeNode != nil {
            txtCurrentTimeNode = nil
        }
        if txtVoiceTimeNode != nil {
            txtVoiceTimeNode = nil
        }
        if sliderNode != nil {
            sliderNode = nil
        }
        if txtTypeIcon != nil {
            txtTypeIcon = nil
        }
        if txtTypeTitle != nil {
            txtTypeTitle = nil
        }
        if txtAmount != nil {
            txtAmount = nil
        }
        if testNode != nil {
            testNode = nil
        }
        if txtTTLDate != nil {
            txtTTLDate = nil
        }
        if txtVALUEDate != nil {
            txtVALUEDate = nil
        }
        if txtTTLSourceCardNumber != nil {
            txtTTLSourceCardNumber = nil
        }
        if txtVALUESourceCardNumber != nil {
            txtVALUESourceCardNumber = nil
        }
        if txtTTLDestinationCardNumber != nil {
            txtTTLDestinationCardNumber = nil
        }
        if txtVALUEDestinationCardNumber != nil {
            txtVALUEDestinationCardNumber = nil
        }
        if txtTTLDestinationBankName != nil {
            txtTTLDestinationBankName = nil
        }
        if txtVALUEDestinationBankName != nil {
            txtVALUEDestinationBankName = nil
        }
        if txtTTLCardOwnerName != nil {
            txtTTLCardOwnerName = nil
        }
        if txtVALUECardOwnerName != nil {
            txtVALUECardOwnerName = nil
        }
        if txtTTLTraceNumber != nil {
            txtTTLTraceNumber = nil
        }
        if txtVALUETraceNumber != nil {
            txtVALUETraceNumber = nil
        }
        if txtTTLRefrenceNumber != nil {
            txtTTLRefrenceNumber = nil
        }
        if txtVALUERefrenceNumber != nil {
            txtVALUERefrenceNumber = nil
        }
        if viewSepratorCardNum != nil {
            viewSepratorCardNum = nil
        }
        if viewSepratorDesCardNum != nil {
            viewSepratorDesCardNum = nil
        }
        if viewSepratorDesBankName != nil {
            viewSepratorDesBankName = nil
        }
        if viewSepratorOwnerName != nil {
            viewSepratorOwnerName = nil
        }
        if viewSepratorTraceNum != nil {
            viewSepratorTraceNum = nil
        }
        if viewSepratorTop != nil {
            viewSepratorTop = nil
        }
        if viewSepratorDate != nil {
            viewSepratorDate = nil
        }
        if btnShowMore != nil {
            btnShowMore = nil
        }
        if txtTTLSenderName != nil {
            txtTTLSenderName = nil
        }
        if txtVALUESenderName != nil {
            txtVALUESenderName = nil
        }
        if txtTTLReciever != nil {
            txtTTLReciever = nil
        }
        if txtVALUEReciever != nil {
            txtVALUEReciever = nil
        }
        if txtTTLDesc != nil {
            txtTTLDesc = nil
        }
        if txtVALUEDesc != nil {
            txtVALUEDesc = nil
        }
        if viewSepratorThree != nil {
            viewSepratorThree = nil
        }
        if viewSepratorFour != nil {
            viewSepratorFour = nil
        }
        if viewSepratorFive != nil {
            viewSepratorFive = nil
        }
        if viewSepratorSix != nil {
            viewSepratorSix = nil
        }
        if viewSepratorSeven != nil {
            viewSepratorSeven = nil
        }
        if viewSepratorOne != nil {
            viewSepratorOne = nil
        }
        if viewSepratorTwo != nil {
            viewSepratorTwo = nil
        }
        if viewSepratorEight != nil {
            viewSepratorEight = nil
        }
        if viewSepratorNine != nil {
            viewSepratorNine = nil
        }
        if viewSepratorTen != nil {
            viewSepratorTen = nil
        }
        if txtTTLSenderPhoneNumber != nil {
            txtTTLSenderPhoneNumber = nil
        }
        if txtVALUESenderPhoneNumber != nil {
            txtVALUESenderPhoneNumber = nil
        }
        if txtTTLRecieverPhoneNumber != nil {
            txtTTLRecieverPhoneNumber = nil
        }
        if txtVALUERecieverPhoneNumber != nil {
            txtVALUERecieverPhoneNumber = nil
        }
        if txtTTLTopUpOperator != nil {
            txtTTLTopUpOperator = nil
        }
        if txtVALUETopUpOperator != nil {
            txtVALUETopUpOperator = nil
        }
        if txtTTLGateWay != nil {
            txtTTLGateWay = nil
        }
        if txtVALUEGateWay != nil {
            txtVALUEGateWay = nil
        }
        if txtTTLOrderNumber != nil {
            txtTTLOrderNumber = nil
        }
        if txtVALUEOrderNumber != nil {
            txtVALUEOrderNumber = nil
        }
        if avatarNode != nil {
            avatarNode = nil
        }
        if indicatorViewAbs != nil {
            indicatorViewAbs = nil
        }
        if lblEyeIcon != nil {
            lblEyeIcon = nil
        }
        if lblEyeText != nil {
            lblEyeText = nil
        }
        if lblLikeIcon != nil {
            lblLikeIcon = nil
        }
        if lblLikeText != nil {
            lblLikeText = nil
        }
        if lblEyeIcon != nil {
            lblEyeIcon = nil
        }
        if lblDisLikeIcon != nil {
            lblDisLikeIcon = nil
        }
        if lblDisLikeText != nil {
            lblDisLikeText = nil
        }
        if checkNode != nil {
            checkNode = nil
        }
        if attachment != nil {
            attachment = nil
        }
        if replyForwardViewNode != nil {
            replyForwardViewNode = nil
        }
        if txtNameNode != nil {
            txtNameNode = nil
        }
        if txtTimeNode != nil {
            txtTimeNode = nil
        }
        if txtStatusNode != nil {
            txtStatusNode = nil
        }
        if nodeText != nil {
            nodeText = nil
        }
        if nodeOnlyText != nil {
            nodeOnlyText = nil
        }
        if contact != nil {
            contact = nil
        }
         
        if swipeToReplyNode != nil {
            swipeToReplyNode = nil
        }
        if swipeToReplyFeedback != nil {
            swipeToReplyFeedback = nil
        }
    }
    
    func makeView(message: IGRoomMessage, finalRoomType : IGRoom.IGType,finalRoom : IGRoom,isIncomming: Bool, bubbleImage: UIImage, isFromSameSender: Bool, shouldShowAvatar: Bool, indexPath: IndexPath) {
        view.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        
        
        self.message = message
        self.finalRoom = finalRoom
        self.finalRoomType = finalRoomType
        self.isIncomming = isIncomming
        self.shouldShowAvatar = shouldShowAvatar
        self.isFromSameSender = isFromSameSender
        index = indexPath
        automaticallyManagesSubnodes = true
        
        
        var msg = message
        
        if message.repliedTo != nil {
            msg = message
            
        } else if let forwardedFrom = message.forwardedFrom {
            msg = forwardedFrom
        } else {
            msg = message
        }
        self.message = msg

        
        if msg.type == .text {
            isTextMessageNode = true
        }
        
        if finalRoom.type == .channel {
            
            if msg.type == .text ||  msg.type == .image ||  msg.type == .imageAndText || msg.type == .gif ||  msg.type == .gifAndText ||  msg.type == .file ||  msg.type == .fileAndText || msg.type == .voice  || msg.type == .video || msg.type == .videoAndText || msg.type == .audio ||  msg.type == .audioAndText || msg.type == .location {
                
                makeLikeDislikeIcons()
                
            }
            
        }
        
        if checkNode == nil {
            checkNode = ASTextNode()
            checkNode!.style.width = ASDimensionMake(.points, 0)
            checkNode!.style.height = ASDimensionMake(.points, 0)
        }
        
        if msg.type == .text || msg.type == .imageAndText || msg.type == .image || msg.type == .gif || msg.type == .gifAndText || msg.type == .video || msg.type == .videoAndText || msg.type == .file || msg.type == .fileAndText || msg.type == .contact || msg.type == .audio || msg.type == .audioAndText || msg.type == .voice  || msg.type == .wallet || msg.type == .location {
            let contentItemsBox : ASLayoutSpec
            if message.forwardedFrom != nil {
                self.message = message

                contentItemsBox = makeContentBubbleItems(msg: message) // make contents

            } else {
                contentItemsBox = makeContentBubbleItems(msg: msg) // make contents

            }
            //            contentItemsBox.style.maxWidth = ASDimensionMake(.points, 50)

            
            let baseBubbleBox = makeBubble(bubbleImage: bubbleImage,shouldShow: isOneCharEmoji ? false : true) // make bubble

            baseBubbleBox.child = contentItemsBox // add contents as child to bubble
            let isShowingAvatar = makeAvatarIfNeeded()
            
            if self.finalRoomType! == .channel {
                if channelForwardBtnNode == nil {
                    channelForwardBtnNode = ASImageNode()
                    channelForwardBtnNode?.alpha = 0.5
                }
                
                channelForwardBtnNode?.contentMode = .scaleAspectFit
                channelForwardBtnNode?.image = UIImage(named: "ig_message_forward")
                
//                self.onDidLoad {[weak self] (node) in
//                    guard let sSelf = self else {
//                        return
//                    }
                DispatchQueue.main.async {

                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.onMultiForwardTap(_:)))
                    self.channelForwardBtnNode?.view.addGestureRecognizer(tap)
                    self.channelForwardBtnNode?.view.isUserInteractionEnabled = true
                //                }
                                }
                
                
            }
            
            self.layoutSpecBlock = {[weak self] node, constrainedSize in
                guard let sSelf = self else {
                    return ASLayoutSpec()
                }
                let stack = ASStackLayoutSpec()
                stack.direction = .horizontal
                stack.spacing = 4
                stack.verticalAlignment = .bottom
                stack.horizontalAlignment = isIncomming ? .left : .right
                
                if isShowingAvatar {
                    baseBubbleBox.style.maxWidth = ASDimension(unit: .points, value: (UIScreen.main.bounds.width) - 100)
                    stack.children = isIncomming ? [sSelf.checkNode!, sSelf.avatarNode! ,baseBubbleBox] : [sSelf.checkNode!, baseBubbleBox, sSelf.avatarNode!]
                }else {
                    baseBubbleBox.style.maxWidth = ASDimension(unit: .points, value: (UIScreen.main.bounds.width) - 60)
                    
                    if sSelf.finalRoomType! == .channel {
                        sSelf.channelForwardBtnNode?.style.preferredSize = CGSize(width: 28, height: 28)
                        
                        let baseBubbleBoxWithForwardBtn = ASStackLayoutSpec(direction: .horizontal, spacing: 4, justifyContent: .start, alignItems: .start, children: [baseBubbleBox, sSelf.channelForwardBtnNode!])
                        baseBubbleBoxWithForwardBtn.verticalAlignment = .bottom
                        stack.children = [sSelf.checkNode!, baseBubbleBoxWithForwardBtn]
                    } else {
                        stack.children = [sSelf.checkNode!, baseBubbleBox]
                    }
                    
                    
                }
                stack.style.flexShrink = 1.0
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 6, bottom: isFromSameSender ? 1 : 10, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: isFromSameSender ? 1 : 10 , right: 5), child: stack)
                
                return insetHSpec
            }
            if message.forwardedFrom != nil {
                manageAttachment(file: message.forwardedFrom!.attachment,msg: message.forwardedFrom!)

            } else {
                manageAttachment(file: msg.attachment,msg: msg)

            }
            if IGGlobal.shouldMultiSelect {
                makeAccessoryButton(id: 0)
            }
            
        } else if msg.type == .sticker {
            
            
            let isShowingAvatar = makeAvatarIfNeeded()

            let contentItemsBox : ASLayoutSpec
            if message.forwardedFrom != nil {
                self.message = message

                contentItemsBox = makeContentBubbleItems(msg: message) // make contents

            } else {
                contentItemsBox = makeContentBubbleItems(msg: msg) // make contents

            }

            self.layoutSpecBlock = {[weak self] node, constrainedSize in
                guard let sSelf = self else {
                    return ASLayoutSpec()
                }
                let stack = ASStackLayoutSpec()
                stack.direction = .horizontal
                stack.spacing = 5
                stack.verticalAlignment = .bottom
                stack.horizontalAlignment = isIncomming ? .left : .right
                if isShowingAvatar {
                    contentItemsBox.style.maxWidth = ASDimension(unit: .points, value: (UIScreen.main.bounds.width) - 100)
                    stack.children = isIncomming ? [sSelf.checkNode!, sSelf.avatarNode! ,contentItemsBox] : [sSelf.checkNode!, contentItemsBox, sSelf.avatarNode!]
                }else {
                    contentItemsBox.style.maxWidth = ASDimension(unit: .points, value: (UIScreen.main.bounds.width) - 60)
                    stack.children = [sSelf.checkNode!, contentItemsBox]
                }
                
                stack.style.flexShrink = 1.0
                
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 6, bottom: isFromSameSender ? 1 : 10, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: isFromSameSender ? 1 : 10 , right: 5), child: stack)
                
                return insetHSpec
            }
            if message.forwardedFrom != nil {
                manageAttachment(file: message.forwardedFrom!.attachment,msg: message.forwardedFrom!)

            } else {
                manageAttachment(file: msg.attachment,msg: msg)

            }

            if IGGlobal.shouldMultiSelect {
                makeAccessoryButton(id: 0)
            }
            
        } else if msg.type == .log || msg.type == .time || msg.type == .unread || msg.type == .progress {
            let contentItemsBox = makeContentBubbleItems(msg: msg) // make contents
            
            self.layoutSpecBlock = {[weak self] node, constrainedSize in
                guard let sSelf = self else {
                    return ASLayoutSpec()
                }
                let stack = ASStackLayoutSpec()
                stack.direction = .horizontal
                stack.spacing = 5
                stack.verticalAlignment = .bottom
                stack.horizontalAlignment = .middle
                if msg.type == .log {
                    stack.children = [sSelf.checkNode!, contentItemsBox]
                }else {
                    stack.children = [contentItemsBox]
                }
                
                stack.style.flexShrink = 1.0
                
                
                let insetHSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom:  0 , right: 0), child: stack)
                
                return insetHSpec
            }
        }
        
        
        if msg.type != .wallet {
//            self.onDidLoad {[weak self] (node) in
//                guard let sSelf = self else {
//                    return
//                }
            DispatchQueue.main.async {[weak self] in
                guard let sSelf = self else {
                    return
                }
                sSelf.manageGestureRecognizers()
            }
//            }
            
        }
        
        if !(IGGlobal.shouldMultiSelect) && finalRoomType != .channel && msg.type != .unread && msg.type != .progress && msg.type != .time && msg.type != .wallet{
            makeSwipeToReply()
        }
        
    }
    
    func EnableDisableInteractions(mode: Bool = true) {
        if mode {
            isUserInteractionEnabled = false
            view.isUserInteractionEnabled = false
            for node in subnodes ?? [ASDisplayNode()] {
                node.isUserInteractionEnabled = false
            }
            
        } else {
            isUserInteractionEnabled = true
            view.isUserInteractionEnabled = true
            for node in subnodes ?? [ASDisplayNode()] {
                node.isUserInteractionEnabled = true
            }
        }
    }
    
    public func makeAccessoryButton(id: Int64) {
        //        print("CREATED ACCESSORY BUTTON")
        
        if message?.type == .log || message?.type == .time || message?.type == .unread || message?.type == .progress || message?.type == .wallet {
            return
        }
        
        addSubnode(checkNode!)
        
        if id == message?.id {
            checkNode!.view.tag = 002
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
                guard let sSelf = self else {
                    return
                }
                
                IGGlobal.makeAsyncText(for: sSelf.checkNode!, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 26, weight: .regular, numberOfLines: 1, font: .fontIcon, alignment: .center)
            }
            
            
        } else {
            checkNode!.view.tag = 001
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
                guard let sSelf = self else {
                    return
                }
                
                IGGlobal.makeAsyncText(for: sSelf.checkNode!, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 26, weight: .regular, numberOfLines: 1, font: .fontIcon, alignment: .center)
            }
            
        }
        checkNode!.style.width = ASDimensionMake(.points, 30)
        checkNode!.style.height = ASDimensionMake(.points, 30)
        
        setNeedsLayout()
    }
    
    public func removeAccessoryButton() {
        checkNode!.style.width = ASDimensionMake(.points, 0)
        checkNode!.style.height = ASDimensionMake(.points, 0)
        checkNode!.removeFromSupernode()
        setNeedsLayout()
    }
    
    private func makeLikeDislikeIcons() {
        
        if lblEyeIcon == nil {
            lblEyeIcon = ASTextNode()
        }
        if lblEyeText == nil {
            lblEyeText = ASTextNode()
        }
        if lblLikeIcon == nil {
            lblLikeIcon = ASTextNode()
        }
        if lblLikeText == nil {
            lblLikeText = ASTextNode()
        }
        if lblDisLikeIcon == nil {
            lblDisLikeIcon = ASTextNode()
        }
        if lblDisLikeText == nil {
            lblDisLikeText = ASTextNode()
        }
        
        var Color = ThemeManager.currentTheme.LabelColor
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

        if currentTheme != "IGAPClassic" {
            
            if currentTheme == "IGAPDay" {
                if currentColorSetLight == "IGAPBlack" {
                    Color = isIncomming ? UIColor.white : ThemeManager.currentTheme.LabelColor
                } else {
                    Color = ThemeManager.currentTheme.LabelColor
                }
            }
            if currentTheme == "IGAPNight" {
                if currentColorSetDark == "IGAPBlack" {
                    Color = isIncomming ? UIColor.white : ThemeManager.currentTheme.LabelColor
                } else {
                    Color = ThemeManager.currentTheme.LabelColor
                }

            }
        } else {
            Color = ThemeManager.currentTheme.LabelColor

        }

        IGGlobal.makeAsyncText(for: lblEyeIcon!, with: "🌣", textColor: Color, size: 18, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: lblLikeIcon!, with: "🌡", textColor: .iGapRed(), size: 18, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: lblDisLikeIcon!, with: "🌢", textColor: .iGapRed(), size: 18, numberOfLines: 1, font: .fontIcon, alignment: .center)
        
        
        manageVoteActions()
    }
    
    private func manageVoteActions(){
        
        if message!.channelExtra != nil {
            var messageVote: IGRoomMessage! = message!
            if let forward = message!.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
                messageVote = forward
            }
             if lblEyeIcon == nil {
                 lblEyeIcon = ASTextNode()
             }
             if lblEyeText == nil {
                 lblEyeText = ASTextNode()
             }
             if lblLikeIcon == nil {
                 lblLikeIcon = ASTextNode()
             }
             if lblLikeText == nil {
                 lblLikeText = ASTextNode()
             }
             if lblDisLikeIcon == nil {
                 lblDisLikeIcon = ASTextNode()
             }
             if lblDisLikeText == nil {
                 lblDisLikeText = ASTextNode()
             }
            var Color = ThemeManager.currentTheme.LabelColor
            let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
            let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
            let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

            if currentTheme != "IGAPClassic" {
                
                if currentTheme == "IGAPDay" {
                    if currentColorSetLight == "IGAPBlack" {
                        Color = isIncomming ? UIColor.white : ThemeManager.currentTheme.LabelColor
                    } else {
                        Color = ThemeManager.currentTheme.LabelColor
                    }
                }
                if currentTheme == "IGAPNight" {
                    if currentColorSetDark == "IGAPBlack" {
                        Color = isIncomming ? UIColor.white : ThemeManager.currentTheme.LabelColor
                    } else {
                        Color = ThemeManager.currentTheme.LabelColor
                    }

                }
            } else {
                Color = ThemeManager.currentTheme.LabelColor

            }
            IGGlobal.makeAsyncText(for: lblEyeText!, with: (messageVote.channelExtra?.viewsLabel ?? "1").inLocalizedLanguage(), textColor: Color, size: 13, numberOfLines: 1, font: .igapFont, alignment: .center)
            
            
            if let channel = messageVote.authorRoom?.channelRoom, channel.hasReaction {
                hasReAction = true
                
                IGGlobal.makeAsyncText(for: lblLikeText!, with: (messageVote.channelExtra?.thumbsUpLabel ?? "0").inLocalizedLanguage(), textColor: Color, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                IGGlobal.makeAsyncText(for: lblDisLikeText!, with: (messageVote.channelExtra?.thumbsDownLabel ?? "0").inLocalizedLanguage(), textColor: Color, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                
            } else {
                hasReAction = false
                
                lblLikeIcon?.removeFromSupernode()
                lblLikeText?.removeFromSupernode()
                lblDisLikeIcon?.removeFromSupernode()
                lblDisLikeText?.removeFromSupernode()
            }
            
            var roomId = messageVote.authorRoom?.id
            if roomId == nil {
                roomId = messageVote.roomId
            }
            IGHelperGetMessageState.shared.getMessageState(roomId: roomId!, messageId: messageVote.id)
        } else {
            lblEyeIcon?.removeFromSupernode()
            lblEyeText?.removeFromSupernode()
            lblLikeIcon?.removeFromSupernode()
            lblLikeText?.removeFromSupernode()
            lblDisLikeIcon?.removeFromSupernode()
            lblDisLikeText?.removeFromSupernode()
            
        }
    }
    
    func updateVoteActions(channelExtra: IGRealmChannelExtra?) {
        message?.channelExtra = channelExtra
        manageVoteActions()
    }
    
    func updateAvatar(userId: Int64, completion: @escaping(()->Void)) {
        
        IGUserInfoRequest.sendRequestAvoidDuplicate(userId: userId) { [weak self] (userInfo) in
            DispatchQueue.main.async {[weak self] in
                guard let sSelf = self else {
                    return
                }
                if let msg = sSelf.message {
                    if !msg.isInvalidated, let authorUser = msg.authorUser, !authorUser.isInvalidated {
                        if let peerId = msg.authorUser?.userId, userInfo.igpID == peerId {
                            completion()
                        }
                    }
                }
            }
        }
        
        
    }
    
    private func makeAvatarIfNeeded() -> Bool {
        
        if finalRoomType == .channel || finalRoomType == .chat {
            return false
        }
        
        if isIncomming {
            if shouldShowAvatar {
                
                // Make avatar Here
                if avatarNode == nil {
                    avatarNode = ASAvatarView()
                    avatarNode!.style.preferredSize = CGSize(width: 45, height: 45)
                    avatarNode!.cornerRadius = 22.5
                    avatarNode!.clipsToBounds = true
                }
                
                if isFromSameSender {
                    avatarNode?.alpha = 0
                    return true
                }else {
                    avatarNode?.alpha = 1
                }
                
                if let user = message?.authorUser?.user {
                    
                    avatarNode?.avatarASImageView?.backgroundColor = .clear
                    avatarNode?.setUser(user.detach())
                    
                }else if let userId = message?.authorUser?.userId {
                    
                    avatarNode?.avatarASImageView?.backgroundColor = .white
                    avatarNode?.avatarASImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
//                    SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(message!.roomId)", sender: (action: ChatMessageAction.userInfo, userId: userId))
                    updateAvatar(userId: userId) {[weak self] in
                        guard let sSelf = self else {
                            return
                        }
                        _ = sSelf.makeAvatarIfNeeded()
                    }
                }
                return true
            }
        }
        
        // Remove Avatar if above conditions are not True
        if avatarNode != nil {
            if subnodes!.contains(avatarNode!) {
                avatarNode?.removeFromSupernode()
            }
            avatarNode = nil
        }
        
        return false
        
    }
    
    private func makeBubble(bubbleImage : UIImage,shouldShow: Bool = true) -> ASLayoutSpec {
        if bubbleImgNode == nil {
            bubbleImgNode = ASImageNode()
        }
        if shadowImgNode == nil {
            shadowImgNode = ASImageNode()
        }
        if shouldShow {
            bubbleImgNode!.image = bubbleImage
            shadowImgNode!.image = bubbleImage
        }
        
        //        addSubnode(shadowImgNode!)//addshadow
        //        addSubnode(bubbleImgNode!)
        bubbleImgNode!.imageModificationBlock = ASImageNodeTintColorModificationBlock(isIncomming ? ThemeManager.currentTheme.ReceiveMessageBubleBGColor : ThemeManager.currentTheme.SendMessageBubleBGColor)
        shadowImgNode!.imageModificationBlock = ASImageNodeTintColorModificationBlock(.darkGray)
        shadowImgNode!.alpha = 0.3
        //MARK :-BUBBLE IMAGE AND SHADOW IMAGE
        let baseSpec = ASBackgroundLayoutSpec()
        if isIncomming {
            let insetShadowBox = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0 , left: 0, bottom: 1, right: 1), child: bubbleImgNode!)
            let overlayShadowBox = ASOverlayLayoutSpec(child: shadowImgNode!, overlay: insetShadowBox)
            
            baseSpec.background = overlayShadowBox
            
        } else {
            let insetShadowBox = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0 , left: 1, bottom: 1, right: 0), child: bubbleImgNode!)
            let overlayShadowBox = ASOverlayLayoutSpec(child: shadowImgNode!, overlay: insetShadowBox)
            
            baseSpec.background = overlayShadowBox
            
        }
        return baseSpec
    }
    private func makeTopBubbleItems(stack: ASLayoutSpec) {
        
        if finalRoomType == .group && isIncomming {
            if message?.type != .sticker && message?.type != .log && message?.type != .unread {
                if txtNameNode == nil {
                    txtNameNode = ASTextNode()
                    txtNameNode!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
                    txtNameNode!.style.minHeight = ASDimensionMake(.points, 20)
                }
                setSenderName() // set text for txtNameNode(sender name)
                let insetBox = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0), child: txtNameNode!)
                stack.children?.insert(insetBox, at: 0)
                
            }
        }
        var layoutMsg = message?.detach()
        
        //check if has reply or Forward
        if let repliedMessage = message?.repliedTo {
            layoutMsg = repliedMessage.detach()
            if replyForwardViewNode == nil {
                replyForwardViewNode = ASReplyForwardNode()
            }
            stack.children?.append(replyForwardViewNode!)
            replyForwardViewNode!.setReplyForward(isReply: true, extraMessage : layoutMsg!,isIncomming : isIncomming)
        } else if let forwardedFrom = message?.forwardedFrom {
            layoutMsg = forwardedFrom.detach()
            if replyForwardViewNode == nil {
                replyForwardViewNode = ASReplyForwardNode()
            }
            
            if message?.type != .log {
                stack.children?.append(replyForwardViewNode!)
                replyForwardViewNode!.setReplyForward(isReply: false, extraMessage : layoutMsg!,isIncomming : isIncomming)
                
            }
        } else {}
        
        
    }
    private func makeContentBubbleItems(msg: IGRoomMessage?) ->ASLayoutSpec {
        let contentSpec = ASStackLayoutSpec()
        contentSpec.direction = .vertical
        contentSpec.style.flexShrink = 1.0
        contentSpec.style.flexGrow = 1.0
        contentSpec.alignItems = .stretch
        contentSpec.spacing = 5
        contentSpec.horizontalAlignment = .none
        
        let TMPwidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
        
        contentSpec.style.maxLayoutSize = ASLayoutSize(width: TMPwidth, height: ASDimension(unit: .points, value: CGFloat.greatestFiniteMagnitude))
        var tmpmsg: IGRoomMessage
        tmpmsg = msg!
        if msg?.forwardedFrom != nil  {
            tmpmsg = msg!.forwardedFrom!
        }
        switch tmpmsg.type {
        case .text :
            let finalBox = setTextNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .image,.imageAndText :
            let finalBox = setImageNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .video,.videoAndText :
            let finalBox = setVideoNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .gif,.gifAndText :
            let finalBox = setGifNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .file,.fileAndText :
            let finalBox = setFileNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .contact :
            let finalBox = setContactNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .audioAndText,.audio :
            let finalBox = setAudioNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .voice :
            let finalBox = setVoiceNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .sticker :
            let finalBox = setStickerNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .location:
            let finalBox = setLocationNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        case .wallet :
            if tmpmsg.wallet?.type == IGPRoomMessageWallet.IGPType.cardToCard.rawValue { //mode: CardToCard
                let finalBox = setCardToCardNodeContent(contentSpec: contentSpec, msg: tmpmsg)
                return finalBox
            } else if tmpmsg.wallet?.type == IGPRoomMessageWallet.IGPType.moneyTransfer.rawValue { //mode: moneyTransfer
                let finalBox = setMoneyTransferNodeContent(contentSpec: contentSpec, msg: tmpmsg)
                return finalBox
            } else if tmpmsg.wallet?.type == IGPRoomMessageWallet.IGPType.topup.rawValue { //mode: topup
                let finalBox = setTopUpNodeContent(contentSpec: contentSpec, msg: tmpmsg)
                return finalBox
            }  else if tmpmsg.wallet?.type == IGPRoomMessageWallet.IGPType.bill.rawValue { //mode: topup
                let finalBox = setPayBillNodeContent(contentSpec: contentSpec, msg: tmpmsg)
                return finalBox
            } else {
                let finalBox = setMoneyTransferNodeContent(contentSpec: contentSpec, msg: tmpmsg)
                return finalBox
                
            }
            
            
            
        case .log,.time,.unread,.progress :
            contentSpec.horizontalAlignment = .middle
            
            var logTypeTemp : logMessageType!
            
            
            switch tmpmsg.type {
            case .log :
                logTypeTemp = .log
            case .time :
                logTypeTemp = .time
            case .unread :
                logTypeTemp = .unread
            case .progress :
                logTypeTemp = .progress
                
            default:
                break
            }
            
            let finalBox = setLogNodeContent(contentSpec: contentSpec, msg: tmpmsg,logType: logTypeTemp)
            return finalBox
        default :
            let finalBox = setTextNodeContent(contentSpec: contentSpec, msg: tmpmsg)
            return finalBox
        }
        
    }
    
    private func makeTextNodeBottomBubbleItems() {
        setTime()
        if isIncomming  {} else {
            setMessageStatus()
        }
        
        if isIncomming {
            txtTimeNode?.style.alignSelf = .end
        } else {}
        
    }
    private func makeVoteItems(contentStack: ASLayoutSpec) {
        
        if finalRoomType! == .channel {
            
            var likeDislikeStack = ASStackLayoutSpec()
            if hasReAction {
                likeDislikeStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .start, children: [lblEyeIcon!,lblEyeText!,lblLikeIcon!,lblLikeText!,lblDisLikeIcon!,lblDisLikeText!])
                likeDislikeStack.verticalAlignment = .center
            } else {
                likeDislikeStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .start, children: [lblEyeIcon!,lblEyeText!])
                likeDislikeStack.verticalAlignment = .center
                
            }
            
            let holderStack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .spaceBetween, alignItems: .start, children: [likeDislikeStack,txtTimeNode!])
            contentStack.children?.append(holderStack)
            return
            
        }
    }
    private func makeBottomBubbleItems(contentStack: ASLayoutSpec) {
        
        setTime()
        
        if finalRoomType! == .channel {
                   
            var likeDislikeStack = ASStackLayoutSpec()
            if hasReAction {
               likeDislikeStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .start, children: [lblEyeIcon!,lblEyeText!,lblLikeIcon!,lblLikeText!,lblDisLikeIcon!,lblDisLikeText!])
               likeDislikeStack.verticalAlignment = .center
            } else {
               likeDislikeStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .start, children: [lblEyeIcon!,lblEyeText!])
               likeDislikeStack.verticalAlignment = .center
               
            }

            if message!.isEdited {
                
                if editTextNode == nil {
                    editTextNode = ASTextNode()
                    IGGlobal.makeAsyncText(for: editTextNode!, with: IGStringsManager.Edited.rawValue.localized, textColor: isIncomming ? ThemeManager.currentTheme.MessageTextReceiverColor : UIColor.chatTimeTextColor(), size: 9, font: .igapFont, alignment: .center)
                }
                
                let holderStack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .spaceBetween, alignItems: .start, children: [likeDislikeStack, editTextNode!, txtTimeNode!])
                contentStack.children?.append(holderStack)
            }else {
                let holderStack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .spaceBetween, alignItems: .start, children: [likeDislikeStack,txtTimeNode!])
                contentStack.children?.append(holderStack)
            }

            return
           
       }
        
        if isIncomming  {} else {
            setMessageStatus()
        }
        
        if isIncomming {
            
            if message!.isEdited {
                if editTextNode == nil {
                    editTextNode = ASTextNode()
                    IGGlobal.makeAsyncText(for: editTextNode!, with: IGStringsManager.Edited.rawValue.localized, textColor: isIncomming ? ThemeManager.currentTheme.MessageTextReceiverColor : UIColor.chatTimeTextColor(), size: 9, font: .igapFont, alignment: .center)
                }
                
                let hStack = ASStackLayoutSpec(direction: .horizontal, spacing: 2, justifyContent: .end, alignItems: .notSet, children: [editTextNode!, txtTimeNode!])
                
                contentStack.children?.append(hStack)
            }else {
                contentStack.children?.append(txtTimeNode!)
                txtTimeNode?.style.alignSelf = .end
            }
            
            
            
        } else {
            
            if message!.isEdited {
                if editTextNode == nil {
                    editTextNode = ASTextNode()
                    IGGlobal.makeAsyncText(for: editTextNode!, with: IGStringsManager.Edited.rawValue.localized, textColor: isIncomming ? ThemeManager.currentTheme.MessageTextReceiverColor : UIColor.chatTimeTextColor(), size: 9, font: .igapFont, alignment: .center)
                }
//                contentStack.children?.append(txtTimeNode!)
                let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode!,txtStatusNode!, editTextNode!])
                timeStatusStack.verticalAlignment = .center
                contentStack.children?.append(timeStatusStack)
            } else {
                
                let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode!,txtStatusNode!])
                timeStatusStack.verticalAlignment = .center
                contentStack.children?.append(timeStatusStack)
            }
            
        }
        
        
        
    }
    private func setTime() {
        if let time = message!.creationTime {
            if txtTimeNode == nil {
                txtTimeNode = ASTextNode()
            }
            txtTimeNode?.style.minHeight = ASDimensionMake(.points, 10)
            txtTimeNode?.style.maxWidth = ASDimensionMake(.points, 50)
            var tmpcolor = UIColor()

            if message?.type == .sticker {
                tmpcolor = .white
                txtTimeNode!.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 0), bottom: 0, right: (isIncomming ? 0 : 0))

            } else {
                tmpcolor = ThemeManager.currentTheme.timeColor
                txtTimeNode!.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))

            }


            IGGlobal.makeAsyncText(for: txtTimeNode!, with: time.convertToHumanReadable(), textColor: isOneCharEmoji ? .white : tmpcolor ,size: 11, weight: isOneCharEmoji ? .bold : .regular, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
    }
    func updatMessage(action: ChatMessageAction = .none,status: IGRoomMessageStatus = .unknown,message: IGRoomMessage?) {

        switch action {
        case .updateStatus :
            print("=-=-=-=-=-UPDATING CELL STATUS")
            setMessageStatus(status: status)
        case .edit :
            print("=-=-=-=-=-UPDATING MESSAGE TEXT")
            self.message = message
            setMessage()
        default :
            print("=-=-=-=-=-UPDATING OTHER PARAMETERS")

            break
        }
        
    }
    private func setMessageStatus(status: IGRoomMessageStatus = .unknown) {
        
        if txtStatusNode == nil {
            txtStatusNode = ASTextNode()
        }
        txtStatusNode?.style.minHeight = ASDimensionMake(.points, 10)
        txtStatusNode?.style.maxWidth = ASDimensionMake(.points, 20)
        if status != .unknown {

            switch status {
            case .sending:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let Color = ThemeManager.currentTheme.LabelColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .sent:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let Color = ThemeManager.currentTheme.LabelColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .delivered:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let Color = ThemeManager.currentTheme.LabelColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .seen,.listened:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
                    let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
                    if currentTheme == "IGAPDay" || currentTheme == "IGAPNight" {
                        if currentColorSetLight == "IGAPBlack" {
                            IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                        } else {
                            IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                        }
                    } else {
                        IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                    }
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .failed, .unknown:
                IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .failedColor(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            }
        } else {

            switch message!.status {
            case .sending:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let Color = ThemeManager.currentTheme.LabelColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .sent:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let Color = ThemeManager.currentTheme.LabelColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .delivered:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let Color = ThemeManager.currentTheme.LabelColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .seen,.listened:
                if isIncomming {
                    let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                    IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                } else {
                    let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
                    let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
                    if currentTheme == "IGAPDay" || currentTheme == "IGAPNight" {
                        if currentColorSetLight == "IGAPBlack" {
                            IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                        } else {
                            IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                        }
                    } else {
                        IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                    }
                }
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            case .failed, .unknown:
                IGGlobal.makeAsyncText(for: txtStatusNode!, with: "", textColor: .failedColor(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                txtStatusNode!.backgroundColor = UIColor.clear
                break
            }
        }
    }
    private func setSenderName() {
        if !(finalRoomType == .chat) {
            if let name = message!.authorUser?.user {
                txtNameNode!.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeAsyncText(for: txtNameNode!, with: name.displayName, textColor: UIColor.hexStringToUIColor(hex: (message!.authorUser?.user!.color)!), size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
            } else {
                txtNameNode!.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeAsyncText(for: txtNameNode!, with: "", textColor: ThemeManager.currentTheme.LabelGrayColor, size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
        }
    }
    //******************************************************//
    //*****************BILL RECIEPT NODE********************//
    //******************************************************//
    private func initPayBillItems() {
        
        initPayBillTextNodeItemns()
        
        initPayBillSeprators()
    }
    private func initPayBillSeprators() {
        if testNode == nil {
            testNode = ASDisplayNode()
        }
        
        if viewSepratorThree == nil {
            viewSepratorThree = ASDisplayNode()
        }
        if viewSepratorFour == nil {
            viewSepratorFour = ASDisplayNode()
        }
        if viewSepratorFive == nil {
            viewSepratorFive = ASDisplayNode()
        }
        if viewSepratorSix == nil {
            viewSepratorSix = ASDisplayNode()
        }
        if viewSepratorSeven == nil {
            viewSepratorSeven = ASDisplayNode()
        }
        if viewSepratorOne == nil {
            viewSepratorOne = ASDisplayNode()
        }
        if viewSepratorTwo == nil {
            viewSepratorTwo = ASDisplayNode()
        }
        if viewSepratorEight == nil {
            viewSepratorEight = ASDisplayNode()
        }
        if viewSepratorNine == nil {
            viewSepratorNine = ASDisplayNode()
        }
        if viewSepratorTen == nil {
            viewSepratorTen = ASDisplayNode()
        }
        
        
    }
    private func initPayBillTextNodeItemns() {
        
        if txtTypeIcon == nil {
            txtTypeIcon = ASTextNode()
        }
        if txtTypeTitle == nil {
            txtTypeTitle = ASTextNode()
        }
        if txtAmount == nil {
            txtAmount = ASTextNode()
        }
        
        if txtTTLDate == nil {
            txtTTLDate = ASTextNode()
        }
        if txtVALUEDate == nil {
            txtVALUEDate = ASTextNode()
        }
        if txtTTLSenderPhoneNumber == nil {
            txtTTLSenderPhoneNumber = ASTextNode()
        }
        if txtVALUESenderPhoneNumber == nil {
            txtVALUESenderPhoneNumber = ASTextNode()
        }
        if txtTTLRecieverPhoneNumber == nil {
            txtTTLRecieverPhoneNumber = ASTextNode()
        }
        if txtVALUERecieverPhoneNumber == nil {
            txtVALUERecieverPhoneNumber = ASTextNode()
        }
        if txtTTLTopUpOperator == nil {
            txtTTLTopUpOperator = ASTextNode()
        }
        if txtVALUETopUpOperator == nil {
            txtVALUETopUpOperator = ASTextNode()
        }
        if txtVALUETopUpOperator == nil {
            txtVALUETopUpOperator = ASTextNode()
        }
        
        if txtTTLSourceCardNumber == nil {
            txtTTLSourceCardNumber = ASTextNode()
        }
        if txtVALUESourceCardNumber == nil {
            txtVALUESourceCardNumber = ASTextNode()
        }
        if txtVALUETraceNumber == nil {
            txtVALUETraceNumber = ASTextNode()
        }
        if txtTTLTraceNumber == nil {
            txtTTLTraceNumber = ASTextNode()
        }
        if txtTTLRefrenceNumber == nil {
            txtTTLRefrenceNumber = ASTextNode()
        }
        if txtVALUERefrenceNumber == nil {
            txtVALUERefrenceNumber = ASTextNode()
        }
        if txtTTLOrderNumber == nil {
            txtTTLOrderNumber = ASTextNode()
        }
        if txtVALUEOrderNumber == nil {
            txtVALUEOrderNumber = ASTextNode()
        }
        if txtTTLGateWay == nil {
            txtTTLGateWay = ASTextNode()
        }
        if txtVALUEGateWay == nil {
            txtVALUEGateWay = ASTextNode()
        }
        
        
        
    }
    private func makePayBillView(message: IGRoomMessage) {
        initPayBillItems()
        if btnShowMore == nil {
            btnShowMore = ASButtonNode()
        }
        
        IGGlobal.makeAsyncText(for: txtTypeIcon!, with: "", textColor: UIColor.iGapPink(), size: 40, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTypeTitle!, with: IGStringsManager.PayBills.rawValue.localized + "                              ", textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        if let amount = (message.wallet?.bill?.amount) {
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: String(amount).inRialFormat() + " " + IGStringsManager.Currency.rawValue.localized
                , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        }
        else{
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: "..." , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        //
        viewSepratorOne!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTwo!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorThree!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFour!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFive!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSix!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSeven!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorEight!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorNine!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTen!.backgroundColor = ThemeManager.currentTheme.LabelColor
        //
        btnShowMore!.style.height = ASDimensionMake(.points, 50)
        btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .white, for: .normal)
        let TMPwidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
        
        btnShowMore?.style.width = ASDimensionMake(.points, 250)

        //
        let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLOrderNumber!,txtVALUEOrderNumber!,txtTTLGateWay!,txtVALUEGateWay!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
        for elemnt in elemArray {
            elemnt.style.preferredSize = CGSize.zero
        }
        //
        btnShowMore!.backgroundColor = UIColor.iGapPink()
        btnShowMore!.layer.cornerRadius = 10.0
        btnShowMore!.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
        //
        
        setPayBillData(message: message)
        
        
    }
    
    private func setPayBillData(message: IGRoomMessage) {
        //TITLES SET DATA
        IGGlobal.makeAsyncText(for: txtTTLDate!, with: IGStringsManager.DateTime.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLSenderPhoneNumber!, with: IGStringsManager.BillType.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLRecieverPhoneNumber!, with: IGStringsManager.BillId.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLTopUpOperator!, with: IGStringsManager.PayIdentifier.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLSourceCardNumber!, with: IGStringsManager.CardNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLOrderNumber!, with: IGStringsManager.OrderId.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLGateWay!, with: IGStringsManager.TerminalId.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLTraceNumber!, with: IGStringsManager.TraceNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLRefrenceNumber!, with: IGStringsManager.RefrenceNum.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        
        //VALUES SET DATA
        if let time = TimeInterval(exactly: (message.wallet?.bill!.requestTime)!) {
            
            IGGlobal.makeAsyncText(for: txtVALUEDate!, with: Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
        if let senderUser = (message.wallet?.bill?.billType) {
            IGGlobal.makeAsyncText(for: txtVALUESenderPhoneNumber!, with: senderUser, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        
        if let receiverUser = (message.wallet?.bill?.billId) {
            IGGlobal.makeAsyncText(for: txtVALUERecieverPhoneNumber!, with: receiverUser.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let chargeOperator = (message.wallet?.bill?.payId) {
            IGGlobal.makeAsyncText(for: txtVALUETopUpOperator!, with: chargeOperator.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

        }
        if let cardNumber = (message.wallet?.bill?.cardNumber) {
            IGGlobal.makeAsyncText(for: txtVALUESourceCardNumber!, with: cardNumber, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let orderNumber = (message.wallet?.bill?.orderId) {
            IGGlobal.makeAsyncText(for: txtVALUEOrderNumber!, with: String(orderNumber).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let terminalNumber = (message.wallet?.bill?.terminalNo) {
            IGGlobal.makeAsyncText(for: txtVALUEGateWay!, with: String(terminalNumber).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let traceNum = (message.wallet?.bill!.traceNumber) {
            IGGlobal.makeAsyncText(for: txtVALUETraceNumber!, with: String(traceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        if let invoiceNum = (message.wallet?.bill!.rrn) {
            IGGlobal.makeAsyncText(for: txtVALUERefrenceNumber!, with: String(invoiceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
        
        self.message = message
        
    }
    private func layoutPayBill(msg: IGRoomMessage) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTypeTitle!, txtAmount!]
        
        
        let profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        profileBox.children = [txtTypeIcon!, textBox]
        
        let mainBox = ASStackLayoutSpec.vertical()
        mainBox.justifyContent = .spaceAround
        mainBox.children = [profileBox]
        let elemArray : [ASLayoutElement] = [viewSepratorOne!,txtTTLDate!,txtVALUEDate!,viewSepratorTwo!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,viewSepratorThree!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,viewSepratorFour!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,viewSepratorFive!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,viewSepratorSix!,txtTTLOrderNumber!,txtVALUEOrderNumber!,viewSepratorSeven!,txtTTLGateWay!,txtVALUEGateWay!,viewSepratorEight!,txtTTLTraceNumber!,txtVALUETraceNumber!,viewSepratorNine!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
        
        for elemnt in elemArray {
            mainBox.children?.append(elemnt)
        }
        mainBox.children?.append(btnShowMore!)
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [viewSepratorOne!,txtTTLDate!,txtVALUEDate!,viewSepratorTwo!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,viewSepratorThree!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,viewSepratorFour!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,viewSepratorFive!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,viewSepratorSix!,txtTTLOrderNumber!,txtVALUEOrderNumber!,viewSepratorSeven!,txtTTLGateWay!,txtVALUEGateWay!,viewSepratorEight!,txtTTLTraceNumber!,txtVALUETraceNumber!,viewSepratorNine!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!,textBox,profileBox,mainBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 20), child: mainBox)
        
        
        return insetSpec
    }
    
    private func setPayBillNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makePayBillView(message: msg)
        return layoutPayBill(msg: msg)
    }
    
    
    //******************************************************//
    //*****************TOPUP RECIEPT NODE*******************//
    //******************************************************//
    private func initTopUpItems() {
        
        initTopUpTextNodeItemns()
        
        initTopUpSeprators()
    }
    private func initTopUpSeprators() {
        if testNode == nil {
            testNode = ASDisplayNode()
        }
        
        if viewSepratorThree == nil {
            viewSepratorThree = ASDisplayNode()
        }
        if viewSepratorFour == nil {
            viewSepratorFour = ASDisplayNode()
        }
        if viewSepratorFive == nil {
            viewSepratorFive = ASDisplayNode()
        }
        if viewSepratorSix == nil {
            viewSepratorSix = ASDisplayNode()
        }
        if viewSepratorSeven == nil {
            viewSepratorSeven = ASDisplayNode()
        }
        if viewSepratorOne == nil {
            viewSepratorOne = ASDisplayNode()
        }
        if viewSepratorTwo == nil {
            viewSepratorTwo = ASDisplayNode()
        }
        if viewSepratorEight == nil {
            viewSepratorEight = ASDisplayNode()
        }
        if viewSepratorNine == nil {
            viewSepratorNine = ASDisplayNode()
        }
        if viewSepratorTen == nil {
            viewSepratorTen = ASDisplayNode()
        }
        
        
    }
    private func initTopUpTextNodeItemns() {
        
        if txtTypeIcon == nil {
            txtTypeIcon = ASTextNode()
        }
        if txtTypeTitle == nil {
            txtTypeTitle = ASTextNode()
        }
        if txtAmount == nil {
            txtAmount = ASTextNode()
        }
        
        if txtTTLDate == nil {
            txtTTLDate = ASTextNode()
        }
        if txtVALUEDate == nil {
            txtVALUEDate = ASTextNode()
        }
        if txtTTLSenderPhoneNumber == nil {
            txtTTLSenderPhoneNumber = ASTextNode()
        }
        if txtVALUESenderPhoneNumber == nil {
            txtVALUESenderPhoneNumber = ASTextNode()
        }
        if txtTTLRecieverPhoneNumber == nil {
            txtTTLRecieverPhoneNumber = ASTextNode()
        }
        if txtVALUERecieverPhoneNumber == nil {
            txtVALUERecieverPhoneNumber = ASTextNode()
        }
        if txtTTLTopUpOperator == nil {
            txtTTLTopUpOperator = ASTextNode()
        }
        if txtVALUETopUpOperator == nil {
            txtVALUETopUpOperator = ASTextNode()
        }
        if txtVALUETopUpOperator == nil {
            txtVALUETopUpOperator = ASTextNode()
        }
        
        if txtTTLSourceCardNumber == nil {
            txtTTLSourceCardNumber = ASTextNode()
        }
        if txtVALUESourceCardNumber == nil {
            txtVALUESourceCardNumber = ASTextNode()
        }
        if txtVALUETraceNumber == nil {
            txtVALUETraceNumber = ASTextNode()
        }
        if txtTTLTraceNumber == nil {
            txtTTLTraceNumber = ASTextNode()
        }
        if txtTTLRefrenceNumber == nil {
            txtTTLRefrenceNumber = ASTextNode()
        }
        if txtVALUERefrenceNumber == nil {
            txtVALUERefrenceNumber = ASTextNode()
        }
        if txtTTLOrderNumber == nil {
            txtTTLOrderNumber = ASTextNode()
        }
        if txtVALUEOrderNumber == nil {
            txtVALUEOrderNumber = ASTextNode()
        }
        if txtTTLGateWay == nil {
            txtTTLGateWay = ASTextNode()
        }
        if txtVALUEGateWay == nil {
            txtVALUEGateWay = ASTextNode()
        }
        
        
        
    }
    private func makeTopUpView(message: IGRoomMessage) {
        initTopUpItems()
        if btnShowMore == nil {
            btnShowMore = ASButtonNode()
        }
        
        IGGlobal.makeAsyncText(for: txtTypeIcon!, with: "", textColor: UIColor.iGapPurple(), size: 40, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTypeTitle!, with: IGStringsManager.TopUp.rawValue.localized + "                              ", textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        if let amount = (message.wallet?.topup?.amount) {
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: String(amount).inRialFormat() + " " + IGStringsManager.Currency.rawValue.localized
                , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        }
        else{
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: "..." , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        //
        viewSepratorOne!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTwo!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorThree!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFour!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFive!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSix!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSeven!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorEight!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorNine!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTen!.backgroundColor = ThemeManager.currentTheme.LabelColor
        //
        btnShowMore!.style.height = ASDimensionMake(.points, 50)
        btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .white, for: .normal)
        btnShowMore?.style.width = ASDimensionMake(.points, 250)

        //
        let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLOrderNumber!,txtVALUEOrderNumber!,txtTTLGateWay!,txtVALUEGateWay!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
        for elemnt in elemArray {
            elemnt.style.preferredSize = CGSize.zero
        }
        //
        btnShowMore!.backgroundColor = UIColor.iGapPurple()
        btnShowMore!.layer.cornerRadius = 10.0
        btnShowMore!.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
        //
        
        setTopUpData(message: message)
        
        
    }
    
    private func setTopUpData(message: IGRoomMessage) {
        //TITLES SET DATA
        IGGlobal.makeAsyncText(for: txtTTLDate!, with: IGStringsManager.DateTime.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLSenderPhoneNumber!, with: IGStringsManager.TopupRequesterMobileNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLRecieverPhoneNumber!, with: IGStringsManager.TopupReceiverMobileNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLTopUpOperator!, with: IGStringsManager.ChargeType.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLSourceCardNumber!, with: IGStringsManager.CardNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLOrderNumber!, with: IGStringsManager.OrderId.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLGateWay!, with: IGStringsManager.TerminalId.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLTraceNumber!, with: IGStringsManager.TraceNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLRefrenceNumber!, with: IGStringsManager.RefrenceNum.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        
        //VALUES SET DATA
        if let time = TimeInterval(exactly: (message.wallet?.topup!.requestTime)!) {
            
            IGGlobal.makeAsyncText(for: txtVALUEDate!, with: Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
        if let senderUser = (message.wallet?.topup?.requesterMobileNumber) {
            IGGlobal.makeAsyncText(for: txtVALUESenderPhoneNumber!, with: senderUser, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        
        if let receiverUser = (message.wallet?.topup?.chargeMobileNumber) {
            IGGlobal.makeAsyncText(for: txtVALUERecieverPhoneNumber!, with: receiverUser, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let chargeOperator = (message.wallet?.topup?.topupType) {
            if chargeOperator == IGProtoBuff.IGPRoomMessageWallet.IGPTopup.IGPType.mci.rawValue {
                IGGlobal.makeAsyncText(for: txtVALUETopUpOperator!, with: IGStringsManager.MCI.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                
            } else if chargeOperator == IGProtoBuff.IGPRoomMessageWallet.IGPTopup.IGPType.rightel.rawValue {
                IGGlobal.makeAsyncText(for: txtVALUETopUpOperator!, with: IGStringsManager.Rightel.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                
            } else if chargeOperator == IGProtoBuff.IGPRoomMessageWallet.IGPTopup.IGPType.irancellWow.rawValue {
                IGGlobal.makeAsyncText(for: txtVALUETopUpOperator!, with: IGStringsManager.Irancell.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                
            }  else if chargeOperator == IGProtoBuff.IGPRoomMessageWallet.IGPTopup.IGPType.irancellPrepaid.rawValue {
                IGGlobal.makeAsyncText(for: txtVALUETopUpOperator!, with: IGStringsManager.Irancell.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                
            }  else if chargeOperator == IGProtoBuff.IGPRoomMessageWallet.IGPTopup.IGPType.irancellPostpaid.rawValue {
                IGGlobal.makeAsyncText(for: txtVALUETopUpOperator!, with: IGStringsManager.Irancell.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                
            } else {
                IGGlobal.makeAsyncText(for: txtVALUETopUpOperator!, with: IGStringsManager.Irancell.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
                
            }
        }
        if let cardNumber = (message.wallet?.topup?.cardNumber) {
            IGGlobal.makeAsyncText(for: txtVALUESourceCardNumber!, with: cardNumber, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let orderNumber = (message.wallet?.topup?.orderId) {
            IGGlobal.makeAsyncText(for: txtVALUEOrderNumber!, with: String(orderNumber).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let terminalNumber = (message.wallet?.topup?.terminalNo) {
            IGGlobal.makeAsyncText(for: txtVALUEGateWay!, with: String(terminalNumber).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let traceNum = (message.wallet?.topup!.traceNumber) {
            IGGlobal.makeAsyncText(for: txtVALUETraceNumber!, with: String(traceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        if let invoiceNum = (message.wallet?.topup!.rrn) {
            IGGlobal.makeAsyncText(for: txtVALUERefrenceNumber!, with: String(invoiceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
        
        self.message = message
        
    }
    private func layoutTopUp(msg: IGRoomMessage) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTypeTitle!, txtAmount!]
        
        
        let profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        profileBox.children = [txtTypeIcon!, textBox]
        
        let mainBox = ASStackLayoutSpec.vertical()
        mainBox.justifyContent = .spaceAround
        mainBox.children = [profileBox]
        let elemArray : [ASLayoutElement] = [viewSepratorOne!,txtTTLDate!,txtVALUEDate!,viewSepratorTwo!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,viewSepratorThree!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,viewSepratorFour!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,viewSepratorFive!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,viewSepratorSix!,txtTTLOrderNumber!,txtVALUEOrderNumber!,viewSepratorSeven!,txtTTLGateWay!,txtVALUEGateWay!,viewSepratorEight!,txtTTLTraceNumber!,txtVALUETraceNumber!,viewSepratorNine!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
        
        for elemnt in elemArray {
            mainBox.children?.append(elemnt)
        }
        mainBox.children?.append(btnShowMore!)
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [viewSepratorOne!,txtTTLDate!,txtVALUEDate!,viewSepratorTwo!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,viewSepratorThree!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,viewSepratorFour!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,viewSepratorFive!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,viewSepratorSix!,txtTTLOrderNumber!,txtVALUEOrderNumber!,viewSepratorSeven!,txtTTLGateWay!,txtVALUEGateWay!,viewSepratorEight!,txtTTLTraceNumber!,txtVALUETraceNumber!,viewSepratorNine!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!,textBox,profileBox,mainBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 20), child: mainBox)
        
        
        return insetSpec
    }
    
    private func setTopUpNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopUpView(message: msg)
        return layoutTopUp(msg: msg)
    }
    
    //******************************************************//
    //*************MONEYTRANSFER RECIEPT NODE***************//
    //******************************************************//
    private func initMoneyTransferItems() {
        
        initMoneyTransferTextNodeItemns()
        
        initMoneyTransferSeprators()
    }
    private func initMoneyTransferSeprators() {
        
        if viewSepratorThree == nil {
            viewSepratorThree = ASDisplayNode()
        }
        if viewSepratorFour == nil {
            viewSepratorFour = ASDisplayNode()
        }
        if viewSepratorFive == nil {
            viewSepratorFive = ASDisplayNode()
        }
        if viewSepratorSix == nil {
            viewSepratorSix = ASDisplayNode()
        }
        if viewSepratorSeven == nil {
            viewSepratorSeven = ASDisplayNode()
        }
        if viewSepratorOne == nil {
            viewSepratorOne = ASDisplayNode()
        }
        if viewSepratorTwo == nil {
            viewSepratorTwo = ASDisplayNode()
        }
    }
    private func initMoneyTransferTextNodeItemns() {
        
        
        if txtTypeIcon == nil {
            txtTypeIcon = ASTextNode()
        }
        if txtTypeTitle == nil {
            txtTypeTitle = ASTextNode()
        }
        if txtAmount == nil {
            txtAmount = ASTextNode()
        }
        if testNode == nil {
            testNode = ASDisplayNode()
        }
        if txtTTLDate == nil {
            txtTTLDate = ASTextNode()
        }
        if txtVALUEDate == nil {
            txtVALUEDate = ASTextNode()
        }
        if txtTTLSenderName == nil {
            txtTTLSenderName = ASTextNode()
        }
        if txtVALUESenderName == nil {
            txtVALUESenderName = ASTextNode()
        }
        if txtTTLReciever == nil {
            txtTTLReciever = ASTextNode()
        }
        if txtVALUEReciever == nil {
            txtVALUEReciever = ASTextNode()
        }
        if txtTTLDesc == nil {
            txtTTLDesc = ASTextNode()
        }
        if txtVALUEDesc == nil {
            txtVALUEDesc = ASTextNode()
        }
        
        if txtTTLTraceNumber == nil {
            txtTTLTraceNumber = ASTextNode()
        }
        if txtVALUETraceNumber == nil {
            txtVALUETraceNumber = ASTextNode()
        }
        if txtTTLRefrenceNumber == nil {
            txtTTLRefrenceNumber = ASTextNode()
        }
        if txtVALUERefrenceNumber == nil {
            txtVALUERefrenceNumber = ASTextNode()
        }
        
    }
    private func makeMoneyTransferView(message: IGRoomMessage) {
        initMoneyTransferItems()
        if btnShowMore == nil {
            btnShowMore = ASButtonNode()
        }
        
        IGGlobal.makeAsyncText(for: txtTypeIcon!, with: "", textColor: UIColor.iGapYellow(), size: 40, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTypeTitle!, with: IGStringsManager.WalletMoneyTransfer.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        if let amount = (message.wallet?.moneyTrasfer?.amount) {
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: String(amount).inRialFormat() + " " + IGStringsManager.Currency.rawValue.localized
                , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        }
        else{
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: "..." , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        
        viewSepratorOne!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTwo!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorThree!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFour!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFive!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSix!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSeven!.backgroundColor = ThemeManager.currentTheme.LabelColor
        
        btnShowMore!.style.height = ASDimensionMake(.points, 50)
        btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)
        
        let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderName!,txtVALUESenderName!,txtTTLReciever!,txtVALUEReciever!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!,txtTTLDesc!,txtVALUEDesc!]
        for elemnt in elemArray {
            elemnt.style.preferredSize = CGSize.zero
        }
        
        btnShowMore!.backgroundColor = UIColor.iGapYellow()
        btnShowMore!.layer.cornerRadius = 10.0
        btnShowMore!.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
        
        
        setMoneyTransferData(message: message)
        
        
    }
    
    private func setMoneyTransferData(message: IGRoomMessage) {
        //TITLES SET DATA
        IGGlobal.makeAsyncText(for: txtTTLDate!, with: IGStringsManager.DateTime.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLSenderName!, with: IGStringsManager.From.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLReciever!, with: IGStringsManager.Reciever.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLTraceNumber!, with: IGStringsManager.TraceNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLRefrenceNumber!, with: IGStringsManager.RefrenceNum.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLDesc!, with: IGStringsManager.Desc.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        //VALUES SET DATA
        if let time = TimeInterval(exactly: (message.wallet?.moneyTrasfer!.payTime)!) {
            
            IGGlobal.makeAsyncText(for: txtVALUEDate!, with: Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        if let senderUser = IGRegisteredUser.getUserInfo(id: (message.wallet?.moneyTrasfer!.fromUserId)!) {
            IGGlobal.makeAsyncText(for: txtVALUESenderName!, with: senderUser.displayName, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let receiverUser = IGRegisteredUser.getUserInfo(id: (message.wallet?.moneyTrasfer!.toUserId)!) {
            IGGlobal.makeAsyncText(for: txtVALUEReciever!, with: receiverUser.displayName, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let traceNum = (message.wallet?.moneyTrasfer!.traceNumber) {
            IGGlobal.makeAsyncText(for: txtVALUETraceNumber!, with: String(traceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        if let invoiceNum = (message.wallet?.moneyTrasfer!.invoiceNumber) {
            IGGlobal.makeAsyncText(for: txtVALUERefrenceNumber!, with: String(invoiceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        if (message.wallet?.moneyTrasfer!.walletDescription)!.isEmpty  || (message.wallet?.moneyTrasfer!.walletDescription) == nil || (message.wallet?.moneyTrasfer!.description) == ""{
            IGGlobal.makeAsyncText(for: txtVALUEDesc!, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        } else {
            IGGlobal.makeAsyncText(for: txtVALUEDesc!, with: ((message.wallet?.moneyTrasfer!.walletDescription)!), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
        self.message = message
        
    }
    private func layoutMoneyTransfer(msg: IGRoomMessage) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTypeTitle!, txtAmount!]
        
        
        let profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        profileBox.children = [txtTypeIcon!, textBox]
        
        let mainBox = ASStackLayoutSpec.vertical()
        mainBox.justifyContent = .spaceAround
        mainBox.children = [profileBox]
        let elemArray : [ASLayoutElement] = [viewSepratorOne!,txtTTLDate!,txtVALUEDate!,viewSepratorTwo!,txtTTLSenderName!,txtVALUESenderName!,viewSepratorThree!,txtTTLReciever!,txtVALUEReciever!,viewSepratorFour!,txtTTLTraceNumber!,txtVALUETraceNumber!,viewSepratorFive!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!,viewSepratorSix!,txtTTLDesc!,txtVALUEDesc!]
        
        for elemnt in elemArray {
            mainBox.children?.append(elemnt)
        }
        mainBox.children?.append(btnShowMore!)
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [viewSepratorOne!,txtTTLDate!,txtVALUEDate!,viewSepratorTwo!,txtTTLSenderName!,txtVALUESenderName!,viewSepratorThree!,txtTTLReciever!,txtVALUEReciever!,viewSepratorFour!,txtTTLTraceNumber!,txtVALUETraceNumber!,viewSepratorFive!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!,viewSepratorSix!,txtTTLDesc!,txtVALUEDesc!, textBox, profileBox, mainBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 20), child: mainBox)
        
        
        return insetSpec
    }
    
    private func setMoneyTransferNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeMoneyTransferView(message: msg)
        return layoutMoneyTransfer(msg: msg)
    }
    //******************************************************//
    //****************CARDTOCARD RECIEPT NODE***************//
    //******************************************************//
    private func initCardToCardItems() {
        
        initCardToCardTextNodeItemns()
        
        initCardToCardSeprators()
    }
    private func initCardToCardSeprators() {
        if viewSepratorCardNum == nil {
            viewSepratorCardNum = ASDisplayNode()
        }
        if viewSepratorDesCardNum == nil {
            viewSepratorDesCardNum = ASDisplayNode()
        }
        if viewSepratorDesBankName == nil {
            viewSepratorDesBankName = ASDisplayNode()
        }
        if viewSepratorOwnerName == nil {
            viewSepratorOwnerName = ASDisplayNode()
        }
        if viewSepratorTraceNum == nil {
            viewSepratorTraceNum = ASDisplayNode()
        }
        if viewSepratorTop == nil {
            viewSepratorTop = ASDisplayNode()
        }
        if viewSepratorDate == nil {
            viewSepratorDate = ASDisplayNode()
        }
    }
    private func initCardToCardTextNodeItemns() {
        if txtTypeIcon == nil {
            txtTypeIcon = ASTextNode()
        }
        if txtTypeTitle == nil {
            txtTypeTitle = ASTextNode()
        }
        if txtAmount == nil {
            txtAmount = ASTextNode()
        }
        if testNode == nil {
            testNode = ASDisplayNode()
        }
        if txtTTLDate == nil {
            txtTTLDate = ASTextNode()
        }
        if txtVALUEDate == nil {
            txtVALUEDate = ASTextNode()
        }
        if txtTTLSourceCardNumber == nil {
            txtTTLSourceCardNumber = ASTextNode()
        }
        if txtVALUESourceCardNumber == nil {
            txtVALUESourceCardNumber = ASTextNode()
        }
        if txtTTLDestinationCardNumber == nil {
            txtTTLDestinationCardNumber = ASTextNode()
        }
        if txtVALUEDestinationCardNumber == nil {
            txtVALUEDestinationCardNumber = ASTextNode()
        }
        if txtTTLDestinationBankName == nil {
            txtTTLDestinationBankName = ASTextNode()
        }
        if txtVALUEDestinationBankName == nil {
            txtVALUEDestinationBankName = ASTextNode()
        }
        if txtTTLCardOwnerName == nil {
            txtTTLCardOwnerName = ASTextNode()
        }
        if txtVALUECardOwnerName == nil {
            txtVALUECardOwnerName = ASTextNode()
        }
        if txtTTLTraceNumber == nil {
            txtTTLTraceNumber = ASTextNode()
        }
        if txtVALUETraceNumber == nil {
            txtVALUETraceNumber = ASTextNode()
        }
        if txtTTLRefrenceNumber == nil {
            txtTTLRefrenceNumber = ASTextNode()
        }
        if txtVALUERefrenceNumber == nil {
            txtVALUERefrenceNumber = ASTextNode()
        }
        
    }
    private func makeCardToCardView(message: IGRoomMessage) {
        initCardToCardItems()
        if btnShowMore == nil {
            btnShowMore = ASButtonNode()
        }
        IGGlobal.makeAsyncText(for: txtTypeIcon!, with: "", textColor: UIColor.iGapBlue(), size: 40, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTypeTitle!, with: IGStringsManager.CardMoneyTransfer.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        if let amount = (message.wallet?.cardToCard?.amount) {
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: String(amount).inRialFormat() + " " + IGStringsManager.Currency.rawValue.localized
                , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        }
        else{
            
            IGGlobal.makeAsyncText(for: txtAmount!, with: "..." , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        
        
        viewSepratorCardNum!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTraceNum!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorOwnerName!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorDesCardNum!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorDesBankName!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTop!.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorDate!.backgroundColor = ThemeManager.currentTheme.LabelColor
        
        btnShowMore!.style.height = ASDimensionMake(.points, 50)
        btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .white, for: .normal)
        
        let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLDestinationCardNumber!,txtVALUEDestinationCardNumber!,txtTTLDestinationBankName!,txtVALUEDestinationBankName!,txtTTLCardOwnerName!,txtVALUECardOwnerName!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
        for elemnt in elemArray {
            elemnt.style.preferredSize = CGSize.zero
        }
        
        btnShowMore!.backgroundColor = UIColor.iGapBlue()
        btnShowMore!.layer.cornerRadius = 10.0
        btnShowMore!.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
        setCardToCardData(message: message)
        
        
    }
    
    private func setCardToCardData(message: IGRoomMessage) {
        //TITLES SET DATA
        IGGlobal.makeAsyncText(for: txtTTLDate!, with: IGStringsManager.DateTime.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLSourceCardNumber!, with: IGStringsManager.CardNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLDestinationCardNumber!, with: IGStringsManager.DestinationCard.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLDestinationBankName!, with: IGStringsManager.DestinationBank.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLCardOwnerName!, with: IGStringsManager.AccountOwnerName.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLTraceNumber!, with: IGStringsManager.TraceNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtTTLRefrenceNumber!, with: IGStringsManager.RefrenceNum.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        //VALUES SET DATA
        if let time = TimeInterval(exactly: (message.wallet?.cardToCard!.requestTime)!) {
            
            IGGlobal.makeAsyncText(for: txtVALUEDate!, with: Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        IGGlobal.makeAsyncText(for: txtVALUESourceCardNumber!, with: (message.wallet?.cardToCard!.sourceCardNumber)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtVALUEDestinationCardNumber!, with: (message.wallet?.cardToCard!.destCardNumber)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtVALUEDestinationBankName!, with: (message.wallet?.cardToCard!.destBankName)!, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtVALUECardOwnerName!, with: (message.wallet?.cardToCard!.cardOwnerName)!, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtVALUETraceNumber!, with: (message.wallet?.cardToCard!.traceNumber)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeAsyncText(for: txtVALUERefrenceNumber!, with: (message.wallet?.cardToCard!.rrn)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        self.message = message
        
    }
    //- Hint : Check tap on  showmore
    @objc func handleUserTap() {
        
        setNeedsLayout()
        transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
    }
    
    
    override func transitionLayout(withAnimation animated: Bool, shouldMeasureAsync: Bool, measurementCompletion completion: (() -> Void)? = nil) {
        
        if message?.wallet?.cardToCard != nil {
            
            if hasShownMore {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .white, for: .normal)
                
                viewSepratorCardNum!.style.height = ASDimensionMake(.points, 0)
                viewSepratorTraceNum!.style.height = ASDimensionMake(.points, 0)
                viewSepratorOwnerName!.style.height = ASDimensionMake(.points, 0)
                viewSepratorDesCardNum!.style.height = ASDimensionMake(.points, 0)
                viewSepratorDesBankName!.style.height = ASDimensionMake(.points, 0)
                viewSepratorDate!.style.height = ASDimensionMake(.points, 0)
                viewSepratorTop!.style.height = ASDimensionMake(.points, 0)
                
                
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLDestinationCardNumber!,txtVALUEDestinationCardNumber!,txtTTLDestinationBankName!,txtVALUEDestinationBankName!,txtTTLCardOwnerName!,txtVALUECardOwnerName!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
                for elemnt in elemArray {
                    elemnt.style.preferredSize = CGSize.zero
                }
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
                
                
            } else {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.GlobalClose.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .white, for: .normal)
                
                viewSepratorCardNum!.style.height = ASDimensionMake(.points, 1)
                viewSepratorTraceNum!.style.height = ASDimensionMake(.points, 1)
                viewSepratorOwnerName!.style.height = ASDimensionMake(.points, 1)
                viewSepratorDesCardNum!.style.height = ASDimensionMake(.points, 1)
                viewSepratorDesBankName!.style.height = ASDimensionMake(.points, 1)
                viewSepratorDate!.style.height = ASDimensionMake(.points, 1)
                viewSepratorTop!.style.height = ASDimensionMake(.points, 1)
                
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLDestinationCardNumber!,txtVALUEDestinationCardNumber!,txtTTLDestinationBankName!,txtVALUEDestinationBankName!,txtTTLCardOwnerName!,txtVALUECardOwnerName!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
                for elemnt in elemArray {
                    elemnt.style.height = ASDimensionMake(.points, 25)
                }
                
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
            }
            
        } else if message?.wallet?.moneyTrasfer != nil {
            if hasShownMore {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)
                
                viewSepratorOne!.style.height = ASDimensionMake(.points, 0)
                viewSepratorTwo!.style.height = ASDimensionMake(.points, 0)
                viewSepratorThree!.style.height = ASDimensionMake(.points, 0)
                viewSepratorFive!.style.height = ASDimensionMake(.points, 0)
                viewSepratorFour!.style.height = ASDimensionMake(.points, 0)
                viewSepratorSix!.style.height = ASDimensionMake(.points, 0)
                viewSepratorSeven!.style.height = ASDimensionMake(.points, 0)
                
                
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderName!,txtVALUESenderName!,txtTTLReciever!,txtVALUEReciever!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!,txtTTLDesc!,txtVALUEDesc!]
                for elemnt in elemArray {
                    elemnt.style.preferredSize = CGSize.zero
                }
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
                
                
            } else {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.GlobalClose.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)
                
                viewSepratorOne!.style.height = ASDimensionMake(.points, 1)
                viewSepratorTwo!.style.height = ASDimensionMake(.points, 1)
                viewSepratorThree!.style.height = ASDimensionMake(.points, 1)
                viewSepratorFive!.style.height = ASDimensionMake(.points, 1)
                viewSepratorFour!.style.height = ASDimensionMake(.points, 1)
                viewSepratorSix!.style.height = ASDimensionMake(.points, 1)
                viewSepratorSeven!.style.height = ASDimensionMake(.points, 1)
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderName!,txtVALUESenderName!,txtTTLReciever!,txtVALUEReciever!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!,txtTTLDesc!,txtVALUEDesc!]
                for elemnt in elemArray {
                    elemnt.style.height = ASDimensionMake(.points, 25)
                }
                
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
            }
            
        } else if message?.wallet?.topup != nil {
            if hasShownMore {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)
                
                viewSepratorOne!.style.height = ASDimensionMake(.points, 0)
                viewSepratorTwo!.style.height = ASDimensionMake(.points, 0)
                viewSepratorThree!.style.height = ASDimensionMake(.points, 0)
                viewSepratorFive!.style.height = ASDimensionMake(.points, 0)
                viewSepratorFour!.style.height = ASDimensionMake(.points, 0)
                viewSepratorSix!.style.height = ASDimensionMake(.points, 0)
                viewSepratorSeven!.style.height = ASDimensionMake(.points, 0)
                viewSepratorEight!.style.height = ASDimensionMake(.points, 0)
                viewSepratorNine!.style.height = ASDimensionMake(.points, 0)
                
                
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLOrderNumber!,txtVALUEOrderNumber!,txtTTLGateWay!,txtVALUEGateWay!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
                for elemnt in elemArray {
                    elemnt.style.preferredSize = CGSize.zero
                }
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
                
                
            } else {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.GlobalClose.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)
                
                viewSepratorOne!.style.height = ASDimensionMake(.points, 1)
                viewSepratorTwo!.style.height = ASDimensionMake(.points, 1)
                viewSepratorThree!.style.height = ASDimensionMake(.points, 1)
                viewSepratorFive!.style.height = ASDimensionMake(.points, 1)
                viewSepratorFour!.style.height = ASDimensionMake(.points, 1)
                viewSepratorSix!.style.height = ASDimensionMake(.points, 1)
                viewSepratorSeven!.style.height = ASDimensionMake(.points, 1)
                viewSepratorEight!.style.height = ASDimensionMake(.points, 1)
                viewSepratorNine!.style.height = ASDimensionMake(.points, 1)
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLOrderNumber!,txtVALUEOrderNumber!,txtTTLGateWay!,txtVALUEGateWay!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
                for elemnt in elemArray {
                    elemnt.style.height = ASDimensionMake(.points, 25)
                }
                
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
            }
        } else if message?.wallet?.bill != nil {
            if hasShownMore {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)
                
                viewSepratorOne!.style.height = ASDimensionMake(.points, 0)
                viewSepratorTwo!.style.height = ASDimensionMake(.points, 0)
                viewSepratorThree!.style.height = ASDimensionMake(.points, 0)
                viewSepratorFive!.style.height = ASDimensionMake(.points, 0)
                viewSepratorFour!.style.height = ASDimensionMake(.points, 0)
                viewSepratorSix!.style.height = ASDimensionMake(.points, 0)
                viewSepratorSeven!.style.height = ASDimensionMake(.points, 0)
                viewSepratorEight!.style.height = ASDimensionMake(.points, 0)
                viewSepratorNine!.style.height = ASDimensionMake(.points, 0)
                
                
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLOrderNumber!,txtVALUEOrderNumber!,txtTTLGateWay!,txtVALUEGateWay!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
                for elemnt in elemArray {
                    elemnt.style.preferredSize = CGSize.zero
                }
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
                
                
            } else {
                testNode!.layoutIfNeeded()
                btnShowMore!.setTitle(IGStringsManager.GlobalClose.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)
                
                viewSepratorOne!.style.height = ASDimensionMake(.points, 1)
                viewSepratorTwo!.style.height = ASDimensionMake(.points, 1)
                viewSepratorThree!.style.height = ASDimensionMake(.points, 1)
                viewSepratorFive!.style.height = ASDimensionMake(.points, 1)
                viewSepratorFour!.style.height = ASDimensionMake(.points, 1)
                viewSepratorSix!.style.height = ASDimensionMake(.points, 1)
                viewSepratorSeven!.style.height = ASDimensionMake(.points, 1)
                viewSepratorEight!.style.height = ASDimensionMake(.points, 1)
                viewSepratorNine!.style.height = ASDimensionMake(.points, 1)
                let elemArray : [ASLayoutElement] = [txtTTLDate!,txtVALUEDate!,txtTTLSenderPhoneNumber!,txtVALUESenderPhoneNumber!,txtTTLRecieverPhoneNumber!,txtVALUERecieverPhoneNumber!,txtTTLTopUpOperator!,txtVALUETopUpOperator!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,txtTTLOrderNumber!,txtVALUEOrderNumber!,txtTTLGateWay!,txtVALUEGateWay!,txtTTLTraceNumber!,txtVALUETraceNumber!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
                for elemnt in elemArray {
                    elemnt.style.height = ASDimensionMake(.points, 25)
                }
                
                UIView.animate(withDuration: 1.0, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.testNode!.layoutIfNeeded()
                })
            }
        } else { }
        
        hasShownMore = !hasShownMore
        
    }
    private func layoutCardToCard(msg: IGRoomMessage) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTypeTitle!, txtAmount!]
        
        
        let profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        profileBox.children = [txtTypeIcon!, textBox]
        
        let mainBox = ASStackLayoutSpec.vertical()
        mainBox.justifyContent = .spaceAround
        mainBox.children = [profileBox]
        let elemArray : [ASLayoutElement] = [viewSepratorTop!,txtTTLDate!,txtVALUEDate!,viewSepratorDate!,txtTTLSourceCardNumber!,txtVALUESourceCardNumber!,viewSepratorCardNum!,txtTTLDestinationCardNumber!,txtVALUEDestinationCardNumber!,viewSepratorDesCardNum!,txtTTLDestinationBankName!,txtVALUEDestinationBankName!,viewSepratorDesBankName!,txtTTLCardOwnerName!,txtVALUECardOwnerName!,viewSepratorOwnerName!,txtTTLTraceNumber!,txtVALUETraceNumber!,viewSepratorTraceNum!,txtTTLRefrenceNumber!,txtVALUERefrenceNumber!]
        
        for elemnt in elemArray {
            mainBox.children?.append(elemnt)
        }
        mainBox.children?.append(btnShowMore!)
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [txtTypeTitle!, txtAmount!,txtTypeIcon!,btnShowMore!, textBox, profileBox, mainBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 20), child: mainBox)
        
        
        return insetSpec
    }
    
    private func setCardToCardNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeCardToCardView(message: msg)
        return layoutCardToCard(msg: msg)
    }
    
    //******************************************************//
    //***********************LOG NODE***********************//
    //******************************************************//
    public enum logMessageType:Int {
        
        case unread            = 1 // exp: 12 unread messages
        case log            = 2 //exp : ali was added to group
        case time            = 3 //time between chats
        case progress            = 4 //progress for loading new chats
        case emptyBox            = 5 //progress for loading new chats
        case unknown            = 6 //unknown message
    }
    private func makeLogView(logType: logMessageType = .log) {
        
        if logType == .progress {
            
            if progressNode == nil {
                progressNode = ASDisplayNode { () -> UIView in
                    let loading = AnimateloadingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                    loading.stopAnimating()
                    loading.startAnimating()

                    return loading

                }

            }
            progressNode?.style.height = ASDimensionMake(.points, 30)
            progressNode?.style.width = ASDimensionMake(.points, 30)
            progressNode?.view.center = CGPoint(x: 15, y: 15)
//            DispatchQueue.main.async {[weak self] in
//                guard let sSelf = self else {
//                    return
//                }
//                (sSelf.progressNode!.view as! AnimationView).play()
//                (sSelf.progressNode!.view as! AnimationView).frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//                (sSelf.progressNode!.view as! AnimationView).contentMode = .scaleAspectFit
//                let animation = Animation.named("messageLoader")
//                (sSelf.progressNode!.view as! AnimationView).animation = animation
//                (sSelf.progressNode!.view as! AnimationView).contentMode = .scaleAspectFit
//                (sSelf.progressNode!.view as! AnimationView).play()
//                (sSelf.progressNode!.view as! AnimationView).loopMode = .loop
//                (sSelf.progressNode!.view as! AnimationView).backgroundBehavior = .pauseAndRestore
//                (sSelf.progressNode!.view as! AnimationView).forceDisplayUpdate()
//
//            }
            progressNode!.alpha = 0.8
            
        } else if logType == .emptyBox {} else {
            if bgNode == nil {
                bgNode = ASDisplayNode()
            }
            if bgTextNode == nil {
                bgTextNode = ASDisplayNode()
            }
            bgNode!.style.height = ASDimensionMake(.points, 50)
            bgTextNode!.style.height = ASDimensionMake(.points, 40)
            bgNode!.backgroundColor = UIColor.clear
            
            switch logType {
                
            case .unread:
                setUnreadMessage(message!)
            case .log:
                setLogMessage(message!)
            case .time:
                setTime(message!.message!)
            case .unknown:
                setUnknownMessage()
                
            default:
                break
            }
        }
    }
    func setTime(_ time: String) {
        if txtLogMessage == nil {
            txtLogMessage = ASTextNode()
        }
        IGGlobal.makeAsyncText(for: txtLogMessage!, with:time, textColor: .white, size: 12, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
        txtLogMessage!.backgroundColor = UIColor.logBackground()
        txtLogMessage!.layer.cornerRadius = 10.0
        txtLogMessage!.clipsToBounds = true
        let logSize = (time.width(withConstrainedHeight: 20, font: UIFont.igFont(ofSize: 16)))
        txtLogMessage!.style.width =  ASDimensionMake(.points, logSize + 10)
        
    }
    func setLogMessage(_ message: IGRoomMessage) {
        if message.log?.type == .pinnedMessage {
            if txtLogMessage == nil {
                txtLogMessage = ASTextNode()
            }
            
            txtLogMessage?.style.maxWidth = ASDimensionMake(.points, UIScreen.main.bounds.width - 20)

            
            if IGRoomMessage.detectPinMessage(message: message).count > 60 {
                IGGlobal.makeAsyncText(for: txtLogMessage!, with: "  " + IGRoomMessage.detectPinMessage(message: message).replacingOccurrences(of: "\n", with: " ").prefix(60) + " ... ", textColor: .white, size: 11, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .center)

            } else {
                IGGlobal.makeAsyncText(for: txtLogMessage!, with: " " + IGRoomMessage.detectPinMessage(message: message) + " ", textColor: .white, size: 11, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .center)

            }

            txtLogMessage!.backgroundColor = UIColor.logBackground()
            txtLogMessage!.layer.cornerRadius = 10.0
            txtLogMessage!.clipsToBounds = true

            
            
        } else {
            if txtLogMessage == nil {
                txtLogMessage = ASTextNode()
            }
            txtLogMessage?.style.maxWidth = ASDimensionMake(.points, UIScreen.main.bounds.width - 20)

            if IGRoomMessageLog.textForLogMessage(message).count > 60 {
                IGGlobal.makeAsyncText(for: txtLogMessage!, with:" " + IGRoomMessageLog.textForLogMessage(message).prefix(60) + " ... ", textColor: .white, size: 11, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .center)

            } else {
                IGGlobal.makeAsyncText(for: txtLogMessage!, with:" " + IGRoomMessageLog.textForLogMessage(message) + " ", textColor: .white, size: 11, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .center)

            }
            
            
            if let user = message.authorUser?.user {
                if user.username == IGAppManager.sharedManager.username() {
                    actorUsernameTitle = IGStringsManager.You.rawValue.localized
                } else {
                    actorUsernameTitle = user.displayName
                }
                actorUser = user
            } else {
                actorUsernameTitle = IGStringsManager.SomeOne.rawValue.localized
            }
            
            
            if let target = message.log?.targetUser {
                if !target.displayName.isEmpty {
                    targetUserNameTitle =  target.displayName
                } else if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
                    targetUserNameTitle =  user.displayName
                }
                targetUser = target
            }else {
                if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
                    targetUserNameTitle =  user.displayName
                    targetUser = user
                } else {
                    IGUserInfoRequest.sendRequest(userId: message.log!.targetUserId)
                }
            }
            
//            txtLogMessage!.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(didTapOnLog(_:))))
            
//            self.onDidLoad {[weak self] (node) in
//                guard let sSelf = self else {
//                    return
//                }
            DispatchQueue.main.async {[weak self] in
                guard let sSelf = self else {
                    return
                }
                sSelf.txtLogMessage!.view.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(sSelf.didTapOnLog(_:))))
                sSelf.txtLogMessage?.view.isUserInteractionEnabled = true
                sSelf.txtLogMessage?.isUserInteractionEnabled = true
            }
//            }
            
            
            txtLogMessage!.backgroundColor = UIColor.logBackground()
            txtLogMessage!.layer.cornerRadius = 10.0
            txtLogMessage!.clipsToBounds = true
            if message.log?.type == .pinnedMessage {
                let logSize = (IGRoomMessage.detectPinMessage(message: message).replacingOccurrences(of: "\n", with: " ").width(withConstrainedHeight: 20, font: UIFont.igFont(ofSize: 11)))
                if logSize >= (UIScreen.main.bounds.width - 20) {
                    txtLogMessage!.style.width =  ASDimensionMake(.points, UIScreen.main.bounds.width - 30)

                } else {
                    txtLogMessage!.style.width =  ASDimensionMake(.points, logSize)
                }

            } else {
                let logSize = (IGRoomMessageLog.textForLogMessage(message).width(withConstrainedHeight: 20, font: UIFont.igFont(ofSize: 11)))
                if logSize >= (UIScreen.main.bounds.width - 20) {
                    txtLogMessage!.style.width =  ASDimensionMake(.points, UIScreen.main.bounds.width - 30)

                } else {
                    txtLogMessage!.style.width =  ASDimensionMake(.points, logSize)
                }

            }

        }
    }
    
    @objc private func didTapOnLog(_ gesture: UITapGestureRecognizer) {
        
        if let actorUserName = actorUsernameTitle {
            let actorUserNameRange = (txtLogMessage!.attributedText!.string as NSString).range(of: actorUserName)
            if gesture.didTapAttributedTextInTextNode(node: txtLogMessage!, inRange: actorUserNameRange) {
//                print("=-=-=-=- Actor User Tapped")
                if let user = actorUser {
                    delegate?.didTapOnUserName(user: user)
                }
            }
        }
        
        if let targetUserName = targetUserNameTitle {
            let targetUserNameRange = (txtLogMessage!.attributedText!.string as NSString).range(of: targetUserName)
            if gesture.didTapAttributedTextInTextNode(node: txtLogMessage!, inRange: targetUserNameRange) {
                if let user = targetUser {
                    delegate?.didTapOnUserName(user: user)
                }
            }
        }
        
    }
    
    func setUnknownMessage(){
        if txtLogMessage == nil {
            txtLogMessage = ASTextNode()
        }
        txtLogMessage?.style.maxWidth = ASDimensionMake(.points, UIScreen.main.bounds.width - 10)

        if bgTextNode == nil {
            bgTextNode = ASDisplayNode()
        }
        IGGlobal.makeAsyncText(for: txtLogMessage!, with: IGStringsManager.UnknownMessage.rawValue.localized, textColor: .white, size: 12, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
        bgTextNode!.layer.cornerRadius = 10.0
        bgTextNode!.clipsToBounds = true
        bgTextNode!.backgroundColor = UIColor.logBackground()
    }
    
    func setUnreadMessage(_ message: IGRoomMessage){
        if txtLogMessage == nil {
            txtLogMessage = ASTextNode()
        }
        txtLogMessage?.style.maxWidth = ASDimensionMake(.points, UIScreen.main.bounds.width - 10)

        if bgTextNode == nil {
            bgTextNode = ASDisplayNode()
        }
        IGGlobal.makeAsyncText(for: txtLogMessage!, with: (message.message?.inLocalizedLanguage())!, textColor: .white, size: 12, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
        bgTextNode!.layer.cornerRadius = 10
        bgTextNode!.clipsToBounds = true
        bgTextNode!.backgroundColor = UIColor.unreadBackground()
    }
    
    private func layoutLog(logType: logMessageType = .log) -> ASLayoutSpec {
        
        
        if logType == .progress {
            if progressNode == nil {
                progressNode = ASDisplayNode()
            }

            let v = ASDisplayNode()

            v.style.height = ASDimensionMake(.points, 50)
            v.style.width = ASDimensionMake(.points, 50)
            v.backgroundColor = .white
            v.cornerRadius = 25
            let fakeStackBottomItemOne = ASDisplayNode()
            let fakeStackBottomItemTwo = ASDisplayNode()

            fakeStackBottomItemOne.style.height = ASDimension(unit: .points, value: 10)
            fakeStackBottomItemTwo.style.height = ASDimension(unit: .points, value: 10)

            let playTxtCenterSpec : ASCenterLayoutSpec
            

            playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: progressNode!)

            // Setting Duration lbl Size

            // Setting Container Stack
            let itemsStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .spaceBetween, alignItems: .start, children: [fakeStackBottomItemOne, playTxtCenterSpec, fakeStackBottomItemTwo])
            itemsStackSpec.style.height = ASDimension(unit: .points, value: 50)
            
            let overlaySpec = ASOverlayLayoutSpec(child: v, overlay: itemsStackSpec)
            
            
            
//            let centerBoxText = ASCenterLayoutSpec(centeringOptions: .XY, child: progressNode!)

//            let bgBox = ASBackgroundLayoutSpec(child: centerBoxText, background: view)
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0), child: overlaySpec)
            
            
            return insetSpec
            
        } else if logType == .emptyBox {
            let verticalBox = ASStackLayoutSpec()
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0), child: verticalBox)
            
            
            return insetSpec
            
        } else if logType == .unread {
            if txtLogMessage == nil {
                txtLogMessage = ASTextNode()
            }
            if bgNode == nil {
                bgNode = ASDisplayNode()
            }
            if bgTextNode == nil {
                bgTextNode = ASDisplayNode()
            }
            let bgView = ASDisplayNode()

            bgView.style.height = ASDimensionMake(.points, 50)
            bgView.style.width = ASDimensionMake(.points, UIScreen.main.bounds.width)
            bgView.backgroundColor = ThemeManager.currentTheme.NavigationFirstColor.withAlphaComponent(0.3)
            bgView.cornerRadius = 0

            let fakeStackLeftItemOne = ASDisplayNode()
            let fakeStackrightItemTwo = ASDisplayNode()
            let centerBoxText = ASCenterLayoutSpec(centeringOptions: .XY, child: txtLogMessage!)
            let insetCSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 20,
                bottom: 0,
                right: 20), child: centerBoxText)

            let backTextBox = ASBackgroundLayoutSpec(child: insetCSpec, background: bgTextNode!)
            let insetBGSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0), child: backTextBox)

            let itemsStackSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .spaceBetween, alignItems: .start, children: [fakeStackLeftItemOne, insetBGSpec, fakeStackrightItemTwo])
            
            let overlaySpec = ASOverlayLayoutSpec(child: bgView, overlay: itemsStackSpec)
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0), child: overlaySpec)
                        

            
            
            return insetSpec

        } else {
            if txtLogMessage == nil {
                txtLogMessage = ASTextNode()
            }
            if bgNode == nil {
                bgNode = ASDisplayNode()
            }
            if bgTextNode == nil {
                bgTextNode = ASDisplayNode()
            }
            
            
            let centerBoxText = ASCenterLayoutSpec(centeringOptions: .XY, child: txtLogMessage!)
            let backTextBox = ASBackgroundLayoutSpec(child: centerBoxText, background: bgTextNode!)
            let backBox = ASBackgroundLayoutSpec(child: backTextBox, background: bgNode!)
//            backBox.style.flexGrow = 1.0
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 10,
                left: 10,
                bottom: 10,
                right: 10), child: backBox)
            
            
            return insetSpec
            
        }
        
    }
    
    private func setLogNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage, logType: logMessageType = .log) -> ASLayoutSpec {
        makeLogView(logType: logType)
        return layoutLog(logType: logType)
    }
    //******************************************************//
    //*********************STICKER NODE*********************//
    //******************************************************//
    
    private func setStickerNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
//        makeTopBubbleItems(stack: contentSpec)
        switch msg.additional?.dataType {
            
        case AdditionalType.STICKER.rawValue :
            if (msg.attachment?.name!.hasSuffix(".json") ?? false) {
                initAnimatedSticker()
            }  else {
                initNormalGiftSticker()
            }
        case AdditionalType.GIFT_STICKER.rawValue :
            initNormalGiftSticker()
            
        default : break
            
        }
//        manageStickerAttachment()
        let tmpppMsg : IGRoomMessage
        if message?.forwardedFrom != nil {
            tmpppMsg = message!.forwardedFrom!
        } else {
            tmpppMsg = message!
        }
        switch tmpppMsg.additional?.dataType {
            
        case AdditionalType.STICKER.rawValue :
            if (message!.attachment?.name!.hasSuffix(".json") ?? false) {
                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    right: 0), child: LiveStickerView!)
                
                let tmpV = ASStackLayoutSpec()
                tmpV.direction = .vertical
                makeTopBubbleItems(stack: tmpV)
                tmpV.children?.append(insetSpec)
                addStickerBottomItems(spec: tmpV)
                
                return tmpV
                
            } else {
                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    right: 0), child: NormalGiftStickerView!)
                
                let tmpV = ASStackLayoutSpec()
                tmpV.direction = .vertical
                makeTopBubbleItems(stack: tmpV)
                tmpV.children?.append(insetSpec)
                addStickerBottomItems(spec: tmpV)//add time and status to bottom of sticker
                
//                let v = ASDisplayNode()
//                v.backgroundColor = .red
//                v.style.height = ASDimensionMake(.points, 20)
//                v.style.width = ASDimensionMake(.points, 50)
//                tmpV.children?.append(v)

                return tmpV
                
            }
        case AdditionalType.GIFT_STICKER.rawValue :
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0), child: NormalGiftStickerView!)
            
            return insetSpec
            
        default :
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0), child: NormalGiftStickerView ?? ASDisplayNode { () -> UIView in
                    let animationView = UIImageView()
                    animationView.contentMode = .scaleAspectFit
                    return animationView
                })
            
            return insetSpec
            
            
        }
        
    }
    private func initAnimatedSticker() {
        if LiveStickerView == nil {
            LiveStickerView = ASDisplayNode { () -> UIView in
                let animationView = AnimationView()
                return animationView
            }
        }
        LiveStickerView!.style.height = ASDimensionMake(.points, 200)
        LiveStickerView!.style.width = ASDimensionMake(.points, 200)
        DispatchQueue.main.async {[weak self] in
            guard let sSelf = self else {
                return
            }
            (sSelf.LiveStickerView!.view as! AnimationView).frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            (sSelf.LiveStickerView!.view as! AnimationView).contentMode = .scaleAspectFit
            (sSelf.LiveStickerView!.view as! AnimationView).loopMode = .loop
            (sSelf.LiveStickerView!.view as! AnimationView).backgroundBehavior = .pauseAndRestore
            (sSelf.LiveStickerView!.view as! AnimationView).forceDisplayUpdate()
            
        }
    }
    
    private func initNormalGiftSticker() {
        if NormalGiftStickerView == nil {
            NormalGiftStickerView = ASDisplayNode { () -> UIView in
                let animationView = UIImageView()
                animationView.contentMode = .scaleAspectFit
                return animationView
            }
        }
        NormalGiftStickerView!.style.height = ASDimensionMake(.points, 200)
        NormalGiftStickerView!.style.width = ASDimensionMake(.points, 200)
        
    }
    private func addStickerBottomItems(spec: ASLayoutSpec) {
        if txtTimeNode == nil {
            txtTimeNode = ASTextNode()
        }
        setTime()
        if isIncomming  {} else {
            if txtStatusNode == nil {
                txtStatusNode = ASTextNode()
            }
            
            setMessageStatus()
        }
        
        let timeAndStatusSpec = ASStackLayoutSpec(direction: .horizontal, spacing: isIncomming ? 5 : 5, justifyContent: .end, alignItems: .end, children: isIncomming ? [txtTimeNode!] : [txtTimeNode!,txtStatusNode!])
        timeAndStatusSpec.verticalAlignment = .center
        let v = ASDisplayNode()
        v.style.preferredSize = CGSize(width: 100, height: 30)
        v.backgroundColor = ThemeManager.currentTheme.LabelGrayColor.withAlphaComponent(0.5)
        v.cornerRadius = 8
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), child: timeAndStatusSpec)
        let bgSpec = ASBackgroundLayoutSpec(child: insetSpec, background: v)
        let finalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: isIncomming ? 5 : 5, justifyContent: .end, alignItems: .end, children: [bgSpec])
        
        spec.children?.append(finalSpec)
        
    }
    
    //******************************************************//
    //***********GIF NODE AND GIF TEXT NODE*************//
    //******************************************************//
    
    private func setGifNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        var prefferedSize : CGSize = CGSize(width: 0, height: 0)
        prefferedSize = NodeExtension.fetchMediaFrame(media: msg.attachment!)
        if gifNode == nil {
            
            gifNode = ASDisplayNode { () -> UIView in
                let view = GIFImageView()
                return view
            }
            
            gifNode!.contentMode = .scaleAspectFit
            
        }
        if msg.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath, fileSize: (msg.attachment?.size)!)) || msg.attachment!.status != .ready {
                if indicatorViewAbs == nil {
                    indicatorViewAbs = ASDisplayNode { () -> UIView in
                        let view = IGProgress()
                        return view
                    }
                    indicatorViewAbs?.style.height = ASDimensionMake(.points, 50)
                    indicatorViewAbs?.style.width = ASDimensionMake(.points, 50)
                    (indicatorViewAbs?.view as? IGProgress)?.setFileType(.download)
                    attachment?.status = .readyToDownload
                    
                }
            } else {
                indicatorViewAbs?.removeFromSupernode()
                indicatorViewAbs = nil
                attachment?.status = .ready
            }
        }
        
        gifNode!.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        gifNode!.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        gifNode!.clipsToBounds = true
        
        gifNode!.layer.cornerRadius = 10
        //        indicatorViewAbs?.style.height = ASDimensionMake(.points, 50)
        //        indicatorViewAbs?.style.width = ASDimensionMake(.points, 50)
        
        if msg.type == .gif {
            RemoveNodeText()
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            let insetsImage = isIncomming ? UIEdgeInsets(top: -5, left: -10, bottom: 0, right: -5) : UIEdgeInsets(top: -5, left: -5, bottom: 0, right: -7)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: gifNode!)
            
            verticalSpec.children?.append(insetSpecImage)
            
            let overlay = ASOverlayLayoutSpec()
            overlay.child = verticalSpec
            
            if indicatorViewAbs != nil {
                
                overlay.overlay = indicatorViewAbs!
                
                //                let overlay = ASOverlayLayoutSpec(child: verticalSpec, overlay: indicatorViewAbs!)
                
            }
            
            contentSpec.children?.append(overlay)
            
            
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
            
            return finalInsetSpec
            
            
        } else {
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 5
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: gifNode!)
            if indicatorViewAbs == nil {
                verticalSpec.children?.append(insetSpecImage)
                
            } else {
                let overlay = ASOverlayLayoutSpec(child: insetSpecImage, overlay: indicatorViewAbs!)
                verticalSpec.children?.append(overlay)
                
            }
            
            //
            AddTextNodeTo(spec: verticalSpec)
            contentSpec.children?.append(verticalSpec)
            nodeText?.style.maxWidth = ASDimensionMake(.points, prefferedSize.width)
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
            
            return finalInsetSpec
            
        }
        
    }
    
    
    //******************************************************//
    //*************FILE NODE AND FILE TEXT NODE*************//
    //******************************************************//
    
    private func setFileNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        
        if txtTitleNode == nil {
            txtTitleNode = ASTextNode()
        }
        if txtSizeNode == nil {
            txtSizeNode = ASTextNode()
        }
        if txtAttachmentNode == nil {
            txtAttachmentNode = ASTextNode()
        }
        txtAttachmentNode!.style.width = ASDimension(unit: .points, value: 60.0)
        txtAttachmentNode!.style.height = ASDimension(unit: .points, value: 60.0)
        txtAttachmentNode!.setThumbnail(for: msg.attachment!)
        
        let tmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.LabelColor, BlackThemeColor: .white)
        IGGlobal.makeAsyncText(for: txtSizeNode!, with: msg.attachment!.sizeToString(), textColor: tmpcolor, size: 12, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .left)

        IGGlobal.makeAsyncText(for: txtTitleNode!, with: msg.attachment!.name!, textColor: tmpcolor, size: 12, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .left)
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTitleNode!, txtSizeNode!]
        
        if msg.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath, fileSize: (msg.attachment?.size)!)) || msg.attachment!.status != .ready {
                if indicatorViewAbs == nil {
                    indicatorViewAbs = ASDisplayNode { () -> UIView in
                        let view = IGProgress()
                        return view
                    }
                    indicatorViewAbs?.style.height = ASDimensionMake(.points, 50)
                    indicatorViewAbs?.style.width = ASDimensionMake(.points, 50)
                    (indicatorViewAbs?.view as? IGProgress)?.setFileType(.download)
                    attachment?.status = .readyToDownload
                    
                }
            } else {
//                indicatorViewAbs?.removeFromSupernode()
                indicatorViewAbs = nil
                attachment?.status = .ready
            }
        }
        
        let txtImageBox : ASOverlayLayoutSpec
        let profileBox : ASStackLayoutSpec
        profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        
        if indicatorViewAbs == nil {
            
            profileBox.children = [txtAttachmentNode!, textBox]
            
        } else {
            txtImageBox = ASOverlayLayoutSpec(child: txtAttachmentNode!, overlay: indicatorViewAbs!)
            profileBox.children = [txtImageBox, textBox]
            
        }
        
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [txtSizeNode!, txtTitleNode!, textBox, profileBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: profileBox
        )
        
        if msg.type == .file {
            RemoveNodeText()
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            
            let insetBoxx = ASInsetLayoutSpec(
                insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                child: insetBox
            )
            verticalSpec.children?.append(insetBoxx)
            contentSpec.children?.append(insetBoxx)
            
            
        } else {
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            
            
            verticalSpec.children?.append(insetBox)
            AddTextNodeTo(spec: verticalSpec)
            contentSpec.children?.append(verticalSpec)
            
        }
        if msg.status == IGRoomMessageStatus.failed {
//            indicatorViewAbs?.backgroundColor = .red

        }
        
        makeBottomBubbleItems(contentStack: contentSpec)
        let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
        
        return finalInsetSpec
        
        
        
    }
    
    //******************************************************//
    //*******************VOICE NODE **********************//
    //******************************************************//
    
    private func setVoiceNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        if btnStateNode == nil {
            btnStateNode = ASButtonNode()
        }
        if txtCurrentTimeNode == nil {
            txtCurrentTimeNode = ASTextNode()
        }
        if txtVoiceTimeNode == nil {
            txtVoiceTimeNode = ASTextNode()
        }
        if sliderNode == nil {
            sliderNode = ASDisplayNode { () -> UIView in
                let view = UISlider()
                view.minimumValue = 0
                view.value = 10
                view.maximumValue = 20
                view.tintColor = .red
                return view
            }
        }
        makeVoiceNode(msg: msg)
        
        let insetBox = layoutVoice(msg: msg)
        let verticalSpec = ASStackLayoutSpec()
        verticalSpec.direction = .vertical
        verticalSpec.spacing = 0
        verticalSpec.children?.append(insetBox)
        
        contentSpec.children?.append(verticalSpec)
        
        musicGustureRecognizers()
        checkPlayerState()
        makeBottomBubbleItems(contentStack: contentSpec)
        let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
        
        return finalInsetSpec
        
    }
    private func makeVoiceNode(msg: IGRoomMessage) {
        sliderNode!.style.preferredSize = CGSize(width: 150, height: 50)
        (sliderNode!.view as! UISlider).maximumTrackTintColor = .black
        (sliderNode!.view as! UISlider).minimumTrackTintColor = .red
        (sliderNode!.view as! UISlider).tintColor = .green
        
        btnStateNode!.layer.cornerRadius = 25
        var tmpcolor = UIColor()
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

        if currentTheme != "IGAPClassic" {
            
            if currentTheme == "IGAPDay" {
                if currentColorSetLight == "IGAPBlack" {
                    tmpcolor = UIColor.white
                } else {
                    tmpcolor = ThemeManager.currentTheme.timeColor
                }
            }
            if currentTheme == "IGAPNight" {
                if currentColorSetDark == "IGAPBlack" {
                    tmpcolor = UIColor.white
                } else {
                    tmpcolor = ThemeManager.currentTheme.timeColor
                }

            }
        } else {
            tmpcolor = ThemeManager.currentTheme.timeColor
        }

        //make current time text
        IGGlobal.makeAsyncText(for: txtCurrentTimeNode!, with: "00:00".inLocalizedLanguage(), textColor: tmpcolor, size: 13, numberOfLines: 1, font: .igapFont,alignment: .left)
        
        checkVoiceButtonState(btn: btnStateNode!,message: msg )
        
        setVoice(message: msg)
    }
    
    func checkVoiceButtonState(btn : ASButtonNode,message: IGRoomMessage) {
        var tmpcolor = UIColor()
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

        if currentTheme != "IGAPClassic" {
            
            if currentTheme == "IGAPDay" {
                if currentColorSetLight == "IGAPBlack" {
                    tmpcolor = UIColor.white
                } else {
                    tmpcolor = ThemeManager.currentTheme.timeColor
                }
            }
            if currentTheme == "IGAPNight" {
                if currentColorSetDark == "IGAPBlack" {
                    tmpcolor = UIColor.white
                } else {
                    tmpcolor = ThemeManager.currentTheme.timeColor
                }

            }
        } else {
            tmpcolor = ThemeManager.currentTheme.timeColor
        }

        if IGGlobal.isFileExist(path: message.attachment!.localPath, fileSize: message.attachment!.size) {
            
            btnStateNode!.style.preferredSize = CGSize(width: 50, height: 50)
            btnStateNode!.setTitle("🎗", with: UIFont.iGapFonticon(ofSize: 35), with: tmpcolor, for: .normal)
            
        } else {
            btnStateNode!.style.preferredSize = CGSize.zero
            btnStateNode!.style.preferredSize = CGSize(width: 50, height: 50)
            btnStateNode!.setTitle("🎗", with: UIFont.iGapFonticon(ofSize: 35), with: tmpcolor, for: .normal)
            
        }
        
        
    }
    
    private func layoutVoice(msg: IGRoomMessage) -> ASInsetLayoutSpec {
        
        let sliderBox = ASStackLayoutSpec.vertical()
        sliderBox.justifyContent = .start
        sliderBox.alignContent = .stretch
        sliderBox.children = [sliderNode!, txtCurrentTimeNode!]
        sliderBox.spacing = 0
        if msg.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath, fileSize: (msg.attachment?.size)!)) || msg.attachment!.status != .ready {
                if indicatorViewAbs == nil {
                    indicatorViewAbs = ASDisplayNode { () -> UIView in
                        let view = IGProgress()
                        return view
                    }
                    indicatorViewAbs?.style.height = ASDimensionMake(.points, 50)
                    indicatorViewAbs?.style.width = ASDimensionMake(.points, 50)
                    (indicatorViewAbs?.view as? IGProgress)?.setFileType(.download)
                    attachment?.status = .readyToDownload
                    
                }
            } else {
                indicatorViewAbs?.removeFromSupernode()
                indicatorViewAbs = nil
                attachment?.status = .ready
            }
        }
        let overlayBox : ASOverlayLayoutSpec?
        let attachmentBox = ASStackLayoutSpec.horizontal()
        
        if indicatorViewAbs == nil {
            attachmentBox.spacing = 0
            attachmentBox.children = [btnStateNode!,sliderBox]
            
        } else {
            overlayBox = ASOverlayLayoutSpec(child: btnStateNode!, overlay: indicatorViewAbs!)
            attachmentBox.spacing = 8
            attachmentBox.children = [overlayBox!, sliderBox]
            
        }
        
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8),
            child: attachmentBox
        )
        
        return insetBox
        
    }
    private func setVoice(message: IGRoomMessage) {
        
        let attachment: IGFile! = message.attachment
        let tmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.timeColor,BlackThemeColor: .white)
        let tmpSliderMincolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.MessageTextReceiverColor,BlackThemeColor: .white)
        let tmpSliderMaxcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.timeColor,BlackThemeColor: .white)
        if isIncomming {
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
            (sliderNode!.view as! UISlider).minimumTrackTintColor = tmpSliderMincolor
            (sliderNode!.view as! UISlider).maximumTrackTintColor = tmpSliderMaxcolor
            IGGlobal.makeAsyncButton(for: btnStateNode!, with: "", textColor: tmpcolor, size: 35, font: .fontIcon, alignment: .center)
        } else {
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
            (sliderNode!.view as! UISlider).setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
            (sliderNode!.view as! UISlider).maximumTrackTintColor = UIColor.black
            (sliderNode!.view as! UISlider).minimumTrackTintColor = UIColor(red: 22.0/255.0, green: 91.0/255.0, blue: 88.0/255.0, alpha: 1.0)
            IGGlobal.makeAsyncButton(for: btnStateNode!, with: "", textColor: tmpcolor, size: 35, font: .fontIcon, alignment: .center)
        }

        (sliderNode!.view as! UISlider).setValue(0.0, animated: false)
        let timeM = Int(attachment.duration / 60)
        let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
        IGGlobal.makeAsyncText(for: txtVoiceTimeNode!, with: "0:00 / \(timeM):\(timeS)".inLocalizedLanguage(), textColor: tmpcolor, size: 13, font: .igapFont, alignment: .center)
    }
    //******************************************************//
    //*******************AUDIO NODE **********************//
    //******************************************************//
    
    private func setAudioNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        RemoveNodeText()
        if btnStateNode == nil {
            btnStateNode = ASButtonNode()
        }
        if txtMusicName == nil {
            txtMusicName = ASTextNode()
        }
        if txtMusicArtist == nil {
            txtMusicArtist = ASTextNode()
        }
        makeAudioView(msg: msg)
        
        let insetBox = layoutAudio(msg: msg)
        let verticalSpec = ASStackLayoutSpec()
        verticalSpec.direction = .vertical
        verticalSpec.spacing = 0
        verticalSpec.children?.append(insetBox)
        
        if msg.type == .audio {
            contentSpec.children?.append(verticalSpec)
        } else {
            if nodeText == nil {
                nodeText = ASTextNode()
            }
            AddTextNodeTo(spec: verticalSpec)
            contentSpec.children?.append(verticalSpec)
            
        }
        musicGustureRecognizers()
        checkPlayerState()
        getMetadata(file: msg.attachment)
        makeBottomBubbleItems(contentStack: contentSpec)
        let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
        
        return finalInsetSpec
        
    }
    
    func getMetadata(file : IGFile!) {
        let path = file!.localUrl
        let asset = AVURLAsset(url: path!)
        let playerItem = AVPlayerItem(asset: asset)
        let metadataList = playerItem.asset.commonMetadata
        var hasSingerName : Bool = false
        var hasSongName : Bool = false
        
        for item in metadataList {
            if item.commonKey!.rawValue == "title" {
                let songName = item.stringValue!
                hasSongName = true
                IGGlobal.makeAsyncText(for: txtMusicName!, with: songName, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
                
            }
            if item.commonKey!.rawValue == "artist" {
                let singerName = item.stringValue!
                hasSingerName = true

                let tmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.timeColor,BlackThemeColor: .white)

                IGGlobal.makeAsyncText(for: txtMusicArtist!, with: singerName, textColor: tmpcolor, size: 14, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
            
        }
        
        if !hasSingerName {
            let singerName = IGStringsManager.UnknownArtist.rawValue.localized
            let tmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.timeColor,BlackThemeColor: .white)

            IGGlobal.makeAsyncText(for: txtMusicArtist!, with: singerName, textColor: tmpcolor, size: 14, numberOfLines: 1, font: .igapFont, alignment: .left)
            
            
            
        }
        if !hasSongName {
            if let sn =  attachment?.name {
                let songName = sn
                IGGlobal.makeAsyncText(for: txtMusicName!, with: songName, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            } else {
                let songName = IGStringsManager.UnknownAudio.rawValue.localized
                IGGlobal.makeAsyncText(for: txtMusicName!, with: songName, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
                
            }
        }
        
    }
    private func makeAudioView(msg: IGRoomMessage) {
        let tmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.timeColor,BlackThemeColor: .white)

        IGGlobal.makeAsyncText(for: txtMusicArtist!, with: "", textColor: tmpcolor
            , size: 14, numberOfLines: 1, font: .igapFont, alignment: .left)
        
        btnStateNode!.style.preferredSize = CGSize(width: 60, height: 60)
        btnStateNode!.layer.cornerRadius = 25
        checkButtonState(btn: btnStateNode!,message: msg)
        IGGlobal.makeAsyncButton(for: btnStateNode!, with: "", textColor: tmpcolor, size: 35, font: .fontIcon, alignment: .center)
        
    }
    
    func checkButtonState(btn : ASButtonNode,message: IGRoomMessage) {
        if IGGlobal.isFileExist(path: message.attachment?.localPath, fileSize: message.attachment!.size) {
            btnStateNode!.style.preferredSize = CGSize(width: 60, height: 60)
            btnStateNode!.setTitle("🎗", with: UIFont.iGapFonticon(ofSize: 35), with: .black, for: .normal)
            
        } else {
            btnStateNode!.style.preferredSize = CGSize.zero
            btnStateNode!.style.preferredSize = CGSize(width: 60, height: 60)
            btnStateNode!.setTitle("🎗", with: UIFont.iGapFonticon(ofSize: 35), with: .black, for: .normal)
            
        }
        
        
    }
    private func layoutAudio(msg: IGRoomMessage) -> ASInsetLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtMusicName!,txtMusicArtist!]
        textBox.spacing = 0
        if msg.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath, fileSize: (msg.attachment?.size)!)) || msg.attachment!.status != .ready {
                if indicatorViewAbs == nil {
                    indicatorViewAbs = ASDisplayNode { () -> UIView in
                        let view = IGProgress()
                        return view
                    }
                    indicatorViewAbs?.style.height = ASDimensionMake(.points, 50)
                    indicatorViewAbs?.style.width = ASDimensionMake(.points, 50)
                    (indicatorViewAbs?.view as? IGProgress)?.setFileType(.download)
                    attachment?.status = .readyToDownload
                    
                }
            } else {
                indicatorViewAbs?.removeFromSupernode()
                indicatorViewAbs = nil
                attachment?.status = .ready
            }
        }
        let overlayBox : ASOverlayLayoutSpec?
        let attachmentBox = ASStackLayoutSpec.horizontal()
        
        if indicatorViewAbs == nil {
            attachmentBox.spacing = 0
            attachmentBox.children = [btnStateNode!, textBox]
            
        } else {
            overlayBox = ASOverlayLayoutSpec(child: btnStateNode!, overlay: indicatorViewAbs!)
            attachmentBox.spacing = 0
            attachmentBox.children = [overlayBox!, textBox]
            
        }
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: attachmentBox
        )
        
        return insetBox
        
    }
    //******************************************************//
    //*******************CONTACT NODE **********************//
    //******************************************************//
    
    private func setContactNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        
        if imgCover == nil {
            imgCover = ASImageNode()
        }
        if txtEmails == nil {
            txtEmails = ASTextNode()
        }
        if txtEmailIcon == nil {
            txtEmailIcon = ASTextNode()
        }
        if txtPhoneNumbers == nil {
            txtPhoneNumbers = ASTextNode()
        }
        if txtPhoneIcon == nil {
            txtPhoneIcon = ASTextNode()
        }
        if txtContactName == nil {
            txtContactName = ASTextNode()
        }
        if btnViewContact == nil {
            btnViewContact = ASButtonNode()
        }
        makeContactView()
        
        let insetBox = layoutContact(msg: msg)
        let verticalSpec = ASStackLayoutSpec()
        verticalSpec.direction = .vertical
        verticalSpec.spacing = 0
        verticalSpec.justifyContent = .start
        verticalSpec.alignItems = isIncomming == true ? .end : .start
        
        verticalSpec.children?.append(insetBox)
        contentSpec.children?.append(verticalSpec)
        
        makeBottomBubbleItems(contentStack: contentSpec)
        let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
        
        getContactDetails(message: msg)
        return finalInsetSpec
        
        
        
    }
    private func layoutContact(msg: IGRoomMessage) -> ASInsetLayoutSpec {
        let phonenumberBox = ASStackLayoutSpec.horizontal()
        phonenumberBox.spacing = 5
        phonenumberBox.children = [txtPhoneIcon!, txtPhoneNumbers!]
        phonenumberBox.verticalAlignment = .center
        
        let emailBox = ASStackLayoutSpec.horizontal()
        emailBox.spacing = 10
        emailBox.children = [txtEmailIcon!, txtEmails!]
        emailBox.verticalAlignment = .center
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        if (msg.contact?.emails.count)! > 0 {
            textBox.children = [txtContactName!,phonenumberBox,emailBox]
        } else {
            textBox.children = [txtContactName!,phonenumberBox]
        }
        textBox.spacing = 0
        
        
        let attachmentBox = ASStackLayoutSpec.horizontal()
        attachmentBox.spacing = 5
        attachmentBox.children = [imgCover!, textBox]
        
        let finalBox = ASStackLayoutSpec.vertical()
        finalBox.justifyContent = .spaceAround
        finalBox.spacing = 5
        finalBox.children = [attachmentBox, btnViewContact!]
        
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [imgCover!,txtEmails!,txtContactName!,imgCover!,btnViewContact!, emailBox,textBox, attachmentBox,finalBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        txtPhoneNumbers!.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: finalBox
        )
        
        return insetBox
    }
    private func makeContactView() {
        imgCover!.style.preferredSize = CGSize(width: 40, height: 40)
        imgCover!.layer.cornerRadius = 20
        imgCover!.image = UIImage(named: "ig_default_contact")
        imgCover!.imageModificationBlock = ASImageNodeTintColorModificationBlock((isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker())!)
        IGGlobal.makeAsyncText(for: txtPhoneIcon!, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtEmailIcon!, with: "🖂", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
        
        if isIncomming {
            btnViewContact!.setTitle(IGStringsManager.ViewContact.rawValue.localized, with: UIFont.igFont(ofSize: 14, weight: .bold), with: ThemeManager.currentTheme.SliderTintColor, for: .normal)
            btnViewContact!.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor
            
        } else {
            btnViewContact!.setTitle(IGStringsManager.ViewContact.rawValue.localized, with: UIFont.igFont(ofSize: 14, weight: .bold), with: ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), for: .normal)
            btnViewContact!.layer.borderColor = ThemeManager.currentTheme.SendMessageBubleBGColor.darker()?.cgColor
            
        }
        btnViewContact!.layer.cornerRadius = 10
        btnViewContact!.layer.borderWidth = 1.0
        btnViewContact!.backgroundColor = .clear
        btnViewContact!.style.height = ASDimension(unit: .points, value: 40.0)
        btnViewContact!.addTarget(self, action: #selector(contactDetailBtnTapAction), forControlEvents: .touchUpInside)
        
    }
    
    @objc func contactDetailBtnTapAction() {
        
        if let _contact = contact {
            delegate?.didTapOnContactDetail(contact: _contact)
        }
        
        //        print("DID TAP ON CONTACT SHOW")
        //        if let _contact = contact {
        //            SwiftEventBus.postToMainThread(EventBusManager.showContactDetail, userInfo: ["contactInfo": _contact])
        //        }
        
    }
    
    func getContactDetails(message: IGRoomMessage) {
        DispatchQueue.main.async {[weak self] in
            guard let sSelf = self else {
                return
            }
            
            if message.contact  == nil {
                let predicate = NSPredicate(format: "primaryKeyId = %@", message.primaryKeyId!)
                sSelf.contact = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first!.contact!
            } else {
                sSelf.contact = message.contact!
            }
            
            let firstName = sSelf.contact?.firstName == nil ? "" : sSelf.contact!.firstName! + " "
            let lastName = sSelf.contact?.lastName == nil ? "" : sSelf.contact!.lastName!
            let name = String(format: "%@%@", firstName, lastName)
            if sSelf.isIncomming {
                
                IGGlobal.makeAsyncText(for: sSelf.txtContactName!, with: name, textColor: ThemeManager.currentTheme.SliderTintColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            } else {
                
                IGGlobal.makeAsyncText(for: sSelf.txtContactName!, with: name, textColor: ThemeManager.currentTheme.SendMessageBubleBGColor.darker()!, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
            if sSelf.contact!.phones.count > 0 {
                let phoneNumber = sSelf.contact!.phones.first!.innerString
                IGGlobal.makeAsyncText(for: sSelf.txtPhoneNumbers!, with: phoneNumber, textColor: ThemeManager.currentTheme.LabelColor, size: 13, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
            
            if (message.contact?.emails.count)! > 0 {
                let emailAdd = sSelf.contact!.emails.first!.innerString
                IGGlobal.makeAsyncText(for: sSelf.txtEmails!, with: emailAdd, textColor: ThemeManager.currentTheme.LabelColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
            }
        }
    }
    //******************************************************//
    //***********IMAGE NODE AND IMAGE TEXT NODE*************//
    //******************************************************//
    
    private func setImageNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        var prefferedSize : CGSize = CGSize(width: 0, height: 0)
        prefferedSize = NodeExtension.fetchMediaFrame(media: msg.attachment!)
        if imgNode == nil {
            imgNode = ASImageNode()
            imgNode!.contentMode = .scaleAspectFill
            
        }
        if msg.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath, fileSize: (msg.attachment?.size)!)) || msg.attachment!.status != .ready{
                if indicatorViewAbs == nil {
                    indicatorViewAbs = ASDisplayNode { () -> UIView in
                        let view = IGProgress()
                        return view
                    }
                    indicatorViewAbs?.style.height = ASDimensionMake(.points, 50)
                    indicatorViewAbs?.style.width = ASDimensionMake(.points, 50)
                    (indicatorViewAbs?.view as? IGProgress)?.setFileType(.download)
                    attachment?.status = .readyToDownload
                    
                }
            } else {
                indicatorViewAbs?.removeFromSupernode()
                indicatorViewAbs = nil
                attachment?.status = .ready
            }
        }
        
        imgNode!.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode!.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        imgNode!.clipsToBounds = true
        imgNode!.style.alignSelf = .center

        if msg.type == .image {
            if finalRoomType == .group {
                imgNode!.layer.cornerRadius = isIncomming ? 0 : 15
            } else {
                imgNode!.layer.cornerRadius =  15
            }
            imgNode!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

            RemoveNodeText()
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start

            
            let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgNode!)
            insetSpecImage.style.flexGrow = 1.0
            insetSpecImage.style.alignSelf = .center
            verticalSpec.children?.append(insetSpecImage)
            
            if indicatorViewAbs == nil {
                contentSpec.children?.append(verticalSpec)
                
            } else {
                let overlay = ASOverlayLayoutSpec(child: verticalSpec, overlay: indicatorViewAbs!)
                contentSpec.children?.append(overlay)
                
            }
            
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets:
                isIncomming ?
                UIEdgeInsets(top: 2, left: 8, bottom: 5, right: 3)
                :
                UIEdgeInsets(top: 0, left: 3, bottom: 5, right: 8),
                                                   child: contentSpec)
            
            return finalInsetSpec
            
            
        } else {
            if finalRoom?.type == .channel {
                imgNode!.layer.cornerRadius =  15
                imgNode!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                    imgNode!.layer.cornerRadius =  15
                    imgNode!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }

            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 5
            verticalSpec.justifyContent = .start
  
            let insetsImage : UIEdgeInsets
            
            if finalRoom?.type == .channel {
                insetsImage = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
                
            } else {
                insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgNode!)
            if indicatorViewAbs == nil {
                verticalSpec.children?.append(insetSpecImage)
                
                
            } else {
                let overlay = ASOverlayLayoutSpec(child: insetSpecImage, overlay: indicatorViewAbs!)
                verticalSpec.children?.append(overlay)
                
            }
//            verticalSpec.alignItems = isIncomming == true ? .end : .start
            verticalSpec.alignItems = .center


            //
            AddTextNodeTo(spec: verticalSpec)
            contentSpec.children?.append(verticalSpec)
            nodeText?.style.maxWidth = ASDimensionMake(.points, prefferedSize.width)
            nodeText?.style.minWidth = ASDimensionMake(.points, prefferedSize.width)
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec : ASInsetLayoutSpec
            if finalRoomType == .channel {
                finalInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 3, bottom: 5, right: 3), child: contentSpec)
            } else {
                finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 3) : UIEdgeInsets(top: 3, left: 4, bottom: 5, right: 8), child: contentSpec)
            }
            
            return finalInsetSpec
            
        }
        
    }
    private func AddTextNodeTo(spec : ASLayoutSpec) {
        if nodeText == nil {
            nodeText = ASTextNode()
        }
        
        nodeText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
        nodeText!.style.minHeight = ASDimensionMake(.points, 20)
        let insetBox = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: nodeText!)
        spec.children?.append(insetBox)
        
        setMessage()
        
        
        
        
    }
    //******************************************************//
    //***********VIDEO NODE AND VIDEO TEXT NODE*************//
    //******************************************************//
    
    private func setVideoNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        var prefferedSize : CGSize = CGSize(width: 0, height: 0)
        prefferedSize = NodeExtension.fetchMediaFrame(media: msg.attachment!)
        if prefferedSize.height <= 150 {
            prefferedSize = CGSize(width: 250, height: 250)
        }
        if imgNode == nil {
            imgNode = ASImageNode()
            imgNode!.contentMode = .scaleAspectFill
            
        } else {
            imgNode!.contentMode = .scaleAspectFill

        }
        if msg.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath, fileSize: (msg.attachment?.size)!)) || msg.attachment!.isInUploadLevels() {

                if indicatorViewAbs == nil {
                    indicatorViewAbs = ASDisplayNode { () -> UIView in
                        let view = IGProgress()
                        return view
                    }
                    indicatorViewAbs?.style.height = ASDimensionMake(.points, 50)
                    indicatorViewAbs?.style.width = ASDimensionMake(.points, 50)
                    (indicatorViewAbs?.view as? IGProgress)?.setFileType(.download)
                    attachment?.status = .readyToDownload
                }
                
                if  btnPlay == nil {
                    btnPlay = ASButtonNode()
                    btnPlay?.style.width = ASDimensionMake(.points, 50)
                    btnPlay?.style.height = ASDimensionMake(.points, 50)
                    btnPlay?.cornerRadius = 25
                    btnPlay?.backgroundColor = UIColor(white: 0, alpha: 0.6)
                    IGGlobal.makeAsyncButton(for: btnPlay!, with: "", textColor: .white, size: 40, weight: .bold, font: .fontIcon, alignment: .center)
                    btnPlay?.isHidden = true
                }
            } else {
                indicatorViewAbs?.removeFromSupernode()
                indicatorViewAbs = nil
                attachment?.status = .ready
                if  btnPlay == nil {
                    btnPlay = ASButtonNode()
                    btnPlay?.style.width = ASDimensionMake(.points, 50)
                    btnPlay?.style.height = ASDimensionMake(.points, 50)
                    btnPlay?.cornerRadius = 25
                    btnPlay?.backgroundColor = UIColor(white: 0, alpha: 0.6)
                    IGGlobal.makeAsyncButton(for: btnPlay!, with: "", textColor: .white, size: 40, weight: .bold, font: .fontIcon, alignment: .center)
                }
                
            }
        }
        
        imgNode!.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode!.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        imgNode!.clipsToBounds = true
                
        if msg.type == .video {
            if finalRoomType == .group {
                imgNode!.layer.cornerRadius = isIncomming ? 0 : 15
            } else {
                imgNode!.layer.cornerRadius =  15
            }
            imgNode!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]


            RemoveNodeText()
            
            let timeTxtNode = ASTextNode()
            let fakeStackBottomItem = ASDisplayNode()
            
            timeTxtNode.layer.cornerRadius = 10
            timeTxtNode.clipsToBounds = true
            timeTxtNode.layer.borderColor = UIColor.white.cgColor
            timeTxtNode.layer.borderWidth = 0.5
            timeTxtNode.backgroundColor = UIColor(white: 0, alpha: 0.3)
            
            timeTxtNode.style.height = ASDimension(unit: .points, value: 20)
            fakeStackBottomItem.style.height = ASDimension(unit: .points, value: 26)
            
            let playTxtCenterSpec : ASCenterLayoutSpec
            
            if btnPlay == nil {
                btnPlay = ASButtonNode()
                // Setting Play Btn Size
                btnPlay!.style.flexBasis = ASDimension(unit: .auto, value:1.0)
                btnPlay!.style.flexGrow = 1
                btnPlay!.style.flexShrink = 1
                btnPlay!.isHidden = true
                
            }
            if indicatorViewAbs == nil {
                playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: btnPlay!)
            } else {
                let playTxtOverlaySpec = ASOverlayLayoutSpec(child: btnPlay!, overlay: indicatorViewAbs!)
                playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: playTxtOverlaySpec)
            }
            
            // Setting Duration lbl Size
            let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5), child: timeTxtNode)
            
            // Setting Container Stack
            let itemsStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 6, justifyContent: .spaceBetween, alignItems: .start, children: [timeInsetSpec, playTxtCenterSpec, fakeStackBottomItem])
            itemsStackSpec.style.height = ASDimension(unit: .points, value: prefferedSize.height)
            
            let overlaySpec = ASOverlayLayoutSpec(child: imgNode!, overlay: itemsStackSpec)
            
            let detachedAttachment = msg.attachment?.detach()
            let time : String! = IGAttachmentManager.sharedManager.convertFileTime(seconds: Int(detachedAttachment?.duration ?? 0.0))
            IGGlobal.makeAsyncText(for: timeTxtNode, with: time, textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
            IGGlobal.makeAsyncText(for: timeTxtNode, with: " " + "(\(IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: detachedAttachment?.size ?? 0)))" + " ", textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
            
            contentSpec.children?.append(overlaySpec)
            
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets:
                isIncomming ?
                UIEdgeInsets(top: 2, left: 8, bottom: 5, right: 3)
                :
                UIEdgeInsets(top: 0, left: 3, bottom: 5, right: 8),
                                                   child: contentSpec)
            
            return finalInsetSpec
            
            
        } else {
            if finalRoom?.type == .channel {
                imgNode!.layer.cornerRadius =  15
                imgNode!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                imgNode!.layer.cornerRadius =  0
            }

            let timeTxtNode = ASTextNode()
            let fakeStackBottomItem = ASDisplayNode()
            
            timeTxtNode.layer.cornerRadius = 7.5
            timeTxtNode.clipsToBounds = true
            timeTxtNode.layer.borderColor = UIColor.white.cgColor
            timeTxtNode.layer.borderWidth = 0.5
            timeTxtNode.backgroundColor = UIColor(white: 0, alpha: 0.3)
            
            timeTxtNode.style.height = ASDimension(unit: .points, value: 15)
            timeTxtNode.style.width = ASDimension(unit: .points, value: 80)
            fakeStackBottomItem.style.height = ASDimension(unit: .points, value: 26)
            
            let playTxtCenterSpec : ASCenterLayoutSpec
            
            if btnPlay == nil {
                btnPlay = ASButtonNode()
                // Setting Play Btn Size
                btnPlay!.style.flexBasis = ASDimension(unit: .auto, value:1.0)
                btnPlay!.style.flexGrow = 1
                btnPlay!.style.flexShrink = 1
                btnPlay!.isHidden = true
            }
            
            if indicatorViewAbs == nil {
                
                playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: btnPlay!)
            } else {
                let playTxtOverlaySpec = ASOverlayLayoutSpec(child: btnPlay!, overlay: indicatorViewAbs!)
                playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: playTxtOverlaySpec)
            }
            
            // Setting Duration lbl Size
            let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 5), child: timeTxtNode)
            
            // Setting Container Stack
            let itemsStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 6, justifyContent: .spaceBetween, alignItems: .start, children: [timeInsetSpec, playTxtCenterSpec, fakeStackBottomItem])
            itemsStackSpec.style.height = ASDimension(unit: .points, value: prefferedSize.height)
            
            let overlaySpec = ASOverlayLayoutSpec(child: imgNode!, overlay: itemsStackSpec)
            
            let detachedAttachment = msg.attachment?.detach()
            let time : String! = IGAttachmentManager.sharedManager.convertFileTime(seconds: Int(detachedAttachment?.duration ?? 0.0))
            
            IGGlobal.makeAsyncText(for: timeTxtNode, with: time, textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
            IGGlobal.makeAsyncText(for: timeTxtNode, with: " " + "(\(IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: detachedAttachment?.size ?? 0)))" + " ", textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
            
            
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 5
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            
            verticalSpec.children?.append(overlaySpec)
            
            
            AddTextNodeTo(spec: verticalSpec)
            contentSpec.children?.append(verticalSpec)
            nodeText?.style.maxWidth = ASDimensionMake(.points, prefferedSize.width)
            
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec : ASInsetLayoutSpec
            if finalRoomType == .channel {
                finalInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 2, left: 3, bottom: 5, right: 3), child: contentSpec)
            } else {
                finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 3) : UIEdgeInsets(top: 5, left: 4, bottom: 5, right: 8), child: contentSpec)
            }

            return finalInsetSpec
            
        }
        
    }
    //******************************************************//
    //***********LOCATION NODE*************//
    //******************************************************//
    
    private func setLocationNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        if imgNode == nil {
            imgNode = ASImageNode()
            imgNode!.contentMode = .scaleAspectFill
        }
        
        if imgPinMarker == nil {
            imgPinMarker = ASImageNode()
            imgPinMarker!.contentMode = .scaleAspectFit
        }
        
        
        imgNode!.image = UIImage(named: "map_screenShot")
        imgPinMarker!.image = UIImage(named: "Location_Marker")
        imgPinMarker!.style.preferredSize = CGSize(width: 30, height: 30)
        imgNode!.style.width = ASDimension(unit: .points, value: 200)
        imgNode!.style.height = ASDimension(unit: .points, value: 160)
        
//        imgNode!.style.width = ASDimension(unit: .points, value: prefferedSize.width)
//        imgNode!.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        imgNode!.clipsToBounds = true
        
        imgNode!.layer.cornerRadius = 15
        
        let pinCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: imgPinMarker!)
        let imgPinOverlaySpec = ASOverlayLayoutSpec(child: imgNode!, overlay: pinCenterSpec)
        
        let verticalSpec = ASStackLayoutSpec()
        verticalSpec.direction = .vertical
        verticalSpec.spacing = 0
        verticalSpec.justifyContent = .start
        verticalSpec.alignItems = isIncomming == true ? .end : .start
        let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
        let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgPinOverlaySpec)
        
        verticalSpec.children?.append(insetSpecImage)
        
        if indicatorViewAbs == nil {
            contentSpec.children?.append(verticalSpec)
            
        } else {
            let overlay = ASOverlayLayoutSpec(child: verticalSpec, overlay: indicatorViewAbs!)
            contentSpec.children?.append(overlay)
            
        }
        
        makeBottomBubbleItems(contentStack: contentSpec)
        let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
        
        return finalInsetSpec
        
        
//        let pinCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: imgPinMarker!)
//
//        let imgPinOverlaySpec = ASOverlayLayoutSpec(child: imgNode!, overlay: pinCenterSpec)
//
//        let verticalSpec = ASStackLayoutSpec()
//        verticalSpec.direction = .vertical
//        verticalSpec.spacing = 0
//        verticalSpec.justifyContent = .start
//        verticalSpec.alignItems = isIncomming == true ? .end : .start
//        let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
//        let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgPinOverlaySpec)
//
//        verticalSpec.children?.append(insetSpecImage)
//
////        if indicatorViewAbs == nil {
////            contentSpec.children?.append(verticalSpec)
////
////        } else {
//          //(child: verticalSpec, overlay: indicatorViewAbs!)
////        contentSpec.children?.append(pinCenterSpec)
//
////        }
//
//        makeBottomBubbleItems(contentStack: contentSpec)
//        let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
//
//        return finalInsetSpec
            
        
    }
    
    
    /*
     ******************************************************************
     ************************ Manage Attachment ***********************
     ******************************************************************
     */
    
    private func manageStickerAttachment() {
        
        if message!.additional?.dataType == AdditionalType.STICKER.rawValue {
            DispatchQueue.main.async {
                IGAttachmentManager.sharedManager.getStickerFileInfo(token: self.message?.attachment?.token ?? "") {[weak self] (file) in
                    guard let sSelf = self else {
                        return
                    }
                    if (sSelf.message!.attachment?.name!.hasSuffix(".json") ?? false) {
                        if sSelf.LiveStickerView != nil {
                            (sSelf.LiveStickerView!.view as! AnimationView).setLiveSticker(for: file)
                        }
                    } else  {
                        if sSelf.NormalGiftStickerView != nil {
                            (sSelf.NormalGiftStickerView!.view as! UIImageView).setSticker(for: file)
                        }
                    }
                }
            }
            return
        }
    }
    
    private func manageAttachment(file: IGFile? = nil,msg: IGRoomMessage){
        
        if msg.type == .sticker {
            DispatchQueue.main.async {
                IGAttachmentManager.sharedManager.getStickerFileInfo(token: msg.attachment?.token ?? "") {[weak self] (file) in
                    guard let sSelf = self else {
                        return
                    }
                    
                    if (msg.attachment?.name!.hasSuffix(".json") ?? false) {
                        if sSelf.LiveStickerView != nil {
                            (sSelf.LiveStickerView!.view as! AnimationView).setLiveSticker(for: file)
                        }
                    } else  {
                        if sSelf.NormalGiftStickerView != nil {
                            (sSelf.NormalGiftStickerView!.view as! UIImageView).setSticker(for: file)
                        }
                    }
                    
                }
            }
            return
        }

        if var attachment = msg.attachment , !(attachment.isInvalidated) {
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                self.attachment = attachmentVariableInCache.value
            } else {
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
                
                IGGlobal.syncroniseDisposDicQueue.sync(flags: .barrier) {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    if let disposable = IGGlobal.dispoasDic[sSelf.message!.id] {
                        IGGlobal.dispoasDic.removeValue(forKey: sSelf.message!.id)
                        disposable.dispose()
                    }
                }
                
                let subscriber = variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {[weak self] in
                        guard let sSelf = self else {
                            return
                        }
                        sSelf.updateAttachmentDownloadUploadIndicatorView()
                    }
                })
                
                IGGlobal.syncroniseDisposDicQueue.sync(flags: .barrier) {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    IGGlobal.dispoasDic[sSelf.message!.id] = subscriber
                }
            }
            /* Rx End */
            
            switch (msg.type) {
            case .image, .imageAndText, .video, .videoAndText :
                if !(attachment.isInvalidated) {
                    if msg.type == .image ||  msg.type == .imageAndText {
//                        imgNode!.image = UIImage(named: "igap_default_image")
//                        imgNode!.setImageColor(color: UIColor.purple)

                    } else {
                        imgNode!.image = UIImage(named: "igap_default_video")
                    }
                    
                    imgNode!.setThumbnail(for: attachment)
                    
                    if attachment.status != .ready {
                        if indicatorViewAbs != nil {
                            (indicatorViewAbs?.view as? IGProgress)?.delegate = self
                        }
                    }
                    break
                }
            case .gif,.gifAndText :
                if !(attachment.isInvalidated) {
                    
                    (gifNode!.view as! GIFImageView).setThumbnail(for: attachment)
                    
                    if attachment.status != .ready {
                        if indicatorViewAbs != nil {
                            (indicatorViewAbs?.view as? IGProgress)?.delegate = self
                        }
                    }
                    break
                }
            case  .file, .fileAndText :
                if !(attachment.isInvalidated) {
                    
                    txtAttachmentNode!.setThumbnail(for: attachment)
                    
                    if attachment.status != .ready {
                        if indicatorViewAbs != nil {
                            (indicatorViewAbs?.view as? IGProgress)?.delegate = self
                        }
                    }
                    break
                }
                
            case .audio, .audioAndText, .voice :
                if !(attachment.isInvalidated) {
                    
                    if attachment.status != .ready {
                        if indicatorViewAbs != nil {
                            (indicatorViewAbs?.view as? IGProgress)?.delegate = self
                        }
                    }
                    break
                }
                
            default:
                break
            }
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        var msg = message
        if let forwarded = message?.forwardedFrom {
            msg = forwarded
        }
        
        if msg!.isInvalidated || (attachment?.isInvalidated) ?? (msg!.attachment != nil) {
            return
        }
        
        if let attachment = attachment {
            let fileExist = IGGlobal.isFileExist(path: attachment.localPath, fileSize: attachment.size)
            if fileExist && !attachment.isInUploadLevels() {
                if msg!.type == .video || msg!.type == .videoAndText {
                    //                    makePlayButton()
                    btnPlay?.isHidden = false
                    indicatorViewAbs?.isHidden = true
                }
                if msg?.status == IGRoomMessageStatus.failed {
                    (indicatorViewAbs?.view as? IGProgress)?.setState(.uploadFailed)
                } else {
                    (indicatorViewAbs?.view as? IGProgress)?.setState(.ready)
                }
                if attachment.type == .gif {
                    attachment.loadData()
                    if let data = attachment.data {
                        (gifNode!.view as! GIFImageView).prepareForAnimation(withGIFData: data)
                        (gifNode!.view as! GIFImageView).startAnimatingGIF()
                    }
                } else if attachment.type == .image {
                    imgNode!.setThumbnail(for: attachment)
                }
                return
            }
            
            if isIncomming || !fileExist {
                (indicatorViewAbs?.view as? IGProgress)?.setFileType(.download)
            } else {
                (indicatorViewAbs?.view as? IGProgress)?.setFileType(.upload)
            }
            (indicatorViewAbs?.view as? IGProgress)?.setState(attachment.status)
            if attachment.status == .downloading || attachment.status == .uploading {
                (indicatorViewAbs?.view as? IGProgress)?.setPercentage(attachment.downloadUploadPercent)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    if (attachment.downloadUploadPercent) == 1.0 {
                        attachment.status = .ready
                        if sSelf.imgNode != nil {
                            sSelf.imgNode!.setThumbnail(for: attachment)
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    //******************************************************//
    //***********************TEXT NODE**********************//
    //******************************************************//
    private func RemoveNodeText() {
        if nodeText != nil  {
            nodeText = nil
        }
        if nodeOnlyText != nil {
            nodeOnlyText = nil
        }
        
    }
    
    private func setTextNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {

        var layoutMsg = msg.detach()
        
        //check if has reply or Forward
        if let repliedMessage = msg.repliedTo {
            layoutMsg = repliedMessage.detach()
        } else if let forwardedFrom = msg.forwardedFrom {
            layoutMsg = forwardedFrom.detach()
        } else {layoutMsg = msg}
        
        var msgT = layoutMsg.message ?? ""
        if let forwardMessage = msg.forwardedFrom {
            msgT = forwardMessage.message ?? ""
        } else {
            msgT = msg.message ?? ""
        }

        
        if IGGlobal.isOnlySpecialEmoji(txtMessage: msgT) {
            
            switch msgT.count {
            case 1 :
                isOneCharEmoji = true
            default :
                isOneCharEmoji = false
            }
        } else {
            isOneCharEmoji = false
        }
        if !isOneCharEmoji {
            makeTopBubbleItems(stack: contentSpec) // make senderName and manage ReplyOr Forward View if needed
        }
        //MARK :-ADD SUBNODES TO CONTENT VERTICAL SPEC
        addTextAsSubnode(spec: contentSpec, msg: msg)
        setMessage() //set Text for TEXTNODE

        return addAdditionalButtons(contentSpec: contentSpec,message: msg)
    }

    
    private func addAdditionalButtons(contentSpec: ASLayoutSpec, message: IGRoomMessage) -> ASLayoutSpec {
               //check if msg has additional data of type bot buttons
               if let additionalData = message.additional?.data, message.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
                   let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (finalRoom!.type == .chat && !(finalRoom!.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
        
                   let buttonBox = makeBotNode(roomId: finalRoom!.id, additionalArrayMain: additionalStruct)
                   contentSpec.children?.append(buttonBox)
         
                   let insetContentSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 4, left: 15, bottom: 10, right: 10) : UIEdgeInsets(top: 4, left: 10, bottom: 10, right: 20), child: contentSpec)
                   
                   return insetContentSpec

                   
               }
               //check if msg has additional data of type CardToCard
               else if let additionalData = message.additional?.data, message.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue,
                   let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (finalRoom!.type == .chat && !(finalRoom!.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)){
                   let buttonBox = makeBotNode(roomId: finalRoom!.id, additionalArrayMain: additionalStruct)
                   contentSpec.children?.append(buttonBox)

                   let insetContentSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 10) : UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 20), child: contentSpec)
                   
                   return insetContentSpec

               } else {
                   let insetContentSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 10) : UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 20), child: contentSpec)
                   
                   return insetContentSpec

               }

    }
    private func setMessage() {
        if let forwardedFrom = message!.forwardedFrom {
            if let msg = forwardedFrom.message {
                setupMessageText(msg)
            }
            
        } else {
            
            if let msg = message!.message {
                if message!.type == .text {
                    if let additionalData = message!.additional?.data, message!.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
                        let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (finalRoom!.type == .chat && !(finalRoom!.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
                        if let msg = message!.message?.replacingOccurrences(of: "⁣", with: "") { // replace with invisible character if exist
                            setupMessageText(msg)
                        }
                        
                    }  else if let additionalData = message!.additional?.data, message!.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue,
                        let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (finalRoom!.type == .chat && !(finalRoom!.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
                        if let msg = message!.message?.replacingOccurrences(of: "⁣", with: "") { // replace with invisible character if exist
                            
                            
                            let t = message!.additional?.data
                            let tmpJsonB = IGHelperJson.parseAdditionalButton(data: t)
                            
                            let b = tmpJsonB![0][0].valueJson
                            let tmpJson = IGHelperJson.parseAdditionalCardToCardInChat(data: b!)
                            
                            let tt = tmpJson?.amount
                            let tmpAmount : Int! = tt
                            //                            let attrsRegular = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 14 , weight: .regular)]
                            let tempMSG = IGStringsManager.Amount.rawValue.localized + " " + String(tmpAmount).inRialFormat() + IGStringsManager.Currency.rawValue.localized  + "\n_________________________\n" + IGStringsManager.Desc.rawValue.localized + " " + msg
                            setupMessageText(tempMSG)
                            
                            
                        }
                        
                    } else {
                        setupMessageText(msg)
                    }
                } else {
                    setupMessageText(msg)
                }
            }
            
        }
        
    }
    private func addTextAsSubnode(spec: ASLayoutSpec,msg: IGRoomMessage) {
        if !isTextMessageNode {
            if nodeText == nil {
                nodeText = ASTextNode()
            }
            if !((subnodes?.contains(nodeText!))!) {
                //                self.addSubnode(nodeText!)
            }
            nodeText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
            nodeText!.style.minHeight = ASDimensionMake(.points, 20)
            makeTextNodeBottomBubbleItems()
            
            var layoutMsg = msg.detach()
            
            //check if has reply or Forward
            if let repliedMessage = msg.repliedTo {
                layoutMsg = repliedMessage.detach()
            } else if let forwardedFrom = msg.forwardedFrom {
                layoutMsg = forwardedFrom.detach()
            } else {layoutMsg = msg}
            
            var msgg = layoutMsg.message
            if let forwardMessage = msg.forwardedFrom {
                msgg = forwardMessage.message
            }
            
            if msgg!.count <= 10 { //10 is a random number u can change it to what ever value u want to
                
                let messageAndTime = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: isIncomming ? [txtTimeNode!] : [txtTimeNode!,txtStatusNode!])
                txtTimeNode!.style.alignSelf = .end
                if !isIncomming {
                    txtStatusNode!.style.alignSelf = .end
                }
                messageAndTime.verticalAlignment = .center
                
                let nodeTextSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .spaceAround, alignItems: .end, children: [nodeText!,messageAndTime])
                
                spec.children?.append(nodeTextSpec)
                
            } else {
                spec.children?.append(nodeText!)
                makeBottomBubbleItems(contentStack: spec)
            }
            
            
        } else {
            
            addNodeOnlyText(spec: spec,message: msg)
        }
        
        
        
    }
    
    private func addNodeOnlyText(spec: ASLayoutSpec,message: IGRoomMessage) {
        if nodeOnlyText == nil {
            nodeOnlyText = OnlyTextNode()
        }
        
        nodeOnlyText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
        nodeOnlyText!.style.minWidth = ASDimensionMake(.points, 200)
        nodeOnlyText!.style.minHeight = ASDimensionMake(.points, 20)
        makeTextNodeBottomBubbleItems()
        
        var layoutMsg = message.detach()
        
        //check if has reply or Forward
        if let repliedMessage = message.repliedTo {
            layoutMsg = repliedMessage.detach()
        } else if let forwardedFrom = message.forwardedFrom {
            layoutMsg = forwardedFrom.detach()
        } else {layoutMsg = message}
        
        var msg = layoutMsg.message ?? ""
        if let forwardMessage = message.forwardedFrom {
            msg = forwardMessage.message ?? ""
        } else {
            msg = message.message ?? ""
        }
        
        if msg.count <= 10 { //10 is a random number u can change it to what ever value u want to
            if IGGlobal.isOnlySpecialEmoji(txtMessage: msg) {
                
                switch msg.count {
                case 1 :
                    nodeOnlyText!.style.height = ASDimensionMake(.points, 110)
                    isOneCharEmoji = true
                default :
                    isOneCharEmoji = false
                }
            } else {
                isOneCharEmoji = false
            }

            nodeOnlyText!.style.minWidth = ASDimensionMake(.points, 70)
            if finalRoomType! == .channel {
                spec.children?.append(nodeOnlyText!)

                var likeDislikeStack = ASStackLayoutSpec()
                if hasReAction {
                    likeDislikeStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .start, children: [lblEyeIcon!,lblEyeText!,lblLikeIcon!,lblLikeText!,lblDisLikeIcon!,lblDisLikeText!])
                    likeDislikeStack.verticalAlignment = .center
                } else {
                    likeDislikeStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .start, children: [lblEyeIcon!,lblEyeText!])
                    likeDislikeStack.verticalAlignment = .center
                    
                }
                
                let holderStack = ASStackLayoutSpec(direction: .horizontal, spacing: 20, justifyContent: .spaceBetween, alignItems: .start, children: [likeDislikeStack,txtTimeNode!])
                spec.children?.append(holderStack)

            } else {
                
                
                
                if isOneCharEmoji {
                    let messageAndTime = ASStackLayoutSpec(direction: .horizontal, spacing: isIncomming ? 5 : 5, justifyContent: .center, alignItems: .center, children: isIncomming ? [txtTimeNode!] : [txtTimeNode!,txtStatusNode!])
                    messageAndTime.verticalAlignment = .center
                    let v = ASDisplayNode()
                    v.style.preferredSize = CGSize(width: 100, height: 30)
                    v.backgroundColor = ThemeManager.currentTheme.LabelGrayColor.withAlphaComponent(0.3)
                    v.cornerRadius = 8
                    let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), child: messageAndTime)
                    let bgSpec = ASBackgroundLayoutSpec(child: insetSpec, background: v)
                    let finalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: isIncomming ? 5 : 5, justifyContent: .end, alignItems: .end, children: [bgSpec])

                    
                    txtTimeNode!.style.alignSelf = .end
                    if !isIncomming {
                        txtStatusNode!.style.alignSelf = .center
                    }
                    messageAndTime.verticalAlignment = .center

                    let nodeTextSpec = ASStackLayoutSpec(direction: isOneCharEmoji ? .vertical : .horizontal, spacing: 5, justifyContent: .spaceBetween, alignItems: isIncomming ? .start : .end, children: [nodeOnlyText!,finalSpec])

                    spec.children?.append(nodeTextSpec)

                    
                    
                } else {

                    let messageAndTime = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: isIncomming ? [txtTimeNode!] : [txtTimeNode!,txtStatusNode!])
                    txtTimeNode!.style.alignSelf = .end
                    if !isIncomming {
                        txtStatusNode!.style.alignSelf = .end
                    }
                    messageAndTime.verticalAlignment = .center
                    
                    let nodeTextSpec = ASStackLayoutSpec(direction: isOneCharEmoji ? .vertical : .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: [nodeOnlyText!,messageAndTime])

                    spec.children?.append(nodeTextSpec)

                    
                }
                
                
                
                
                
                
                
                
                
                
                
                
                

            }

        } else {
            spec.children?.append(nodeOnlyText!)
            makeBottomBubbleItems(contentStack: spec)
        }
        
    }
    private func setupMessageText(_ msg: String) {
        if !isTextMessageNode {
            if nodeText == nil {
                nodeText = ASTextNode()
            }
        } else {
            if nodeOnlyText == nil {
                nodeOnlyText = OnlyTextNode()
            }
        }
        if let forwardedFrom = message!.forwardedFrom {

            if forwardedFrom.linkInfo == nil {

                let labeltmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.LabelColor, BlackThemeColor: .white)
                
                if !isTextMessageNode {
                    IGGlobal.makeAsyncText(for: nodeText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                    
                } else {

                    if msg == "❤️" {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: 50 , numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

                    } else {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                    }
                    
                }
                return
            }
            if let itms = ActiveLabelJsonify.toObejct(forwardedFrom.linkInfo!) {
                if isTextMessageNode {
                    nodeOnlyText!.attributedText = addLinkDetection(text: msg, activeItems: itms)
                    nodeOnlyText!.isUserInteractionEnabled = true
                    nodeOnlyText!.delegate = self
                } else {
                    nodeText!.attributedText = addLinkDetection(text: msg, activeItems: itms)
                    nodeText!.isUserInteractionEnabled = true
                    nodeText!.delegate = self
                }
                
            } else {
                let labeltmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.LabelColor, BlackThemeColor: .white)
                
                if !isTextMessageNode {
                    IGGlobal.makeAsyncText(for: nodeText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                    
                } else {

                    if msg == "❤️" {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: 50 , numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

                    } else {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                    }
                    
                }
            }

        } else {

            if message!.linkInfo == nil {

                let labeltmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.LabelColor, BlackThemeColor: .white)
                
                if !isTextMessageNode {
                    IGGlobal.makeAsyncText(for: nodeText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                    
                } else {
                    if msg == "❤️" {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: 50, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

                    } else {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

                    }
                    
                }
                return
            }
            if let itms = ActiveLabelJsonify.toObejct(message!.linkInfo!) {
                if isTextMessageNode {
                    nodeOnlyText!.attributedText = addLinkDetection(text: msg, activeItems: itms)
                    nodeOnlyText!.isUserInteractionEnabled = true
                    nodeOnlyText!.delegate = self
                } else {
                    nodeText!.attributedText = addLinkDetection(text: msg, activeItems: itms)
                    nodeText!.isUserInteractionEnabled = true
                    nodeText!.delegate = self
                }
                
            }else {
                let labeltmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.LabelColor, BlackThemeColor: .white)
                
                if !isTextMessageNode {
                    IGGlobal.makeAsyncText(for: nodeText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                    
                } else {
                    if msg == "❤️" {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: 50, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

                    } else {
                        IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: labeltmpcolor, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

                    }
                    
                }
            }
        }


        
    }
    
    func makeBotNode(roomId: Int64?, additionalArrayMain: [[IGStructAdditionalButton]], isKeyboard: Bool = false) -> ASLayoutSpec {
        let buttonBoxV = ASStackLayoutSpec.vertical()
        buttonBoxV.justifyContent = .center
        buttonBoxV.style.flexShrink = 1.0
        buttonBoxV.style.flexGrow = 1.0
        buttonBoxV.alignItems = .stretch
        buttonBoxV.spacing = 5

        for (_, row) in additionalArrayMain.enumerated() {
        
                  let buttonBoxH = ASStackLayoutSpec.horizontal()
                  buttonBoxH.justifyContent = .spaceAround
                    buttonBoxH.spacing = 5
                    buttonBoxH.style.flexShrink = 1.0
                    buttonBoxH.style.flexGrow = 1.0
                    buttonBoxH.alignItems = .stretch
            
                  for additionalButton in row {
                    let view = ASDisplayNode()
                    let img = ASNetworkImageNode()
                    let button = ASButtonNode()
                    if let roomID = roomId {
                        button.accessibilityIdentifier = String(roomID) // set roomId as tag and when use try to tap on button use from this tag for post to the specific event

                    }

                    button.style.flexShrink = 1.0
                    button.style.flexGrow = 1.0
                    button.style.height = ASDimensionMake(.points, 50)
                    button.layer.cornerRadius = 10
                    button.contentVerticalAlignment = .center
                    button.contentHorizontalAlignment = .middle
                    button.backgroundColor = ThemeManager.currentTheme.SendMessageBubleBGColor.darker(by: 20)
                    
//                    button.gradient(from: ThemeManager.currentTheme.NavigationFirstColor, to: ThemeManager.currentTheme.NavigationFirstColor)

                    button.titleNode.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                    img.style.height = ASDimensionMake(.points, 30)
                    img.style.width = ASDimensionMake(.points, 30)
                    ASbuttonActionDic[button] = additionalButton
                    ASbuttonViewDic[button] = view
                    if !(IGGlobal.shouldMultiSelect) {
                        button.addTarget(self, action: #selector(onBotButtonClick), forControlEvents: ASControlNodeEvent.touchUpInside)

                    }
                    addSubnode(button)
                    if additionalButton.imageUrl != nil {
                        img.url = (additionalButton.imageUrl)
                        view.addSubnode(img)
                    }
                    if additionalButton.actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue {

                        IGGlobal.makeAsyncButton(for: button, with: IGStringsManager.CardToCard.rawValue.localized, textColor: .white, weight: .regular, font: .igapFont, alignment: .center)
                        
                    } else {
                        
                        IGGlobal.makeAsyncButton(for: button, with: additionalButton.label, textColor: .white, size: 11, weight: .bold, font: .igapFont, alignment: .center)

                    }

                      buttonBoxH.children?.append(button)
                  }
                    buttonBoxV.children?.append(buttonBoxH)
            
          }
        return buttonBoxV
    }
    
    @objc private func onBotButtonClick(sender: ASButtonNode){
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sender.isEnabled = true
        }
        
        if let structAdditional = ASbuttonActionDic[sender] {
            manageAdditionalActions(roomId: sender.accessibilityIdentifier!, structAdditional: structAdditional)
            
            UIView.animate(withDuration: 0.2, animations: {[weak self] in
                guard let sSelf = self else {
                    return
                }
                sSelf.ASbuttonViewDic[sender]!.backgroundColor = UIColor.customKeyboardButton()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                UIView.animate(withDuration: 0.2, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.ASbuttonViewDic[sender]!.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.5)
                })
            }
        }
    }
    
    
    private func manageAdditionalActions(roomId: String, structAdditional: IGStructAdditionalButton){
        if !(IGGlobal.shouldMultiSelect) {

            switch structAdditional.actionType {
                
            case IGPDiscoveryField.IGPButtonActionType.none.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.joinLink.rawValue :
                IGHelperJoin.getInstance().requestToCheckInvitedLink(invitedLink: structAdditional.value)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.botAction.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.usernameLink.rawValue :
                IGHelperChatOpener.checkUsernameAndOpenRoom(username: structAdditional.value, joinToRoom: false)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.webLink.rawValue :
                IGHelperOpenLink.openLink(urlString: structAdditional.value, forceOpenInApp: true)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.webViewLink.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.billMenu.rawValue :
                IGFinancialServiceBill.BillInfo = nil
                IGFinancialServiceBill.isTrafficOffenses = false
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: structAdditional.value)
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.trafficBillMenu.rawValue :
                IGFinancialServiceBill.BillInfo = nil
                IGFinancialServiceBill.isTrafficOffenses = true
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: structAdditional.value)
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.streamPlay.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.payByWallet.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.payDirect.rawValue :
                guard let jsonValue = structAdditional.valueJson as? String, let json = jsonValue.toJSON() as? [String:AnyObject], let token = json["token"] as? String else {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    break
                }
                IGGlobal.prgShow()
                IGApiPayment.shared.orderCheck(token: token, completion: { (success, payment, errorMessage) in
                    IGGlobal.prgHide()
                    let paymentView = IGPaymentView.sharedInstance
                    
                    if success {
                        guard let paymentData = payment else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            return
                        }
                        
                        paymentView.show(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Pay.rawValue.localized, payToken: token, payment: paymentData)
                    } else {
                        
                        paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Pay.rawValue.localized, message: errorMessage ?? "", payToken: token)
                    }
                })
                break
                
            case IGPDiscoveryField.IGPButtonActionType.requestPhone.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.requestLocation.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.showAlert.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue :
                if let valueJson = structAdditional.valueJson, let finalData = IGHelperJson.parseAdditionalCardToCardInChat(data: valueJson) {
                    let tmpAmount = finalData.amount
                    let tmpCardNumber = finalData.cardNumber
                    IGHelperFinancial.shared.sendCardToCardRequestWithAmount(toUserId: finalData.userId , amount: (tmpAmount), destinationCard: tmpCardNumber)
                }
                break
                
            default:
                break
            }
        }
    }
    //******************************************************//
    //***********************Swipe Gesture**********************//
    //******************************************************//
    
    private func makeSwipeToReply() {// Telegram Func
//        self.onDidLoad {[weak self] (node) in
//            guard let sSelf = self else {
//                return
//            }
        DispatchQueue.main.async {[weak self] in
            guard let sSelf = self else {
                return
            }
            let replyRecognizer = ChatSwipeToReplyRecognizer(target: self, action: #selector(sSelf.swipeToReplyGesture(_:)))
            sSelf.view.addGestureRecognizer(replyRecognizer)
        }
//        }
    }
    
    @objc func swipeToReplyGesture(_ recognizer: ChatSwipeToReplyRecognizer) {
        switch recognizer.state {
        case .began:
            currentSwipeToReplyTranslation = 0.0
            if swipeToReplyFeedback == nil {
                swipeToReplyFeedback = HapticFeedback()
                swipeToReplyFeedback?.prepareImpact()
            }
        case .changed:
            var translation = recognizer.translation(in: self.view)
            translation.x = max(-80.0, min(0.0, translation.x))
            if (translation.x < -45.0) != (currentSwipeToReplyTranslation < -45.0) {
                if translation.x < -45.0, swipeToReplyNode == nil {
                    swipeToReplyFeedback?.impact()
                    
                    let swipeToReplyNode = ChatMessageSwipeToReplyNode(fillColor: UIColor.black, strokeColor: UIColor.red, foregroundColor: .white)
                    self.swipeToReplyNode = swipeToReplyNode
                    insertSubnode(swipeToReplyNode, at: 0)
                }
            }
            self.currentSwipeToReplyTranslation = translation.x
            var bounds = self.bounds
            bounds.origin.x = -translation.x
            self.bounds = bounds
            
            if let swipeToReplyNode = self.swipeToReplyNode {
                swipeToReplyNode.frame = CGRect(origin: CGPoint(x: bounds.size.width, y: frame.height - 40), size: CGSize(width: 28, height: 28))
                
                swipeToReplyNode.alpha = min(1.0, abs(translation.x / 45.0))
                
            }
        case .ended:
            swipeToReplyFeedback = nil
            
            var bounds = self.bounds
            bounds.origin.x = 0.0
            self.bounds = bounds
            if let swipeToReplyNode = self.swipeToReplyNode {
                self.swipeToReplyNode = nil
                swipeToReplyNode.removeFromSupernode()
            }
            
            if recognizer.translation(in: self.view).x < -45.0 {
                self.delegate?.swipToReply(cellMessage: message!)
            }
            


        
            
        case .cancelled:
            self.swipeToReplyFeedback = nil
            
            var bounds = self.bounds
            bounds.origin.x = 0.0
            self.bounds = bounds
            if let swipeToReplyNode = self.swipeToReplyNode {
                self.swipeToReplyNode = nil
                swipeToReplyNode.removeFromSupernode()
            }
            
        default:
            break
        }
    }
    
    /****************************************************************************/
    /******************************* Audio Player *******************************/
    
    /** check current voice state and if is playing update values to current state */
    private func checkPlayerState(){
        
        if message!.type == .audio || message!.type == .audioAndText {
            IGNodePlayer.shared.startPlayer(btnPlayPause: btnStateNode, slider: UISlider(), timer: ASTextNode(), roomMessage: message!, justUpdate: true, room: finalRoom)
        }else {
            guard let slideer = (sliderNode) else {
                return
            }
            IGNodePlayer.shared.startPlayer(btnPlayPause: btnStateNode, slider: slideer.view as? UISlider, timer: txtCurrentTimeNode, roomMessage: message!, justUpdate: true, room: finalRoom)

        }
        
    }
    
    private func musicGustureRecognizers() {
        if btnStateNode != nil {
            btnStateNode!.addTarget(self, action: #selector(didTapOnPlay(_:)), forControlEvents: .touchUpInside)
        }
        
    }
    
    @objc func didTapOnPlay(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if message!.type == .audio || message!.type == .audioAndText {
            IGGlobal.isVoice = false // determine the file is not voice and is music
            IGGlobal.clickedAudioCellIndexPath = index
            IGNodePlayer.shared.startPlayer(btnPlayPause: btnStateNode, slider: UISlider(), timer: ASTextNode(), roomMessage: message!,room: finalRoom)
        }else {
            IGGlobal.isVoice = true
            IGGlobal.clickedAudioCellIndexPath = index
            IGNodePlayer.shared.startPlayer(btnPlayPause: btnStateNode, slider: (sliderNode!.view as! UISlider), timer: txtCurrentTimeNode, roomMessage: message!,room: finalRoom)
        }
        
        
    }
    
}


class OnlyTextNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.clear
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }
    
}

//MARK: - Text Link Detection
extension ChatControllerNode: ASTextNodeDelegate {
    
    func addLinkDetection(text: String, activeItems: [ActiveLabelItem]) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = text.isRTL() ? .right : .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let labeltmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.LabelColor, BlackThemeColor: isIncomming ? UIColor.white : ThemeManager.currentTheme.LabelColor)
        let tmpcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.SliderTintColor, BlackThemeColor: isIncomming ? UIColor.white : .black)
        let boldcolor = IGGlobal.makeCustomColor(OtherThemesColor: ThemeManager.currentTheme.LabelColor, BlackThemeColor: ThemeManager.currentTheme.LabelColor )

        //MARK:- BOLD handling
        var nsText: NSString = (text as NSString)
        for aItem in activeItems {
            let isBold = aItem.isBold ?? false
            if isBold {
                nsText = nsText.replacingCharacters(in: NSMakeRange(aItem.offset, 1), with: "‎") as NSString
                nsText = nsText.replacingCharacters(in: NSMakeRange(aItem.offset+1, 1), with: "‎") as NSString
                nsText = nsText.replacingCharacters(in: NSMakeRange(aItem.offset + aItem.limit - 1, 1), with: "‎") as NSString
                nsText = nsText.replacingCharacters(in: NSMakeRange(aItem.offset + aItem.limit - 2, 1), with: "‎") as NSString
            }
        }
        
        let finalText = String(nsText)
        let attributedString : NSMutableAttributedString
        var sizeT = fontDefaultSize
        //MARK:-EMOJI detection for rxtrution
        if IGGlobal.isOnlySpecialEmoji(txtMessage: text) {
            switch text.count {
            case 1 :
                isOneCharEmoji = true
                sizeT = 90
            case 2 :
                isOneCharEmoji = false
                sizeT = 50
            case 3 :
                isOneCharEmoji = false
                sizeT = 30
            default :
                isOneCharEmoji = false
                sizeT = fontDefaultSize
            }
        } else {
            isOneCharEmoji = false
            sizeT = fontDefaultSize
        }

        attributedString = NSMutableAttributedString(string: finalText, attributes: [NSAttributedString.Key.foregroundColor: labeltmpcolor, NSAttributedString.Key.font:UIFont.igFont(ofSize: sizeT), NSAttributedString.Key.paragraphStyle: paragraphStyle])

        let st = NSMutableParagraphStyle()
        st.lineSpacing = 0
        st.maximumLineHeight = 20
        
        
        for itm in activeItems where ((itm.isBold ?? false) == false){
            let range = NSMakeRange(itm.offset, itm.limit)
            let normalFont = UIFont.igFont(ofSize: fontDefaultSize, weight: .regular)
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: tmpcolor, NSAttributedString.Key.underlineColor: UIColor.clear, NSAttributedString.Key.link: (itm.type, getStringAtRange(string: finalText, range: range)), NSAttributedString.Key.paragraphStyle: st , NSAttributedString.Key.font:normalFont], range: range)
        }
        
        for itm in activeItems where ((itm.isBold ?? false) == true) {
            if itm.type == "bold" {
                
                let range = NSMakeRange(itm.offset, itm.limit)
                let boldFont = UIFont.igFont(ofSize: fontDefaultSize, weight: .bold)
                attributedString.addAttributes([NSAttributedString.Key.foregroundColor: boldcolor, NSAttributedString.Key.underlineColor: UIColor.clear, NSAttributedString.Key.link: (itm.type, getStringAtRange(string: finalText, range: range)), NSAttributedString.Key.paragraphStyle: st , NSAttributedString.Key.font:boldFont], range: range)
                
            }else {
                
                let range = NSMakeRange(itm.offset, itm.limit)
                let boldFont = UIFont.igFont(ofSize: fontDefaultSize, weight: .bold)
                attributedString.addAttributes([NSAttributedString.Key.foregroundColor: tmpcolor, NSAttributedString.Key.underlineColor: UIColor.clear, NSAttributedString.Key.link: (itm.type, getStringAtRange(string: finalText, range: range)), NSAttributedString.Key.paragraphStyle: st , NSAttributedString.Key.font:boldFont], range: range)
                
            }
        }
        
        return attributedString
        
    }
    private func UpdateMessageBubble(contentSpec : ASStackLayoutSpec, shouldHide: Bool = false) {
        if shouldHide {
            
        }
        
    }
    
    func textNode(_ textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: Any!, at point: CGPoint) -> Bool {
        return true
    }
    
    func textNode(_ textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: Any!, at point: CGPoint, textRange: NSRange) {
        
        guard let type = value as? (String, String) else {
            return
        }
        
        let str = (type.1).replacingOccurrences(of: "‎", with: "")
        
        if !IGGlobal.shouldMultiSelect {
            switch type.0 {
            case "url":
                delegate?.didTapOnURl(url: URL(string: str)!)
                break
            case "deepLink":
                delegate?.didTapOnDeepLink(url: URL(string: str)!)
                break
            case "email":
                delegate?.didTapOnEmail(email: str)
                break
            case "bot":
                delegate?.didTapOnBotAction(action: str)
                break
            case "mention":
                delegate?.didTapOnMention(mentionText: str)
                break
            case "hashtag":
                delegate?.didTapOnHashtag(hashtagText: str)
                break
            default:
                break
            }
        }
        
    }
    
    private func getStringAtRange(string: String, range: NSRange) -> String {
        return (string as NSString).substring(with: range)
    }
    
    
}


//MARK: - Gesture Recognizers

extension ChatControllerNode: UIGestureRecognizerDelegate {
    
    func manageGestureRecognizers() {
//        DispatchQueue.global(qos: .userInteractive).sync {
            if !IGGlobal.shouldMultiSelect  {
                
                let tapAndHold = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnCell(_:)))
                tapAndHold.minimumPressDuration = 0.2
                view.addGestureRecognizer(tapAndHold)
                
                view.isUserInteractionEnabled = true
                var tmppmsg : IGRoomMessage
                if message?.forwardedFrom != nil {
                    tmppmsg = message!.forwardedFrom!
                } else {
                    tmppmsg = message!
                }

                if message?.repliedTo != nil {
                    let onReplyClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnReply(_:)))
                    replyForwardViewNode?.view.addGestureRecognizer(onReplyClick)
                    replyForwardViewNode?.isUserInteractionEnabled = true
                    if !(IGGlobal.shouldMultiSelect) {
                        replyForwardViewNode?.isUserInteractionEnabled = true
                    }else {
                        replyForwardViewNode?.isUserInteractionEnabled = false
                        
                    }
                }
                
                if message?.forwardedFrom != nil {
                    let onForwardClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnForward(_:)))
                    replyForwardViewNode?.view.addGestureRecognizer(onForwardClick)
                    if !(IGGlobal.shouldMultiSelect) {
                        replyForwardViewNode?.isUserInteractionEnabled = true
                    }else {
                        replyForwardViewNode?.isUserInteractionEnabled = false
                    }
                }
                
                if tmppmsg.type == .file || tmppmsg.type == .fileAndText {
                    let onFileClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                    txtAttachmentNode?.view.addGestureRecognizer(onFileClick)
                    
                    if !(IGGlobal.shouldMultiSelect) {
                        txtAttachmentNode?.view.isUserInteractionEnabled = true
                    }
                    else {
                        txtAttachmentNode?.view.isUserInteractionEnabled = false
                    }
                }
                
                
                if tmppmsg.type == .image || tmppmsg.type == .imageAndText || tmppmsg.type == .video || tmppmsg.type == .videoAndText {
                    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                    imgNode?.view.addGestureRecognizer(tap)
                    if !(IGGlobal.shouldMultiSelect) {
                        imgNode?.isUserInteractionEnabled = true
                    }
                    else {
                        imgNode?.isUserInteractionEnabled = false
                    }
                    
                }
                
                if tmppmsg.type == .location {
                    let onLocationClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                    view.addGestureRecognizer(onLocationClick)
                    
                    if !(IGGlobal.shouldMultiSelect) {
                        isUserInteractionEnabled = true
                    }
                    else {
                        isUserInteractionEnabled = false
                    }
                }
                
                
                if tmppmsg.type == .sticker {
                    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
//                    view.addGestureRecognizer(tap)
                    LiveStickerView?.view.addGestureRecognizer(tap)
                    NormalGiftStickerView?.view.addGestureRecognizer(tap)
                    
                    if !(IGGlobal.shouldMultiSelect) {
                        
                        LiveStickerView?.view.isUserInteractionEnabled = true
                        NormalGiftStickerView?.view.isUserInteractionEnabled = true
                        
                    }else {
                        LiveStickerView?.view.isUserInteractionEnabled = false
                        NormalGiftStickerView?.view.isUserInteractionEnabled = false
                    }
                }
                
                //            if btnReturnToMessageAbs != nil {
                //                let tapReturnToMessage = UITapGestureRecognizer(target: self, action: #selector(didTapOnReturnToMessage(_:)))
                //                btnReturnToMessageAbs?.addGestureRecognizer(tapReturnToMessage)
                //            }
                
                txtStatusNode?.addTarget(self, action: #selector(didTapOnFailedStatus(_:)), forControlEvents: .touchUpInside)
                
                lblLikeIcon?.addTarget(self, action: #selector(didTapOnVoteUp(_:)), forControlEvents: .touchUpInside)
                lblLikeText?.addTarget(self, action: #selector(didTapOnVoteUp(_:)), forControlEvents: .touchUpInside)
                
                lblDisLikeIcon?.addTarget(self, action: #selector(didTapOnVoteDown(_:)), forControlEvents: .touchUpInside)
                lblDisLikeText?.addTarget(self, action: #selector(didTapOnVoteDown(_:)), forControlEvents: .touchUpInside)
                
                let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
                avatarNode?.view.addGestureRecognizer(gesture)
                
                
            }
//        }
    }
    
    @objc func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if !(IGGlobal.shouldMultiSelect) {
                delegate?.didTapAndHoldOnMessage(cellMessage: message!,index: index)
            }
        default:
            break
        }
    }
    
    func didTapAttachmentOnCell(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            if message!.attachment != nil {
                didTapOnAttachment(gestureRecognizer)
            }
        }
    }
    
    @objc func onMultiForwardTap(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapOnMultiForward(cellMessage: message!, isFromCloud: IGGlobal.isCloud(room: finalRoom!))
    }
    
    @objc func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            delegate?.didTapOnAttachment(cellMessage: message!)
        }
        
    }
    @objc func didTapOnReply(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            delegate?.didTapOnReply(cellMessage: message!)
        }
    }
    
    @objc func didTapOnForward(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapOnForward(cellMessage: message!)
    }
    
    @objc func didTapOnReturnToMessage(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapOnReturnToMessage()
    }
    
    @objc func didTapOnFailedStatus(_ gestureRecognizer: UITapGestureRecognizer) {
        if message!.status == .failed {
            delegate?.didTapOnFailedStatus(cellMessage: message!)
        }
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapOnForwardedAttachment(cellMessage: message!)
        
    }
    
    @objc func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            delegate?.didTapOnSenderAvatar(cellMessage: message!)
        }
    }
    
    @objc func didTapOnVoteUp(_ gestureRecognizer: UITapGestureRecognizer) {
        var messageVote: IGRoomMessage! = message
        if let forward = message!.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
            messageVote = forward
        }
        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsUp)
    }
    
    @objc func didTapOnVoteDown(_ gestureRecognizer: UITapGestureRecognizer) {
        var messageVote: IGRoomMessage! = message
        if let forward = message!.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
            messageVote = forward
        }
        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsDown)
    }
    
    //    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //        return true
    //    }
    //
    //    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        if pan != nil {
    //            let direction = pan.direction(in: superview!)
    //            if direction.contains(.Left) {
    //                return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    //            } else {
    //                return false
    //            }
    //        }
    //        else {
    //            return false
    //        }
    //    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if pan != nil {
            let direction = pan.direction(in: view)
            if direction.contains(.Left)
            {
                return abs((pan.velocity(in: view)).x) > abs((pan.velocity(in: view)).y)
            }
            else {
                return true
            }
            
        }
        else {
            return true
            
        }
    }
    
}

extension ChatControllerNode: IGProgressDelegate {
    
    func downloadUploadIndicatorDidTap(_ indicator: IGProgress) {
        if !IGGlobal.shouldMultiSelect {///if not in multiSelectMode
            
            if let attachment = self.attachment {
                if attachment.status == .uploading {
                    SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(finalRoom!.id)", sender: (action: ChatMessageAction.delete, roomId: finalRoom!.id, messageId: message!.id))
                    IGUploadManager.sharedManager.cancelUpload(attachment: attachment)
                } else if attachment.status == .uploadFailed {
                    IGMessageSender.defaultSender.resend(message: message!, to: finalRoom!)
                    
                } else {
                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
                }
            }
            
        }
    }
    
}

extension ASDisplayNode {
    func gradient(from color1: UIColor, to color2: UIColor) {
        DispatchQueue.main.async {

            let size = self.view.frame.size
            let width = size.width
            let height = size.height


            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [color1.cgColor, color2.cgColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: height/2)
            gradient.endPoint = CGPoint(x: 1.0, y: height/2)
            gradient.cornerRadius = 30
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            self.view.layer.insertSublayer(gradient, at: 0)
        }
    }
}
