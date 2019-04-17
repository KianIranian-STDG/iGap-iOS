//
//  SMQROverlayView.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/18/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Show UIView objects on camera view, The scanner camera view in normal mode is empty
/// view, according to design, we need to add paygear icon, scanner border,
/// manual input and light on or off buttons; all above items handled here
class SMQROverlayView: UIView {
    
    
    /// Center image view of camera
    public lazy var borderImageView: UIImageView? = {
        let bIV = UIImageView()
        bIV.image = UIImage(named: "page_1")!

        bIV.backgroundColor                           = .clear
        bIV.clipsToBounds                             = true
        bIV.translatesAutoresizingMaskIntoConstraints = false
        
        return bIV
    }()
    
    /// Description of camera view
    public lazy var infoLabel: UILabel? = {
        let iL = UILabel()
        iL.text = "Scan".localized

        iL.textAlignment                             = .center
        iL.font                                      = SMFonts.IranYekanBold(30)
        iL.textColor                                 = .white
        iL.backgroundColor                           = .clear
        iL.clipsToBounds                             = true
        iL.translatesAutoresizingMaskIntoConstraints = false
        
        return iL
    }()
    
    
    /// Image view of paygear icon
    public lazy var iconImageView: UIImageView? = {
        let iIV = UIImageView()
        iIV.image = UIImage(named: "pg")!
        
        iIV.backgroundColor                           = .clear
        iIV.clipsToBounds                             = true
        iIV.translatesAutoresizingMaskIntoConstraints = false
        
        return iIV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupSubViews()
    }

    /// Add view items to subview
    func setupSubViews() {

        self.addSubview(borderImageView!)
        self.addSubview(infoLabel!)
        self.addSubview(iconImageView!)
    }
    
    /// Set view Constraint to handle autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        NSLayoutConstraint(item: borderImageView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: borderImageView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: borderImageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150).isActive = true
        NSLayoutConstraint(item: borderImageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150).isActive = true

        NSLayoutConstraint(item: infoLabel!, attribute: .bottom, relatedBy: .equal, toItem: borderImageView!, attribute: .top, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: infoLabel!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: infoLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 130).isActive = true
        NSLayoutConstraint(item: infoLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
    
        
        NSLayoutConstraint(item: iconImageView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: iconImageView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: iconImageView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 52).isActive = true
        NSLayoutConstraint(item: iconImageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 26).isActive = true


        
        
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//        
//    }
    

}
