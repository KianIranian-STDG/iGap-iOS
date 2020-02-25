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
    private let avatarImageSize: CGFloat = 50
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
    
    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?
    
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
        
        if let repliedMessage = message.repliedTo {
            msg = message
            
        } else if let forwardedFrom = message.forwardedFrom {
            msg = forwardedFrom
        } else {
            msg = message
        }
        
        
        if msg.type == .text {
            isTextMessageNode = true
        }
        if msg.type == .text || msg.type == .imageAndText || msg.type == .image || msg.type == .gif || msg.type == .gifAndText {
            let baseBubbleBox = makeBubble(bubbleImage: bubbleImage) // make bubble
            let contentItemsBox = makeContentBubbleItems(msg: msg) // make contents
            baseBubbleBox.child = contentItemsBox // add contents as child to bubble
            
            self.layoutSpecBlock = {[weak self] node, constrainedSize in
                guard let sSelf = self else {
                    return ASLayoutSpec()
                }
                let stack = ASStackLayoutSpec()
                stack.direction = .horizontal
                stack.spacing = 5
                stack.verticalAlignment = .bottom
                stack.horizontalAlignment = isIncomming ? .left : .right
                stack.children = [baseBubbleBox]
                stack.style.flexShrink = 1.0
                
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 10, bottom: isFromSameSender ? 1 : 10, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: isFromSameSender ? 1 : 10 , right: 5), child: stack)
                
                return insetHSpec
            }
            manageAttachment(file: message.attachment)
        }
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
                    txtNameNode!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 50)
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
        contentSpec.spacing = 10
        
        
        switch msg!.type {
        case .text :
            let finalBox = setTextNodeContent(contentSpec: contentSpec)
            
            return finalBox
        case .image,.imageAndText :
            let finalBox = setImageNodeContent(contentSpec: contentSpec, msg: msg!)
            
            return finalBox
        case .gif,.gifAndText :
            let finalBox = setGifNodeContent(contentSpec: contentSpec, msg: msg!)
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
                }
            }
        }
        if indicatorViewAbs == nil {
            indicatorViewAbs = ASDisplayNode { () -> UIView in
                let view = IGProgress()
                return view
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
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: gifNode!)
            
            verticalSpec.children?.append(insetSpecImage)
            let overlay = ASOverlayLayoutSpec(child: verticalSpec, overlay: indicatorViewAbs!)
            contentSpec.children?.append(overlay)
            
    
            AddTextNodeTo(spec: contentSpec)
            setMessage()
            
            nodeText?.style.maxWidth = ASDimensionMake(.points, prefferedSize.width)
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
            
            return finalInsetSpec

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
            imgNode!.contentMode = .scaleAspectFit
            
        }
        if message!.attachment != nil {
            if !(IGGlobal.isFileExist(path: msg.attachment!.localPath)) {
                if indicatorViewAbs == nil {
                    indicatorViewAbs = ASDisplayNode { () -> UIView in
                        let view = IGProgress()
                        return view
                    }
                }
            }
        }
        if indicatorViewAbs == nil {
            indicatorViewAbs = ASDisplayNode { () -> UIView in
                let view = IGProgress()
                return view
            }
        }
        imgNode!.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode!.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        imgNode!.clipsToBounds = true
        
        imgNode!.layer.cornerRadius = 10
        indicatorViewAbs!.style.height = ASDimensionMake(.points, 50)
        indicatorViewAbs!.style.width = ASDimensionMake(.points, 50)
        
        if msg.type == .image {
            RemoveNodeText()
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            let insetsImage = isIncomming ? UIEdgeInsets(top: -5, left: -10, bottom: 0, right: -5) : UIEdgeInsets(top: -5, left: -5, bottom: 0, right: -7)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgNode!)
            
            verticalSpec.children?.append(insetSpecImage)
            
            let overlay = ASOverlayLayoutSpec(child: verticalSpec, overlay: indicatorViewAbs!)
            contentSpec.children?.append(overlay)
            
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
            
            return finalInsetSpec
            
            
        } else {
            
            let verticalSpec = ASStackLayoutSpec()
            verticalSpec.direction = .vertical
            verticalSpec.spacing = 0
            verticalSpec.justifyContent = .start
            verticalSpec.alignItems = isIncomming == true ? .end : .start
            let insetsImage = isIncomming ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let insetSpecImage = ASInsetLayoutSpec(insets: insetsImage, child: imgNode!)
            
            verticalSpec.children?.append(insetSpecImage)
            let overlay = ASOverlayLayoutSpec(child: verticalSpec, overlay: indicatorViewAbs!)
            contentSpec.children?.append(overlay)
            
    
            AddTextNodeTo(spec: contentSpec)
            setMessage()
            
            nodeText?.style.maxWidth = ASDimensionMake(.points, prefferedSize.width)
            makeBottomBubbleItems(contentStack: contentSpec)
            let finalInsetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
            
            return finalInsetSpec

        }
        
    }
    private func AddTextNodeTo(spec : ASLayoutSpec) {
        if nodeText == nil {
            nodeText = ASTextNode()
        }

        nodeText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 50)
        nodeText!.style.minHeight = ASDimensionMake(.points, 20)        
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
            
            if txtTimeNode == nil {
                txtTimeNode = ASTextNode()
            }

            if txtStatusNode == nil {
                txtStatusNode = ASTextNode()
            }

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
        }
        

    }
    
    /*
     ******************************************************************
     ************************ Manage Attachment ***********************
     ******************************************************************
     */
    
    private func manageAttachment(file: IGFile? = nil){
        
        
        if var attachment = message!.attachment , !(attachment.isInvalidated) {
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                attachment = attachmentVariableInCache.value
            } else {
                IGAttachmentManager.sharedManager.add(attachment: attachment)
                if let variable = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                    attachment = variable.value
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
                        
                        (indicatorViewAbs!.view as! IGProgress).delegate = self
                    }
                    break
                }
            case .gif,.gifAndText :
                if !(attachment.isInvalidated) {
                    
                    (gifNode!.view as! GIFImageView).setThumbnail(for: attachment)
                    
                    if attachment.status != .ready {
                        
                        (indicatorViewAbs!.view as! IGProgress).delegate = self
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
                
                (indicatorViewAbs!.view as! IGProgress).setState(.ready)
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
                (indicatorViewAbs!.view as! IGProgress).setFileType(.download)
            } else {
                (indicatorViewAbs!.view as! IGProgress).setFileType(.upload)
            }
            (indicatorViewAbs!.view as! IGProgress).setState(attachment.status)
            if attachment.status == .downloading || attachment.status == .uploading {
                (indicatorViewAbs!.view as! IGProgress).setPercentage(attachment.downloadUploadPercent)
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
        let insetContentSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10) : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: contentSpec)
        
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
            nodeText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 50)
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

        nodeOnlyText!.style.maxWidth = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 50)
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

extension ChatControllerNode: IGProgressDelegate {
    
    func downloadUploadIndicatorDidTap(_ indicator: IGProgress) {
        if !IGGlobal.shouldMultiSelect {///if not in multiSelectMode
            
            if let attachment = attachment {
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
