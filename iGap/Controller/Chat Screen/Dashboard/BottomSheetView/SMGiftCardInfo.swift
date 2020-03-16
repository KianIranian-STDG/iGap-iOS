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
    
    var giftCardInfo: IGStructGiftCardInfo!
    
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
        manageTextColors(labels: [txtCardNumber, txtExpirationDate, txtCVV2, txtPin, txtCopy, txtExpirationDateValue, txtCVV2Value, txtPinValue, txtCardNumberValue])
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(cardNumberClick))
        txtCardNumberValue.isUserInteractionEnabled = true
        txtCardNumberValue.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(dateClick))
        txtExpirationDateValue.isUserInteractionEnabled = true
        txtExpirationDateValue.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(cvvClick))
        txtCVV2Value.isUserInteractionEnabled = true
        txtCVV2Value.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(pinClick))
        txtPinValue.isUserInteractionEnabled = true
        txtPinValue.addGestureRecognizer(tap4)
    }
    
    func setInfo(giftCardInfo: IGStructGiftCardInfo!){
        self.giftCardInfo = giftCardInfo
        txtExpirationDateValue.text = giftCardInfo.expireDate.substring(0, 2).inLocalizedLanguage() + " / " + giftCardInfo.expireDate.substring(2, 4).inLocalizedLanguage()
        txtCVV2Value.text = giftCardInfo.cvv2.inLocalizedLanguage()
        txtPinValue.text = giftCardInfo.secondPassword.inLocalizedLanguage()
        
        let cardNumber = giftCardInfo.cardNumber.substring(0, 4) + " - " +
            giftCardInfo.cardNumber.substring(4, 8) + " - " +
            giftCardInfo.cardNumber.substring(8, 12) + " - " +
            giftCardInfo.cardNumber.substring(12, 16)
        txtCardNumberValue.text = cardNumber.inLocalizedLanguage()
    }
    
    private func manageTextColors(labels: [UILabel]){
        for label in labels {
            label.textColor = ThemeManager.currentTheme.LabelColor
        }
    }
    
    //MARK:- User Actions
    @objc
    func cardNumberClick(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = self.giftCardInfo.cardNumber
        IGHelperShowToastAlertView.shared.showPopAlert(view: self, innerView: txtCopy, message: IGStringsManager.TextCopied.rawValue.localized, type: .success)
    }
    
    @objc
    func dateClick(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = self.giftCardInfo.expireDate
        IGHelperShowToastAlertView.shared.showPopAlert(view: self, innerView: txtCopy, message: IGStringsManager.TextCopied.rawValue.localized, type: .success)
    }
    
    @objc
    func cvvClick(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = self.giftCardInfo.cvv2
        IGHelperShowToastAlertView.shared.showPopAlert(view: self, innerView: txtCopy, message: IGStringsManager.TextCopied.rawValue.localized, type: .success)
    }
    
    @objc
    func pinClick(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = self.giftCardInfo.secondPassword
        IGHelperShowToastAlertView.shared.showPopAlert(view: self, innerView: txtCopy, message: IGStringsManager.TextCopied.rawValue.localized, type: .success)
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
