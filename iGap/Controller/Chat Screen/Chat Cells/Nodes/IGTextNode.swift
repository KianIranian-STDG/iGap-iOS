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

class IGTextNode: ASCellNode {
    
    private let textNode = MsgTextTextNode()
    
    private let message: IGRoomMessage
    private let isIncomming: Bool
    
    init(message: IGRoomMessage, isIncomming: Bool) {
        self.message = message
        self.isIncomming = isIncomming
        super.init()
        setupView()
    }
    
    private func setupView() {
        
        
//        textNode.attributedText = addLinkDetection(message, highLightColor: .red)
        
        
        textNode.attributedText = NSAttributedString(string: message.message!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.igFont(ofSize: fontDefaultSize)])
        textNode.isUserInteractionEnabled = true
        textNode.delegate = self
        addSubnode(textNode)
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let textNodeVerticalOffset = CGFloat(6)
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 + (isIncomming ? 0 : textNodeVerticalOffset),
            bottom: 0,
            right: 0 + (isIncomming ? textNodeVerticalOffset : 0)), child: textNode)
        
        
        return insetSpec
        
    }
    
}

private class MsgTextTextNode: ASTextNode {
    
    override init() {
        super.init()
        placeholderColor = UIColor.clear
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        let size = super.calculateSizeThatFits(constrainedSize)
        return CGSize(width: max(size.width, 15), height: size.height)
    }
     
}


extension IGTextNode: ASTextNodeDelegate {
    
    
    func addLinkDetection(_ text: String, highLightColor: UIColor) -> NSAttributedString{

        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        let range = NSMakeRange(0, text.count)
        let attributedText = NSAttributedString(string: text)
//        if let attributedText = attributedText {
        let mutableString = NSMutableAttributedString()
        mutableString.append(attributedText)
        detector?.enumerateMatches(in: text, range: range) {
            (result, _, _) in
            if let fixedRange = result?.range {
                mutableString.addAttribute(NSAttributedString.Key.underlineColor, value: highLightColor, range: fixedRange)
                mutableString.addAttribute(NSAttributedString.Key.link, value: result?.url ?? "", range: fixedRange)
                mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: highLightColor, range: fixedRange)

            }
        }
        return mutableString
//        }
    }
    
    
    
    
    
    
    
}
