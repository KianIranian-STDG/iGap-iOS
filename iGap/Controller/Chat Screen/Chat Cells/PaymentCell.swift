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
import IGProtoBuff

class PaymentCell: IGMessageGeneralCollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var txtFrom: UILabel!
    @IBOutlet weak var txtTo: UILabel!
    @IBOutlet weak var txtTrace: UILabel!
    @IBOutlet weak var txtInvoice: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet var txtCardNumber: UILabel!
    @IBOutlet var txtRRN: UILabel!
    @IBOutlet var txtDescription: UILabel!
    
    @IBOutlet weak var lblAmountTitle: UILabel!
    @IBOutlet weak var lblFromTitle: UILabel!
    @IBOutlet weak var ttlInvoicelblInvoiceTitle: UILabel!
    @IBOutlet weak var lblTraceNumberTitle: UILabel!
    @IBOutlet weak var lblToTitle: UILabel!
    @IBOutlet var lblCardNumber: UILabel!
    @IBOutlet var lblRRN: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet weak var ttlTransfer: UILabel!
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
    class func nib() -> UINib {
        return UINib(nibName: "PaymentCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initChangeLang()
        self.cellMessage = nil
        self.delegate = nil
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
    }
    func initChangeLang() {
        lblToTitle.text = "GLOBAL_TO".MessageViewlocalized
        lblFromTitle.text = "GLOBAL_FROM".MessageViewlocalized
        ttlInvoicelblInvoiceTitle.text = "TTL_INVOICE_NUMBER".MessageViewlocalized
        lblAmountTitle.text = "PRICE".MessageViewlocalized
        lblTraceNumberTitle.text = "TRACE_NUMBER".MessageViewlocalized
        ttlTransfer.text = "PAYMENT_TRANSFER_MONEY".MessageViewlocalized
        lblCardNumber.text = "TTL_CARDNUM".MessageViewlocalized
        lblRRN.text = "TTL_REFERENCE_NUMBER".MessageViewlocalized
        lblDescription.text = "DESCRIPTION".MessageViewlocalized
        ttlTransfer.font = UIFont.igFont(ofSize: 15)
        txtDate.font = UIFont.igFont(ofSize: 15)
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.cellMessage = message
        self.mainView.layer.cornerRadius = 12.0
        self.mainView.layer.masksToBounds = true
        self.mainView.backgroundColor = UIColor.dialogueBoxIncomming()

        guard let wallet = message.wallet?.payment else {
            return
        }
        
        txtAmount.text = String(describing: wallet.amount).inRialFormat().inLocalizedLanguage() + " " + "CURRENCY".MessageViewlocalized
        txtTrace.text = String(describing: wallet.traceNumber).inLocalizedLanguage()
        txtInvoice.text = String(describing: wallet.invoiceNumber).inLocalizedLanguage()
        txtRRN.text = String(describing: wallet.rrn)
        txtCardNumber.text = wallet.cardNumber
        
        if let senderUser = IGRegisteredUser.getUserInfo(id: wallet.fromUserId) {
            txtFrom.font = UIFont.igFont(ofSize: 13)
            txtFrom.text = senderUser.displayName
        }
        
        if let receiverUser = IGRegisteredUser.getUserInfo(id: wallet.toUserId) {
            txtTo.font = UIFont.igFont(ofSize: 13)
            txtTo.text = receiverUser.displayName
        }
        
        if wallet.walletDescription!.isEmpty {
            txtDescription.text = "NO_DESCRIPTION".MessageViewlocalized
        } else {
            txtDescription.text = wallet.walletDescription
        }
        
        if let time = TimeInterval(exactly: wallet.payTime) {
            txtDate.text = Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage()
        }
        
        mainViewHeight.constant = messageSizes.bubbleSize.height
        // Hint: use "messageAttachmentHeight" for description height in "PaymentCell"
        descriptionHeight?.constant = messageSizes.messageAttachmentHeight
    }
}
