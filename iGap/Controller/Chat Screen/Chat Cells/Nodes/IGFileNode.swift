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

class IGFileNode: AbstractNode {
    
    private var txtAttachmentNode = ASTextNode()
    private var txtTitleNode = ASTextNode()
    private var txtSizeNode = ASTextNode()
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    override func didLoad() {
        super.didLoad()
        checkBtnState()
    }
    
    override func setupView() {
        super.setupView()
        
        self.txtAttachmentNode.style.width = ASDimension(unit: .points, value: 60.0)
        self.txtAttachmentNode.style.height = ASDimension(unit: .points, value: 60.0)
        self.txtAttachmentNode.setThumbnail(for: message.attachment!)

        IGGlobal.makeAsyncText(for: txtTitleNode , with: message.attachment!.name!, font: .igapFont)
        IGGlobal.makeAsyncText(for: txtSizeNode , with: message.attachment!.sizeToString(), font: .igapFont)

        addSubnode(txtAttachmentNode)
        addSubnode(txtTitleNode)
        addSubnode(txtSizeNode)
        addSubnode(indicatorViewAbs)
        
        if message.type == .fileAndText {
            addSubnode(textNode)
        }
        
    }
    
    private func checkBtnState() {
        
        if IGGlobal.isFileExist(path: self.message.attachment!.localPath, fileSize: self.message.attachment!.size) {
            indicatorViewAbs.isHidden = true
            indicatorViewAbs.style.preferredSize = CGSize.zero
        } else {
            indicatorViewAbs.isHidden = false
            indicatorViewAbs.style.preferredSize = CGSize(width: 60, height: 60)
        }
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTitleNode, txtSizeNode]
        
        let txtImageBox = ASOverlayLayoutSpec(child: txtAttachmentNode, overlay: indicatorViewAbs)

        let profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        profileBox.children = [txtImageBox, textBox]

        // Apply text truncation
        let elems: [ASLayoutElement] = [txtSizeNode, txtTitleNode, textBox, profileBox]
        for elem in elems {
           elem.style.flexShrink = 1
        }

        let insetBox = ASInsetLayoutSpec(
           insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
           child: profileBox
        )

        if message.type == .file {
            
            let insetBoxx = ASInsetLayoutSpec(
                insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                child: insetBox
            )
            
            return insetBoxx
            
        } else {
            
            let vStack = ASStackLayoutSpec(direction: .vertical, spacing: 6, justifyContent: .start, alignItems: .start, children: [insetBox, textNode])
            
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let insetSpecccc = ASInsetLayoutSpec(insets: insets, child: vStack)
            
            return insetSpecccc
            
        }
        
        
        
    }
    
    
}

