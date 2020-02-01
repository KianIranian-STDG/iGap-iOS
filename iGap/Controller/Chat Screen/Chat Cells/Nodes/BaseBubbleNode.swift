/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import AsyncDisplayKit
import SwiftEventBus

@objc protocol ChatDelegate : AnyObject{
    
    func openuserProfile(message : IGRoomMessage)
}

class BaseBubbleNode: ASCellNode {
    private var finalRoom: IGRoom!
    private var finalRoomType: IGRoom.IGType!
    var message: IGRoomMessage?
    private var isIncomming: Bool
    private var shouldShowAvatar : Bool
    private var isFromSameSender : Bool
    private let bubbleImgNode = ASImageNode()
    private let txtTimeNode = ASTextNode()
    private let txtNameNode = ASTextNode()
    private let txtStatusNode = ASTextNode()
    private var subNode = ASDisplayNode()

    private(set) var bubbleNode = ASCellNode()
    private var replyForwardViewNode = ASReplyForwardNode()
    
    private var imgNodeReply = ASImageNode()
    
    private let avatarImageViewNode = ASAvatarView()
    private let avatarBtnViewNode = ASButtonNode()
    weak var delegate : ChatDelegate!
    
    weak var generalMessageDelegate: IGMessageGeneralCollectionViewCellDelegate?
    
    var pan: UIPanGestureRecognizer!
    var tapMulti: UITapGestureRecognizer!
    
    override func didLoad() {
        super.didLoad()
        self.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        manageGestureRecognizers()
        if !(IGGlobal.shouldMultiSelect) {
            makeSwipeImage()
            swipePositionManager()
        }
    }
    
