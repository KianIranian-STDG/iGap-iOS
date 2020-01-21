//
//  MessageWhatsappTextNode.swift
//  MMTextureChat
//
//  Created by Mukesh on 19/07/17.
//  Copyright © 2017 MadAboutApps. All rights reserved.
//

import UIKit
import AsyncDisplayKit

private class MessageTextNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.clear
        isLayerBacked = true
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }
    
}

class MessageWhatsappTextNode : ASDisplayNode , ASTextNodeDelegate{
    
    let isOutgoing: Bool
    let textNode: ASTextNode
    
    public init(text: NSAttributedString, isOutgoing: Bool) {
        self.isOutgoing = isOutgoing
        
        textNode = MessageTextNode()
        
        let attr = NSMutableAttributedString(attributedString: text)
        
        
        textNode.attributedText = attr
        
        super.init()
        
        addSubnode(textNode)
        
        //target delegate
        textNode.isUserInteractionEnabled = true
        textNode.delegate = self
        let linkcolor = isOutgoing ? UIColor.white : UIColor.blue
//        textNode.addLinkDetection(attr.string, highLightColor: linkcolor)
//        textNode.addUserMention(highLightColor: linkcolor)
        
    }
    
    
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textNodeVerticalOffset = CGFloat(6)
        
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isOutgoing ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isOutgoing ? textNodeVerticalOffset : 0)), child: textNode)
        
        
        return insetSpec
        
        //        return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: ASStackLayoutJustifyContent.start, alignItems: .start, children: [insetSpec])
        
    }
    
    
    //MARK: - Text Delegate
    
    public func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return true
    }
    
    public func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        print("link tap")
        
    }
}


