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
    }

    
    private func customizeUI() {
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
    }
    

    @objc func pressedBack(){
        self.popViewController(animated: true)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
    }
    
    func pushNewViewController(page:SMPages) {
        
    }
    
    func pushNewViewController(page:SMPages,animated:Bool) {
    }
    
    func findViewController(page:SMPages) -> UIViewController {
        let identifier = page.rawValue.components(separatedBy: "@")[0]
        let nibName = page.rawValue.components(separatedBy: "@")[1]
        
        let story = UIStoryboard(name: nibName, bundle: self.nibBundle)
        
        return story.instantiateViewController(withIdentifier: identifier)
    }

    
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		
		self.duringPushAnimation = false;
		if let delegate = smDelegate {
			delegate.navigationController(navigationController, didShow: viewController, animated: animated)
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
