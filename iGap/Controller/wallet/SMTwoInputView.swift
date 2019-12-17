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
class SMTwoInputView: UIView {
    
    /// Title of view
    @IBOutlet var infoLblOne: UILabel!

    @IBOutlet var inputTFOne: UITextField!
    @IBOutlet var inputTFTwo: customAmountTextField!
    @IBOutlet var inputTFThree: customCardNumberTextField!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var closeBtn: UIButton!
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
    class func loadFromNib() -> SMTwoInputView {
        return UINib(nibName: "SMTwoInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMTwoInputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.inputTFTwo.text = SMStringUtil.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()

//        infoLblOne.text = IGStringsManager.Amount.rawValue.localized
        closeBtn.setTitle(IGStringsManager.GlobalCancel.rawValue.localized, for: .normal)
        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        initTheme()
    }
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        closeBtn.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        confirmBtn.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        infoLblOne.textColor = ThemeManager.currentTheme.LabelColor
        confirmBtn.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        
        inputTFOne.placeHolderColor = ThemeManager.currentTheme.LabelColor
        inputTFTwo.placeHolderColor = ThemeManager.currentTheme.LabelColor
        inputTFThree.placeHolderColor = ThemeManager.currentTheme.LabelColor

        inputTFOne.textColor = ThemeManager.currentTheme.LabelColor
        inputTFTwo.textColor = ThemeManager.currentTheme.LabelColor
        inputTFThree.textColor = ThemeManager.currentTheme.LabelColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
            inputTFOne.endEditing(true)
        }
    }
    /// Layout subview after loading view to support autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
//        infoLblOne.textAlignment = SMDirection.TextAlignment()
        //        inputTF.textAlignment = inputTF.textAlignment
        
    }
    
    @IBAction func closeModal(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.frame.height
        }) { (true) in
        }
    }
    
    
}
