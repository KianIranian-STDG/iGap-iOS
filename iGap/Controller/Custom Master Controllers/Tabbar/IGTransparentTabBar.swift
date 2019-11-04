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

//@IBDesignable
class IGTransparentTabBar: UITabBar {
    
    private var materialKey = false
    
    @IBInspectable var isTransparent: Bool {
        get {
            return materialKey
        }
        set {
            materialKey = newValue
            if materialKey {
                self.backgroundImage = UIImage()
//                self.setBackgroundImage(UIImage(), for: .default)
                self.shadowImage = UIImage()
                self.isTranslucent = true
            }
        }
    }
    
    
    @IBInspectable var height: CGFloat = 60.0
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        if height > 0.0 {
            
            if #available(iOS 11.0, *) {
                sizeThatFits.height = height + window.safeAreaInsets.bottom
            } else {
                sizeThatFits.height = height
            }
        }
        return sizeThatFits
    }
}


