//
//  QRMainTabbarController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class QRMainTabbarController: UITabBarController {
    
        enum CurrentTabQR {
            case myQR
            case qrScan

        }
        
        internal static var currentTabStatic: CurrentTabQR = .qrScan
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tabBar.barTintColor = UIColor.iGapBars()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            selectedItemTitleMustbeBold()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            selectedItemTitleMustbeBold()
        }
        
        
        override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            selectedItemTitleMustbeBold()
        }
        
        func selectedItemTitleMustbeBold(){
            for item in tabBar.items!{
                if #available(iOS 10.0, *) {
                    item.badgeColor = UIColor.unreadLable()
                }
                if tabBar.selectedItem == item {
                    setCurrentTab(tag: (tabBar.selectedItem?.tag)!)
                    let selectedTitleFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
                    let selectedTitleColor = UIColor.black
                    item.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): selectedTitleFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): selectedTitleColor]), for: UIControl.State.normal)
                } else {
                    let normalTitleFont = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.regular)
                    let normalTitleColor = UIColor(red: 176.0/255.0, green: 224.0/255.0, blue: 230.0/255.0, alpha: 1.0)
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
