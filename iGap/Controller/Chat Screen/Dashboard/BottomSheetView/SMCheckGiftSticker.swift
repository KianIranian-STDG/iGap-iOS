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

/// Input view to get only one input and button to confirm action
class SMCheckGiftSticker: UIView {
    
    /// Title of view
    @IBOutlet var infoLblOne: UILabel!
    @IBOutlet var imgGiftCard: UIImageView!
    @IBOutlet var txtBuyDetail: UILabel!
    @IBOutlet var confirmBtn: UIButton!
    var title = IGStringsManager.GiftStickerBuy.rawValue.localized
    
    /// - Returns: instance of SMSingleInputView loaded from nib file
    class func loadFromNib() -> SMCheckGiftSticker {
        return UINib(nibName: "SMCheckGiftSticker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMCheckGiftSticker
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.infoLblOne.text = title
        self.txtBuyDetail.text = IGStringsManager.NationalCode.rawValue.localized
        self.confirmBtn.setTitle(IGStringsManager.InquiryAndShopping.rawValue.localized, for: .normal)
        initTheme()
    }
    
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        infoLblOne.textColor = ThemeManager.currentTheme.LabelColor
        txtBuyDetail.textColor = ThemeManager.currentTheme.LabelColor
        txtBuyDetail.font = UIFont.igFont(ofSize: 15)
        
        confirmBtn.layer.cornerRadius = confirmBtn.bounds.height / 2
        confirmBtn.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        confirmBtn.layer.borderWidth = 1.0
    }
    
    @IBAction func closeModal(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.frame.height
        }) { (true) in
        }
    }
    
    func setInfo(token: String, amount: String){
        confirmBtn.setTitle(IGStringsManager.Payment.rawValue.localized, for: .normal)
        
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            DispatchQueue.main.async {
                self.imgGiftCard.setSticker(for: file)
            }
        })
        
        txtBuyDetail.text = IGStringsManager.GiftCardSelected.rawValue.localized + "\n" + amount.inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
    }
    
    func setInfo(giftSticker: IGStructGiftCardStatus, date: String){
        confirmBtn.setTitle(IGStringsManager.ActivateOrSendAsMessage.rawValue.localized, for: .normal)
        
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: giftSticker.sticker.token, completion: { (file) -> Void in
            DispatchQueue.main.async {
                self.imgGiftCard.setSticker(for: file)
            }
        })
        
        let finalDate = date.dateFromStringFormat(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", showHour: true) ?? ""
        txtBuyDetail.text = String(describing: giftSticker.sticker.giftAmount).inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized + "\n" + finalDate
    }
}
