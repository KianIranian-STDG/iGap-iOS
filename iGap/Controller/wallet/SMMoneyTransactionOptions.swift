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
class SMMoneyTransactionOptions: UIView {
    
    @IBOutlet var btnWalletTransfer: UIButton!
    @IBOutlet var btnCardToCardTransfer: UIButton!
    @IBOutlet var btnWallet: UIButton!
    @IBOutlet var btnCard: UIButton!
    @IBOutlet weak var lblTop: UILabel!
    @IBOutlet weak var btnGiftStickerTitle: UIButton!
    @IBOutlet weak var btnGiftStickerIcon: UIButton!
    @IBOutlet var containerView: UIView!

    /// Load view from nib file
    /// - Returns: instance of SMMoneyTransactionOptions loaded from nib file
    class func loadFromNib() -> SMMoneyTransactionOptions {
        return UINib(nibName: "SMMoneyTransactionOptions", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMMoneyTransactionOptions
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)

        initiconFonts()
        self.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
    }
    
    private func initiconFonts() {
        btnWallet.titleLabel?.font = UIFont.iGapFonticon(ofSize: 28)
        btnCard.titleLabel?.font = UIFont.iGapFonticon(ofSize: 28)
        btnCard.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnWallet.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnCardToCardTransfer.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnWalletTransfer.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnGiftStickerTitle.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnGiftStickerIcon.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        lblTop.textColor = ThemeManager.currentTheme.LabelColor
        btnWallet.setTitle("", for: .normal)
        btnCard.setTitle("", for: .normal)
        btnGiftStickerIcon.setTitle("", for: .normal)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
}
