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

class CardToCardCell: IGMessageGeneralCollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var ttlAmount: UILabel!
    @IBOutlet weak var ttlRrn: UILabel!
    @IBOutlet weak var ttlInvoice: UILabel!
    @IBOutlet weak var ttlSourceCardNUmber: UILabel!
    @IBOutlet weak var ttlDestinationCardNUmber: UILabel!
    @IBOutlet weak var ttlDestinationBankName: UILabel!
    @IBOutlet weak var ttlSourceBankName: UILabel!
    @IBOutlet weak var txtAccountOwnerName: UILabel!
    
    @IBOutlet weak var ttlTransfer: IGLabel!
    @IBOutlet weak var lblDestinationBankName: UILabel!
    @IBOutlet weak var lblSourceBankName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblSourceCard: UILabel!
    @IBOutlet weak var lblDestinationCard: UILabel!
    @IBOutlet weak var ttlInvoicelblInvoiceNumber: UILabel!
    @IBOutlet weak var lblRrn: UILabel!
    @IBOutlet weak var lblAccountOwnerName: UILabel!
    @IBOutlet weak var ttlDate: UILabel!

    class func nib() -> UINib {
        return UINib(nibName: "CardToCardCell", bundle: Bundle(for: self))
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
        ttlTransfer.text = "CARD_TRANSFER_MONEY".localized
        ttlTransfer.backgroundColor = UIColor.iGapSkyBlue()
        ttlDate.backgroundColor = UIColor.iGapSkyBlue()
        ttlTransfer.textColor = UIColor.black
        ttlDate.textColor = UIColor.black
        ttlInvoicelblInvoiceNumber.text = "TRACE_NUMBER".localized
        ttlAmount.text = IGStringsManager.Price.rawValue.localized
        ttlTransfer.font = UIFont.igFont(ofSize: 15)
        ttlDate.font = UIFont.igFont(ofSize: 15)
        ttlDestinationCardNUmber.text = IGStringsManager.DestinationCardNumber.rawValue.localized
        ttlSourceCardNUmber.text = IGStringsManager.CardNumber.rawValue.localized
        lblSourceBankName.text = "SOURCE_BANK".localized
        ttlDestinationBankName.text = IGStringsManager.DestinationBank.rawValue.localized
        lblRrn.text = "TTL_REFERENCE_NUMBER".localized
        lblAccountOwnerName.text = "TTL_ACCOUNT_OWNER_NAME".localized
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.cellMessage = message
        self.mainView.layer.cornerRadius = 12.0
        self.mainView.layer.masksToBounds = true
        self.mainView.backgroundColor = UIColor.dialogueBoxIncomming()

        guard let cardToCard = message.wallet?.cardToCard else {
            return
        }
        lblAmount.text = String(describing: cardToCard.amount).inRialFormat().inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
        ttlRrn.text =  (cardToCard.traceNumber)!.inLocalizedLanguage()
        ttlInvoice.text = (cardToCard.rrn)!.inLocalizedLanguage()
        lblSourceCard.text = (cardToCard.sourceCardNumber)!.inLocalizedLanguage()
        lblDestinationCard.text = (cardToCard.destCardNumber)!.inLocalizedLanguage()
        ttlSourceBankName.text = (cardToCard.bankName)!.inLocalizedLanguage()
        lblDestinationBankName.text = (cardToCard.destBankName)!.inLocalizedLanguage()
        txtAccountOwnerName.text = cardToCard.cardOwnerName
        
        if let time = TimeInterval(exactly: cardToCard.requestTime) {
            ttlDate.text = Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage()
        }
    }
}
