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

class WalletCell: IGMessageGeneralCollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var txtFrom: UILabel!
    @IBOutlet weak var txtTo: UILabel!
    @IBOutlet weak var txtTrace: UILabel!
    @IBOutlet weak var txtInvoice: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "WalletCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellMessage = nil
        self.delegate = nil
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.cellMessage = message
        self.mainView.layer.cornerRadius = 12.0
        self.mainView.layer.masksToBounds = true
        self.mainView.backgroundColor = UIColor.dialogueBoxIncomming()
        
        guard let wallet = message.wallet else {
            return
        }
        
        txtAmount.text = String(describing: wallet.amount) + " Rials"
        txtTrace.text = String(describing: wallet.traceNumber)
        txtInvoice.text = String(describing: wallet.invoiceNumber)
        
        if let senderUser = IGRegisteredUser.getUserInfo(id: wallet.fromUserId) {
            txtFrom.font = UIFont.igFont(ofSize: 13)
            txtFrom.text = senderUser.displayName
        }
        
        if let receiverUser = IGRegisteredUser.getUserInfo(id: wallet.toUserId) {
            txtTo.font = UIFont.igFont(ofSize: 13)
            txtTo.text = receiverUser.displayName
        }
        
        if let time = TimeInterval(exactly: wallet.payTime) {
            txtDate.text = Date(timeIntervalSince1970: time).completeHumanReadableTime()
        }
    }
}
