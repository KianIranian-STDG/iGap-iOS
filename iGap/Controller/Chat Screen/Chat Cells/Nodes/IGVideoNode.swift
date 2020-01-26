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

class IGVideoNode: AbstractNode {
    
    private var playTxtNode: ASTextNode
    private var timeTxtNode: ASTextNode
    
    private let fakeStackBottomItem = ASDisplayNode()
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false) {
        playTxtNode = ASTextNode()
        timeTxtNode = ASTextNode()
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode)
        setupView()
    }
    
    
    
//    private let image: UIImage
//    private let isOutgoing: Bool
//    private var text: String?
    
//    init(message: IGRoomMessage, isOutgoing: Bool) {
//        self.image = #imageLiteral(resourceName: "becky.jpg")
//        self.text = message.message
//        self.isOutgoing = isOutgoing
//        imgNode = MsgImageImageNode()
//        txtNode = ASTextNode()
//        playTxtNode = ASTextNode()
//        timeTxtNode = ASTextNode()
//        super.init()
//        setupView()
//    }
    
    
    
    override func setupView() {
        super.setupView()
        

        imgNode.image = message.attachment?.attachedImage
        addSubnode(imgNode)

        let stl = NSMutableParagraphStyle()
        stl.alignment = NSTextAlignment.center

        playTxtNode.attributedText = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.iGapFonticon(ofSize: 55), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: stl])
        playTxtNode.maximumNumberOfLines = 1
        playTxtNode.cornerRadius = 27.5
        playTxtNode.clipsToBounds = true
        playTxtNode.backgroundColor = UIColor(white: 0, alpha: 0.5)

        timeTxtNode.attributedText = NSAttributedString(string: "  00:05(616.33 کیلوبایت)  ", attributes: [NSAttributedString.Key.font : UIFont.igFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.baselineOffset: -4])
        timeTxtNode.layer.cornerRadius = 12
        timeTxtNode.clipsToBounds = true
        timeTxtNode.layer.borderColor = UIColor.white.cgColor
        timeTxtNode.layer.borderWidth = 0.5
        timeTxtNode.backgroundColor = UIColor(white: 0, alpha: 0.3)

        addSubnode(playTxtNode)
        addSubnode(timeTxtNode)

        if message.type == .videoAndText {
            addSubnode(textNode)
        }

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

            // setting image Size
        let prefferedSize = NodeExtension.fetchMediaFrame(image: message.attachment?.attachedImage ?? UIImage())
        
        imgNode.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        
        let imgAbsSpec = ASAbsoluteLayoutSpec(children: [imgNode])
        
        
        timeTxtNode.style.height = ASDimension(unit: .points, value: 26)
        fakeStackBottomItem.style.height = ASDimension(unit: .points, value: 26)
        
            // Setting Play Btn Size
        playTxtNode.style.flexBasis = ASDimension(unit: .auto, value:1.0)
        playTxtNode.style.flexGrow = 1
        playTxtNode.style.flexShrink = 1
        
        let playTxtCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: playTxtNode)
        
            // Setting Duration lbl Size
        let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), child: timeTxtNode)
        
            // Setting Container Stack
        let itemsStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 6, justifyContent: .spaceBetween, alignItems: .start, children: [timeInsetSpec, playTxtCenterSpec, fakeStackBottomItem])
        itemsStackSpec.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        
        let overlaySpec = ASOverlayLayoutSpec(child: imgAbsSpec, overlay: itemsStackSpec)
        
        let textNodeVerticalOffset = CGFloat(6)

        if message.type == .video {
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isIncomming ? textNodeVerticalOffset : 0),
            bottom: 0,
            right: 0 + (isIncomming ? 0 : textNodeVerticalOffset)), child: overlaySpec)
            
            return insetSpec
            
        }else {
            
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 5,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 5,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: textNode)

            return ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .center, children: [overlaySpec, insetSpec])
            
        }
        
    }
    
}

