//
//  MessageWhatsappBubbleNode.swift
//  MMTextureChat
//
//  Created by Mukesh on 19/07/17.
//  Copyright © 2017 MadAboutApps. All rights reserved.
//

import UIKit
import AsyncDisplayKit

//Whatsapp

public let kAMMessageCellNodeAvatarImageSize: CGFloat = 24

public let kAMMessageCellNodeTopTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                  NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
public let kAMMessageCellNodeContentTopTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                         NSAttributedString.Key.font:UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)]
public let kAMMessageCellNodeBottomTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                     NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption2)]
public let kAMMessageCellNodeBubbleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                 NSAttributedString.Key.font:UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
public let kAMMessageCellNodeCaptionTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                      NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption2)]

class MessageWhatsappBubbleNode: ASCellNode{
    
    private let isOutgoing: Bool
    private let bubbleImageNode: ASImageNode
    private let timeNode: ASTextNode
    private let sectionNode: ASTextNode
    private let nameNode: ASTextNode
    private var bubbleNode: ASDisplayNode
//    let message : Chat
    let message : IGRoomMessage
//    weak var delegate : ChatDelegate!
    
    
    
    
    init(msg : IGRoomMessage, isOutgoing: Bool, bubbleImage: UIImage) {
        self.isOutgoing = isOutgoing
        self.message = msg
        bubbleImageNode = ASImageNode()
        bubbleImageNode.image = bubbleImage
        
        
        timeNode = ASTextNode()
        nameNode = ASTextNode()
        bubbleNode = ASDisplayNode()
        sectionNode = ASTextNode()
        
        super.init()
        
            if let text = msg.message{
                let myString = text
                let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blue , NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize) ]
                let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)

                bubbleNode = MessageWhatsappTextNode(text: myAttrString, isOutgoing: isOutgoing)
                
            }
            
        
        addSubnode(bubbleImageNode)
        addSubnode(bubbleNode)
        
 
        if let name = msg.authorUser?.userInfo.displayName{
            nameNode.textContainerInset = UIEdgeInsets(top: 0, left: (isOutgoing ? 0 : 6), bottom: 0, right: (isOutgoing ? 6 : 0))
            nameNode.attributedText = NSAttributedString(string: name, attributes: kAMMessageCellNodeTopTextAttributes)
            addSubnode(nameNode)
            
            
        }
                
        
        
    }
    
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.spacing = 5
        
        if let _ = message.authorUser?.userInfo.displayName{
//            nameNode.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
            stack.children?.append(nameNode)
            
        }
        stack.children?.append(bubbleNode)
        
        let textNodeVerticalOffset = CGFloat(6)
        timeNode.style.alignSelf = .end
        
        
        
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = bubbleImageNode
        
        
        if let _ = bubbleNode  as? MessageWhatsappTextNode{
            if let namecount = message.message{
                if(namecount.count <= 20){
                    
                    let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: ASStackLayoutAlignItems.start, children: [stack , timeNode])
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsets(top: 8,left: 12 + (isOutgoing ? 0 : textNodeVerticalOffset),bottom: 8,right: 12 + (isOutgoing ? textNodeVerticalOffset : 0)),child: horizon)
                    
                    
                }else{
                    stack.children?.append(timeNode)
                    verticalSpec.child = ASInsetLayoutSpec(
                        insets: UIEdgeInsets(top: 8,left: 12 + (isOutgoing ? 0 : textNodeVerticalOffset),bottom: 8,right: 12 + (isOutgoing ? textNodeVerticalOffset : 0)),child: stack)
                    
                }
                
            }
            
            
        }
        
                        
        
        //space it
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


