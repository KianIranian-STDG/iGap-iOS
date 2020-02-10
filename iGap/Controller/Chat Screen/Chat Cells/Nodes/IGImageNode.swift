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

class IGImageNode: AbstractNode {
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom: IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    override func setupView() {
        
        super.setupView()
        let prefferedSize = NodeExtension.fetchMediaFrame(media: message.attachment!)
        
        imgNode.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        imgNode.layer.cornerRadius = 10
        indicatorViewAbs.style.height = ASDimensionMake(.points, 50)
        indicatorViewAbs.style.width = ASDimensionMake(.points, 50)
        
        addSubnode(imgNode)

        if message.type == .imageAndText {
            addSubnode(textNode)
        }
        
        
        if message.attachment != nil {
            addSubnode(indicatorViewAbs)
        }
        
        
//        checkIndicatorState()

        
    }
//    func checkIndicatorState() {
//        if IGGlobal.isFileExist(path: message.attachment!.path(), fileSize: message.attachment!.size) {
//            indicatorViewAbs.isHidden = true
//            indicatorViewAbs.style.preferredSize = CGSize.zero
//            
//        } else {
//            indicatorViewAbs.isHidden = false
//            indicatorViewAbs.style.preferredSize = CGSize(width: 50, height: 50)
//        }
//    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {


        let acNodeSpec = ASOverlayLayoutSpec(child: imgNode, overlay: indicatorViewAbs)
        
        if message.type == .image {
            
            return acNodeSpec
            
        }else {
            
            return ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .stretch, children: [acNodeSpec, textNode])
            
        }
        
    }
    
}

