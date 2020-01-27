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
    private var txtCurrentTimeNode = ASTextNode()
    private var txtVoiceTimeNode = ASTextNode()

    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = true,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()

        node.style.preferredSize = CGSize(width: 200, height: 50)
        btnStateNode.style.preferredSize = CGSize(width: 50, height: 50)

        btnStateNode.layer.cornerRadius = 25
        
        //make current time text
        IGGlobal.makeText(for: self.txtCurrentTimeNode, with: "00:00".inLocalizedLanguage(), textColor: .lightGray, size: 12, numberOfLines: 1)
//        msgTextNode.isUserInteractionEnabled = true
        addSubnode(node)
        addSubnode(txtVoiceTimeNode)
        addSubnode(txtCurrentTimeNode)
        addSubnode(btnStateNode)
        addSubnode(indicatorViewAbs)
        checkButtonState(btn: btnStateNode)
    }
    
    
    func checkButtonState(btn : ASButtonNode ) {
        if IGGlobal.isFileExist(path: message.attachment!.path(), fileSize: message.attachment!.size) {
            indicatorViewAbs.isHidden = true
            indicatorViewAbs.style.preferredSize = CGSize.zero

        } else {
            indicatorViewAbs.isHidden = false
            indicatorViewAbs.style.preferredSize = CGSize(width: 50, height: 50)

            btnStateNode.setTitle("🎗", with: UIFont.iGapFonticon(ofSize: 40), with: .black, for: .normal)

        }

        
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let sliderBox = ASStackLayoutSpec.vertical()
        sliderBox.justifyContent = .spaceAround
        sliderBox.children = [node, txtCurrentTimeNode]
        sliderBox.spacing = 0
        
        let overlayBox = ASOverlayLayoutSpec(child: btnStateNode, overlay: indicatorViewAbs)

        let attachmentBox = ASStackLayoutSpec.horizontal()
        attachmentBox.spacing = 10
        attachmentBox.children = [overlayBox, sliderBox]

        
        // Apply text truncation
        let elems: [ASLayoutElement] = [txtCurrentTimeNode,overlayBox, sliderBox, attachmentBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: attachmentBox
        )
        
        return insetBox
        

    }
    
    
    
}


