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
import SnapKit

class IGVoiceNode: AbstractNode {
    

    let node = ASDisplayNode { () -> UIView in
        let view = UISlider()
        view.minimumValue = 0
        view.value = 10
        view.maximumValue = 20
        view.tintColor = .red

        return view
    }

    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = true) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()

        node.style.preferredSize = CGSize(width: 50, height: 50)
//        msgTextNode.isUserInteractionEnabled = true
        addSubnode(node)
        
    }
    
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let textNodeVerticalOffset = CGFloat(6)
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: node)
        
        
        return insetSpec
        
    }
    
    
    
}


