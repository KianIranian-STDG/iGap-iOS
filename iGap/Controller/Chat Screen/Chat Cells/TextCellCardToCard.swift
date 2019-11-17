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

class TextCellCardToCard: IGMessageGeneralCollectionViewCell {
    
    var imgAvatarPay : UIImageViewX!
    
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
        return UINib(nibName: "TextCellCardToCard", bundle: Bundle(for: self))
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
        
        guard let cardToCard = message.wallet?.cardToCard else {
            return
        }
        lblAmount.text = String(describing: cardToCard.amount).inRialFormat().inLocalizedLanguage() + " " + "CURRENCY".localized
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
