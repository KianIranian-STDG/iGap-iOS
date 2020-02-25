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

class TopupCell: IGMessageGeneralCollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topupMessage: IGLabel!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var txtAmountValue: UILabel!
    @IBOutlet weak var txtRequesterMobileNumber: UILabel!
    @IBOutlet weak var txtRequesterMobileNumberValue: UILabel!
    @IBOutlet weak var txtRecieversMobileNumber: UILabel!
    @IBOutlet weak var txtRecieversMobileNumberValue: UILabel!
    @IBOutlet weak var txtBillType: UILabel!
    @IBOutlet weak var txtBillTypeValue: UILabel!
    @IBOutlet weak var txtCardNumber: UILabel!
    @IBOutlet weak var txtCardNumberValue: UILabel!
    @IBOutlet weak var txtOrderId: UILabel!
    @IBOutlet weak var txtOrderIdValue: UILabel!
    @IBOutlet weak var txtTerminalId: UILabel!
    @IBOutlet weak var txtTerminalIdValue: UILabel!
    @IBOutlet weak var txtReferenceId: UILabel!
    @IBOutlet weak var txtReferenceIdValue: UILabel!
    @IBOutlet weak var txtTrackingCode: UILabel!
    @IBOutlet weak var txtTrackingCodeValue: UILabel!
    @IBOutlet weak var txtDate: UILabel!

    class func nib() -> UINib {
        return UINib(nibName: "TopupCell", bundle: Bundle(for: self))
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
        topupMessage.text = IGStringsManager.TopupMessage.rawValue.localized
        topupMessage.backgroundColor = UIColor.iGapTopupCellPurple()
        txtDate.backgroundColor = UIColor.iGapTopupCellPurple()
        topupMessage.font = UIFont.igFont(ofSize: 15)
        txtDate.font = UIFont.igFont(ofSize: 15)
        
        txtAmount.text = IGStringsManager.Amount.rawValue.localized
        txtRequesterMobileNumber.text = IGStringsManager.TopupRequesterMobileNumber.rawValue.localized
        txtRecieversMobileNumber.text = IGStringsManager.TopupReceiverMobileNumber.rawValue.localized
        txtBillType.text = IGStringsManager.BillType.rawValue.localized
        txtCardNumber.text = IGStringsManager.CardNumber.rawValue.localized
        txtOrderId.text = IGStringsManager.OrderId.rawValue.localized
        txtTerminalId.text = IGStringsManager.TerminalId.rawValue.localized
        txtReferenceId.text = IGStringsManager.RefrenceNum.rawValue.localized
        txtTrackingCode.text = IGStringsManager.TraceNumber.rawValue.localized
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.cellMessage = message
        self.mainView.layer.cornerRadius = 12.0
        self.mainView.layer.masksToBounds = true
        self.mainView.backgroundColor = UIColor.dialogueBoxIncomming()

        guard let topup = message.wallet?.topup else {
            return
        }
        
        txtAmountValue.text = String(describing: topup.amount).inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
        txtRequesterMobileNumberValue.text = topup.requesterMobileNumber?.inLocalizedLanguage()
        txtRecieversMobileNumberValue.text = topup.chargeMobileNumber?.inLocalizedLanguage()
        txtBillTypeValue.text = fetchTopupType(type: topup.topupType)
        txtCardNumberValue.text = topup.cardNumber?.inLocalizedLanguage()
        txtOrderIdValue.text =  String(describing: topup.orderId).inLocalizedLanguage()
        txtTerminalIdValue.text =  String(describing: topup.terminalNo).inLocalizedLanguage()
        txtReferenceIdValue.text =  String(describing: topup.rrn).inLocalizedLanguage()
        txtTrackingCodeValue.text =  String(describing: topup.traceNumber).inLocalizedLanguage()
        
        if let time = TimeInterval(exactly: topup.requestTime) {
            txtDate.text = Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage()
        }
    }
    
    public func fetchTopupType(type: IGPRoomMessageWallet.IGPTopup.IGPType.RawValue) -> String {
        switch type {
        case IGPRoomMessageWallet.IGPTopup.IGPType.irancellPrepaid.rawValue,
             IGPRoomMessageWallet.IGPTopup.IGPType.irancellWow.rawValue,
             IGPRoomMessageWallet.IGPTopup.IGPType.irancellWimax.rawValue,
             IGPRoomMessageWallet.IGPTopup.IGPType.irancellPostpaid.rawValue:
            return IGStringsManager.Irancell.rawValue.localized
            
        case IGPRoomMessageWallet.IGPTopup.IGPType.mci.rawValue:
            return IGStringsManager.MCI.rawValue.localized
            
        case IGPRoomMessageWallet.IGPTopup.IGPType.rightel.rawValue:
            return IGStringsManager.Rightel.rawValue.localized
            
        default:
            return ""
        }
        
    }
}
