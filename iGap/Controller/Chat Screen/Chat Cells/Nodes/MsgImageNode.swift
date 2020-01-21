//
//  MsgImageNode.swift
//  iGap
//
//  Created by ahmad mohammadi on 1/20/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import AsyncDisplayKit

class MsgImageNode: ASCellNode {
    
    private var imgNode : MsgImageImageNode
    private var txtNode: ASTextNode
    
    private let image: UIImage
    private let isOutgoing: Bool
    private var text: String?
    
    init(image: UIImage, text: String? = nil, isOutgoing: Bool) {
        self.image = image
        self.text = text
        imgNode = MsgImageImageNode()
        txtNode = ASTextNode()
        self.isOutgoing = isOutgoing
        super.init()
        setupView()
    }
    
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

        
        let prefferedSize = fetchMediaFrame(image: image)
        
        imgNode.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        
        let absSpec = ASAbsoluteLayoutSpec(children: [imgNode])
        
        let textNodeVerticalOffset = CGFloat(6)

        if text == nil {
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isOutgoing ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isOutgoing ? textNodeVerticalOffset : 0)), child: absSpec)
            
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
            left: 0 + (isOutgoing ? 0 : textNodeVerticalOffset),
            bottom: 5,
            right: 0 + (isOutgoing ? textNodeVerticalOffset : 0)), child: txtNode)

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


private func fetchMediaFrame(image: UIImage) -> CGSize {
    return mediaFrame(image: image,
                      maxWidth:  CellSizeLimit.ConstantSizes.Bubble.Width.Maximum.Attachment,
                      maxHeight: CellSizeLimit.ConstantSizes.Bubble.Height.Maximum.Attachment,
                      minWidth:  CellSizeLimit.ConstantSizes.Bubble.Width.Minimum.Attachment,
                      minHeight: CellSizeLimit.ConstantSizes.Bubble.Height.Minimum.Attachment)
    
}

private func mediaFrame(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat, minWidth: CGFloat, minHeight: CGFloat) -> CGSize {
    if image.size.width != 0 && image.size.height != 0 {
        var width = CGFloat(image.size.width)
        var height = CGFloat(image.size.height)
        if width > maxWidth && height > maxHeight {
            if width/maxWidth > height/maxHeight {
                height = height * maxWidth/width
                width = maxWidth
            } else {
                width = width * maxHeight/height
                height = maxHeight
            }
        } else if width > maxWidth {
            height = height * maxWidth/width
            width = maxWidth
        } else if height > maxHeight {
            width = width * maxHeight/height
            height = maxHeight
        }
        width  = max(width, minWidth)
        height = max(height, minHeight)
        return CGSize(width: width, height: height)
    } else {
        return CGSize(width: minWidth, height: minHeight)
    }
}
