//
//  SMSingleInputView.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/21/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Input view to get only one input and button to confirm action
class SMSingleInputView: UIView, UITextFieldDelegate {

    /// Title of view
    @IBOutlet var infoLbl: UILabel!

    @IBOutlet var inputTF: UITextField!
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
    class func loadFromNib() -> SMSingleInputView {
        return UINib(nibName: "SMSingleInputView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMSingleInputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    /// Layout subview after loading view to support autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
     
        containerView!.layer.borderWidth = 1
        containerView!.layer.borderColor = UIColor(netHex: 0xb2bec4).cgColor
        containerView.layer.cornerRadius = 12
		
		self.transform = SMDirection.PageAffineTransform()
		infoLbl.transform = self.transform
		inputTF.transform = self.transform
		confirmBtn.transform = self.transform
		
		infoLbl.textAlignment = SMDirection.TextAlignment()
		inputTF.textAlignment = infoLbl.textAlignment
		
    }
    
    /// Method of UITextFieldDelegate
    ///
    /// - Parameter textField: selected TextField
    /// - Returns: dismiss keyboard by selecting return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        inputTF.resignFirstResponder()
        return true
    }
}
