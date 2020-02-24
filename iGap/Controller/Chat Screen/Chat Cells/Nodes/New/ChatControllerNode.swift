//
//  ChatControllerNode.swift
//  iGap
//
//  Created by ahmad mohammadi on 2/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import AsyncDisplayKit

class ChatControllerNode: ASCellNode {
    
        // Message Needed Data
    private var message : IGRoomMessage!
    private var finalRoomType: IGRoom.IGType!
    private var finalRoom: IGRoom!
    
        // View Items
    private let nodeMedia = ASNetworkImageNode() // MUST BE CHANGED TO CustomImageNode
    private let nodeText = ASTextNode()
    private let nodeOnlyText = OnlyTextNode()
    private let nodeGif = ASDisplayNode { () -> UIView in
        let view = GIFImageView()
        return view
    }
    private let nodeSlider = ASDisplayNode { () -> UIView in
        let view = UISlider()
        view.minimumValue = 0
        view.value = 10
        view.maximumValue = 20
        view.tintColor = .red
        return view
    }
    private var nodebtnAudioState = ASButtonNode()
    private var nodeIndicator = ASDisplayNode { () -> UIView in
        let view = IGProgress()
        return view
    }
    
    
    override init() {
        super.init()
    }
    
    func makeView(message: IGRoomMessage, finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        
        
            // Managing Subnodes' adding and visibility
        switch message.type {
        case .text:
            if !(subnodes!.contains(nodeOnlyText)) {
                addSubnode(nodeOnlyText)
            }
            setVisibile(nodes: nodeOnlyText)
            nodeOnlyText.attributedText = NSAttributedString(string: message.message ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            nodeOnlyText.backgroundColor = .red
//            nodeOnlyText.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
//            nodeOnlyText.frame = CGRect(origin: nodeOnlyText.frame.origin, size: CGSize(width: 150, height: 150))
            self.layoutSpecBlock = {[weak self] node, constrainedSize in
                guard let sSelf = self else {
                    return ASLayoutSpec()
                }
                sSelf.nodeOnlyText.style.preferredSize = CGSize(width: 150, height: 150)
                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0 ,
                bottom: 0,
                right: 0), child: sSelf.nodeOnlyText)
                
                return insetSpec
            }
            
            break
        case .image:
            if !(subnodes!.contains(nodeMedia)) {
                addSubnode(nodeMedia)
            }
            setVisibile(nodes: nodeMedia)
            
            var prefferedSize : CGSize = CGSize(width: 0, height: 0)
            if message.attachment!.largeThumbnail == nil && message.attachment!.smallThumbnail == nil {
                prefferedSize = CGSize(width: 200, height: 200)
            } else  {
                prefferedSize = NodeExtension.fetchMediaFrame(media: message.attachment!)
            }
            
            nodeMedia.style.width = ASDimension(unit: .points, value: prefferedSize.width)
            nodeMedia.style.height = ASDimension(unit: .points, value: prefferedSize.height)
            
            nodeMedia.setThumbnail(for: message.attachment!)
            
            self.layoutSpecBlock = {[weak self] node, constrainedSize in
                guard let sSelf = self else {
                    return ASLayoutSpec()
                }
                
                sSelf.nodeOnlyText.style.preferredSize = CGSize(width: 150, height: 150)
                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0 ,
                bottom: 0,
                right: 0), child: sSelf.nodeMedia)
                return insetSpec
                
            }
            
            
            
            
            break
        case .imageAndText:
            if !(subnodes!.contains(nodeMedia)) {
                addSubnode(nodeMedia)
            }
            if !(subnodes!.contains(nodeText)) {
                addSubnode(nodeText)
            }
            setVisibile(nodes: nodeMedia, nodeText)
            break
        case .video:
            if !(subnodes!.contains(nodeMedia)) {
                addSubnode(nodeMedia)
            }
            setVisibile(nodes: nodeMedia)
            break
        case .videoAndText:
            if !(subnodes!.contains(nodeMedia)) {
                addSubnode(nodeMedia)
            }
            if !(subnodes!.contains(nodeText)) {
                addSubnode(nodeText)
            }
            setVisibile(nodes: nodeMedia, nodeText)
            break
        default:
            return
        }
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        guard let msg = message else {
            return ASLayoutSpec()
        }

        switch msg.type {
        case .text:

            let mainBoxV = ASStackLayoutSpec.vertical()
            mainBoxV.justifyContent = .spaceAround

            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0 ,
                bottom: 0,
                right: 0), child: nodeOnlyText)
            mainBoxV.children?.append(insetSpec)

            return mainBoxV
        default:
            break
        }

        return ASLayoutSpec()

    }
    
        
    private func setVisibile(nodes: ASDisplayNode...) {
        if nodes.contains(nodeMedia){
            nodeMedia.isHidden = false
        }else {
            nodeMedia.isHidden = true
        }
        
        if nodes.contains(nodeText){
            nodeText.isHidden = false
        }else {
            nodeText.isHidden = true
        }
        
        if nodes.contains(nodeOnlyText){
            nodeOnlyText.isHidden = false
        }else {
            nodeOnlyText.isHidden = true
        }
        
        if nodes.contains(nodeGif){
            nodeGif.isHidden = false
        }else {
            nodeGif.isHidden = true
        }
        
        if nodes.contains(nodeSlider){
            nodeSlider.isHidden = false
        }else {
            nodeSlider.isHidden = true
        }
        
        if nodes.contains(nodebtnAudioState){
            nodebtnAudioState.isHidden = false
        }else {
            nodebtnAudioState.isHidden = true
        }
        
        if nodes.contains(nodeIndicator){
            nodeIndicator.isHidden = false
        }else {
            nodeIndicator.isHidden = true
        }
    }
    
}


class OnlyTextNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.clear
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }
    
}
