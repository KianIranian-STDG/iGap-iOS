//
//  IGTextNode.swift
//  iGap
//
//  Created by ahmad mohammadi on 1/19/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import AsyncDisplayKit

class IGTextNode: ASCellNode {
    
    private let textNode = MsgTextTextNode()
    
    private let message: String
    private let isOutgoing: Bool
    
    init(message: String, isOutgoing: Bool) {
        self.message = message
        self.isOutgoing = isOutgoing
        super.init()
        setupView()
    }
    
    private func setupView() {
        
        textNode.attributedText = NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize)])
        textNode.isUserInteractionEnabled = true
        addSubnode(textNode)
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let textNodeVerticalOffset = CGFloat(6)
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isOutgoing ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isOutgoing ? textNodeVerticalOffset : 0)), child: textNode)
        
        
        return insetSpec
        
    }
    
}

private class MsgTextTextNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.clear
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }
     
}
