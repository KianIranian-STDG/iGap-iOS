//
//  AbstractNode.swift
//  iGap
//
//  Created by ahmad mohammadi on 1/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import AsyncDisplayKit
import SwiftEventBus


class AbstractNode: ASCellNode {
    
    let textNode = ASTextNode()
    let msgTextNode = MsgTextTextNode() // Only Use in IGTextNode
    
    let message: IGRoomMessage
    let finalRoom: IGRoom!
    let finalRoomType: IGRoom.IGType
    let isIncomming: Bool
    var attachment: IGFile?
    //IMAGE NODE FOR IMAGENODE AND VIDEO NODE
    var imgNode = ASNetworkImageNode()
    //UISlider for IGVOICE NODE
    let node = ASDisplayNode { () -> UIView in
        let view = UISlider()
        view.minimumValue = 0
        view.value = 10
        view.maximumValue = 20
        view.tintColor = .red

        return view
    }
    //BUTTON DOWNLOAD/PLAY/PAUSE for NODES
    var btnStateNode = ASButtonNode()
    //progress Node
    var indicatorViewAbs = IGProgressNode()


    private var isTextMessageNode = false
    
    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?

    init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        self.finalRoom = finalRoom
        self.finalRoomType = finalRoomType
        self.message = message
        self.isIncomming = isIncomming
        self.isTextMessageNode = isTextMessageNode
        super.init()
        
    }

    func setupView() {
        if let forwardedFrom = message.forwardedFrom {
            if let msg = forwardedFrom.message {
                setupMessageText(msg)
            }

        } else {
            if let msg = message.message {
                setupMessageText(msg)
            }

        }
        manageAttachment(file: message.attachment)
    }
    
    private func setupMessageText(_ msg: String) {
        
        if message.linkInfo == nil {
            if isTextMessageNode {
                IGGlobal.makeText(for: textNode, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.localizedDirection)

            } else {
                IGGlobal.makeText(for: msgTextNode, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.localizedDirection)

            }
            return
        }

        if let itms = ActiveLabelJsonify.toObejct(message.linkInfo!) {
            if isTextMessageNode {
                msgTextNode.attributedText = addLinkDetection(text: msg, activeItems: itms)
                msgTextNode.isUserInteractionEnabled = true
                msgTextNode.delegate = self
            } else {
                textNode.attributedText = addLinkDetection(text: msg, activeItems: itms)
                textNode.isUserInteractionEnabled = true
                textNode.delegate = self
            }
            
        }
        
    }
    
    
    /*
     ******************************************************************
     ************************ Manage Attachment ***********************
     ******************************************************************
     */
    
    private func manageAttachment(file: IGFile? = nil){

        if message.type == .sticker || message.additional?.dataType == AdditionalType.STICKER.rawValue {

            if let stickerStruct = IGHelperJson.parseStickerMessage(data: (message.additional?.data)!) {
                //IGGlobal.imgDic[stickerStruct.token!] = self.imgMediaAbs
                DispatchQueue.main.async {
                    IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerStruct.token) { (file) in

                        if (self.message.attachment?.name!.hasSuffix(".json") ?? false) {
//                            self.animationView.setLiveSticker(for: file)
                        } else {
//                            self.imgMediaAbs?.setSticker(for: file)

                        }

                    }
                }
            }
            return
        }

        if var attachment = message.attachment , !(attachment.isInvalidated) {
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                attachment = attachmentVariableInCache.value
            } else {
                //self.attachment = attachment.detach()
                //let attachmentRef = ThreadSafeReference(to: attachment)
                IGAttachmentManager.sharedManager.add(attachment: attachment)
                if let variable = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                    self.attachment = variable.value
                } else {
                    self.attachment = attachment
                }
            }

            /* Rx Start */
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                attachment = variableInCache.value

                if let disposable = IGGlobal.dispoasDic[self.message.id] {
                    IGGlobal.dispoasDic.removeValue(forKey: self.message.id)
                    disposable.dispose()
                }
                let subscriber = variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                })
                IGGlobal.dispoasDic[self.message.id] = subscriber
            }
            /* Rx End */

            switch (message.type) {
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText,.voice:
                if !(attachment.isInvalidated) {
                    imgNode.setThumbnail(for: attachment)

                    if attachment.status != .ready {
                        indicatorViewAbs.delegate = self
                    }
                    break
                }

            default:
                break
            }
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if message.isInvalidated || (self.attachment?.isInvalidated) ?? (message.attachment != nil) {
            return
        }

        if let attachment = self.attachment {
            let fileExist = IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size)
            if fileExist && !attachment.isInUploadLevels() {
                if message.type == .video || message.type == .videoAndText {
//                    makeVideoPlayView()
                }

                indicatorViewAbs.setState(.ready)
                if attachment.type == .gif {
                    attachment.loadData()
                    if let data = attachment.data {
//                        imgMediaAbs?.prepareForAnimation(withGIFData: data)
//                        imgMediaAbs?.startAnimatingGIF()
                    }
                } else if attachment.type == .image {
                    imgNode.setThumbnail(for: attachment)
                }
                return
            }

            if isIncomming || !fileExist {
                indicatorViewAbs.setFileType(.download)
            } else {
                indicatorViewAbs.setFileType(.upload)
            }
            indicatorViewAbs.setState(attachment.status)
            if attachment.status == .downloading || attachment.status == .uploading {
                indicatorViewAbs.setPercentage(percent: Int(attachment.downloadUploadPercent))
            }
        }
    }


    
}



