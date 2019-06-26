//
//  SMBottomButton.swift
//  PayGear
//
//  Created by Amir Soltani on 4/8/18.
//  Copyright © 2018 Samsson. All rights reserved.
//

import UIKit

class SMGradientButton: UIButton {
    
    private let gradientLayer = SMSimpleLinearGradientLayer()
    var activityIndicator:UIActivityIndicatorView?
    
    var colors:[UIColor] = [UIColor.white,UIColor.white]{
        didSet {
            gradientLayer.colors = self.colors
        }
    }
    
    
    @IBInspectable
    var fromColor: UIColor = UIColor.white {
        didSet {
            self.colors = [fromColor, toColor]
        }
    }
    
    @IBInspectable
    var toColor: UIColor = UIColor.white {
        didSet {
            self.colors = [fromColor, toColor]
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = self.bounds
        
        gradientLayer.cornerRadius = self.layer.cornerRadius
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
        
        self.titleLabel?.font = UIFont.igFont(ofSize: 17)
            
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.titleLabel?.layer.shadowRadius = 3
        self.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        self.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.titleLabel?.layer.shadowOpacity = 0.5
        self.titleLabel?.layer.masksToBounds = false
        self.setTitleColor(UIColor.white, for: .normal)
        self.clipsToBounds = true
        
    }
    

    
    func gotoLoadingState(){
        if self.activityIndicator == nil{
            self.activityIndicator = UIActivityIndicatorView(style: .white)
            self.activityIndicator?.frame = self.bounds
            self.activityIndicator?.backgroundColor = self.backgroundColor
            self.activityIndicator?.alpha = 0
            self.activityIndicator?.startAnimating()
            
            self.addSubview(self.activityIndicator!)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.activityIndicator?.alpha = 1
            })
            
            self.isUserInteractionEnabled = false
        }
    }
    
    func gotoButtonState(){
    
        if self.activityIndicator != nil{
            UIView.animate(withDuration: 0.2, animations: {
                self.activityIndicator?.alpha = 0
            }, completion: {finished in
                self.activityIndicator?.removeFromSuperview()
                self.activityIndicator = nil
                self.isUserInteractionEnabled = true
            })
        }
    }
    
    func enable() {
        self.isEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = SMColor.PrimaryColor
        }
    }
    
    func disable() {
        self.isEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = SMColor.InactiveField
        }
    }
    
}
