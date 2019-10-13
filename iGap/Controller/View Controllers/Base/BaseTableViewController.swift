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
import maincore
import RxSwift

class BaseTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    let disposeBag = DisposeBag()
    
    var isAppEnglish: Bool {
        get {
            return SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        }
    }
    
    var transform: CGAffineTransform {
        get {
            return isAppEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    var semantic: UISemanticContentAttribute {
        get {
            return isAppEnglish ? .forceLeftToRight : .forceRightToLeft
        }
    }
    
    var TextAlignment: NSTextAlignment {
        return isAppEnglish ? .left : .right
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    public func setDirectionManually(direction: UISemanticContentAttribute)  {
        UIView.appearance().semanticContentAttribute = direction
    }
    
    func initNavigationBar(title: String? = nil, rightItemText: String? = nil, iGapFont: Bool = false, rightAction: @escaping () -> ()) {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: rightItemText, title: title, iGapFont: iGapFont)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        navigationItem.rightViewContainer?.addAction(rightAction)
    }
    
}
