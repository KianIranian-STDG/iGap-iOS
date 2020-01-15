/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation
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
class ASTextCell : ASCellNode {

    private let isOutgoing: Bool
    private let bubbleImageNode: ASImageNode
    private let textNode: ASTextNode
    
    init(text: NSAttributedString, isOutgoing: Bool, bubbleImage: UIImage) {
        self.isOutgoing = isOutgoing

        bubbleImageNode = ASImageNode()
        bubbleImageNode.image = bubbleImage

        textNode = MessageTextNode()
        textNode.attributedText = text
        
        super.init()
        
        addSubnode(bubbleImageNode)
        addSubnode(textNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textNodeVerticalOffset = CGFloat(6)
        return ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(
                insets: UIEdgeInsets(
                    top: 12,
                    left: 12 + (isOutgoing ? 0 : textNodeVerticalOffset),
                    bottom: 12,
                    right: 12 + (isOutgoing ? textNodeVerticalOffset : 0)),
                child: textNode),
            background: bubbleImageNode)
    }
    
}
