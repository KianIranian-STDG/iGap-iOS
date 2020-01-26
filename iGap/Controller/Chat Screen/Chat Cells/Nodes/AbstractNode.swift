//
//  AbstractNode.swift
//  iGap
//
//  Created by ahmad mohammadi on 1/23/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import AsyncDisplayKit


class AbstractNode: ASCellNode {
    
    let textNode = ASTextNode()
    let msgTextNode = MsgTextTextNode() // Only Use in IGTextNode
    
    let message: IGRoomMessage
    let isIncomming: Bool
    private var isTextMessageNode = false
    
    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?

    init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool) {
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
    }
    
    private func setupMessageText(_ msg: String) {
        
        if message.linkInfo == nil {
            if isTextMessageNode {
                textNode.attributedText = NSAttributedString(string: msg, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize)])
            } else {
                msgTextNode.attributedText = NSAttributedString(string: msg, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize)])
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
        print("=-=-=-=-", value, "=-=-=", point, "=-=-=", textRange)
        
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
