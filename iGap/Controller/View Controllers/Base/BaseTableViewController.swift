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
    
    var isRTL: Bool {
        get {
            return LocaleManager.isRTL
        }
    }
    
    var transform: CGAffineTransform {
        get {
            return LocaleManager.transform
        }
    }
    
    var semantic: UISemanticContentAttribute {
        get {
            return LocaleManager.semantic
        }
    }
    
    var TextAlignment: NSTextAlignment {
        get {
            return LocaleManager.TextAlignment
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        if #available(iOS 13.0, *) {
//            overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: IGGlobal.themeMode)!
//        } else {
//            // Fallback on earlier versions
//        }

        self.hideKeyboardWhenTappedAround()
    }
    
//    public func setDirectionManually(direction: UISemanticContentAttribute)  {
//        UIView.appearance().semanticContentAttribute = direction
//    }
    
    func initNavigationBar(title: String? = nil, rightItemText: String? = nil, iGapFont: Bool = false, rightAction: @escaping () -> ()) {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: rightItemText, title: title, iGapFont: iGapFont)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        navigationItem.rightViewContainer?.addAction(rightAction)
    }
    
}
