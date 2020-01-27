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
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        playTxtNode = ASTextNode()
        timeTxtNode = ASTextNode()
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType: finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    override func setupView() {
        super.setupView()
        
        addSubnode(imgNode)
        
        IGGlobal.makeText(for: playTxtNode, with: "", textColor: .white, size: 55, numberOfLines: 1, font: .fontIcon, alignment: .center)
        
        playTxtNode.cornerRadius = 27.5
        playTxtNode.clipsToBounds = true
        playTxtNode.backgroundColor = UIColor(white: 0, alpha: 0.5)

        let time : String! = IGAttachmentManager.sharedManager.convertFileTime(seconds: Int((message.attachment?.duration)!))
        
        IGGlobal.makeText(for: timeTxtNode, with: time, textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: timeTxtNode, with: " " + "(\(IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: (message.attachment?.size)!)))" + " ", textColor: .white, size: 10, numberOfLines: 1, font: .igapFont, alignment: .center)
        
        timeTxtNode.layer.cornerRadius = 10
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
        let prefferedSize = NodeExtension.fetchMediaFrame(media: message.attachment!)
        
        imgNode.style.width = ASDimension(unit: .points, value: prefferedSize.width)
        imgNode.style.height = ASDimension(unit: .points, value: prefferedSize.height)
        
        let imgAbsSpec = ASAbsoluteLayoutSpec(children: [imgNode])
        
        
        timeTxtNode.style.height = ASDimension(unit: .points, value: 20)
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
        
        if message.type == .video {
            
            return overlaySpec
            
        }else {
            
            return ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .center, children: [overlaySpec, textNode])
            
        }
        
    }
    
}

