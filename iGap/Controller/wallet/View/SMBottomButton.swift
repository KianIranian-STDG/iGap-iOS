//
//  SMBottomButton.swift
//  PayGear
//
//  Created by Amir Soltani on 4/8/18.
//  Copyright © 2018 Samsson. All rights reserved.
//

import UIKit

//@IBDesignable
class SMBottomButton: UIButton {
    
    var activityIndicator:UIActivityIndicatorView?
    private let gradientLayer = SMSimpleLinearGradientLayer()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.onCreate()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.onCreate()
    }
    
    
    var colors:[UIColor] = [UIColor.white,UIColor.white]{
        didSet{
            gradientLayer.colors = self.colors
        }
    }
    
    
    @IBInspectable
    var fromColor: UIColor = UIColor.white {
        didSet {
            self.colors = [UIColor.iGapMainColor(), UIColor.iGapMainColor()]
        }
    }
    
    
    @IBInspectable
    var toColor: UIColor = UIColor.white {
        didSet {
            self.colors = [UIColor.iGapMainColor(), UIColor.iGapMainColor()]
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        if gradientLayer.superlayer == nil {
            layer.backgroundColor = UIColor.iGapMainColor().cgColor
        }
        
        
//        self.titleLabel?.layer.shadowRadius = 3
//        self.titleLabel?.layer.shadowColor = UIColor.black.cgColor
//        self.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
//        self.titleLabel?.layer.shadowOpacity = 0.5
//        self.titleLabel?.layer.masksToBounds = false
//        self.setTitleColor(UIColor.white, for: .normal)
//        self.clipsToBounds = true
        
    }
    
    func onCreate() {
        
        //self.backgroundColor = SMColor.InactiveField
        self.titleLabel?.font = UIFont.igFont(ofSize: 18)
        self.titleLabel?.layer.shadowRadius = 3
        self.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        self.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.titleLabel?.layer.shadowOpacity = 0.5
        self.titleLabel?.layer.masksToBounds = false
        self.setTitleColor(UIColor.white, for: .normal)
        self.isEnabled = false
        self.clipsToBounds = true
        
    }

    var text = ""
    
    func gotoLoadingState() {
        
        if self.activityIndicator == nil{
            self.activityIndicator = UIActivityIndicatorView(style: .white)
            self.activityIndicator?.frame = self.bounds
            //self.activityIndicator?.backgroundColor = self.backgroundColor
            self.activityIndicator?.alpha = 0
            self.activityIndicator?.startAnimating()
            text = (self.titleLabel?.text)!
            self.setTitle("", for: .normal)
            self.addSubview(self.activityIndicator!)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.activityIndicator?.alpha = 1
            })
            
            self.isUserInteractionEnabled = false
        }
    }
    
    func gotoButtonState() {
    
        if self.activityIndicator != nil{
            UIView.animate(withDuration: 0.2, animations: {
                self.activityIndicator?.alpha = 0
            }, completion: {finished in
                self.activityIndicator?.removeFromSuperview()
                self.activityIndicator = nil
                self.isUserInteractionEnabled = true
                self.setTitle(self.text, for: .normal)
            })
        }
    
    }
    
    func enable() {
        self.isEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        }
    }
    
    func disable() {
        self.isEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = SMColor.InactiveField
        }
    }
    
}
