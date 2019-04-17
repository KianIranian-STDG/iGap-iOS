//
//  SMNavigationController.swift
//  PayGear
//
//  Created by Amir Soltani on 4/8/18.
//  Copyright © 2018 Samsson. All rights reserved.
//

import UIKit


protocol SMNavigationControllerDelegate {
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)
}

extension SMNormalWithDrawViewController {
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		
	}
}
class SMNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    public enum SMNavigationStyle : Int {
        case NoStyle              = 0
        case SMMainPageStyle      = 1
        case SMSignupStyle        = 2
        
    }
	
	
	var duringPushAnimation : Bool!
	
	public var smDelegate : SMNavigationControllerDelegate! {
		didSet {
			
		}
	}
	
    public static var shared: SMNavigationController = SMNavigationController.buildRTLNavigation()
    
    public static func buildRTLNavigation() -> SMNavigationController {
        
        let nav = SMNavigationController()
        nav.view.semanticContentAttribute = .forceLeftToRight
        return nav
    }
    
    private var gradientColors : [UIColor] = [UIColor(netHex: 0x2196f3), UIColor(netHex: 0x0d47a1)]
    private var backgroundColor : UIColor = SMColor.PrimaryColor
    var gradient : CAGradientLayer?
    
    var leftBarButton: [UIBarButtonItem]?
    var style: SMNavigationStyle = .SMMainPageStyle {
        didSet {
            self.customizeUI()
        }
    }
	
	override func viewDidLoad() {
		 super.viewDidLoad()
		
		self.delegate = self
		self.interactivePopGestureRecognizer?.delegate = self
	}
    override func viewWillAppear(_ animated: Bool) {
        if !self.viewControllers[0].isKind(of: SMMainTabBarController.self){
        self.customizeUI()
            if style == .SMMainPageStyle {
                self.backgroundColor = SMColor.PrimaryColor
                self.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationBar.shadowImage = UIImage()
                self.navigationBar.isTranslucent = true
                self.navigationBar.backgroundColor = UIColor.clear
                var height = CGFloat.init(0)
                if  UIApplication.shared.statusBarFrame.height == 40 {
                     height = UIApplication.shared.statusBarFrame.height - 20.0}
//                else if UIApplication.shared.statusBarFrame.height == 64 {
//                    height = UIApplication.shared.statusBarFrame.height - 44.0}
                else {
                    height = UIApplication.shared.statusBarFrame.height
                }
                gradient = CAGradientLayer(frame:
                    CGRect(x: 0, y: 0, width: UIApplication.shared.statusBarFrame.width, height: height + self.navigationBar.frame.height),colors :
                    gradientColors)
                gradient?.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient?.endPoint = CGPoint(x: 1.0, y: 0.5)
                self.view.layer.insertSublayer(gradient!, at : 1)
                
            }
        }
    }

    
    private func customizeUI() {

        switch style {
        case .SMMainPageStyle:
            
            self.gradientColors = [UIColor(netHex: 0x2196f3), UIColor(netHex: 0x0d47a1)]
              self.view.backgroundColor = UIColor.clear
        case .SMSignupStyle:
            self.gradientColors = [.clear, .clear]
            self.backgroundColor = .clear
            
        default:
            self.gradientColors = [UIColor(netHex: 0x2196f3), UIColor(netHex: 0x0d47a1)]
            self.backgroundColor = SMColor.PrimaryColor
        }
    }
	
    func setRootViewController(page:SMPages) {
        self.setRootViewController(page: page, animated: true)
    }
    
    func setRootViewController(page:SMPages,animated:Bool) {
        
        self.setRootViewController(vc: findViewController(page: page),animated: animated)
    }
    
    func setRootViewController(vc:UIViewController) {
        self.setRootViewController(vc: vc, animated: true)
    }
    
    func setRootViewController(vc:UIViewController,animated:Bool) {
        
        if vc.isKind(of: SMMainTabBarController.self) || vc.isKind(of: SMIntroViewController.self) {
            SMNavigationController.shared.navigationBar.isHidden = true
            gradient?.removeFromSuperlayer()
            self.view.layoutIfNeeded()
        }
        
        self.setViewControllers([vc], animated: true)
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        btn.addTarget(self, action: #selector(self.pressedBack), for: .touchUpInside)
        btn.imageView?.tintColor = UIColor.white
        btn.setImage(UIImage(named: "arrow_back_white")!.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 42)
        
        self.leftBarButton = [UIBarButtonItem(customView: btn)]
        
        self.addBackButton()
    }
    

    @objc func pressedBack(){
        self.popViewController(animated: true)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		DispatchQueue.main.async {
			self.duringPushAnimation = true
			super.pushViewController(viewController, animated: true)
			self.addBackButton()
		}
    }
    
    func pushNewViewController(page:SMPages) {
		
		DispatchQueue.main.async {
			self.duringPushAnimation = true
        	self.pushNewViewController(page: page, animated: true)
			self.addBackButton()
		}
    }
    
    func pushNewViewController(page:SMPages,animated:Bool) {
        let viewC = self.findViewController(page: page)
        
        
        if viewC.isKind(of: SMMainTabBarController.self){
            for vc in self.viewControllers{
                if vc.isKind(of: SMMainTabBarController.self){
                    SMNavigationController.shared.navigationBar.isHidden = true
                    break
                }
            }
        }else{
            SMNavigationController.shared.navigationBar.isHidden = true
        }
        
        viewC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
        viewC.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: UIView())
		
		DispatchQueue.main.async {
			self.duringPushAnimation = true
        	super.pushViewController(viewC, animated: true)
			self.addBackButton()
		}
		
    }
    
    func findViewController(page:SMPages) -> UIViewController {
        let identifier = page.rawValue.components(separatedBy: "@")[0]
        let nibName = page.rawValue.components(separatedBy: "@")[1]
        
        let story = UIStoryboard(name: nibName, bundle: self.nibBundle)
        
        return story.instantiateViewController(withIdentifier: identifier)
    }

    
    func addBackButton(){
        
        for i in 0..<self.viewControllers.count {
        
            if i > 0{
                self.viewControllers[i].navigationItem.leftBarButtonItems = self.leftBarButton
            }
        }
    }
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		
		self.duringPushAnimation = false;
		if let delegate = smDelegate {
			delegate.navigationController(navigationController, didShow: viewController, animated: animated)
		}
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer == self.interactivePopGestureRecognizer {
			return (self.viewControllers.count > 1 && !self.duringPushAnimation)
		}
		else {
			return true
		}
	}
	
//	func changeLanguageOfSubViews(_ language: String) {
//		
//		for i in 0..<self.viewControllers.count {
//			
//			if i > 0{
//				self.viewControllers[i].changeLanguage(language)
//			}
//		}
//	}

}
