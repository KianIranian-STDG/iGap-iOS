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
class SMGiftCardInfo: UIView {
    
    @IBOutlet var infoHeader: UILabel!
    @IBOutlet var txtCardNumber: UILabel!
    @IBOutlet var txtCardNumberValue: UILabel!
    @IBOutlet var txtExpirationDate: UILabel!
    @IBOutlet var txtExpirationDateValue: UILabel!
    @IBOutlet var txtCVV2: UILabel!
    @IBOutlet var txtCVV2Value: UILabel!
    @IBOutlet var txtPin: UILabel!
    @IBOutlet var txtPinValue: UILabel!
    @IBOutlet var txtCopy: UILabel!
    
    
    /// Load view from nib file
    /// - Returns: instance of SMSingleInputView loaded from nib file
    class func loadFromNib() -> SMGiftCardInfo {
        return UINib(nibName: "SMGiftCardInfo", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMGiftCardInfo
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        initTheme()
    }
    
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        
        infoHeader.text = IGStringsManager.GiftStickerCardInfoTitle.rawValue.localized
        txtCardNumber.text = IGStringsManager.CardNumber.rawValue.localized
        txtExpirationDate.text = IGStringsManager.ExpireDate.rawValue.localized
        txtCVV2.text = IGStringsManager.CVV2.rawValue.localized
        txtPin.text = IGStringsManager.InternetPin2.rawValue.localized
        txtCopy.text = IGStringsManager.ClickForCopy.rawValue.localized
        manageTextColors(labels: [txtCardNumber, txtExpirationDate, txtCVV2, txtPin, txtCopy], lighter: 10)
        manageTextColors(labels: [txtCardNumberValue, txtExpirationDateValue, txtCVV2Value, txtPinValue])
    }
    
    func setInfo(giftCardInfo: IGStructGiftCardInfo!){
        txtCardNumberValue.text = giftCardInfo.cardNumber.inLocalizedLanguage()
        txtExpirationDateValue.text = giftCardInfo.expireDate.substring(0, 2).inLocalizedLanguage() + " / " + giftCardInfo.expireDate.substring(2, 4).inLocalizedLanguage()
        txtCVV2Value.text = giftCardInfo.cvv2.inLocalizedLanguage()
        txtPinValue.text = giftCardInfo.secondPassword.inLocalizedLanguage()
    }
    
    private func manageTextColors(labels: [UILabel], lighter: CGFloat? = nil){
        
        if lighter != nil {
            for label in labels {
                label.textColor = ThemeManager.currentTheme.LabelColor.lighter(by: lighter!)
            }
        } else {
            for label in labels {
                label.textColor = ThemeManager.currentTheme.LabelColor
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != self {}
    }
    
    /// Layout subview after loading view to support autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func closeModal(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.frame.height
        }) { (true) in
        }
    }
}
