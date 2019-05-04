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

class IGNavigationController: UINavigationController, UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.topItem?.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 50), for: UIBarMetrics.default)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func popViewController(animated: Bool) -> UIViewController? {
        let numberOfPages = super.viewControllers.count
        if numberOfPages == 2  {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoBackToMainNotificationName), object: nil)
            return super.popViewController(animated: animated)

        }
            
        else {
            return super.popViewController(animated: animated)

        }

    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
