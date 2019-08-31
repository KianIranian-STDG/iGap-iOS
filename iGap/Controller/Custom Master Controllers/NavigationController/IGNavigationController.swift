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

class IGNavigationController: UINavigationController, UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.topItem?.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 50), for: UIBarMetrics.default)
//        configNavigationBar()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        changeGradientImage()
    }
    override func popViewController(animated: Bool) -> UIViewController? {
        let numberOfPages = super.viewControllers.count
        if numberOfPages == 2  {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoBackToMainNotificationName), object: nil)
            return super.popViewController(animated: animated)

        }
            
        else {
            return super.popViewController(animated: animated)

        }

    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    let orangeGradient = [UIColor(rgb: 0xB9E244), UIColor(rgb: 0x41B120)]
    let orangeGradientLocation = [0.0, 1.0]
    
    lazy var colorView = { () -> UIView in
        let view = UIView()
        view.isUserInteractionEnabled = false
        navigationBar.addSubview(view)
        navigationBar.sendSubviewToBack(view)
        return view
    }()
    lazy var colorViewNavBar = { () -> UIView in
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 10)
        return view
    }()
    lazy var searchViewNavBar = { () -> UIView in
        let view = UIView()
        view.isUserInteractionEnabled = true
        
        
        view.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMinYCorner], radius: 10)
        
        view.backgroundColor = .white
        return view
    }()

    
    func changeGradientImage() {
        // 1 status bar
        colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: navigationBar.frame.width, height: UIApplication.shared.statusBarFrame.height)
        
        // 2
        colorView.backgroundColor = UIColor(patternImage: gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: navigationBar).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: navigationBar.frame.size.width/2, bottom: 0, right: navigationBar.frame.size.width/2), resizingMode: .stretch))
 
        // 2.5
        navigationBar.addSubview(colorView)
        
        //2.6
        colorViewNavBar.frame = CGRect(x: 0, y: 0, width: navigationBar.frame.width, height: navigationBar.frame.height)
        
        //2.7
        colorViewNavBar.backgroundColor = UIColor(patternImage: gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: navigationBar).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: navigationBar.frame.size.width/2, bottom: 0, right: navigationBar.frame.size.width/2), resizingMode: .stretch))
        
        searchViewNavBar.backgroundColor = .red
        self.navigationBar.insertSubview(colorViewNavBar, at: 1)
    }

    public func addSearchBar(state : Bool) {
        if state {
            self.colorViewNavBar.addSubview(searchViewNavBar)
            searchViewNavBar.snp.makeConstraints { (make) in
                make.width.equalTo(self.navigationBar.frame.size.width - 100)
                make.height.equalTo(self.navigationBar.frame.size.height / 2)
                make.centerX.equalTo(self.navigationBar.snp.centerX)
                make.centerY.equalTo(self.navigationBar.snp.bottom)
            }
        }
        else {
            
            self.searchViewNavBar.removeFromSuperview()
        }
        
    }
    
    func configNavigationBar() {
        navigationBar.barStyle = .default
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    func gradientImage(withColours colours: [UIColor], location: [Double], view: UIView) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = location as [NSNumber]
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 2
        
//        shadowView.layer.insertSublayer(shadowLayer, at: 0)

        gradient.cornerRadius = view.layer.cornerRadius
        return UIImage.image(from: gradient) ?? UIImage()
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
