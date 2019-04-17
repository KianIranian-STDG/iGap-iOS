//
//  SMTabbarViewController.swift
//  PayGear
//
//  Created by a on 4/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import messages

class SMMainTabBarController: UITabBarController,UITabBarControllerDelegate {
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    var tabBarTopFocusLine:UIView?
    
    public static let packetTabNavigationController = SMNavigationController.buildRTLNavigation()
    public static let qrTabNavigationController = SMNavigationController.buildRTLNavigation()
	public static let messageTabNavigationController = SMNavigationController.buildRTLNavigation()
    public static let serviceTabNavigationController = SMNavigationController.buildRTLNavigation()
    
    public static var currentSubNavNavigation: SMNavigationController = SMMainTabBarController.packetTabNavigationController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        self.setupPages(completion: { b in
        self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.payShort(notification:)), name: Notification.Name(NotificationKeys.NKShortcutSelection), object: nil)
        })
		
		(UIApplication.shared.delegate as! App_SocketService).ss_StartSocket()
    }

    @objc
    func barcode(notification : Notification){
        

    }


    @objc func payShort(notification : AnyObject ){
            let tab = notification.userInfo["tab"]
//            self.setupPages(completion: { b in
//                if b == true {
					selectedIndex = tab as! Int
            		setCurrentTapFocusLine(index: selectedIndex)
					//go to selected page
					let page = notification.userInfo["page"] as! Int
					if selectedIndex == 0 {
						DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(50), execute: {
							(self.viewControllers![self.selectedIndex] as! SMNavigationController).popToRootViewController(animated: false)
							(self.viewControllers![self.selectedIndex].children.first as! SMPacketViewController).gotToSubPage(page: page)
						})
					}
					else {
						DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(50), execute: {
							(self.viewControllers![self.selectedIndex] as! SMNavigationController).popToRootViewController(animated: false)
						})
					}
					
         }
    
    
    func setupPages(completion: (_ result: Bool) -> Void){
        
        let nav = SMNavigationController.buildRTLNavigation()
        
        let packetTab = nav.findViewController(page: .Packet) as! SMPacketViewController
        let qrTab = nav.findViewController(page: .QR) as! SMBarCodeScannerViewController
		let messageTab = nav.findViewController(page: .Message) as! SMMessageViewController
        let serviceTab = nav.findViewController(page: .Service) as! SMServicesViewController
		
		
        qrTab.SMTitle = "qr.tab.title".localized
        qrTab.finishDelegate = packetTab
		
        
        
        SMMainTabBarController.packetTabNavigationController.setRootViewController(vc: packetTab, animated: false)
        SMMainTabBarController.qrTabNavigationController.setRootViewController(vc: qrTab, animated: false)
		SMMainTabBarController.messageTabNavigationController.setRootViewController(vc: messageTab, animated: false)
        SMMainTabBarController.serviceTabNavigationController.setRootViewController(vc: serviceTab, animated: false)
		
        
        SMMainTabBarController.packetTabNavigationController.tabBarItem = UITabBarItem(title: "packet.tab.title".localized , image: UIImage(named: "wallet"), selectedImage: UIImage(named: "selectedWallet"))
        SMMainTabBarController.qrTabNavigationController.tabBarItem = UITabBarItem(title: "qr.tab.title".localized , image: UIImage(named: "qr"), selectedImage: UIImage(named: "selectedQr"))
		SMMainTabBarController.messageTabNavigationController.tabBarItem = UITabBarItem(title: "message.tab.title".localized , image: UIImage(named: "message"), selectedImage: UIImage(named: "message"))
        SMMainTabBarController.serviceTabNavigationController.tabBarItem = UITabBarItem(title: "services.tab.title".localized , image: UIImage(named: "selectedService"), selectedImage: UIImage(named: "selectedService"))
		
        
        self.viewControllers = [
                                SMMainTabBarController.packetTabNavigationController,
                                SMMainTabBarController.qrTabNavigationController
//                                ,SMMainTabBarController.messageTabNavigationController
//                              ,SMMainTabBarController.serviceTabNavigationController
                                ]
        
        
		completion(true)
    }
    
    
    func setupUI(){
        
        self.tabBar.tintColor = SMColor.PrimaryColor
        self.tabBar.backgroundColor = UIColor.clear
        
        
        let attributesNormal = [ NSAttributedString.Key.font: SMFonts.IranYekanBold(11),NSAttributedString.Key.foregroundColor:SMColor.HintTranspatentTextColor]
        let attributesSelected = [ NSAttributedString.Key.font: SMFonts.IranYekanBold(11),NSAttributedString.Key.foregroundColor:SMColor.HintTextColor]
        
        
        for vc in self.viewControllers!{
            
            vc.tabBarItem.setTitleTextAttributes(attributesNormal , for: .normal)
            vc.tabBarItem.setTitleTextAttributes(attributesSelected , for: .selected)
        }
        
        tabBarTopFocusLine = UIView()
        tabBarTopFocusLine?.backgroundColor = SMColor.PrimaryColor
        self.tabBar.addSubview(tabBarTopFocusLine!)
        self.selectedIndex = 1
        self.tabBarController?.selectedIndex = 1
        setCurrentTapFocusLine(index: 1)

    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if selectedViewController == nil{
            return false
        }
        
        if viewController == selectedViewController {
            
            SMMainTabBarController.currentSubNavNavigation.popToRootViewController(animated: true)
            
            return false
        }
        
        
        if let indx = self.viewControllers?.index(of: viewController){
            switch indx {
            case 0:
                SMMainTabBarController.currentSubNavNavigation = SMMainTabBarController.packetTabNavigationController
            
            default:
                SMMainTabBarController.currentSubNavNavigation = SMMainTabBarController.qrTabNavigationController
                
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MAIN_TABBAR_SWITCH"), object: indx)
            SMLog.SMPrint("postnotif \(indx)")
            
            setCurrentTapFocusLine(index: indx)
            
        }else{
            SMMainTabBarController.currentSubNavNavigation = SMMainTabBarController.packetTabNavigationController
        }
        
        
        let fromView = selectedViewController!.view
        let toView = viewController.view
        
        //Just to fix resize issue
        (viewController as! SMNavigationController).navigationBar.frame.origin.y = 20
        
        UIView.transition(from: fromView!, to: toView!, duration: 0.2, options: [.transitionCrossDissolve], completion: nil)
        
        return true
    }
    
    
	public func setCurrentTapFocusLine(index:Int){
		
		let gapBetweenLines = 24
		let tabWidth = Int( Int(UIScreen.main.bounds.width) / (self.viewControllers?.count)!)
		let w = tabWidth - gapBetweenLines
		let x = (tabWidth * index) + (gapBetweenLines / (self.viewControllers?.count)!)
		
		UIView.animate(withDuration: 0.15, animations: {
			self.tabBarTopFocusLine?.frame = CGRect(x: x, y: 0, width: w, height: 2)
		})
	}
}
