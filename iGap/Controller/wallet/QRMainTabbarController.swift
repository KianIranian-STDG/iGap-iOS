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

class QRMainTabbarController: UITabBarController {
    
        enum CurrentTabQR {
            case myQR
            case qrScan

        }
        
        internal static var currentTabStatic: CurrentTabQR = .qrScan
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tabBar.barTintColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
            tabBar.items![0].title = "SETTING_PAGE_QRCODE_SCANNER".localizedNew
            tabBar.items![1].title = "MY_QR".localizedNew
        }
        
        override func viewWillAppear(_ animated: Bool) {
            selectedItemTitleMustbeBold()
            tabBar.items![0].title = "SETTING_PAGE_QRCODE_SCANNER".localizedNew
            tabBar.items![1].title = "MY_QR".localizedNew
        }
        
        override func viewDidAppear(_ animated: Bool) {
            selectedItemTitleMustbeBold()
            tabBar.items![0].title = "SETTING_PAGE_QRCODE_SCANNER".localizedNew
            tabBar.items![1].title = "MY_QR".localizedNew
        }
        
        override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            selectedItemTitleMustbeBold()
            tabBar.items![0].title = "SETTING_PAGE_QRCODE_SCANNER".localizedNew
            tabBar.items![1].title = "MY_QR".localizedNew
        }
        
        func selectedItemTitleMustbeBold(){
            for item in tabBar.items!{
                if #available(iOS 10.0, *) {
                    item.badgeColor = UIColor(named: themeColor.tabbarLabelColor.rawValue)
                }
                if tabBar.selectedItem == item {
                    setCurrentTab(tag: (tabBar.selectedItem?.tag)!)
                    let selectedTitleFont = UIFont.igFont(ofSize: 12, weight: .bold)
                    let selectedTitleColor = UIColor.black
                    item.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): selectedTitleFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): selectedTitleColor]), for: UIControl.State.normal)
                } else {
                    let normalTitleFont = UIFont.igFont(ofSize: 12, weight: .regular)
                    let normalTitleColor = UIColor.white
                    item.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): normalTitleFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): normalTitleColor, convertFromNSAttributedStringKey(NSAttributedString.Key.backgroundColor): UIColor.black]), for: UIControl.State.normal)
                }
            }
            if #available(iOS 10.0, *) {
                self.tabBar.unselectedItemTintColor = UIColor.white
            }
        }
        
        private func setCurrentTab(tag: Int){
            switch tag {
                
            case 0:
                QRMainTabbarController.currentTabStatic = .myQR
                return
                
            case 1:
                QRMainTabbarController.currentTabStatic = .qrScan
                return
                
           
            default:
                QRMainTabbarController.currentTabStatic = .qrScan
                return
            }
        }
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
        guard let input = input else { return nil }
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
        return input.rawValue
}
