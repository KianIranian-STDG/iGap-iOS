//
//  SMMoneyTransactionOptions.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/16/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

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
