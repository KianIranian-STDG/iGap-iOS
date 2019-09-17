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

class IGTabBarStickerController: UITabBarController, UIGestureRecognizerDelegate{
    
    var stickerCategories: [StickerCategory]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView()
        view.frame = self.tabBar.bounds

        view.backgroundColor = UIColor(patternImage: gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: self.tabBar).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: self.tabBar.frame.size.width/2, bottom: 0, right: self.tabBar.frame.size.width/2), resizingMode: .stretch))
        

        view.roundCorners(corners: [.layerMaxXMinYCorner,.layerMinXMinYCorner], radius: 10)
        view.layer.borderWidth = 1
        view.layer.borderColor =  UIColor.tabbarBGColor().cgColor
        self.tabBar.insertSubview(view, at: 0)
        initNavigationBar()
    }
    func gradientImage(withColours colours: [UIColor], location: [Double], view: UIView) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = location as [NSNumber]
        gradient.cornerRadius = view.layer.cornerRadius
        return UIImage.image(from: gradient) ?? UIImage()
    }
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "STICKER_CATEGORY".localizedNew, width: 200)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var controllers: [UIViewController] = []
        for category in stickerCategories {
            let tabBarItem = UITabBarItem(title: category.name, image: nil, selectedImage: nil)
            tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -11)
            
            let stickerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: IGStickerViewController.self)) as! IGStickerViewController
            stickerController.stickerPageType = .CATEGORY
            stickerController.stickerCategoryId = category.id
            stickerController.tabBarItem = tabBarItem
            controllers.append(stickerController)
        }
        self.viewControllers = controllers
        
        selectedItemTitleMustbeBold()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                let selectedTitleFont = UIFont.igFont(ofSize: 15, weight: .bold)
                item.setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont], for: UIControl.State.normal)
            } else {
                let normalTitleFont = UIFont.igFont(ofSize: 12, weight: .regular)
                item.setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont], for: UIControl.State.normal)
            }
            if #available(iOS 10.0, *) {
                self.tabBar.unselectedItemTintColor = UIColor.tabbarTextUnselectedColor()
            }
        }
    }
    
    
    static func openStickerCategories() {
        IGGlobal.prgShow()
        IGApiSticker.shared.stickerCategories { categories in
            IGGlobal.prgHide()
            let tabbarSticker = IGTabBarStickerController.instantiateFromAppStroryboard(appStoryboard: .Main)
            tabbarSticker.stickerCategories = categories
            UIApplication.topViewController()?.navigationController!.pushViewController(tabbarSticker, animated: true)
        }
    }
}
