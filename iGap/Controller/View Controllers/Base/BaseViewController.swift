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

class BaseViewController: UIViewController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideKeyboardWhenTappedAround()
        let current : String = SMLangUtil.loadLanguage()
        switch current {
        case "fa" :
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            
        case "en" :
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            
        case "ar" :
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            
        default :
            break
        }
    }
    
    public func setDirectionManually(direction: UISemanticContentAttribute)  {
        UIView.appearance().semanticContentAttribute = direction
    }
}
