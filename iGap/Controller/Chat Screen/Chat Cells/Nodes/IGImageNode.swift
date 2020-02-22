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

    deinit {
        imgNode.removeFromSupernode()
        textNode.removeFromSupernode()
        print("CHECK DEINIT FOR IMAGENODE SELF: \(self) REMOVED")
        print("CHECK DEINIT FOR IMAGENODE IMAGE: \(imgNode) REMOVED" )
        print("CHECK DEINIT FOR IMAGENODE TEXT: \(textNode) REMOVED" )
    }
    override func setupView() {
        
        super.setupView()
        var prefferedSize : CGSize = CGSize(width: 0, height: 0)
        if message.attachment!.largeThumbnail == nil && message.attachment!.smallThumbnail == nil {
            prefferedSize = CGSize(width: 200, height: 200)
        } else  {
            prefferedSize = NodeExtension.fetchMediaFrame(media: message.attachment!)
        }
        if message.type == .gif || message.type == .gifAndText {
            (gifNode).style.width = ASDimension(unit: .points, value: prefferedSize.width)
            (gifNode).style.height = ASDimension(unit: .points, value: prefferedSize.height)
            (gifNode).clipsToBounds = true
            (gifNode).backgroundColor = .red
            (gifNode).layer.cornerRadius = 10
            indicatorViewAbs.style.height = ASDimensionMake(.points, 50)
            indicatorViewAbs.style.width = ASDimensionMake(.points, 50)
            

            if message.type == .imageAndText || message.type == .gifAndText {
                addSubnode(textNode)
            }
            addSubnode(gifNode)

            
            if message.attachment != nil {
                addSubnode(indicatorViewAbs)
            }

            

        } else if message.type == .image || message.type == .imageAndText {
            imgNode.style.width = ASDimension(unit: .points, value: prefferedSize.width)
            imgNode.style.height = ASDimension(unit: .points, value: prefferedSize.height)
            imgNode.clipsToBounds = true
            
            imgNode.layer.cornerRadius = 10
            indicatorViewAbs.style.height = ASDimensionMake(.points, 50)
            indicatorViewAbs.style.width = ASDimensionMake(.points, 50)
            

            if message.type == .imageAndText || message.type == .gifAndText {
                addSubnode(textNode)
            }
            addSubnode(imgNode)

            
            if message.attachment != nil {
                addSubnode(indicatorViewAbs)
            }

        }

        
    }

    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if message.type == .gif || message.type == .gifAndText {


            if message.type == .gif {
                let verticalSpec = ASStackLayoutSpec()
                verticalSpec.direction = .vertical
                verticalSpec.spacing = 0
                verticalSpec.justifyContent = .start
                verticalSpec.alignItems = isIncomming == true ? .end : .start
                
                verticalSpec.children?.append(gifNode)

                let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                let insetSpec = ASInsetLayoutSpec(insets: insets, child: verticalSpec)
                
                let overlay = ASOverlayLayoutSpec(child: insetSpec, overlay: indicatorViewAbs)
                return overlay

            }else {
                let verticalSpec = ASStackLayoutSpec()
                verticalSpec.direction = .vertical
                verticalSpec.spacing = 0
                verticalSpec.alignItems = .stretch
                verticalSpec.justifyContent = .start

                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                    top: 0,
                    left: 0 ,
                    bottom: 0,
                    right: 0), child: textNode)

                let overlay = ASOverlayLayoutSpec(child: imgNode, overlay: indicatorViewAbs)

                verticalSpec.children?.append(overlay)
                verticalSpec.children?.append(insetSpec)

                let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                let insetSpecccc = ASInsetLayoutSpec(insets: insets, child: verticalSpec)

                return insetSpecccc

                
            }
            
        } else if message.type == .image || message.type == .imageAndText {

            if message.type == .image {
                let verticalSpec = ASStackLayoutSpec()
                verticalSpec.direction = .vertical
                verticalSpec.spacing = 0
                verticalSpec.justifyContent = .start
                verticalSpec.alignItems = isIncomming == true ? .end : .start
                
                verticalSpec.children?.append(imgNode)

                let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                let insetSpec = ASInsetLayoutSpec(insets: insets, child: verticalSpec)
                
                let overlay = ASOverlayLayoutSpec(child: insetSpec, overlay: indicatorViewAbs)
                return overlay

            }else {
                let verticalSpec = ASStackLayoutSpec()
                verticalSpec.direction = .vertical
                verticalSpec.spacing = 0
                verticalSpec.alignItems = .stretch
                verticalSpec.justifyContent = .start

                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                    top: 0,
                    left: 0 ,
                    bottom: 0,
                    right: 0), child: textNode)

                let overlay = ASOverlayLayoutSpec(child: imgNode, overlay: indicatorViewAbs)

                verticalSpec.children?.append(overlay)
                verticalSpec.children?.append(insetSpec)

                let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                let insetSpecccc = ASInsetLayoutSpec(insets: insets, child: verticalSpec)

                return insetSpecccc

                
            }
        } else {

            if message.type == .image {
                let verticalSpec = ASStackLayoutSpec()
                verticalSpec.direction = .vertical
                verticalSpec.spacing = 0
                verticalSpec.justifyContent = .start
                verticalSpec.alignItems = isIncomming == true ? .end : .start
                
                verticalSpec.children?.append(imgNode)

                let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                let insetSpec = ASInsetLayoutSpec(insets: insets, child: verticalSpec)
                
                let overlay = ASOverlayLayoutSpec(child: insetSpec, overlay: indicatorViewAbs)
                return overlay

            }else {
                let verticalSpec = ASStackLayoutSpec()
                verticalSpec.direction = .vertical
                verticalSpec.spacing = 0
                verticalSpec.alignItems = .stretch
                verticalSpec.justifyContent = .start

                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                    top: 0,
                    left: 0 ,
                    bottom: 0,
                    right: 0), child: textNode)

                let overlay = ASOverlayLayoutSpec(child: imgNode, overlay: indicatorViewAbs)

                verticalSpec.children?.append(overlay)
                verticalSpec.children?.append(insetSpec)

                let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                let insetSpecccc = ASInsetLayoutSpec(insets: insets, child: verticalSpec)

                return insetSpecccc

                
            }
        }
        
    }
    
}


