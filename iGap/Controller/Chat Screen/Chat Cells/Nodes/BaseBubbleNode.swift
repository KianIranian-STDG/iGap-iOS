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
    private var finalRoomType: IGRoom.IGType!
    private var message: IGRoomMessage?
    private var isIncomming: Bool
    private var shouldShowAvatar : Bool
    private var isFromSameSender : Bool
    private let bubbleImgNode = ASImageNode()
    private let timeTxtNode = ASTextNode()
    private let nameTxtNode = ASTextNode()
    private let statusTxtNode = ASTextNode()
    
    private(set) var bubbleNode = ASCellNode()
    private var replyForwardViewNode = ASReplyForwardNode()

    private let avatarImageViewNode = ASAvatarView()
    private let avatarBtnViewNode = ASButtonNode()
    weak var delegate : ChatDelegate!

    init(message : IGRoomMessage, finalRoomType : IGRoom.IGType, isIncomming: Bool, bubbleImage: UIImage, isFromSameSender: Bool, shouldShowAvatar: Bool) {
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
                nameTxtNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                nameTxtNode.attributedText = NSAttributedString(string: name.displayName, attributes: kAMMessageCellNodeTopTextAttributes)
            } else {
                nameTxtNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                nameTxtNode.attributedText = NSAttributedString(string: "", attributes: kAMMessageCellNodeTopTextAttributes)
            }
        }

         if let forwardedMessage = message?.forwardedFrom {
            if forwardedMessage.type == .text {
                bubbleNode = IGTextNode(message: forwardedMessage, isIncomming: isIncomming)
            }
        } else {
            if message!.type == .text {
                bubbleNode = IGTextNode(message: message!, isIncomming: isIncomming)
            }else if message!.type == .image {
                bubbleNode = IGImageNode(message: message!, isIncomming: isIncomming)
            }

        }
        if message!.type == .text {
            bubbleNode = IGTextNode(message: message!, isIncomming: isIncomming)
        }else if message!.type == .image {
            bubbleNode = IGImageNode(message: message!, isIncomming: isIncomming)
        }
        if let time = message!.creationTime {
            timeTxtNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
            timeTxtNode.attributedText = NSAttributedString(string: time.convertToHumanReadable(), attributes: kAMMessageCellNodeTopTextAttributes)
        }

        if message!.type == .text ||  message!.type == .image {
            if(isIncomming){
                
                avatarImageViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                avatarImageViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                avatarImageViewNode.clipsToBounds = true

                //clearButton on top of ASAvatarView
                avatarBtnViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                avatarBtnViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                avatarBtnViewNode.clipsToBounds = true
                
                //set size of status marker to zero for incomming messages
                statusTxtNode.style.preferredSize = CGSize.zero

            }else{
                avatarImageViewNode.style.preferredSize = CGSize.zero
                avatarBtnViewNode.style.preferredSize = CGSize.zero
                let attribbutes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                   NSAttributedString.Key.font: UIFont.iGapFonticon(ofSize: 15)]

                self.statusTxtNode.attributedText = NSAttributedString(string: "", attributes: attribbutes)
            }
            //Add SubNodes
            addSubnode(bubbleImgNode)
            if !(finalRoomType == .chat) {
                addSubnode(nameTxtNode)
            }
            addSubnode(replyForwardViewNode)
            addSubnode(bubbleNode)
            addSubnode(timeTxtNode)
            addSubnode(statusTxtNode)
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
        if !(finalRoomType == .chat) {
            stack.children?.append(nameTxtNode)
        }
        //check if has reply or Forward
        if let repliedMessage = message?.repliedTo {
                   stack.children?.append(replyForwardViewNode)
            replyForwardViewNode.setReplyForward(isReply: true, extraMessage : repliedMessage)

            stack.children?.append(bubbleNode)
        } else if let forwardedFrom = message?.forwardedFrom {
                   stack.children?.append(replyForwardViewNode)
                   replyForwardViewNode.setReplyForward(isReply: false, extraMessage : forwardedFrom)
                   stack.children?.append(bubbleNode)
        } else {
            stack.children?.append(bubbleNode)
        }


        let textNodeVerticalOffset = CGFloat(6)
        timeTxtNode.style.alignSelf = .end
        
        
        
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = bubbleImgNode
        
        
        if let _ = bubbleNode  as? IGTextNode{
            if let msgcount = message!.message{
                if(msgcount.count <= 20){
                    
                    if (self.finalRoomType == .channel) {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [timeTxtNode])

                        let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .end, alignItems: ASStackLayoutAlignItems.end, children: isIncomming ? [stack , timeStatusStack] : [stack , timeStatusStack])
                        horizon.verticalAlignment = .bottom
                        
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset)),child: horizon)
                        
                    } else {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [timeTxtNode,statusTxtNode])

                        let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .end, alignItems: ASStackLayoutAlignItems.end, children: isIncomming ? [stack , timeStatusStack] : [stack , timeStatusStack])
                        horizon.verticalAlignment = .bottom
                        
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset)),child: horizon)
                        
                    }
                    
                }else{
                    
                    if (self.finalRoomType == .channel) {

                        stack.children?.append(timeTxtNode)
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset)),child: stack)
                        
                    } else {
                        
                        if isIncomming {
                            stack.children?.append(timeTxtNode)
                            verticalSpec.child = ASInsetLayoutSpec(
                                insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset)),child: stack)

                        } else {
                            let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [timeTxtNode,statusTxtNode])
                            stack.children?.append(timeStatusStack)
                            verticalSpec.child = ASInsetLayoutSpec(
                                insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset)),child: stack)

                        }

                        
                    }

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
