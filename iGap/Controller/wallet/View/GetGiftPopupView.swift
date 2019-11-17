//
//  GetGiftPopupView.swift
//  PayGear
//
//  Created by HSM on 2/21/19.
//  Copyright © 2019 Samsoon. All rights reserved.
//

import UIKit

protocol HandleGiftView {
    func closeGift()
    func confirmGift()
}

class GetGiftPopupView: UIView {

    // Outlets
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    @IBOutlet weak var ConfirmButton: SMGradientButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var ConfirmButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var resultBackGroundView: UIView!
    @IBOutlet weak var GradiantView: UIView!
    @IBOutlet weak var ResultLabel: UILabel!
    
    // Variables
    var delegate : HandleGiftView?
    var finishDelegate : HandleDefaultCard?
    var MessageText = String()
    var gradientLayer = CAGradientLayer()

    // System Functions
    override func awakeFromNib() {
//        self.frame.size.height = 500.0

        self.TitleLabel.text = IGStringsManager.Gift.rawValue.localized
        self.ConfirmButton.setTitle(IGStringsManager.GetGift.rawValue.localized, for: .normal)
        self.ConfirmButton.setImage(nil, for: .normal)
        self.CancelButton.setTitle(IGStringsManager.GlobalCancel.rawValue.localized, for: .normal)
        self.MessageLabel.text = self.MessageText
        
        gradientLayer.colors = [UIColor(red: 34/255, green: 148/255, blue: 255/255, alpha: 1), UIColor(red: 222/255, green: 10/255, blue: 233/255, alpha: 1)]
        gradientLayer.locations = [0.0,1.0]
        self.GradiantView.layer.addSublayer(gradientLayer)
        self.resultBackGroundView.isHidden = true
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = self.GradiantView.bounds
    }
    
    
    class func instanceFromNib() -> GetGiftPopupView {
        return UINib(nibName: "GetGiftPopup", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! GetGiftPopupView
    }
    
    // Actions
    @IBAction func ConfirmButton(_ sender: Any) {
        delegate?.confirmGift()
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        delegate?.closeGift()
    }
}
