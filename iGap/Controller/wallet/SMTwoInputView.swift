//
//  SMSingleAmountInputView.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/17/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

/// Input view to get only one input and button to confirm action
class SMTwoInputView: UIView {
    
    /// Title of view
    @IBOutlet var infoLblOne: UILabel!

    @IBOutlet var inputTFOne: UITextField!
    @IBOutlet var inputTFTwo: customAmountTextField!
    @IBOutlet var inputTFThree: customCardNumberTextField!
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
    class func loadFromNib() -> SMTwoInputView {
        return UINib(nibName: "SMTwoInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMTwoInputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.inputTFTwo.text = SMStringUtil.separateFormat(newStr, separators: [4, 4, 4, 4], delimiter: "-").inLocalizedLanguage()

//        infoLblOne.text = "TTL_AMOUNT".localizedNew
        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        
        
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
    
    
}
