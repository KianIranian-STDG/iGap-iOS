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
var currentTabIndex: Int! = 2

enum TabBarTab : Int {
    case Contact = 0
    case Call = 1
    case Recent = 2
    case Dashboard = 3
    case Profile = 4
}

class IGTabBarController: UITabBarController {
    
    internal static var currentTabStatic: TabBarTab = .Recent
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    private func initView() {
        
        self.delegate = self
        
        self.tabBar.barTintColor = UIColor(named: themeColor.tabBarColor.rawValue)
        self.tabBar.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.tabBar.layer.cornerRadius = abs(CGFloat(Int(12 * 100)) / 100)
        self.tabBar.clipsToBounds = true
        self.tabBar.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.view.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        
        setTabBarItems()
        self.selectedIndex = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {

        for item in tabBar.items! {
            if #available(iOS 10.0, *) {
                item.badgeColor = UIColor.unreadLable()
//                item.badgeValue = "2".inLocalizedLanguage()
                item.badgeValue = item.badgeValue?.inLocalizedLanguage()
                item.setBadgeTextAttributes([
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)
                    ], for: .normal)
            }
        }
    }
    
    public func selectTabBar(tabBar: UITabBar, didSelect item: TabBarTab) {
        for item in tabBar.items! {
            if #available(iOS 10.0, *) {
                item.badgeColor = UIColor.unreadLable()
            }
        }
        let navigationControllerr = self.navigationController as! IGNavigationController
        
        switch item {
        case .Contact:
            navigationControllerr.navigationBar.isHidden = false
            //            navigationControllerr.addSearchBar(state: "True")
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.searchController = nil
            
            navigationControllerr.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.isTranslucent = false
            
            currentTabIndex = TabBarTab.Contact.rawValue
            break
        case .Call:
            navigationControllerr.navigationBar.isHidden = false
            //            navigationControllerr.addSearchBar(state: "False")
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.searchController = nil
            navigationControllerr.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.isTranslucent = false
            
            currentTabIndex = TabBarTab.Call.rawValue
            
            break
        case .Recent:
            navigationControllerr.navigationBar.isHidden = false
            //            navigationControllerr.addSearchBar(state: "True")
            navigationControllerr.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.isTranslucent = false
            
            currentTabIndex = TabBarTab.Recent.rawValue
            
            break
        case .Dashboard:
            navigationControllerr.navigationBar.isHidden = false
            //            navigationControllerr.addSearchBar(state: "False")
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.searchController = nil
            navigationControllerr.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.isTranslucent = false
            
            currentTabIndex = TabBarTab.Dashboard.rawValue
            
            break
        case .Profile:
//            navigationControllerr.navigationBar.isHidden = true
//            navigationControllerr.addSearchBar(state: "False")
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.searchController = nil
//            navigationControllerr.navigationBar.shadowImage = UIImage()
//            navigationControllerr.navigationBar.isTranslucent = true
//            self.navigationController?.navigationBar.shadowImage = UIImage()
            
//            navigationControllerr.navigationBar.barTintColor = UIColor.redColor()
//            navigationControllerr.navigationBar.isTranslucent = false
//            navigationBar.setBackgroundImage(UIImage(), for: .default)
//            navigationBar.shadowImage = UIImage()
            
            currentTabIndex = TabBarTab.Profile.rawValue
            
            break
        }
    }
    
    func setTabBarItems() {
        let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
        myTabBarItem1.image = UIImage(named: "ig-Phone-Book-Off_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.selectedImage = UIImage(named: "ig-Phone-Book-on_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.title = ""
        myTabBarItem1.tag = 0
        myTabBarItem1.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        
        let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
        myTabBarItem2.image = UIImage(named: "ig-Call-List_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem2.selectedImage = UIImage(named: "ig-Call-List-on_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem2.title = ""
        myTabBarItem2.tag = 1
        myTabBarItem2.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        
        let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
        myTabBarItem3.image = UIImage(named: "ig-Room-List-Off_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem3.selectedImage = UIImage(named: "ig-Room-List-on_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem3.title = ""
        myTabBarItem3.tag = 2
        
        myTabBarItem3.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let myTabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
        myTabBarItem4.image = UIImage(named: "ig-Dashboard-off_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem4.selectedImage = UIImage(named: "ig-Discovery-on_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem4.title = ""
        myTabBarItem4.tag = 3
        
        myTabBarItem4.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let myTabBarItem5 = (self.tabBar.items?[4])! as UITabBarItem
        myTabBarItem5.image = UIImage(named: "ig-Settings-off_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem5.selectedImage = UIImage(named: "ig-Settings-on_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem5.title = ""
        myTabBarItem5.tag = 4
        
        myTabBarItem5.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
    }

    
    private func setCurrent(tab: TabBarTab) {
        switch tab {
        case .Contact:
            IGTabBarController.currentTabStatic = .Contact
            break
        case .Call:
            IGTabBarController.currentTabStatic = .Call
            break
        case .Recent:
            IGTabBarController.currentTabStatic = .Recent
            break
        case .Dashboard:
            IGTabBarController.currentTabStatic = .Dashboard
            break
        case .Profile:
            IGTabBarController.currentTabStatic = .Profile
            break
        }
    }
}

extension IGTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.selectTabBar(tabBar: tabBar, didSelect: TabBarTab(rawValue: tabBarController.selectedIndex) ?? .Recent)
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
