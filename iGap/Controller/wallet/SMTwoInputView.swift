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
    @IBOutlet var lblTFOne: UILabel!
    @IBOutlet var lblTFTwo: UILabel!
    @IBOutlet var lblTFThree: UILabel!

    @IBOutlet var inputTFOne: UITextField!
    @IBOutlet var inputTFTwo: customAmountTextField!
    @IBOutlet var inputTFThree: customCardNumberTextField!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var closeBtn: UIButton!
    
    /// Load view from nib file
    ///
    /// - Returns: instance of SMSingleInputView loaded from nib file
    class func loadFromNib() -> SMTwoInputView {
        return UINib(nibName: "SMTwoInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMTwoInputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        closeBtn.setTitle(IGStringsManager.GlobalCancel.rawValue.localized, for: .normal)
        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.lblTFOne.text = IGStringsManager.GlobalMessage.rawValue.localized
        self.lblTFTwo.text = IGStringsManager.Amount.rawValue.localized
        self.lblTFThree.text = IGStringsManager.CardNumber.rawValue.localized

        self.lblTFOne.textAlignment = lblTFOne.localizedDirection
        self.lblTFTwo.textAlignment = lblTFTwo.localizedDirection
        self.lblTFThree.textAlignment = lblTFThree.localizedDirection

        initTheme()
    }
    
    private func initTheme() {
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        customizeButtons([confirmBtn])
        customizeTextFields([inputTFOne, inputTFTwo, inputTFThree])
    }
    
    private func customizeButtons(_ buttons: [UIButton]){
        for button in buttons {
            button.layer.cornerRadius = button.bounds.height / 2
            button.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
            button.layer.borderWidth = 1.0
        }
    }
    
    private func customizeTextFields(_ textFields: [UITextField]){
        for textField in textFields {
            textField.textColor = ThemeManager.currentTheme.LabelColor
            textField.backgroundColor = ThemeManager.currentTheme.BackGroundColor
            textField.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
            textField.layer.borderWidth = 1.0
            textField.layer.masksToBounds = true
            textField.layer.cornerRadius = textField.bounds.height / 2
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != self {
            inputTFOne.endEditing(true)
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
