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
    @IBOutlet var edtInternationalCode: UITextField!
    @IBOutlet var btnOne: UIButton!
    @IBOutlet var btnTwo: UIButton!
 
    /// Load view from nib file
    ///
    /// - Returns: instance of SMSingleInputView loaded from nib file
    class func loadFromNib() -> SMGiftStickerAlertView {
        return UINib(nibName: "SMGiftStickerAlertView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMGiftStickerAlertView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.edtInternationalCode.placeholder = IGStringsManager.NationalCode.rawValue.localized
        self.btnOne.setTitle(IGStringsManager.InquiryAndShopping.rawValue.localized, for: .normal)
        initTheme()
        
        if let nationalCode = IGSessionInfo.getNationalCode() {
            self.edtInternationalCode.text = nationalCode
        }
    }
    
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        infoLblOne.textColor = ThemeManager.currentTheme.LabelColor
        
        edtInternationalCode.textColor = ThemeManager.currentTheme.LabelColor
        edtInternationalCode.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        edtInternationalCode.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        edtInternationalCode.layer.borderWidth = 1.0
        edtInternationalCode.layer.masksToBounds = true
        edtInternationalCode.layer.cornerRadius = edtInternationalCode.bounds.height / 2
        
        btnOne.layer.cornerRadius = btnOne.bounds.height / 2
        btnOne.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btnOne.layer.borderWidth = 1.0
        
        btnTwo.layer.cornerRadius = btnTwo.bounds.height / 2
        btnTwo.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btnTwo.layer.borderWidth = 1.0
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
