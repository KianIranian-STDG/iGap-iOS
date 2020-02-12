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
import SwiftEventBus
import IGProtoBuff
import RxSwift

class AbstractNode: ASCellNode {
    
    let textNode = ASTextNode()
    let msgTextNode = MsgTextTextNode() // Only Use in IGTextNode
    var imgNodeCopy = ASDisplayNode()

    let message: IGRoomMessage
    let finalRoom: IGRoom!
    let finalRoomType: IGRoom.IGType
    let isIncomming: Bool
    var attachment: IGFile?
    //IMAGE NODE FOR IMAGENODE AND VIDEO NODE
    var imgNode = ASNetworkImageNode()
    //UISlider for IGVOICE NODE
    let sliderNode = ASDisplayNode { () -> UIView in
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
    var indicatorViewAbs = ASDisplayNode { () -> UIView in
        let view = IGProgress()
        
        return view
    }
    var btnShowMore = ASButtonNode()
    var playTxtNode = ASTextNode()
    
    var isAttachmentReady = false
    
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
    override func didLoad() {
        super.didLoad()
    }
    func setupView() {
        
        imgNode.contentMode = .scaleAspectFill
        
        if let forwardedFrom = message.forwardedFrom {
            if let msg = forwardedFrom.message {
                setupMessageText(msg)
            }
            
        } else {
            
            if let msg = message.message {
                if message.type == .text {
                    if let additionalData = message.additional?.data, message.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
                        let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (self.finalRoom.type == .chat && !(self.finalRoom.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
                        if let msg = message.message?.replacingOccurrences(of: "⁣", with: "") { // replace with invisible character if exist
                            setupMessageText(msg)
                        }
                        
                    }  else if let additionalData = message.additional?.data, message.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue,
                        let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (self.finalRoom.type == .chat && !(self.finalRoom.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
                        if let msg = message.message?.replacingOccurrences(of: "⁣", with: "") { // replace with invisible character if exist

                            
                            let t = message.additional?.data
                            let tmpJsonB = IGHelperJson.parseAdditionalButton(data: t)
                            
                            let b = tmpJsonB![0][0].valueJson
                            let tmpJson = IGHelperJson.parseAdditionalCardToCardInChat(data: b!)
                            
                            let tt = tmpJson?.amount
                            let tmpAmount : Int! = tt
//                            let attrsRegular = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 14 , weight: .regular)]
                            let tempMSG = IGStringsManager.Amount.rawValue.localized + " " + String(tmpAmount).inRialFormat() + IGStringsManager.Currency.rawValue.localized  + "\n_________________________\n" + IGStringsManager.Desc.rawValue.localized + " " + msg
                            setupMessageText(tempMSG)

                            
                        }
                        
                    } else {
                        setupMessageText(msg)
                    }
                } else {
                    setupMessageText(msg)
                }
            }
            
        }
        
        if message.attachment != nil {
            if IGGlobal.isFileExist(path: message.attachment!.localPath, fileSize: message.attachment!.size) {
                indicatorViewAbs.isHidden = true
                indicatorViewAbs.style.preferredSize = CGSize.zero
                isAttachmentReady = true
                
                if message.type == .video || message.type == .videoAndText {
//                    addSubnode(playTxtNode)
                    insertSubnode(playTxtNode, aboveSubnode: imgNode)
                }
                
            } else {
                indicatorViewAbs.isHidden = false
                indicatorViewAbs.style.preferredSize = CGSize(width: 50, height: 50)
            }
        }
        
        manageAttachment(file: message.attachment)
    }
    
    private func setupMessageText(_ msg: String) {
        
        if message.linkInfo == nil {
            if !isTextMessageNode {
                IGGlobal.makeAsyncText(for: textNode, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.localizedDirection)
                
                IGGlobal.makeAsyncText(for: textNode, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

            } else {
                IGGlobal.makeAsyncText(for: msgTextNode, with: msg, textColor: .black, size: fontDefaultSize, numberOfLines: 0, font: .igapFont, alignment: msg.isRTL() ? .right : .left)

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
                            self.imgNode.setSticker(for: file)
                            
                        }
                        
                    }
                }
            }
            return
        }
        
        if var attachment = message.attachment , !(attachment.isInvalidated) {
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                self.attachment = attachmentVariableInCache.value
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
                
                IGGlobal.syncroniseDisposDicQueue.sync(flags: .barrier) {
                    if let disposable = IGGlobal.dispoasDic[self.message.id] {
                        IGGlobal.dispoasDic.removeValue(forKey: self.message.id)
                        disposable.dispose()
                    }
                }
                
                let subscriber = variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                })
                  
                IGGlobal.syncroniseDisposDicQueue.sync(flags: .barrier) {
                    IGGlobal.dispoasDic[self.message.id] = subscriber
                }
            }
            /* Rx End */
            
            switch (message.type) {
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText,.voice:
                if !(attachment.isInvalidated) {
                    imgNode.setThumbnail(for: attachment)
                    
                    if attachment.status != .ready {

                        (indicatorViewAbs.view as! IGProgress).delegate = self
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
            let fileExist = IGGlobal.isFileExist(path: attachment.localPath, fileSize: attachment.size)
            if fileExist && !attachment.isInUploadLevels() {
                if message.type == .video || message.type == .videoAndText {
                    //                    makeVideoPlayView()
//                    playTxtNode
//                    addSubnode(playTxtNode)
                    insertSubnode(playTxtNode, aboveSubnode: imgNode)
                }
                
                (indicatorViewAbs.view as! IGProgress).setState(.ready)
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
                (indicatorViewAbs.view as! IGProgress).setFileType(.download)
            } else {
                (indicatorViewAbs.view as! IGProgress).setFileType(.upload)
            }
            (indicatorViewAbs.view as! IGProgress).setState(attachment.status)
            if attachment.status == .downloading || attachment.status == .uploading {
                (indicatorViewAbs.view as! IGProgress).setPercentage(attachment.downloadUploadPercent)
                print("======-PERCENTAGE-========")
                print(attachment.downloadUploadPercent)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if (attachment.downloadUploadPercent) == 1.0 {
                        attachment.status = .ready
                        self.imgNode.setThumbnail(for: attachment)

                    }
                }
            }
        }
    }
    
    
    
}


//MARK: - Text Link Detection
extension AbstractNode: ASTextNodeDelegate {
    
    func addLinkDetection(text: String, activeItems: [ActiveLabelItem]) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = text.isRTL() ? .right : .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let kAMMessageCellNodeContentTopTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                    NSAttributedString.Key.font:UIFont.igFont(ofSize: 12),NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSMutableAttributedString(string: text, attributes: kAMMessageCellNodeContentTopTextAttributes as [NSAttributedString.Key : Any])
        
        
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
extension AbstractNode: IGProgressDelegate {
    
    func downloadUploadIndicatorDidTap(_ indicator: IGProgress) {
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

