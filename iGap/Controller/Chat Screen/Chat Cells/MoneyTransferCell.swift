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

class MoneyTransferCell: IGMessageGeneralCollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var txtFrom: UILabel!
    @IBOutlet weak var txtTo: UILabel!
    @IBOutlet weak var txtTrace: UILabel!
    @IBOutlet weak var txtInvoice: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    var wallet: IGRoomMessageMoneyTransfer!
    
    @IBOutlet weak var lblAmountTitle: UILabel!
    @IBOutlet weak var lblFromTitle: UILabel!
    @IBOutlet weak var ttlInvoicelblInvoiceTitle: UILabel!
    @IBOutlet weak var lblTraceNumberTitle: UILabel!
    @IBOutlet weak var lblToTitle: UILabel!
    @IBOutlet weak var ttlTransfer: UILabel!
    @IBOutlet weak var lblDescription: ActiveLabel!
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
    class func nib() -> UINib {
        return UINib(nibName: "MoneyTransferCell", bundle: Bundle(for: self))
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
        lblToTitle.text = "GLOBAL_TO".localizedNew
        lblFromTitle.text = "GLOBAL_FROM".localizedNew
        ttlInvoicelblInvoiceTitle.text = "TTL_INVOICE_NUMBER".localizedNew
        lblAmountTitle.text = "PRICE".localizedNew
        lblTraceNumberTitle.text = "TRACE_NUMBER".localizedNew
        ttlTransfer.font = UIFont.igFont(ofSize: 15)
        txtDate.font = UIFont.igFont(ofSize: 15)
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.mainView.layer.cornerRadius = 12.0
        self.mainView.layer.masksToBounds = true
        self.mainView.backgroundColor = UIColor.dialogueBoxIncomming()
        
        guard let wallet = message.wallet?.moneyTrasfer else { return }
        
        ttlTransfer.text = "WALLET_TRANSFER_MONEY".localizedNew
        ttlTransfer.backgroundColor = UIColor.iGapYellow()
        txtDate.backgroundColor = UIColor.iGapYellow()
        ttlTransfer.textColor = UIColor.black
        txtDate.textColor = UIColor.black
        txtAmount.text = String(describing: wallet.amount).inLocalizedLanguage() + "CURRENCY".localizedNew
        txtTrace.text = String(describing: wallet.traceNumber).inLocalizedLanguage()
        txtInvoice.text = String(describing: wallet.invoiceNumber).inLocalizedLanguage()
        
        if let senderUser = IGRegisteredUser.getUserInfo(id: wallet.fromUserId) {
            txtFrom.font = UIFont.igFont(ofSize: 13)
            txtFrom.text = senderUser.displayName
        }
        
        if let receiverUser = IGRegisteredUser.getUserInfo(id: wallet.toUserId) {
            txtTo.font = UIFont.igFont(ofSize: 13)
            txtTo.text = receiverUser.displayName
        }

        if wallet.walletDescription!.isEmpty {
            txtDescription.text = "NO_DESCRIPTION".localizedNew
        } else {
            txtDescription.text = message.wallet?.moneyTrasfer?.walletDescription
        }
        
        if let time = TimeInterval(exactly: wallet.payTime) {
            txtDate.text = Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage()
        }
        
        mainViewHeight.constant = messageSizes.bubbleSize.height
        // Hint: use "messageAttachmentHeight" for description height in "MoneyTransferCell"
        descriptionHeight?.constant = messageSizes.messageAttachmentHeight
    }
}
