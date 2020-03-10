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
class SMCheckBuyGiftSticker: UIView {
    
    /// Title of view
    @IBOutlet var infoLblOne: UILabel!
    @IBOutlet var imgGiftCard: UIImageView!
    @IBOutlet var txtBuyDetail: UILabel!
    @IBOutlet var confirmBtn: UIButton!
 
    /// - Returns: instance of SMSingleInputView loaded from nib file
    class func loadFromNib() -> SMCheckBuyGiftSticker {
        return UINib(nibName: "SMCheckBuyGiftSticker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMCheckBuyGiftSticker
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.infoLblOne.text = IGStringsManager.GiftStickerBuy.rawValue.localized
        self.txtBuyDetail.text = IGStringsManager.NationalCode.rawValue.localized
        self.confirmBtn.setTitle(IGStringsManager.InquiryAndShopping.rawValue.localized, for: .normal)
        initTheme()
    }
    
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        confirmBtn.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        confirmBtn.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        confirmBtn.setTitle(IGStringsManager.Payment.rawValue.localized, for: .normal)
        infoLblOne.textColor = ThemeManager.currentTheme.LabelColor
        txtBuyDetail.textColor = ThemeManager.currentTheme.LabelColor
        txtBuyDetail.font = UIFont.igFont(ofSize: 15)
        
        confirmBtn.layer.borderWidth = 1.0
        confirmBtn.layer.cornerRadius = 5
    }
    
    @IBAction func closeModal(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.frame.height
        }) { (true) in
        }
    }
    
    func setInfo(token: String, amount: String){
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            DispatchQueue.main.async {
                self.imgGiftCard.setSticker(for: file)
            }
        })
        
        txtBuyDetail.text = IGStringsManager.GiftCardSelected.rawValue.localized + "\n" + amount.inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
    }
}
