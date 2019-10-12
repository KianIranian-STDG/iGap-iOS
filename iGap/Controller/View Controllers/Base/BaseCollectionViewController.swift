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

private let reuseIdentifier = "Cell"

class BaseCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        let _ : String = SMLangUtil.loadLanguage()
    }
    
    public func setDirectionManually(direction: UISemanticContentAttribute)  {
        UIView.appearance().semanticContentAttribute = direction
    }
    
}
