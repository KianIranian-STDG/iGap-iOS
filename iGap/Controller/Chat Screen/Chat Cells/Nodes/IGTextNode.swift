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

class IGTextNode: AbstractNode {
    
//    private let textNode = MsgTextTextNode()
    
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = true) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()

//        msgTextNode.isUserInteractionEnabled = true
        addSubnode(msgTextNode)
        
    }
    
//    private func setupView() {
//
//
////        textNode.attributedText = addLinkDetection(message, highLightColor: .red)
//        textNode.attributedText = NSAttributedString(string: "sdlkcnsdkjnksdjn sdkjcnsk sdkjnks nsdkj nksn skjdn dskjn sdkjnd kjsn", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize)])
//
//        msgTextNode.isUserInteractionEnabled = true
//        addSubnode(msgTextNode)
//
//    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let textNodeVerticalOffset = CGFloat(6)
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: msgTextNode)
        
        
        return insetSpec
        
    }
    
    
    
}


