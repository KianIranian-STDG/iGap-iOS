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

class IGNavigationBar: UINavigationBar, UINavigationBarDelegate {
    
    var isTransparent: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.tintColor = UIColor.white
//        self.isTranslucent = false
//        self.barTintColor = UIColor.white
//        self.layer.shadowColor = UIColor.clear.cgColor
//        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        self.layer.shadowRadius = 4.0
//        self.layer.shadowOpacity = 0.35
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white ] // Title color
        UINavigationBar.appearance().tintColor = .white // Left. bar buttons
        
        
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()

        for items in self.items! {
            if items.leftBarButtonItems != nil {

                for item in items.leftBarButtonItems! {
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .default)
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .compact)
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .compactPrompt)
                    item.setBackgroundVerticalPositionAdjustment(-100, for: .defaultPrompt)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .default)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .compact)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .compactPrompt)
                    item.setTitlePositionAdjustment(UIOffset(horizontal: 100, vertical: -10) , for: .defaultPrompt)
                }
            }
        }
    }
    
    func setGradientBackground(colors: [UIColor], startPoint: CAGradientLayer.Point = .topLeft, endPoint: CAGradientLayer.Point = .bottomLeft) {
        self.isTransparent = false
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors, startPoint: startPoint, endPoint: endPoint)
        self.isTranslucent = false
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
    
    func setTransparentNavigationBar() {
        self.isTransparent = true
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
}
