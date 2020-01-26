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

class IGFileNode: AbstractNode {
    
    private var fileImgNode: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .scaleAspectFit
        return node
    }()
    private var titleTxtNode = ASTextNode()
    private var sizeTxtNode = ASTextNode()
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode)
        setupView()
    }
    
    override func setupView() {
        super.setupView()
        
        fileImgNode.image = UIImage(named: "IG_Message_Cell_File_Pdf")
        titleTxtNode.attributedText = NSAttributedString(string: "heeeeeellllooo")
        sizeTxtNode.attributedText = NSAttributedString(string: "Sizzzzzzeeeeee")
        addSubnode(fileImgNode)
        addSubnode(titleTxtNode)
        addSubnode(sizeTxtNode)
        
        if message.type == .imageAndText {
            addSubnode(textNode)
        }
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        fileImgNode.style.width = ASDimension(unit: .points, value: 80)
        fileImgNode.style.height = ASDimension(unit: .points, value: 100)
        
        let imgAbsStack = ASAbsoluteLayoutSpec(children: [fileImgNode])
        
        let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .start, children: [titleTxtNode, sizeTxtNode])
        
        let hoStack = ASStackLayoutSpec(direction: .horizontal, spacing: 4, justifyContent: .start, alignItems: .start, children: [imgAbsStack, verticalStack])
        hoStack.verticalAlignment = .top
        
        
        let textNodeVerticalOffset = CGFloat(6)
        
        if message.type == .file {
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: hoStack)
            
            return insetSpec
            
        }else {
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 5,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 5,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: textNode)

            return ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .center, children: [hoStack, insetSpec])
            
        }
        
    }
    
    
}

