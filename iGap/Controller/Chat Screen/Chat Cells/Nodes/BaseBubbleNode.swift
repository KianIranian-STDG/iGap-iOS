//
//  BaseBubbleNode.swift
//  iGap
//
//  Created by ahmad mohammadi on 1/19/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import AsyncDisplayKit

class BaseBubbleNode: ASCellNode {
    
    private var message: IGRoomMessage
    private var isOutgoing: Bool
    
    private let bubbleImgNode = ASImageNode()
    private let timeTxtNode = ASTextNode()
    private let nameTxtNode = ASTextNode()
    private let statusImgNode = ASImageNode()
    
    private var bubbleNode = ASDisplayNode()
    
    init(message : IGRoomMessage, isOutgoing: Bool, bubbleImage: UIImage) {
        self.message = message
        self.isOutgoing = isOutgoing
        self.bubbleImgNode.image = bubbleImage
        super.init()
        
        setupView()
        
    }
    
    
    private func setupView() {
        
        if message.type == .text {
            bubbleNode = MsgTextNode(message: message.message ?? "", isOutgoing: isOutgoing)
        }else if message.type == .image {
            bubbleNode = MsgImageNode(image: message.attachment?.attachedImage ?? #imageLiteral(resourceName: "holm.jpg"), isOutgoing: isOutgoing)
        }
        
        
        addSubnode(bubbleImgNode)
        addSubnode(bubbleNode)
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.spacing = 5
        
        
        if let _ = message.authorUser?.userInfo.displayName{
            stack.children?.append(nameTxtNode)
        }
        stack.children?.append(bubbleNode)
        
        let textNodeVerticalOffset = CGFloat(6)
        timeTxtNode.style.alignSelf = .end
        
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = bubbleImgNode
        
//        if let _ = bubbleNode  as? MsgTextNode{
            if let namecount = message.message{
                if(namecount.count <= 20){
                    
                    let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: ASStackLayoutAlignItems.start, children: [stack , timeTxtNode])
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsets(top: 8,left: 12 + (isOutgoing ? 0 : textNodeVerticalOffset),bottom: 8,right: 12 + (isOutgoing ? textNodeVerticalOffset : 0)),child: horizon)
                }else{
                    stack.children?.append(timeTxtNode)
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsets(top: 8,left: 12 + (isOutgoing ? 0 : textNodeVerticalOffset),bottom: 8,right: 12 + (isOutgoing ? textNodeVerticalOffset : 0)),child: stack)
                    
                }
            }
//        }
        
        
        let insetSpec = ASInsetLayoutSpec(insets: isOutgoing ? UIEdgeInsets(top: 1, left: 32, bottom: 5, right: 4) : UIEdgeInsets(top: 1, left: 4, bottom: 5, right: 32), child: verticalSpec)
        
        
        let stackSpec = ASStackLayoutSpec()
        stackSpec.direction = .vertical
        stackSpec.justifyContent = .spaceAround
        stackSpec.alignItems = isOutgoing ? .end : .start
        
        stackSpec.spacing = 0
        stackSpec.children = [insetSpec]
            
        
        return stackSpec
        
    }
    
}
