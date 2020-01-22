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

class IGImageNode: ASCellNode {
    
    private var imgNode : MsgImageImageNode
    private var txtNode: ASTextNode
    
    private let image: UIImage
    private let isIncomming: Bool
    private var text: String?
    
    
    init(message: IGRoomMessage, isIncomming: Bool) {
        self.image = message.attachment?.attachedImage ?? UIImage()
        self.text = message.message
        imgNode = MsgImageImageNode()
        txtNode = ASTextNode()
        self.isIncomming = isIncomming
        super.init()
        setupView()
    }
    
    
//    init(image: UIImage, text: String? = nil, isIncomming: Bool) {
//        self.image = image
//        self.text = text
//        imgNode = MsgImageImageNode()
//        txtNode = ASTextNode()
//        self.isIncomming = isIncomming
//        super.init()
//        setupView()
//    }
    
    private func setupView() {
        
        imgNode.image = image
        addSubnode(imgNode)
        
        if let txt = text {
            txtNode.backgroundColor = .clear
            addSubnode(txtNode)
            txtNode.attributedText = NSAttributedString(string: txt, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize)])
        }
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        
        let prefferedSize = NodeExtension.fetchMediaFrame(image: image)
        
        imgNode.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        
        let absSpec = ASAbsoluteLayoutSpec(children: [imgNode])
        
        let textNodeVerticalOffset = CGFloat(6)

        if text == nil {
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: absSpec)
            
            return insetSpec
            
        }else {
            
//            let insetSpec = ASInsetLayoutSpec()
//            insetSpec.children = [absSpec, txtNode]
//            insetSpec.insets = UIEdgeInsets(top: 0,
//                                            left: 0 + (isOutgoing ? 0 : textNodeVerticalOffset),
//                                            bottom: 0,
//                                            right: 0 + (isOutgoing ? textNodeVerticalOffset : 0))
//
//            return insetSpec
//            txtNode.style.width = ASDimension(unit: .points, value: prefferedSize.width)
//            txtNode.style.minHeight = ASDimension(unit: .points, value: 40)
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 5,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 5,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: txtNode)

            return ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .center, children: [absSpec, insetSpec])
            
        }
        
    }
    
}

private class MsgImageImageNode: ASImageNode {
    
    override init() {
        super.init()
        contentMode = .scaleAspectFit
        isUserInteractionEnabled = true
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {

        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)

    }
    
}

