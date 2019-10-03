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
    
    /// Title of view
    
    @IBOutlet var btnWalletTransfer: UIButton!
    @IBOutlet var btnCardToCardTransfer: UIButton!
    @IBOutlet var btnWallet: UIButton!
    @IBOutlet var btnCard: UIButton!
    @IBOutlet var containerView: UIView!

    /// Load view from nib file
    ///
    /// - Returns: instance of SMMoneyTransactionOptions loaded from nib file
    class func loadFromNib() -> SMMoneyTransactionOptions {
        return UINib(nibName: "SMMoneyTransactionOptions", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMMoneyTransactionOptions
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)

        initiconFonts()
    }
    
    private func initiconFonts() {
        btnWallet.titleLabel?.font = UIFont.iGapFonticon(ofSize: 28)
        btnCard.titleLabel?.font = UIFont.iGapFonticon(ofSize: 28)

        btnWallet.setTitle("", for: .normal)
        btnCard.setTitle("", for: .normal)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = (touches.first)
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
        }

    }
   
    /// Layout subview after loading view to support autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.transform = SMDirection.PageAffineTransform()
    }
    
}
