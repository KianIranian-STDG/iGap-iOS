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

class IGTabBarController: UITabBarController {
    
    enum CurrentTab {
        case Recent
        case Dashboard
        case Call
    }
    
    internal static var currentTabStatic: CurrentTab = .Recent
    
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
                let selectedTitleFont = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.bold)
                item.setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont], for: UIControl.State.normal)
            } else {
                let normalTitleFont = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.medium)
                item.setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont], for: UIControl.State.normal)
            }
            if #available(iOS 10.0, *) {
                self.tabBar.unselectedItemTintColor = UIColor.tabbarUnselectedColor()
            }
        }
    }
    
    private func setCurrentTab(tag: Int){
        switch tag {
            
        case 0:
            IGTabBarController.currentTabStatic = .Recent
            return
            
        case 1:
            IGTabBarController.currentTabStatic = .Dashboard
            return
            
        case 2:
            IGTabBarController.currentTabStatic = .Call
            return
            
        default:
            IGTabBarController.currentTabStatic = .Recent
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
