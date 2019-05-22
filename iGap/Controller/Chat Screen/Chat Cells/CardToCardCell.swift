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
    @IBOutlet weak var ttlFrom: UILabel!
    @IBOutlet weak var ttlTo: UILabel!
    @IBOutlet weak var ttlTrace: UILabel!
    @IBOutlet weak var ttlInvoice: UILabel!
    @IBOutlet weak var ttlSourceCardNUmber: UILabel!
    @IBOutlet weak var ttlDestinationCardNUmber: UILabel!

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblSourceCard: UILabel!
    @IBOutlet weak var lblDestinationCard: UILabel!
    @IBOutlet weak var ttlInvoicelblInvoiceNumber: UILabel!
    @IBOutlet weak var lblTraceNumber: UILabel!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var ttlTransfer: IGLabel!
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
        ttlTransfer.text = "CARD_TRANSFER_MONEY".localizedNew
        ttlTransfer.backgroundColor = UIColor.iGapSkyBlue()
        ttlDate.backgroundColor = UIColor.iGapSkyBlue()
        ttlTransfer.textColor = UIColor.black
        ttlDate.textColor = UIColor.black
        ttlTo.text = "GLOBAL_TO".localizedNew
        ttlFrom.text = "GLOBAL_FROM".localizedNew
        ttlInvoice.text = "TTL_INVOICE_NUMBER".localizedNew
        ttlAmount.text = "PRICE".localizedNew
        ttlTransfer.text = "TRACE_NUMBER".localizedNew
        ttlTransfer.font = UIFont.igFont(ofSize: 15)
        ttlDate.font = UIFont.igFont(ofSize: 15)
        ttlDestinationCardNUmber.text = "TTL_DESTI_CARDNUM".localizedNew
        ttlSourceCardNUmber.text = "TTL_CARDNUM".localizedNew


        
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.mainView.layer.cornerRadius = 12.0
        self.mainView.layer.masksToBounds = true
        self.mainView.backgroundColor = UIColor.dialogueBoxIncomming()

        guard let cardToCard = message.wallet?.cardToCard else {
            return
        }
    }
}