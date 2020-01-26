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
    
    private var imgAttachmentNode = ASNetworkImageNode()
    private var txtAttachmentNode: ASTextNode = {
        let node = ASTextNode()
        return node
    }()
    private var txtTitleNode = ASTextNode()
    private var txtSizeNode = ASTextNode()
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode)
        setupView()
    }
    
    override func setupView() {
        super.setupView()
        let filename: NSString = message.attachment!.name! as NSString
        let fileExtension = filename.pathExtension
        
        if fileExtension == "jpg" {
            self.imgAttachmentNode.style.width = ASDimension(unit: .points, value: 50.0)
            self.imgAttachmentNode.style.height = ASDimension(unit: .points, value: 50.0)
            self.imgAttachmentNode.image = UIImage(named: "igap_default_image")
            self.imgAttachmentNode.layer.cornerRadius = 10
            self.txtAttachmentNode.style.preferredSize = CGSize.zero
            self.imgAttachmentNode.setThumbnail(for: message.attachment!)
            IGGlobal.makeText(for: txtTitleNode , with: message.attachment!.name!)
            IGGlobal.makeText(for: txtSizeNode , with: message.attachment!.sizeToString())

        } else {
            self.imgAttachmentNode.style.preferredSize = CGSize.zero
            self.txtAttachmentNode.style.width = ASDimension(unit: .points, value: 50.0)
            self.txtAttachmentNode.style.height = ASDimension(unit: .points, value: 50.0)
            self.txtAttachmentNode.setThumbnail(for: message.attachment!)

            IGGlobal.makeText(for: txtTitleNode , with: message.attachment!.name!)
            IGGlobal.makeText(for: txtSizeNode , with: message.attachment!.sizeToString())
        }

        addSubnode(imgAttachmentNode)
        addSubnode(txtAttachmentNode)
        addSubnode(txtTitleNode)
        addSubnode(txtSizeNode)
        
        if message.type == .imageAndText {
            addSubnode(textNode)
        }
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTitleNode, txtSizeNode]
        
        let attachmentBox = ASStackLayoutSpec.horizontal()
        attachmentBox.spacing = 0
        attachmentBox.children = [txtAttachmentNode, imgAttachmentNode]

        let profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        profileBox.children = [attachmentBox, textBox]
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [txtSizeNode, txtTitleNode, textBox, profileBox, attachmentBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: profileBox
        )
        
        return insetBox
        
        
        
    }
    
    
}

