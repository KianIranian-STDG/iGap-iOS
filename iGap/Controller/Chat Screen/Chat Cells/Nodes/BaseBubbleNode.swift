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

class BaseBubbleNode: ASCellNode {
    
    private var message: IGRoomMessage
    private var isIncomming: Bool
    private var shouldShowAvatar : Bool
    private var isFromSameSender : Bool
    private let bubbleImgNode = ASImageNode()
    private let timeTxtNode = ASTextNode()
    private let nameTxtNode = ASTextNode()
    private let statusImgNode = ASImageNode()
    
    private var bubbleNode = ASDisplayNode()
    private let avatarImageViewNode = ASAvatarView()

    init(message : IGRoomMessage, isIncomming: Bool, bubbleImage: UIImage, isFromSameSender: Bool, shouldShowAvatar: Bool) {
        self.message = message
        self.isIncomming = isIncomming
        self.shouldShowAvatar = shouldShowAvatar
        self.isFromSameSender = isFromSameSender
        self.bubbleImgNode.image = bubbleImage
        super.init()
        
        setupView()
        
    }
    
    
    private func setupView() {
        if let name = message.authorUser?.userInfo.displayName {
            nameTxtNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
            nameTxtNode.attributedText = NSAttributedString(string: name, attributes: kAMMessageCellNodeTopTextAttributes)
        }

        if message.type == .text {
            bubbleNode = IGTextNode(message: message, isIncomming: isIncomming)
        }else if message.type == .image {
            bubbleNode = IGImageNode(message: message, isIncomming: isIncomming)
        }
        if let time = message.creationTime {
            timeTxtNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
            timeTxtNode.attributedText = NSAttributedString(string: time.convertToHumanReadable(), attributes: kAMMessageCellNodeTopTextAttributes)
        }

        
        
        //avatar
//        if let _ = IGAvatar.getLastAvatar(ownerId: (message.authorUser?.user!.id)!), let avatarFile = message.authorUser?.user!.avatar?.file {
//            avatarImageViewNode.setAvatar(avatar: avatarFile)
////            avatarImageViewNode.image = UIImage(named: "AppIcon")
//
//        } else if let avatar = message.authorUser?.user!.avatar {
//            avatarImageViewNode.setAvatar(avatar: avatar.file!)
////            avatarImageViewNode.image = UIImage(named: "AppIcon")
//
//        }else{
//            avatarImageViewNode.image = UIImage(named: "AppIcon")
//        }
//        avatarImageViewNode.image = UIImage(named: "AppIcon")

        if(isIncomming){
            avatarImageViewNode.style.preferredSize = CGSize.zero
            
        }else{
            avatarImageViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
            avatarImageViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
            avatarImageViewNode.clipsToBounds = true

        }
        addSubnode(bubbleImgNode)
        addSubnode(nameTxtNode)
        addSubnode(bubbleNode)
        addSubnode(timeTxtNode)
        addSubnode(avatarImageViewNode)
        
        

    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.spacing = 5
        
        stack.children?.append(nameTxtNode)
        stack.children?.append(bubbleNode)

        let textNodeVerticalOffset = CGFloat(6)
        timeTxtNode.style.alignSelf = .end
        
        
        
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = bubbleImgNode
        
        
        if let _ = bubbleNode  as? IGTextNode{
            if let namecount = message.message{
                if(namecount.count <= 20){
                    
                    let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: ASStackLayoutAlignItems.start, children: [stack , timeTxtNode])
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset)),child: horizon)
                    
                    
                }else{
                    stack.children?.append(timeTxtNode)
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsets(top: 8,left: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset),bottom: 8,right: 12 + (isIncomming ? textNodeVerticalOffset : textNodeVerticalOffset)),child: stack)
                    
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


        let stackHSpec = ASStackLayoutSpec()
        stackHSpec.direction = .horizontal
        stackHSpec.spacing = 5
//        stackHSpec.justifyContent = .spaceBetween
        stackHSpec.verticalAlignment = .bottom
//        stackHSpec.style.preferredSize.width = 200
        stackHSpec.children = [stackSpec,avatarImageViewNode]
        stackHSpec.style.flexShrink = 1.0
        stackHSpec.style.flexGrow = 1.0

        let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 1, left: 5, bottom: 5, right: 4) : UIEdgeInsets(top: 1, left: 4, bottom: 5, right: 5), child: stackHSpec)

        

        return insetHSpec
        
    }
    
}