    init(message : IGRoomMessage, finalRoomType : IGRoom.IGType, finalRoom : IGRoom, isIncomming: Bool, bubbleImage: UIImage, isFromSameSender: Bool, shouldShowAvatar: Bool) {
        self.finalRoom = finalRoom
        self.finalRoomType = finalRoomType
        self.message = message
        self.isIncomming = isIncomming
        self.shouldShowAvatar = shouldShowAvatar
        self.isFromSameSender = isFromSameSender
        self.bubbleImgNode.image = bubbleImage
        super.init()
        
        setupView()
        
    }
    
    
    private func setupView() {
        if !(finalRoomType == .chat) {
            if let name = message!.authorUser?.userInfo {
                txtNameNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeText(for: txtNameNode, with: name.displayName, textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
            } else {
                txtNameNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeText(for: txtNameNode, with: "", textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
        }
        
        var msg = message
        
        if let forMessage = message?.forwardedFrom { // if message contains Forward message pass forwarded message instead of original message
            msg = forMessage
        }
        
        if message!.type == .text {
            bubbleNode = IGTextNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if message!.type == .image || message!.type == .imageAndText {
            bubbleNode = IGImageNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if message!.type == .video || message!.type == .videoAndText {
            bubbleNode = IGVideoNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if message!.type == .file || message!.type == .fileAndText {
            bubbleNode = IGFileNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if message!.type == .voice {
            bubbleNode = IGVoiceNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if message!.type == .location {
            bubbleNode = IGLocationNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if message!.type == .audio {
            bubbleNode = IGMusicNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if message!.type == .contact {
            bubbleNode = IGContactNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if message!.type == .sticker {
            bubbleNode = IGStrickerNormalNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }
        
        
        
        if let time = message!.creationTime {
            txtTimeNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
            IGGlobal.makeText(for: txtTimeNode, with: time.convertToHumanReadable(), textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
        if message!.type == .text ||  message!.type == .image ||  message!.type == .imageAndText ||  message!.type == .file ||  message!.type == .fileAndText || message!.type == .voice || message!.type == .location || message!.type == .video || message!.type == .videoAndText || message!.type == .audio || message!.type == .contact || message!.type == .sticker {
            if(isIncomming){
                
                avatarImageViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                avatarImageViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                avatarImageViewNode.clipsToBounds = true
                
                //clearButton on top of ASAvatarView
                avatarBtnViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                avatarBtnViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                avatarBtnViewNode.clipsToBounds = true
                
                //set size of status marker to zero for incomming messages
                txtStatusNode.style.preferredSize = CGSize.zero
                
            }else{
                avatarImageViewNode.style.preferredSize = CGSize.zero
                avatarBtnViewNode.style.preferredSize = CGSize.zero
                
                IGGlobal.makeText(for: self.txtStatusNode, with: "", textColor: .lightGray, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                
            }
            //Add SubNodes
            if message?.type == .sticker {
                addSubnode(subNode)
            }

            addSubnode(bubbleImgNode)
            if finalRoomType == .group && isIncomming {
               addSubnode(txtNameNode)
            }
            addSubnode(replyForwardViewNode)
            addSubnode(bubbleNode)
            addSubnode(txtTimeNode)
            addSubnode(txtStatusNode)
            addSubnode(avatarImageViewNode)
            addSubnode(avatarBtnViewNode)//Button with clear BG in order to handle tap on avatar
            
            //Avatar
            if let user = message!.authorUser?.user {
                avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.clear
                avatarImageViewNode.setUser(user)
            } else if let userId = message!.authorUser?.userId {
                avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.white
                avatarImageViewNode.avatarASImageView!.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
                SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(message!.roomId)", sender: (action: ChatMessageAction.userInfo, userId: userId))
            }
            
            //Taps
            avatarBtnViewNode.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
            
        }
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.spacing = 5
        if finalRoomType == .group && isIncomming {
            if message?.type != .sticker || message?.type != .log || message?.type != .unread {

                stack.children?.append(txtNameNode)
                
            }
        }
        //check if has reply or Forward
        if let repliedMessage = message?.repliedTo {
            
            stack.children?.append(replyForwardViewNode)
            replyForwardViewNode.setReplyForward(isReply: true, extraMessage : repliedMessage)
            
            stack.children?.append(bubbleNode)
        } else if let forwardedFrom = message?.forwardedFrom {
            if message?.type != .sticker || message?.type != .log {
                stack.children?.append(replyForwardViewNode)
                replyForwardViewNode.setReplyForward(isReply: false, extraMessage : forwardedFrom)
            }
            stack.children?.append(bubbleNode)
        } else {
            stack.children?.append(bubbleNode)
        }
        
        
        let textNodeVerticalOffset = CGFloat(6)
        txtTimeNode.style.alignSelf = .end
        
        let verticalSpec = ASBackgroundLayoutSpec()
        if message?.type != .sticker || message?.type == .log {
            verticalSpec.background = bubbleImgNode
        }
        
        /**************************************************************/
        /************DIFFRENT NODES SHOULD BE ADDED HERE**************/
        /**************************************************************/
        
        
        
        
        
        /**************************************************************/
        /************TEXT NODE**************/
        /**************************************************************/
        
        if let _ = bubbleNode  as? IGTextNode{ // Only Contains Text
            var msg = message!.message
            if let forwardMessage = message?.forwardedFrom {
                msg = forwardMessage.message
            }
            if let msgcount = msg {
                if(msgcount.count <= 20){
                    
                    if (self.finalRoomType == .channel) {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode])
                        
                        let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .end, alignItems: ASStackLayoutAlignItems.end, children: isIncomming ? [stack , timeStatusStack] : [stack , timeStatusStack])
                        horizon.verticalAlignment = .bottom
                        
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: horizon)
                        
                    } else {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center
                        
                        let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .end, alignItems: ASStackLayoutAlignItems.end, children: [stack , timeStatusStack])
                        horizon.verticalAlignment = .bottom
                        
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: horizon)
                        
                    }
                    
                }else{
                    
                    if (self.finalRoomType == .channel) {
                        
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    } else {
                        
                        if isIncomming {
                            stack.children?.append(txtTimeNode)
                            verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12 + textNodeVerticalOffset, bottom: 8, right: 12 + textNodeVerticalOffset),child: stack)
                            
                        } else {
                            let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                            timeStatusStack.verticalAlignment = .center

                            stack.children?.append(timeStatusStack)
                            verticalSpec.child = ASInsetLayoutSpec(
                                insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            
        }
            /**************************************************************/
            /************IMAGE AND IMAGE TEXT NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGImageNode{
            if message!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode])
                    
                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                    
                    
                } else {
                    
                    if isIncomming {
//                        stack.children?.append(txtTimeNode)
//                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode])
                        
                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                        
                        
                    } else {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center

                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                        
                    }
                    
                }
                
            }
            
            
        }
            
            /**************************************************************/
            /************VIDEO AND VIDEO TEXT NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGVideoNode{
            if message!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                } else {
                    
                    if isIncomming {
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                        
                    } else {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center

                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                        
                    }
                    
                }
                
            }
            
            
        }
            
            /**************************************************************/
            /************FILE NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGFileNode {
            
            if message!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                } else {
                    
                    if isIncomming {
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    } else {
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center

                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    }
                    
                }
                
            }
            
        }
            
            /**************************************************************/
            /************VOICE NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGVoiceNode {
            
            if message!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                    
                } else {
                    
                    if isIncomming {
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    } else {
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center

                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    }
                    
                }
                
            }
            
        }
            
            /**************************************************************/
            /************MUSIC NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGMusicNode {
            
            if let msattachment = message!.attachment{
                
                if message!.attachment != nil{
                    
                    if (self.finalRoomType == .channel) {
                        
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    } else {
                        
                        if isIncomming {
                            stack.children?.append(txtTimeNode)
                            verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset, bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                            
                        } else {
                            let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                            timeStatusStack.verticalAlignment = .center

                            stack.children?.append(timeStatusStack)
                            verticalSpec.child = ASInsetLayoutSpec(
                                insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
            
            
            /**************************************************************/
            /************LOCATION NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGLocationNode{
            
            if (self.finalRoomType == .channel) {
                
                stack.children?.append(txtTimeNode)
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                
            } else {
                
                if isIncomming {
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                } else {
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                    timeStatusStack.verticalAlignment = .center

                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
        }
        /**************************************************************/
            /************CONTACT NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGContactNode{
            
            if (self.finalRoomType == .channel) {
                
                stack.children?.append(txtTimeNode)
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)

            } else {
                
                if isIncomming {
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                } else {
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                    timeStatusStack.verticalAlignment = .center

                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
            
            
        }

            /**************************************************************/
            /************NORMAL STICKER NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGStrickerNormalNode{
            
            if (self.finalRoomType == .channel) {
                
                stack.children?.append(txtTimeNode)
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)

            } else {
                
                if isIncomming {
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                } else {
                    subNode.style.preferredSize = CGSize(width: 100, height: 30)
                    subNode.backgroundColor = UIColor(white: 0, alpha: 0.6)
                    subNode.layer.cornerRadius = 5
                    let timeStatusBackBox = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                    timeStatusBackBox.verticalAlignment = .center
                    let backBox = ASBackgroundLayoutSpec(child: timeStatusBackBox, background: subNode)
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: [backBox])
                    
                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
            
            
        }

        
        //        space it
        let insetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 1, left: 5, bottom: 5, right: 4) : UIEdgeInsets(top: 1, left: 4, bottom: 5, right: 5), child: verticalSpec)
        
        
        let stackSpec = ASStackLayoutSpec()
        stackSpec.direction = .vertical
        stackSpec.justifyContent = .spaceAround
        stackSpec.alignItems = isIncomming ? .start : .end
        stackSpec.style.flexShrink = 1.0
        stackSpec.style.flexGrow = 1.0
        
        stackSpec.spacing = 0
        stackSpec.children = [insetSpec]
        
        
        let ASBGStack = ASBackgroundLayoutSpec(child: avatarBtnViewNode, background: avatarImageViewNode)
        let stackHSpec = ASStackLayoutSpec()
        stackHSpec.direction = .horizontal
        stackHSpec.spacing = 5
        //        stackHSpec.justifyContent = .spaceBetween
        stackHSpec.verticalAlignment = .bottom
        //        stackHSpec.style.preferredSize.width = 200
        stackHSpec.children = isIncomming ? [ASBGStack,stackSpec] : [stackSpec,ASBGStack]
        stackHSpec.style.flexShrink = 1.0
        stackHSpec.style.flexGrow = 1.0
        
        let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 1, left: 5, bottom: 5, right: 4) : UIEdgeInsets(top: 1, left: 4, bottom: 5, right: 5), child: stackHSpec)
        
        
        
        return insetHSpec
        
    }
    //- Hint : Check tap on user profile
    @objc func handleUserTap() {
        
        if(delegate != nil){
            if let msg = message{
                self.delegate.openuserProfile(message: msg)
                
            }
        }
    }
}

    //MARK: - Gesture Recognizers

extension BaseBubbleNode: UIGestureRecognizerDelegate {
    
    func manageGestureRecognizers() {
        if !IGGlobal.shouldMultiSelect  {
            
            let tapAndHold = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnCell(_:)))
            tapAndHold.minimumPressDuration = 0.2
            bubbleNode.view.addGestureRecognizer(tapAndHold)
            
            bubbleNode.view.isUserInteractionEnabled = true
            
            if message?.repliedTo != nil {
                let onReplyClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnReply(_:)))
                replyForwardViewNode.view.addGestureRecognizer(onReplyClick)
                replyForwardViewNode.isUserInteractionEnabled = true
                if !(IGGlobal.shouldMultiSelect) {
                    replyForwardViewNode.isUserInteractionEnabled = true
                }else {
                    replyForwardViewNode.isUserInteractionEnabled = false

                }
            }
            
            if message?.forwardedFrom != nil {
                let onForwardClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnForward(_:)))
                replyForwardViewNode.view.addGestureRecognizer(onForwardClick)
                if !(IGGlobal.shouldMultiSelect) {
                    replyForwardViewNode.isUserInteractionEnabled = true
                }else {
                    replyForwardViewNode.isUserInteractionEnabled = false
                }
            }
            
            if bubbleNode as? IGFileNode != nil {
                let onFileClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                bubbleNode.view.addGestureRecognizer(onFileClick)
                
                if !(IGGlobal.shouldMultiSelect) {
                    (bubbleNode as! IGImageNode).imgNode.isUserInteractionEnabled = true
                }
                else {
                    (bubbleNode as! IGImageNode).imgNode.isUserInteractionEnabled = false
                }
            }
            
            if bubbleNode as? IGImageNode != nil || bubbleNode as? IGVideoNode != nil {
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                bubbleNode.view.addGestureRecognizer(tap1)
                if !(IGGlobal.shouldMultiSelect) {
                    bubbleNode.isUserInteractionEnabled = true
                }
                else {
                    bubbleNode.isUserInteractionEnabled = false
                }
            }
            
//            if animationView != nil {
//                let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
//                animationView?.addGestureRecognizer(tap2)
//                if !(IGGlobal.shouldMultiSelect) {
//                    animationView?.isUserInteractionEnabled = true
//                }
//                else {
//                    animationView?.isUserInteractionEnabled = false
//                }
//            }
//            if btnReturnToMessageAbs != nil {
//                let tapReturnToMessage = UITapGestureRecognizer(target: self, action: #selector(didTapOnReturnToMessage(_:)))
//                btnReturnToMessageAbs?.addGestureRecognizer(tapReturnToMessage)
//            }
//
//            let statusGusture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFailedStatus(_:)))
//            txtStatusAbs?.addGestureRecognizer(statusGusture)
//            txtStatusAbs?.isUserInteractionEnabled = true
//
//            let tap5 = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
//            avatarViewAbs?.addGestureRecognizer(tap5)
//
//            let tapVoteUp = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteUp(_:)))
//            txtVoteUpAbs?.addGestureRecognizer(tapVoteUp)
//            txtVoteUpAbs?.isUserInteractionEnabled = true
//
//            let tapVoteDown = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteDown(_:)))
//            txtVoteDownAbs?.addGestureRecognizer(tapVoteDown)
//            txtVoteDownAbs?.isUserInteractionEnabled = true

        }
    }
    
    @objc func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if !(IGGlobal.shouldMultiSelect) {
                self.generalMessageDelegate?.didTapAndHoldOnMessage(cellMessage: message!)
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
        self.generalMessageDelegate?.didTapOnMultiForward(cellMessage: message!, isFromCloud: IGGlobal.isCloud(room: finalRoom))
    }

    @objc func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.generalMessageDelegate?.didTapOnAttachment(cellMessage: message!)
        }
    }
    
    @objc func didTapOnReply(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.generalMessageDelegate?.didTapOnReply(cellMessage: message!)
        }
    }
    
    @objc func didTapOnForward(_ gestureRecognizer: UITapGestureRecognizer) {
        self.generalMessageDelegate?.didTapOnForward(cellMessage: message!)
    }
    
    @objc func didTapOnReturnToMessage(_ gestureRecognizer: UITapGestureRecognizer) {
        self.generalMessageDelegate?.didTapOnReturnToMessage()
    }
    
    @objc func didTapOnFailedStatus(_ gestureRecognizer: UITapGestureRecognizer) {
        if message!.status == .failed {
            self.generalMessageDelegate?.didTapOnFailedStatus(cellMessage: message!)
        }
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.generalMessageDelegate?.didTapOnForwardedAttachment(cellMessage: message!)
        
    }
    
    @objc func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.generalMessageDelegate?.didTapOnSenderAvatar(cellMessage: message!)
        }
    }
    
//    @objc func didTapOnVoteUp(_ gestureRecognizer: UITapGestureRecognizer) {
//        var messageVote: IGRoomMessage! = message
//        if let forward = message!.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
//            messageVote = forward
//        }
//        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsUp)
//    }
//
//    @objc func didTapOnVoteDown(_ gestureRecognizer: UITapGestureRecognizer) {
//        var messageVote: IGRoomMessage! = message
//        if let forward = message!.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
//            messageVote = forward
//        }
//        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsDown)
//    }
//
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
    
    
    
    
    /*
     ******************************************************************
     ************************** Swipe to Reply ************************
     ******************************************************************
     */
    
    private func makeSwipeImage() {
//        self.backgroundColor = UIColor.clear
//        imgReply = UIImageView()
//        imgReply.contentMode = .scaleAspectFit
//        imgReply.image = UIImage(named: "ig_message_reply")
//        imgReply.alpha = 0.5
        
        imgNodeReply.contentMode = .scaleAspectFit
        imgNodeReply.image = UIImage(named: "ig_message_reply")
        imgNodeReply.alpha = 0.5
        
        
        if !(IGGlobal.shouldMultiSelect) {
            pan = UIPanGestureRecognizer(target: self, action: #selector(onSwipe(_:)))
            pan.delegate = self
            view.addGestureRecognizer(pan)
        }
    }
    
    private func swipePositionManager(){
        if finalRoom.isInvalidated {
            return
        }
        if finalRoomType == .chat || finalRoomType == .group {
            if pan != nil {
                
                if (pan.state == UIGestureRecognizer.State.changed) {
//                    self.insertSubview(imgReply, belowSubview: self.contentView)
                    let p: CGPoint = pan.translation(in: view)
                    let width = self.view.frame.width
                    let height = self.view.frame.height
                    self.view.frame = CGRect(x: p.x,y: 0, width: width, height: height);
                    self.imgNodeReply.frame = CGRect(x: p.x + width + imgNodeReply.frame.size.width, y: (height/2) - (imgNodeReply.frame.size.height) / 2 , width: CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT), height: CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT))
                    
                } else if (pan.state == UIGestureRecognizer.State.ended) || (pan.state == UIGestureRecognizer.State.cancelled) {
                    imgNodeReply.removeFromSupernode()
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
            let shouldReply = abs(pan.velocity(in: view).x) > UIScreen.main.bounds.width / 2
            let direction = pan.direction(in: view.superview!)
            
            if direction.contains(.Left) {
                switch message!.status {

                case .failed, .unknown , .sending:
                    UIView.animate(withDuration: 0.2, animations: {
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
                    })
                    break
                default :
                    if (shouldReply) {
//                        let collectionView: UITableView = view.superview as! UITableView
//                        let indexPath: IndexPath = collectionView.indexPathForItem(at: view.center)!
//                        collectionView.delegate?.collectionView!(collectionView, performAction: #selector(onSwipe(_:)), forItemAt: indexPath, withSender: nil)
                        
                        
                        let tableView = view.superview!.superview!.superview as! UITableView
                        let indexPath = tableView.indexPathForRow(at: view.center)!
                        tableView.delegate?.tableView?(tableView, performAction: #selector(onSwipe(_:)), forRowAt: indexPath, withSender: nil)
                        
                        
                        
                        
                        
                        
                        
                        
                        UIView.animate(withDuration: 0.2, animations: {[weak self] in
                            guard let sSelf = self else {
                                return
                            }
                            sSelf.setNeedsLayout()
                            sSelf.generalMessageDelegate?.swipToReply(cellMessage: sSelf.message!)
                            sSelf.layoutIfNeeded()
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    
    
   
}
