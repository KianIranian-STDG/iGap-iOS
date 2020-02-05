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
import SwiftEventBus

class IGCircularLoaderNode: AbstractNode {
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = true,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()
        
        addSubnode(CircularLoaderNode)
        CircularLoaderNode.style.height = ASDimensionMake(.points, 30)
        CircularLoaderNode.style.width = ASDimensionMake(.points, 30)
    }
    
    

    

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: CircularLoaderNode
        )
        
        return insetBox
        
        
    }
    
    
    
}


