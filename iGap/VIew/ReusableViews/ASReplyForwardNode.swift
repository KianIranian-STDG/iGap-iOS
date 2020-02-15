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
    private var isIncomming : Bool = false
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
        self.verticalView?.layer.cornerRadius = 1.5
        self.imgReplyAttachment?.style.width = ASDimension(unit: .points, value: 50.0)
        self.imgReplyAttachment?.style.height = ASDimension(unit: .points, value: 50.0)
        self.imgReplyAttachment?.layer.cornerRadius = 10.0

        
        verticalView?.backgroundColor = isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker()
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
            profileBox.spacing = 5
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
    func setReplyForward(isReply: Bool,extraMessage : IGRoomMessage,isIncomming : Bool = false) {
        self.isReply = isReply
        self.isIncomming = isIncomming
        if self.isReply { // isReply
            
            if extraMessage.type == .text { // if reply orforwarded message type is Text Only

                imgReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                txtReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero

                if let user = extraMessage.authorUser?.user { //get reply message sender Name
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: user.displayName, textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                } else if let sender = extraMessage.authorRoom { //get reply message sender Room Title
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: sender.title ?? "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker() , size: 12, numberOfLines: 1, font: .igapFont)
                } else {
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                }
                IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: extraMessage.message ?? "", textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont)//get reply message message
            } else if extraMessage.type == .image || extraMessage.type == .imageAndText || extraMessage.type == .video || extraMessage.type == .videoAndText { // if reply or forward message has image/Video attachment
                imgReplyAttachment!.style.preferredSize = CGSize(width: 50.0, height: 50.0)
                txtReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                if extraMessage.attachment != nil {

                    imgReplyAttachment!.setThumbnail(for: extraMessage.attachment!)
                }
                if let user = extraMessage.authorUser?.user { //get reply message sender Name
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: user.displayName, textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                } else if let sender = extraMessage.authorRoom { //get reply message sender Room Title
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: sender.title ?? "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                } else {
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                }
                if extraMessage.message != nil { //if has message
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: extraMessage.message ?? "", textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont)//get reply message message
                } else {
                    txtReplyMsgForwardSource!.style.preferredSize = CGSize.zero // set size two zero
                }

            } else if extraMessage.type == .voice || extraMessage.type == .audio || extraMessage.type == .audioAndText  || extraMessage.type == .file || extraMessage.type == .contact || extraMessage.type == .fileAndText   {
                imgReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                txtReplyAttachment!.style.preferredSize = CGSize(width: 50.0, height: 50.0)
                if extraMessage.attachment != nil {
                    txtReplyAttachment!.setThumbnail(for: extraMessage.attachment!)
                } else {
                    txtReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                }
                if let user = extraMessage.authorUser?.user { //get reply message sender Name
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: user.displayName, textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                } else if let sender = extraMessage.authorRoom { //get reply message sender Room Title
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: sender.title ?? "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                } else {
                    IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                }
                switch extraMessage.type {
                    
                case .unknown:
                    break
                case .audio,.audioAndText:
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: IGStringsManager.AudioMessage.rawValue.localized, textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont)//get reply message message
                case .voice:
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: IGStringsManager.VoiceMessage.rawValue.localized, textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont)//get reply message message
                case .file,.fileAndText:
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: IGStringsManager.FileMessage.rawValue.localized, textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont)//get reply message message
                case .contact:
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: IGStringsManager.ContactMessage.rawValue.localized, textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont)//get reply message message
                default:
                    break
                }

            }

        } else { // is Forward
                imgReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero
                txtReplyAttachment!.style.preferredSize = CGSize.zero // set size two zero

                IGGlobal.makeAsyncText(for: self.txtRepOrForwardNode!, with: IGStringsManager.ForwardedFrom.rawValue.localized, textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)//shows Forwarded Message at top

                if let user = extraMessage.authorUser?.user { //get Forward message sender Name
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: user.displayName, textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                } else if let sender = extraMessage.authorRoom { //get Forward message sender Room Title
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: sender.title ?? "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                } else {
                    IGGlobal.makeAsyncText(for: self.txtReplyMsgForwardSource!, with: "", textColor: isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), size: 12, numberOfLines: 1, font: .igapFont)
                }

        }
    }
}
