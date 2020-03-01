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
    
    // Message Needed Data
    private var message : IGRoomMessage?
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

    private var avatarNode : ASAvatarView?
    
    private var indicatorViewAbs : ASDisplayNode?
    
    private var attachment: IGFile?
    private var subNode : ASDisplayNode?
    //    public var checkNode : ASTextNode?
    var hasReAction : Bool = false
    private var replyForwardViewNode : ASReplyForwardNode?
    private var txtNameNode : ASTextNode?
    
    private var txtTimeNode : ASTextNode?
    private var txtStatusNode : ASTextNode?
    private var index: IndexPath!
    //    private let avatarImageViewNode = ASAvatarView()
    //    private var replyForwardViewNode = ASReplyForwardNode()
    //    private var imgNodeReply = ASImageNode()
    
    // View Items
    //    private let nodeMedia = ASNetworkImageNode() // MUST BE CHANGED TO CustomImageNode
    private var nodeText : ASTextNode?
    private var nodeOnlyText : OnlyTextNode?
    //    private let nodeGif = ASDisplayNode { () -> UIView in
    //        let view = GIFImageView()
    //        return view
    //    }
    
    var pan: UIPanGestureRecognizer!
    var tapMulti: UITapGestureRecognizer!
    
    private var currentSwipeToReplyTranslation: CGFloat = 0.0
    private var swipeToReplyNode: ChatMessageSwipeToReplyNode?
    private var swipeToReplyFeedback: HapticFeedback?
    
    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?
    