extension AbstractNode: ASTextNodeDelegate {
    
    func addLinkDetection(text: String, activeItems: [ActiveLabelItem]) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize)])
        
        for itm in activeItems {
            let st = NSMutableParagraphStyle()
            st.lineSpacing = 0
            st.maximumLineHeight = 20
            
            let range = NSMakeRange(itm.offset, itm.limit)
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme.SliderTintColor, NSAttributedString.Key.underlineColor: UIColor.clear, NSAttributedString.Key.link: (itm.type, getStringAtRange(string: text, range: range)), NSAttributedString.Key.paragraphStyle: st], range: range)
        }
        
        return attributedString
        
    }
    
    
    func textNode(_ textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: Any!, at point: CGPoint) -> Bool {
        return true
    }
    
    func textNode(_ textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: Any!, at point: CGPoint, textRange: NSRange) {
        
        guard let type = value as? (String, String) else {
            return
        }
        
        if !IGGlobal.shouldMultiSelect {
            switch type.0 {
            case "url":
                delegate?.didTapOnURl(url: URL(string: type.1)!)
                break
            case "deepLink":
                delegate?.didTapOnDeepLink(url: URL(string: type.1)!)
                break
            case "email":
                delegate?.didTapOnEmail(email: type.1)
                break
            case "bot":
                delegate?.didTapOnBotAction(action: type.1)
                break
            case "mention":
                delegate?.didTapOnMention(mentionText: type.1)
                break
            case "hashtag":
                delegate?.didTapOnHashtag(hashtagText: type.1)
                break
            default:
                break
            }
        }
        
    }
    
    private func getStringAtRange(string: String, range: NSRange) -> String {
        return (string as NSString).substring(with: range)
    }
    
    
}

class MsgTextTextNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.clear
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }
     
}
extension AbstractNode: IGProgreeNodeDelegate {
    
    func downloadUploadIndicatorDidTap(_ indicator: IGProgressNode) {
        if !IGGlobal.shouldMultiSelect {///if not in multiSelectMode

            if let attachment = self.attachment {
                if attachment.status == .uploading {
                    SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(self.finalRoom.id)", sender: (action: ChatMessageAction.delete, roomId: self.finalRoom.id, messageId: self.message.id))
                    IGUploadManager.sharedManager.cancelUpload(attachment: attachment)
                } else if attachment.status == .uploadFailed {
                        IGMessageSender.defaultSender.resend(message: self.message, to: finalRoom)
                    
                } else {
                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
                }
            }
            
        }
    }
    
}
