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


class IGLocationNode: AbstractNode {
    private var imgPinMarker = ASNetworkImageNode()
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false, finalRoomType: IGRoom.IGType, finalRoom: IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode, finalRoomType: finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    override func setupView() {
        
        super.setupView()
        
        imgNode.image = UIImage(named: "map_screenShot")
        imgPinMarker.image = UIImage(named: "Location_Marker")
        imgPinMarker.style.preferredSize = CGSize(width: 30, height: 30)
        imgNode.style.width = ASDimension(unit: .points, value: 260)
        imgNode.style.height = ASDimension(unit: .points, value: 160)

        imgNode.contentMode = .scaleAspectFill
        addSubnode(imgNode)
        addSubnode(imgPinMarker)

//        if message.type == .imageAndText {
//            addSubnode(textNode)
//        }
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let backCenterAspec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: imgNode)
         
        let percentCenterAspec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: imgPinMarker)
        percentCenterAspec.horizontalPosition = .center
                
        let over1Spec = ASOverlayLayoutSpec(child: backCenterAspec, overlay: percentCenterAspec)
        
        return over1Spec

    }
    
}