//    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?
    
    //    private let nodeSlider = ASDisplayNode { () -> UIView in
    //        let view = UISlider()
    //        view.minimumValue = 0
    //        view.value = 10
    //        view.maximumValue = 20
    //        view.tintColor = .red
    //        return view
    //    }
    //    private var nodebtnAudioState = ASButtonNode()
    //    private var nodeIndicator = ASDisplayNode { () -> UIView in
    //        let view = IGProgress()
    //        return view
    //    }
    
    override func didLoad() {
        super.didLoad()
    }
    override init() {
        super.init()
    }
    deinit {
        ForceFreeUPMemory()
        print("deinit is being called fr chatcontrollerNode")
    }
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
        
        
        if msg.type == .text {
            isTextMessageNode = true
        }
        if msg.type == .text || msg.type == .imageAndText || msg.type == .image || msg.type == .gif || msg.type == .gifAndText || msg.type == .video || msg.type == .videoAndText || msg.type == .file || msg.type == .fileAndText  {
            let baseBubbleBox = makeBubble(bubbleImage: bubbleImage) // make bubble
            let contentItemsBox = makeContentBubbleItems(msg: msg) // make contents
            baseBubbleBox.child = contentItemsBox // add contents as child to bubble
            
            let isShowingAvatar = makeAvatarIfNeeded()
            
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
                    stack.children = isIncomming ? [sSelf.avatarNode! ,baseBubbleBox] : [baseBubbleBox, sSelf.avatarNode!]
                }else {
                    stack.children = [baseBubbleBox]
                }
                stack.style.flexShrink = 1.0

                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 6, bottom: isFromSameSender ? 1 : 10, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: isFromSameSender ? 1 : 10 , right: 5), child: stack)

                return insetHSpec
            }
            if msg.type != .file && msg.type != .fileAndText {
                manageAttachment(file: message.attachment)
            }
        } else if msg.type == .sticker {

            
            let isShowingAvatar = makeAvatarIfNeeded()
            let contentItemsBox = makeContentBubbleItems(msg: msg) // make contents

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
                    stack.children = isIncomming ? [sSelf.avatarNode! ,contentItemsBox] : [contentItemsBox, sSelf.avatarNode!]
                }else {
                    stack.children = [contentItemsBox]
                }
                
                stack.style.flexShrink = 1.0


                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 6, bottom: isFromSameSender ? 1 : 10, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: isFromSameSender ? 1 : 10 , right: 5), child: stack)

                return insetHSpec
            }
            manageAttachment(file: message.attachment)
        } else if msg.type == .log {
            let contentItemsBox = makeContentBubbleItems(msg: msg) // make contents
            
            self.layoutSpecBlock = {[weak self] node, constrainedSize in
                guard self != nil else {
                    return ASLayoutSpec()
                }
                let stack = ASStackLayoutSpec()
                stack.direction = .horizontal
                stack.spacing = 5
                stack.verticalAlignment = .bottom
                stack.horizontalAlignment = isIncomming ? .left : .right
                stack.children = [contentItemsBox]
                stack.style.flexShrink = 1.0
                
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 10, bottom: isFromSameSender ? 1 : 10, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: isFromSameSender ? 1 : 10 , right: 5), child: stack)
                
                return insetHSpec
            }
        }
        
        manageGestureRecognizers()
        if !(IGGlobal.shouldMultiSelect) && finalRoomType != .channel{
            makeSwipeToReply()
        }
        
    }
    
    private func makeAvatarIfNeeded() -> Bool {
        
        if finalRoomType == .channel {
            return false
        }
        
        if isIncomming {
            if shouldShowAvatar && !isFromSameSender {
                
                // Make avatar Here
                if avatarNode == nil {
                    avatarNode = ASAvatarView()
                    avatarNode!.style.preferredSize = CGSize(width: 45, height: 45)
                    avatarNode!.cornerRadius = 22.5
                    avatarNode!.clipsToBounds = true
                }
                
                
                if let user = message?.authorUser?.user {
                    
                    avatarNode?.avatarASImageView?.backgroundColor = .clear
                    avatarNode?.setUser(user)
                    
                }else if let userId = message?.authorUser?.userId {
                    
                    avatarNode?.avatarASImageView?.backgroundColor = .white
                    avatarNode?.avatarASImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
                    SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(message!.roomId)", sender: (action: ChatMessageAction.userInfo, userId: userId))
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
    
    private func makeBubble(bubbleImage : UIImage) -> ASLayoutSpec {
        if bubbleImgNode == nil {
            bubbleImgNode = ASImageNode()
        }
        if shadowImgNode == nil {
            shadowImgNode = ASImageNode()
        }
        
        bubbleImgNode!.image = bubbleImage
        shadowImgNode!.image = bubbleImage
        
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
            if message?.type != .sticker || message?.type != .log || message?.type != .unread {
                if txtNameNode == nil {
                    txtNameNode = ASTextNode()
                    txtNameNode!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
                    txtNameNode!.style.minHeight = ASDimensionMake(.points, 20)
                }
                setSenderName() // set text for txtNameNode(sender name)
                stack.children?.insert(txtNameNode!, at: 0)
                
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
            
            if message?.type != .sticker || message?.type != .log {
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
        
        
        switch msg!.type {
        case .text :
            let finalBox = setTextNodeContent(contentSpec: contentSpec)
            
            return finalBox
        case .image,.imageAndText :
            let finalBox = setImageNodeContent(contentSpec: contentSpec, msg: msg!)
            
            return finalBox
        case .video,.videoAndText :
            let finalBox = setVideoNodeContent(contentSpec: contentSpec, msg: msg!)
            
            return finalBox
        case .gif,.gifAndText :
            let finalBox = setGifNodeContent(contentSpec: contentSpec, msg: msg!)
            return finalBox
        case .file,.fileAndText :
            let finalBox = setFileNodeContent(contentSpec: contentSpec, msg: msg!)
            return finalBox
        case .sticker :
            let finalBox = setStickerNodeContent(contentSpec: contentSpec, msg: msg!)
            return finalBox
        default :
            let finalBox = setTextNodeContent(contentSpec: contentSpec)
            
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
    
    private func makeBottomBubbleItems(contentStack: ASLayoutSpec) {
        
        
        setTime()
        if isIncomming  {} else {
            setMessageStatus()
        }
        
        if isIncomming {
            contentStack.children?.append(txtTimeNode!)
            txtTimeNode?.style.alignSelf = .end
        } else {
            let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode!,txtStatusNode!])
            timeStatusStack.verticalAlignment = .center
            
            contentStack.children?.append(timeStatusStack)
        }
        
        
        
    }
    private func setTime() {
        if let time = message!.creationTime {
            if txtTimeNode == nil {
                txtTimeNode = ASTextNode()
            }
            txtTimeNode?.style.minHeight = ASDimensionMake(.points, 10)
            txtTimeNode?.style.maxWidth = ASDimensionMake(.points, 50)
            txtTimeNode!.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
            IGGlobal.makeAsyncText(for: txtTimeNode!, with: time.convertToHumanReadable(), textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
    }
    private func setMessageStatus() {
        
        if txtStatusNode == nil {
            txtStatusNode = ASTextNode()
        }
        txtStatusNode?.style.minHeight = ASDimensionMake(.points, 10)
        txtStatusNode?.style.maxWidth = ASDimensionMake(.points, 20)
        
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
    private func setSenderName() {
        if !(finalRoomType == .chat) {
            if let name = message!.authorUser?.userInfo {
                txtNameNode!.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeAsyncText(for: txtNameNode!, with: name.displayName, textColor: UIColor.hexStringToUIColor(hex: (message!.authorUser?.user!.color)!), size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
            } else {
                txtNameNode!.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeAsyncText(for: txtNameNode!, with: "", textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
        }
    }
    
    //******************************************************//
    //*********************STICKER NODE*********************//
    //******************************************************//
    
    private func setStickerNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
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
        manageStickerAttachment()
        
        switch message?.additional?.dataType {
            
        case AdditionalType.STICKER.rawValue :
            if (self.message!.attachment?.name!.hasSuffix(".json") ?? false) {
                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0), child: LiveStickerView!)
                
                return insetSpec

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
            right: 0), child: NormalGiftStickerView!)
            
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
        self.LiveStickerView!.style.height = ASDimensionMake(.points, 200)
        self.LiveStickerView!.style.width = ASDimensionMake(.points, 200)
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
        self.NormalGiftStickerView!.style.height = ASDimensionMake(.points, 200)
        self.NormalGiftStickerView!.style.width = ASDimensionMake(.points, 200)

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

        let timeAndStatusSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: isIncomming ? [txtTimeNode!] : [txtTimeNode!,txtStatusNode!])
        timeAndStatusSpec.verticalAlignment = .center
        let v = ASDisplayNode()
        v.style.preferredSize = CGSize(width: 100, height: 30)
        v.backgroundColor = .darkGray
        v.cornerRadius = 10
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), child: timeAndStatusSpec)
        let bgSpec = ASBackgroundLayoutSpec(child: insetSpec, background: v)
        let finalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: [bgSpec])

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
        if message!.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath)) {
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
        indicatorViewAbs!.style.height = ASDimensionMake(.points, 50)
        indicatorViewAbs!.style.width = ASDimensionMake(.points, 50)
        
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
            
            let overlay = ASOverlayLayoutSpec(child: verticalSpec, overlay: indicatorViewAbs!)
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
    //***********GIF NODE AND GIF TEXT NODE*************//
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
        self.txtAttachmentNode!.style.width = ASDimension(unit: .points, value: 60.0)
        self.txtAttachmentNode!.style.height = ASDimension(unit: .points, value: 60.0)
        self.txtAttachmentNode!.setThumbnail(for: msg.attachment!)

        IGGlobal.makeAsyncText(for: txtTitleNode! , with: msg.attachment!.name!, font: .igapFont)
        IGGlobal.makeAsyncText(for: txtSizeNode! , with: msg.attachment!.sizeToString(), font: .igapFont)

        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTitleNode!, txtSizeNode!]
        
        if message!.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath)) {
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

       makeBottomBubbleItems(contentStack: contentSpec)
       let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
       
       return finalInsetSpec

        
        
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
        if message!.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath)) {
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
        
        imgNode!.layer.cornerRadius = 7
        
        if msg.type == .image {
            RemoveNodeText()
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: -6, bottom: 0, right: -6) : UIEdgeInsets(top: 2, left: -6, bottom: 0, right: -6)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgNode!)
            
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
            
            
        } else {
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 5
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: -6, bottom: 0, right: -6) : UIEdgeInsets(top: 2, left: -6, bottom: 0, right: -6)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgNode!)
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
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 10) : UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 15), child: contentSpec)
            
            return finalInsetSpec

        }
        
    }
    private func AddTextNodeTo(spec : ASLayoutSpec) {
        if nodeText == nil {
            nodeText = ASTextNode()
        }

        nodeText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
        nodeText!.style.minHeight = ASDimensionMake(.points, 20)
        spec.children?.append(nodeText!)

        setMessage()

        
        

    }
    //******************************************************//
    //***********VIDEO NODE AND VIDEO TEXT NODE*************//
    //******************************************************//
    
    private func setVideoNodeContent(contentSpec: ASLayoutSpec, msg: IGRoomMessage) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec)
        var prefferedSize : CGSize = CGSize(width: 0, height: 0)
        prefferedSize = NodeExtension.fetchMediaFrame(media: msg.attachment!)
        if imgNode == nil {
            imgNode = ASImageNode()
            imgNode!.contentMode = .scaleAspectFit
            
        }
        if message!.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath)) {
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
                if  btnPlay == nil {
                    btnPlay = ASButtonNode()
                    btnPlay?.style.width = ASDimensionMake(.points, 50)
                    btnPlay?.style.height = ASDimensionMake(.points, 50)
                    btnPlay?.cornerRadius = 25
                    btnPlay?.backgroundColor = isIncomming ? ThemeManager.currentTheme.ReceiveMessageBubleBGColor : ThemeManager.currentTheme.SendMessageBubleBGColor
                    IGGlobal.makeAsyncButton(for: btnPlay!, with: "🎗", textColor: ThemeManager.currentTheme.LabelColor, size: 30, weight: .bold, font: .fontIcon, alignment: .center)
                }

            }
        }

        imgNode!.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode!.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        imgNode!.clipsToBounds = true
        
        imgNode!.layer.cornerRadius = 10
        
        if msg.type == .video {
            RemoveNodeText()
            
            
                let timeTxtNode = ASTextNode()
                let fakeStackBottomItem = ASDisplayNode()
                
                timeTxtNode.style.height = ASDimension(unit: .points, value: 20)
                fakeStackBottomItem.style.height = ASDimension(unit: .points, value: 26)
                
                let playTxtCenterSpec : ASCenterLayoutSpec
            
                if indicatorViewAbs == nil {
                    if btnPlay == nil {
                        btnPlay = ASButtonNode()
                        // Setting Play Btn Size
                        btnPlay!.style.flexBasis = ASDimension(unit: .auto, value:1.0)
                        btnPlay!.style.flexGrow = 1
                        btnPlay!.style.flexShrink = 1

                    }
                    playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: btnPlay!)
                } else {
                    playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: indicatorViewAbs!)
                }
                
                // Setting Duration lbl Size
                let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), child: timeTxtNode)
                
                // Setting Container Stack
                let itemsStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 6, justifyContent: .spaceBetween, alignItems: .start, children: [timeInsetSpec, playTxtCenterSpec, fakeStackBottomItem])
                itemsStackSpec.style.height = ASDimension(unit: .points, value: prefferedSize.height)
                
                let overlaySpec = ASOverlayLayoutSpec(child: imgNode!, overlay: itemsStackSpec)
                
                let time : String! = IGAttachmentManager.sharedManager.convertFileTime(seconds: Int((message!.attachment?.duration)!))
                
                IGGlobal.makeAsyncText(for: timeTxtNode, with: time, textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
                IGGlobal.makeAsyncText(for: timeTxtNode, with: " " + "(\(IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: (message!.attachment?.size)!)))" + " ", textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
                
                
                contentSpec.children?.append(overlaySpec)
                
                
            
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
            
            return finalInsetSpec
            
            
        } else {
            
                let timeTxtNode = ASTextNode()
                let fakeStackBottomItem = ASDisplayNode()
                
                timeTxtNode.style.height = ASDimension(unit: .points, value: 20)
                fakeStackBottomItem.style.height = ASDimension(unit: .points, value: 26)
                
                let playTxtCenterSpec : ASCenterLayoutSpec
            
                if indicatorViewAbs == nil {
                    if btnPlay == nil {
                        btnPlay = ASButtonNode()
                        // Setting Play Btn Size
                        btnPlay!.style.flexBasis = ASDimension(unit: .auto, value:1.0)
                        btnPlay!.style.flexGrow = 1
                        btnPlay!.style.flexShrink = 1

                    }
                    playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: btnPlay!)
                } else {
                    playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: indicatorViewAbs!)
                }
                
                // Setting Duration lbl Size
                let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), child: timeTxtNode)
                
                // Setting Container Stack
                let itemsStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 6, justifyContent: .spaceBetween, alignItems: .start, children: [timeInsetSpec, playTxtCenterSpec, fakeStackBottomItem])
                itemsStackSpec.style.height = ASDimension(unit: .points, value: prefferedSize.height)
                
                let overlaySpec = ASOverlayLayoutSpec(child: imgNode!, overlay: itemsStackSpec)
                
                let time : String! = IGAttachmentManager.sharedManager.convertFileTime(seconds: Int((message!.attachment?.duration)!))
                
                IGGlobal.makeAsyncText(for: timeTxtNode, with: time, textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
                IGGlobal.makeAsyncText(for: timeTxtNode, with: " " + "(\(IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: (message!.attachment?.size)!)))" + " ", textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
                
                
                
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
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
            
            return finalInsetSpec
            
            
        }
        
    }
    

    /*
     ******************************************************************
     ************************ Manage Attachment ***********************
     ******************************************************************
     */
    
    private func manageStickerAttachment() {

        if self.message!.additional?.dataType == AdditionalType.STICKER.rawValue {
            
            if let stickerStruct = IGHelperJson.parseStickerMessage(data: (self.message!.additional?.data)!) {
                //IGGlobal.imgDic[stickerStruct.token!] = self.imgMediaAbs
                DispatchQueue.main.async {
                    IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerStruct.token) { (file) in
                        
                        if (self.message!.attachment?.name!.hasSuffix(".json") ?? false) {
                            if self.LiveStickerView != nil {
                                (self.LiveStickerView!.view as! AnimationView).setLiveSticker(for: file)
                            }
                        } else  {
                            if self.NormalGiftStickerView != nil {

                                (self.NormalGiftStickerView!.view as! UIImageView).setSticker(for: file)
                            }
                        }
                        
                    }
                }
            } else {
                if let stickerStruct = IGHelperJson.parseStickerMessage(data: (self.message!.additional?.data)!) {
                    
                    DispatchQueue.main.async {
                        IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerStruct.token) { (file) in
                            (self.NormalGiftStickerView!.view as! UIImageView).setSticker(for: file)
                        }
                    }
                }
            }
            return
        }

        
    }
    private func manageAttachment(file: IGFile? = nil){
        
        
        if var attachment = message!.attachment , !(attachment.isInvalidated) {
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
            
            switch (message!.type) {
            case .image, .imageAndText, .video, .videoAndText,.voice, .audio, .audioAndText, .file, .fileAndText:
                if !(attachment.isInvalidated) {
                    
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

            default:
                break
            }
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if message!.isInvalidated || (attachment?.isInvalidated) ?? (message!.attachment != nil) {
            return
        }
        
        if let attachment = attachment {
            let fileExist = IGGlobal.isFileExist(path: attachment.localPath, fileSize: attachment.size)
            if fileExist && !attachment.isInUploadLevels() {
                if message!.type == .video || message!.type == .videoAndText {
                    //                    insertSubnode(playTxtNode, aboveSubnode: imgNode)
                }
                
                (indicatorViewAbs?.view as? IGProgress)?.setState(.ready)
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
                        sSelf.imgNode!.setThumbnail(for: attachment)
                        
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
    
    private func setTextNodeContent(contentSpec: ASLayoutSpec) -> ASLayoutSpec {
        makeTopBubbleItems(stack: contentSpec) // make senderName and manage ReplyOr Forward View if needed
        //MARK :-ADD SUBNODES TO CONTENT VERTICAL SPEC
        addTextAsSubnode(spec: contentSpec)
        setMessage() //set Text for TEXTNODE
        let insetContentSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 10) : UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 20), child: contentSpec)
        
        return insetContentSpec
        
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
    private func addTextAsSubnode(spec: ASLayoutSpec) {
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
            
            var layoutMsg = message?.detach()
            
            //check if has reply or Forward
            if let repliedMessage = message?.repliedTo {
                layoutMsg = repliedMessage.detach()
            } else if let forwardedFrom = message?.forwardedFrom {
                layoutMsg = forwardedFrom.detach()
            } else {layoutMsg = message}
            
            var msg = layoutMsg!.message
            if let forwardMessage = message?.forwardedFrom {
                msg = forwardMessage.message
            }
            
            if msg!.count <= 20 { //20 is a random number u can change it to what ever value u want to
                
                let messageAndTime = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: isIncomming ? [txtTimeNode!] : [txtTimeNode!,txtStatusNode!])
                txtTimeNode!.style.alignSelf = .end
                if !isIncomming {
                    txtStatusNode!.style.alignSelf = .end
                }
                messageAndTime.verticalAlignment = .center
                
                let nodeTextSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .spaceBetween, alignItems: .end, children: [nodeText!,messageAndTime])
                
                spec.children?.append(nodeTextSpec)
                
            } else {
                spec.children?.append(nodeText!)
                makeBottomBubbleItems(contentStack: spec)
            }
            
            
        } else {
            addNodeOnlyText(spec: spec)
        }
        
        
        
    }
    
    private func addNodeOnlyText(spec: ASLayoutSpec) {
        if nodeOnlyText == nil {
            nodeOnlyText = OnlyTextNode()
        }

        nodeOnlyText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
        nodeOnlyText!.style.minHeight = ASDimensionMake(.points, 20)
        makeTextNodeBottomBubbleItems()
        
        var layoutMsg = message?.detach()
        
        //check if has reply or Forward
        if let repliedMessage = message?.repliedTo {
            layoutMsg = repliedMessage.detach()
        } else if let forwardedFrom = message?.forwardedFrom {
            layoutMsg = forwardedFrom.detach()
        } else {layoutMsg = message}
        
        var msg = layoutMsg!.message
        if let forwardMessage = message?.forwardedFrom {
            msg = forwardMessage.message
        }
        
        if msg!.count <= 20 { //20 is a random number u can change it to what ever value u want to
            
            let messageAndTime = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: isIncomming ? [txtTimeNode!] : [txtTimeNode!,txtStatusNode!])
            txtTimeNode!.style.alignSelf = .end
            if !isIncomming {
                txtStatusNode!.style.alignSelf = .end
            }
            messageAndTime.verticalAlignment = .center
            
            let nodeTextSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .spaceBetween, alignItems: .end, children: [nodeOnlyText!,messageAndTime])
            
            spec.children?.append(nodeTextSpec)
            
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
        if message!.linkInfo == nil {
            if !isTextMessageNode {
                IGGlobal.makeAsyncText(for: nodeText!, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.localizedDirection)
                
                IGGlobal.makeAsyncText(for: nodeText!, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                
            } else {
                IGGlobal.makeAsyncText(for: nodeOnlyText!, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)
                
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
            
        }
        
    }
 
    
    //******************************************************//
    //***********************Swipe Gesture**********************//
    //******************************************************//
    
    private func makeSwipeToReply() {// Telegram Func
        let replyRecognizer = ChatSwipeToReplyRecognizer(target: self, action: #selector(self.swipeToReplyGesture(_:)))
        self.view.addGestureRecognizer(replyRecognizer)

    }
    
    @objc func swipeToReplyGesture(_ recognizer: ChatSwipeToReplyRecognizer) {
        switch recognizer.state {
            case .began:
                self.currentSwipeToReplyTranslation = 0.0
                if self.swipeToReplyFeedback == nil {
                    self.swipeToReplyFeedback = HapticFeedback()
                    self.swipeToReplyFeedback?.prepareImpact()
                }
            case .changed:
                var translation = recognizer.translation(in: self.view)
                translation.x = max(-80.0, min(0.0, translation.x))
                if (translation.x < -45.0) != (self.currentSwipeToReplyTranslation < -45.0) {
                    if translation.x < -45.0, self.swipeToReplyNode == nil {
                        self.swipeToReplyFeedback?.impact()

                        let swipeToReplyNode = ChatMessageSwipeToReplyNode(fillColor: UIColor.black, strokeColor: UIColor.red, foregroundColor: .white)
                        self.swipeToReplyNode = swipeToReplyNode
                        self.insertSubnode(swipeToReplyNode, at: 0)
                    }
                }
                self.currentSwipeToReplyTranslation = translation.x
                var bounds = self.bounds
                bounds.origin.x = -translation.x
                self.bounds = bounds
            
                if let swipeToReplyNode = self.swipeToReplyNode {
                    swipeToReplyNode.frame = CGRect(origin: CGPoint(x: bounds.size.width, y: self.frame.height - 40), size: CGSize(width: 33.0, height: 33.0))
                    
                    swipeToReplyNode.alpha = min(1.0, abs(translation.x / 45.0))

            }
            case .ended:
                self.swipeToReplyFeedback = nil
                
                var bounds = self.bounds
                bounds.origin.x = 0.0
                self.bounds = bounds
                if let swipeToReplyNode = self.swipeToReplyNode {
                    self.swipeToReplyNode = nil
                    swipeToReplyNode.removeFromSupernode()
                }

                if recognizer.translation(in: self.view).x < -45.0 {
                    self.delegate?.swipToReply(cellMessage: self.message!)
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
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme.LabelColor, NSAttributedString.Key.font:UIFont.igFont(ofSize: 12), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        
        for itm in activeItems {
            let st = NSMutableParagraphStyle()
            st.lineSpacing = 0
            st.maximumLineHeight = 20
            
            let range = NSMakeRange(itm.offset, itm.limit)
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme.SliderTintColor, NSAttributedString.Key.underlineColor: UIColor.clear, NSAttributedString.Key.link: (itm.type, getStringAtRange(string: text, range: range)), NSAttributedString.Key.paragraphStyle: st], range: range)
        }
        
        return attributedString
        
    }
    
    
    func textNode(_ textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: Any!, at point: CGPoint) -> Bool {
        return true
    }
    
    func textNode(_ textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: Any!, at point: CGPoint, textRange: NSRange) {
        
        guard let type = value as? (String, String) else {
            return
        }
        
        if !IGGlobal.shouldMultiSelect {
            switch type.0 {
            case "url":
                delegate?.didTapOnURl(url: URL(string: type.1)!)
                break
            case "deepLink":
                delegate?.didTapOnDeepLink(url: URL(string: type.1)!)
                break
            case "email":
                delegate?.didTapOnEmail(email: type.1)
                break
            case "bot":
                delegate?.didTapOnBotAction(action: type.1)
                break
            case "mention":
                delegate?.didTapOnMention(mentionText: type.1)
                break
            case "hashtag":
                delegate?.didTapOnHashtag(hashtagText: type.1)
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
        if !IGGlobal.shouldMultiSelect  {
            
            let tapAndHold = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnCell(_:)))
            tapAndHold.minimumPressDuration = 0.2
            self.view.addGestureRecognizer(tapAndHold)
            
            self.view.isUserInteractionEnabled = true
            
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
            
            if message?.type == .file || message?.type == .fileAndText {
                let onFileClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                view.addGestureRecognizer(onFileClick)
                
                if !(IGGlobal.shouldMultiSelect) {
                    view.isUserInteractionEnabled = true
                }
                else {
                    view.isUserInteractionEnabled = false
                }
            }
            
            
            
            if message?.type == .image || message?.type == .imageAndText || message?.type == .video || message?.type == .videoAndText {
                let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                imgNode?.view.addGestureRecognizer(tap)
                if !(IGGlobal.shouldMultiSelect) {
                    imgNode?.isUserInteractionEnabled = true
                }
                else {
                    imgNode?.isUserInteractionEnabled = false
                }
                
            }
            
            if message?.type == .location {
                let onLocationClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                view.addGestureRecognizer(onLocationClick)
                
                if !(IGGlobal.shouldMultiSelect) {
                    isUserInteractionEnabled = true
                }
                else {
                    isUserInteractionEnabled = false
                }
            }
            
            
            if message?.type == .sticker {
                let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                view.addGestureRecognizer(tap)
                
                if !(IGGlobal.shouldMultiSelect) {
                    isUserInteractionEnabled = true
                }
                else {
                    isUserInteractionEnabled = false
                }
            }
            
//            if btnReturnToMessageAbs != nil {
//                let tapReturnToMessage = UITapGestureRecognizer(target: self, action: #selector(didTapOnReturnToMessage(_:)))
//                btnReturnToMessageAbs?.addGestureRecognizer(tapReturnToMessage)
//            }
            
            txtStatusNode?.addTarget(self, action: #selector(didTapOnFailedStatus(_:)), forControlEvents: .touchUpInside)

//            lblLikeIcon.addTarget(self, action: #selector(didTapOnVoteUp(_:)), forControlEvents: .touchUpInside)
//            lblLikeText.addTarget(self, action: #selector(didTapOnVoteUp(_:)), forControlEvents: .touchUpInside)
//
//            lblDisLikeIcon.addTarget(self, action: #selector(didTapOnVoteDown(_:)), forControlEvents: .touchUpInside)
//            lblDisLikeText.addTarget(self, action: #selector(didTapOnVoteDown(_:)), forControlEvents: .touchUpInside)
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
            avatarNode?.view.addGestureRecognizer(gesture)
            
            
        }
    }
    
    @objc func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if !(IGGlobal.shouldMultiSelect) {
                self.delegate?.didTapAndHoldOnMessage(cellMessage: message!,index: index)
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
        self.delegate?.didTapOnMultiForward(cellMessage: message!, isFromCloud: IGGlobal.isCloud(room: finalRoom!))
    }
    
    @objc func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.delegate?.didTapOnAttachment(cellMessage: message!)
        }

    }
    @objc func didTapOnReply(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.delegate?.didTapOnReply(cellMessage: message!)
        }
    }
    
    @objc func didTapOnForward(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForward(cellMessage: message!)
    }
    
    @objc func didTapOnReturnToMessage(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnReturnToMessage()
    }
    
    @objc func didTapOnFailedStatus(_ gestureRecognizer: UITapGestureRecognizer) {
        if message!.status == .failed {
            self.delegate?.didTapOnFailedStatus(cellMessage: message!)
        }
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnForwardedAttachment(cellMessage: message!)
        
    }
    
    @objc func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.delegate?.didTapOnSenderAvatar(cellMessage: message!)
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
            let direction = pan.direction(in: self.view)
            if direction.contains(.Left)
            {
                return abs((pan.velocity(in: self.view)).x) > abs((pan.velocity(in: self.view)).y)
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
