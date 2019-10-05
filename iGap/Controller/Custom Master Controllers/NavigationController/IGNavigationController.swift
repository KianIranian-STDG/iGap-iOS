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
import SnapKit

class IGNavigationController: UINavigationController, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    self.navigationBar.topItem?.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 50), for: UIBarMetrics.default)
        setNavigationGradient()
        configNavigationBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                // appearance has changed
                // Update your user interface based on the appearance
                if let navBar = self.navigationBar as? IGNavigationBar {
                    if navBar.isTransparent {
//                        navBar.setTransparentNavigationBar()
                    } else {
                        self.setNavigationGradient()
                    }
                }
                
            }
        } else {
            // Fallback on earlier versions
            if let navBar = self.navigationBar as? IGNavigationBar {
                                if navBar.isTransparent {
            //                        navBar.setTransparentNavigationBar()
                                } else {
                                    self.setNavigationGradient()
                                }
                            }
        }
    }
    
    private func setNavigationGradient() {
        if let navigationBar = self.navigationBar as? IGNavigationBar {
            navigationBar.setGradientBackground(colors: [UIColor(named: themeColor.navigationFirstColor.rawValue)!, UIColor(named: themeColor.navigationSecondColor.rawValue)!], startPoint: .centerLeft, endPoint: .centerRight)
        }
    }
    
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let numberOfPages = super.viewControllers.count
        if numberOfPages == 2  {
            if currentTabIndex == TabBarTab.Profile.rawValue {
//                if let navigationBar = self.navigationBar as? IGNavigationBar {
//                    navigationBar.setTransparentNavigationBar()
//                }
                return super.popViewController(animated: animated)
            }
            else {
//                self.navigationBar.isHidden = false

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoBackToMainNotificationName), object: nil)
                return super.popViewController(animated: animated)
            }
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
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("TAPPED ON VIEW")
    }

    func configNavigationBar() {
        navigationBar.barStyle = .default
        navigationBar.shadowImage = UIImage()
//        navigationBar.isTranslucent = false
        
//        navigationBar.tintColor = UIColor.white
//        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIImage {
    class func image(from layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size,
                                               layer.isOpaque, UIScreen.main.scale)
        
        defer { UIGraphicsEndImageContext() }
        
        // Don't proceed unless we have context
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
