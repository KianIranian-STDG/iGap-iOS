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

class IGStrickerNormalNode: AbstractNode {
    
    
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom: IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    override func setupView() {
        
        super.setupView()
        
        imgNode.style.width = ASDimension(unit: .points, value: 200.0)
        imgNode.style.height = ASDimension(unit: .points, value: 200.0)

        addSubnode(imgNode)

        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {


        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0), child: imgNode)
        
        return insetSpec

    }
    
}

