/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation
import AsyncDisplayKit

class ASReplyForwardNode: ASDisplayNode {

    var isReply : Bool = true //if false means it's Forward
    private var verticalView : ASDisplayNode?
    private var txtRepOrForwardNode : MsgTextTextNode?
    private var txtReplyMsgForwardSource: MsgTextTextNode?
    private var txtReplyAttachment: MsgTextTextNode?
    private var imgReplyAttachment : ASNetworkImageNode?
    
    override init() {
        super.init()
        configure()
    }

    
    private func configure() {
        self.subnodes!.forEach {
            $0.removeFromSupernode()
        }
        self.verticalView = ASDisplayNode()
        self.txtRepOrForwardNode = MsgTextTextNode()
        self.txtReplyMsgForwardSource = MsgTextTextNode()
        self.txtReplyAttachment = MsgTextTextNode()
        self.imgReplyAttachment = ASNetworkImageNode()

        self.verticalView!.style.width = ASDimension(unit: .points, value: 3.0)

        self.imgReplyAttachment?.style.width = ASDimension(unit: .points, value: 50.0)
        self.imgReplyAttachment?.style.height = ASDimension(unit: .points, value: 50.0)
        self.imgReplyAttachment?.layer.cornerRadius = 10.0

        verticalView?.backgroundColor = .blue
        addSubnode(self.verticalView!)
        addSubnode(self.txtRepOrForwardNode!)
        addSubnode(self.txtReplyMsgForwardSource!)
        addSubnode(self.imgReplyAttachment!)
        addSubnode(self.txtReplyAttachment!)

    }

        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

            
            let textBox = ASStackLayoutSpec.vertical()
            textBox.justifyContent = .spaceAround
            textBox.children = [txtRepOrForwardNode!, txtReplyMsgForwardSource!]
            
            let attachmentBox = ASStackLayoutSpec.horizontal()
            attachmentBox.spacing = 0
            attachmentBox.children = [imgReplyAttachment!, txtReplyAttachment!]

            let profileBox = ASStackLayoutSpec.horizontal()
            profileBox.spacing = 10
            profileBox.children = [verticalView!,attachmentBox, textBox]


            // Apply text truncation
            let elems: [ASLayoutElement] = [txtRepOrForwardNode!, txtReplyMsgForwardSource!, textBox, profileBox]
            for elem in elems {
              elem.style.flexShrink = 1
            }
            
            let insetBox = ASInsetLayoutSpec(
              insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
              child: profileBox
            )
            
            return insetBox

            
        }
    func setReplyForward(isReply: Bool,extraMessage : IGRoomMessage) {
        self.isReply = isReply
        if self.isReply { // isReply
            
            if extraMessage.type == .text { // if reply orforwarded message type is Text Only

                imgReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                txtReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero

                if let user = extraMessage.authorUser?.user { //get reply message sender Name
                    IGGlobal.makeText(for: self.txtRepOrForwardNode!, with: user.displayName, textColor: .lightGray, size: 12, numberOfLines: 1)
                } else if let sender = extraMessage.authorRoom { //get reply message sender Room Title
                    IGGlobal.makeText(for: self.txtRepOrForwardNode!, with: sender.title ?? "", textColor: .lightGray, size: 12, numberOfLines: 1)
                } else {
                    IGGlobal.makeText(for: self.txtRepOrForwardNode!, with: "", textColor: .lightGray, size: 12, numberOfLines: 1)
                }
                IGGlobal.makeText(for: self.txtReplyMsgForwardSource!, with: extraMessage.message ?? "", textColor: .lightGray, size: 12, numberOfLines: 1)//get reply message message
            } else if extraMessage.type == .image || extraMessage.type == .imageAndText || extraMessage.type == .video || extraMessage.type == .videoAndText { // if reply or forward message has image/Video attachment
                imgReplyAttachment!.style.preferredSize = CGSize(width: 50.0, height: 50.0)
                txtReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                imgReplyAttachment!.setThumbnail(for: extraMessage.attachment!)

                if let user = extraMessage.authorUser?.user { //get reply message sender Name
                    IGGlobal.makeText(for: self.txtRepOrForwardNode!, with: user.displayName, textColor: .lightGray, size: 12, numberOfLines: 1)
                } else if let sender = extraMessage.authorRoom { //get reply message sender Room Title
                    IGGlobal.makeText(for: self.txtRepOrForwardNode!, with: sender.title ?? "", textColor: .lightGray, size: 12, numberOfLines: 1)
                } else {
                    IGGlobal.makeText(for: self.txtRepOrForwardNode!, with: "", textColor: .lightGray, size: 12, numberOfLines: 1)
                }
                if extraMessage.message != nil { //if has message
                    IGGlobal.makeText(for: self.txtReplyMsgForwardSource!, with: extraMessage.message ?? "", textColor: .lightGray, size: 12, numberOfLines: 1)//get reply message message
                } else {
                    txtReplyMsgForwardSource!.style.preferredSize = CGSize.zero // set size two zero
                }

            }

        } else { // is Forward
                imgReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                txtReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero

                IGGlobal.makeText(for: self.txtRepOrForwardNode!, with: IGStringsManager.ForwardedFrom.rawValue.localized, textColor: .lightGray, size: 12, numberOfLines: 1)//shows Forwarded Message at top

                if let user = extraMessage.authorUser?.user { //get Forward message sender Name
                    IGGlobal.makeText(for: self.txtReplyMsgForwardSource!, with: user.displayName, textColor: .lightGray, size: 12, numberOfLines: 1)
                } else if let sender = extraMessage.authorRoom { //get Forward message sender Room Title
                    IGGlobal.makeText(for: self.txtReplyMsgForwardSource!, with: sender.title ?? "", textColor: .lightGray, size: 12, numberOfLines: 1)
                } else {
                    IGGlobal.makeText(for: self.txtReplyMsgForwardSource!, with: "", textColor: .lightGray, size: 12, numberOfLines: 1)
                }

        }
    }
}
