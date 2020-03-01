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
class SMGiftStickerAlertView: UIView {
    
    /// Title of view
    @IBOutlet var infoLblOne: UILabel!
    @IBOutlet var txtInternationalCode: UILabel!
    @IBOutlet var edtInternationalCode: UITextField!
    @IBOutlet var confirmBtn: UIButton!
 
    /// Load view from nib file
    ///
    /// - Returns: instance of SMSingleInputView loaded from nib file
    class func loadFromNib() -> SMGiftStickerAlertView {
        return UINib(nibName: "SMGiftStickerAlertView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMGiftStickerAlertView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.infoLblOne.text = IGStringsManager.GiftSticker.rawValue.localized
        self.txtInternationalCode.text = IGStringsManager.NationalCode.rawValue.localized
        self.edtInternationalCode.textAlignment = edtInternationalCode.localizedDirection

        initTheme()
    }
    
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        confirmBtn.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        infoLblOne.textColor = ThemeManager.currentTheme.LabelColor
        txtInternationalCode.textColor = ThemeManager.currentTheme.LabelColor
        confirmBtn.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        
        edtInternationalCode.textColor = ThemeManager.currentTheme.LabelColor
        edtInternationalCode.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        edtInternationalCode.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        edtInternationalCode.layer.borderWidth = 1.0
        edtInternationalCode.layer.cornerRadius = 10
        confirmBtn.layer.borderWidth = 1.0
        confirmBtn.layer.cornerRadius = 10
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
            edtInternationalCode.endEditing(true)
        }
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
