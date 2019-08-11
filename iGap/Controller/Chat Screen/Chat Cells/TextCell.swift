/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import SnapKit

class TextCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var txtMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtMessage: ActiveLabel!
    var imgAvatarPay : UIImageViewX!
    class func nib() -> UINib {
        return UINib(nibName: "TextCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        super.setMessage(message, room: room, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        
        if message.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue {
            makeAvatarPay()
        } else {
            removeAvatarPay()
        }
    }
    
    private func initializeView(){
        
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
        mainBubbleViewHeightAbs = mainBubbleViewHeight
        messageViewAbs = messageView
        
        /********** lable **********/
        txtMessageAbs = txtMessage
        
        /******** constraint ********/
        txtMessageHeightConstraintAbs = txtMessageHeightConstraint
    }
    private func removeAvatarPay() {
        if imgAvatarPay != nil {
            imgAvatarPay.image = nil
            imgAvatarPay.backgroundColor = .clear
            imgAvatarPay.contentMode = .scaleAspectFit
            imgAvatarPay.borderColor = .clear
            imgAvatarPay.borderWidth = 0.0

        }

    }
    private func makeAvatarPay(){
        
        if imgAvatarPay == nil {
            imgAvatarPay = UIImageViewX()
            self.contentView.addSubview(imgAvatarPay)
            imgAvatarPay.image = UIImage(named: "debit-card")
            imgAvatarPay.layer.cornerRadius = 25
            imgAvatarPay.backgroundColor = .white
            imgAvatarPay.layer.masksToBounds = true
            imgAvatarPay.contentMode = .scaleAspectFit
            imgAvatarPay.borderColor = UIColor.chatBubbleBackground(isIncommingMessage: isIncommingMessage)
            imgAvatarPay.borderWidth = 2.0
        }
        
        imgAvatarPay.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerX.equalTo(mainBubbleViewAbs.snp.centerX)
            make.top.equalTo(self.contentView.snp.top).offset(0)

        }
        
    }
}

