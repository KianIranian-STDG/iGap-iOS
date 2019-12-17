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
class SMSingleAmountInputView: UIView {
    
    /// Title of view
    @IBOutlet var infoLbl: UILabel!
    
    @IBOutlet var inputTF: customAmountTextField!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var containerView: UIView!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    /// Load view from nib file
    ///
    /// - Returns: instance of SMSingleInputView loaded from nib file
    class func loadFromNib() -> SMSingleAmountInputView {
        return UINib(nibName: "SMSingleAmountInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMSingleAmountInputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoLbl.text = IGStringsManager.Amount.rawValue.localized
        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        initTheme()

        
    }
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        infoLbl.textColor = ThemeManager.currentTheme.LabelColor
        inputTF.textColor = ThemeManager.currentTheme.LabelColor
        inputTF.placeHolderColor = ThemeManager.currentTheme.LabelColor
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
            inputTF.endEditing(true)
        }
    }
    /// Layout subview after loading view to support autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView!.layer.borderWidth = 1
        containerView!.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        containerView.layer.cornerRadius = 12
        
        //        self.transform = SMDirection.PageAffineTransform()
//        infoLbl.transform = self.transform
//        inputTF.transform = self.transform
//        confirmBtn.transform = self.transform
        
        infoLbl.textAlignment = SMDirection.TextAlignment()
//        inputTF.textAlignment = inputTF.textAlignment
        
    }

    
}
