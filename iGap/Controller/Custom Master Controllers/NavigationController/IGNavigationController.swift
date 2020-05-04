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
import SwiftEventBus

class IGNavigationController: UINavigationController, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.semanticContentAttribute = .forceLeftToRight

        manageTheme()
        setNavigationGradient()
        
        configNavigationBar()
        SwiftEventBus.onMainThread(self, name: "initTheme") { result in
            self.setNavigationGradient()

        }
    }
    private func manageColorSet(mode: String = "IGAPClassic") {
        let currentColorSet = UserDefaults.standard.string(forKey: "CurrentColorSet") ?? "IGAPDefaultColor"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        if mode == "IGAPClassic" {
            switch currentColorSet {
            default:
                DefaultColorSetManager.currentColorSet = DefaultColorSet()
                SwiftEventBus.post("initTheme")
                break
            }
            
        } else if mode == "IGAPDay" {
            
            switch currentColorSetLight {
            case "IGAPBlue" :
                DayColorSetManager.currentColorSet = BlueColorSet()
                break
            case "IGAPTorquoise" :
                DayColorSetManager.currentColorSet = TorquoiseColorSet()
                break
                
            case "IGAPGreen" :
                DayColorSetManager.currentColorSet = GreenColorSet()
                break
                
            case "IGAPPink" :
                DayColorSetManager.currentColorSet = PinkColorSet()
                break
                
            case "IGAPOrange" :
                DayColorSetManager.currentColorSet = OrangeColorSet()
                break
                
            case "IGAPPurple" :
                DayColorSetManager.currentColorSet = PurpleColorSet()
                break
                
            case "IGAPRed" :
                DayColorSetManager.currentColorSet = RedColorSet()
                break
                
            case "IGAPGold" :
                DayColorSetManager.currentColorSet = GoldColorSet()
                break
                
            case "IGAPLightGray" :
                DayColorSetManager.currentColorSet = LightGrayColorSet()
                break
                
            default: break
            }
            SwiftEventBus.post("initTheme")

        } else {
            
            switch currentColorSetDark {
            case "IGAPBlue" :
                NightColorSetManager.currentColorSet = BlueColorSetNight()
                break
            case "IGAPTorquoise" :
                NightColorSetManager.currentColorSet = TorquoiseColorSetNight()
                break
                
            case "IGAPGreen" :
                NightColorSetManager.currentColorSet = GreenColorSetNight()
                break
                
            case "IGAPPink" :
                NightColorSetManager.currentColorSet = PinkColorSetNight()
                break
                
            case "IGAPOrange" :
                NightColorSetManager.currentColorSet = OrangeColorSetNight()
                break
                
            case "IGAPPurple" :
                NightColorSetManager.currentColorSet = PurpleColorSetNight()
                break
                
            case "IGAPRed" :
                NightColorSetManager.currentColorSet = RedColorSetNight()
                break
                
            case "IGAPGold" :
                NightColorSetManager.currentColorSet = GoldColorSetNight()
                break
                
            case "IGAPLightGray" :
                NightColorSetManager.currentColorSet = LightGrayColorSetNight()
                break
                
            default: break
            }
            SwiftEventBus.post("initTheme")

        }
    }
    private func manageTheme() {
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        
        switch currentTheme {
        case "IGAPClassic" :
            ThemeManager.currentTheme = ClassicTheme()
            manageColorSet(mode: "IGAPClassic")
        case "IGAPDay" :
            ThemeManager.currentTheme = DayTheme()
            manageColorSet(mode: "IGAPDay")
        case "IGAPNight" :
            ThemeManager.currentTheme = NightTheme()
            manageColorSet(mode: "IGAPNight")
        default:
            ThemeManager.currentTheme = ClassicTheme()
            manageColorSet(mode: "IGAPClassic")
        }
        
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
//                    navBar.setTransparentNavigationBar()
                } else {
                    self.setNavigationGradient()
                }
            }
        }
    }
    
    private func setNavigationGradient() {
        if let navigationBar = self.navigationBar as? IGNavigationBar {
            navigationBar.setGradientBackground(colors: [ThemeManager.currentTheme.NavigationFirstColor, ThemeManager.currentTheme.NavigationSecondColor], startPoint: .centerLeft, endPoint: .centerRight)
        }
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let numberOfPages = super.viewControllers.count
        if numberOfPages == 2  {
            if currentTabIndex == TabBarTab.Profile.rawValue {
                return super.popViewController(animated: animated)
            } else {
                SwiftEventBus.post(EventBusManager.changeDirection)
                UIApplication.topViewController()?.view.endEditing(true)
                return super.popViewController(animated: animated)
            }
        } else {
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
        print("TAPPED ON VIEW")
    }

    func configNavigationBar() {
        navigationBar.barStyle = .default
        navigationBar.shadowImage = UIImage()
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
