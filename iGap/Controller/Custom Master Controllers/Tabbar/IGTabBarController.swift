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
        case Contact
        case Call
        case Recent
        case Dashboard
        case Profile

    }
    
    internal static var currentTabStatic: CurrentTab = .Recent
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        
    }
    private func initView() {
        
        UITabBar.appearance().backgroundImage = UIImage.colorForNavBar(color: .white)
        UITabBar.appearance().shadowImage = UIImage.colorForNavBar(color: .clear)
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.layer.cornerRadius = 10
        setTabBarItems()
        self.selectedIndex = 2
        let view = UIView()
        view.backgroundColor = UIColor.tabbarBGColor()
        view.frame = self.tabBar.bounds
        view.roundCorners(corners: [.layerMaxXMinYCorner,.layerMinXMinYCorner], radius: 10)
        view.layer.borderWidth = 1
        view.layer.borderColor =  UIColor.tabbarBGColor().cgColor
        self.tabBar.insertSubview(view, at: 0)
        let navigationControllerr = self.navigationController as! IGNavigationController
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        for item in tabBar.items!{
            if #available(iOS 10.0, *) {
                item.badgeColor = UIColor.unreadLable()
            }
        }

    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("ITEMSELECTED", item.tag)
        
        for item in tabBar.items!{
            if #available(iOS 10.0, *) {
                item.badgeColor = UIColor.unreadLable()
            }
        }
        let navigationControllerr = self.navigationController as! IGNavigationController
        
        switch item.tag {
        case 0:
//            navigationControllerr.addSearchBar(state: "False")
            
            break
        case 1:
//            navigationControllerr.addSearchBar(state: "False")
            
            break
        case 2:
//            navigationControllerr.addSearchBar(state: "True")
            
            break
        case 3:
//            navigationControllerr.addSearchBar(state: "False")
            
            break
        case 4:
//            navigationControllerr.addSearchBar(state: "False")
            
            break
        default:
            break
        }
        
        //        selectedItemTitleMustbeBold()
    }
    
    func setTabBarItems() {
        let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
        myTabBarItem1.image = UIImage(named: "ig-Phone-Book-Off_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.selectedImage = UIImage(named: "ig-Phone-Book-On_25")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
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
