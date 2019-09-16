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
var isActive = true
var viewSearchBarRecent = UIView()
var btnSearchBarRecent = UIButton()

var searchbarRecentWidth = CGFloat()

class IGNavigationController: UINavigationController, UINavigationBarDelegate,UISearchBarDelegate {
    var searchBarRecent = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.topItem?.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 50), for: UIBarMetrics.default)
        searchBarRecent.endEditing(true)
        
        configNavigationBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBarRecent.endEditing(true)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        changeGradientImage()
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let numberOfPages = super.viewControllers.count
        if numberOfPages == 2  {
            if currentTabIndex == 4 {
                
                
                self.navigationBar.isHidden = true
                return super.popViewController(animated: animated)
                
            }
            else {
                self.navigationBar.isHidden = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoBackToMainNotificationName), object: nil)
//                addSearchBar(state: "True")
                return super.popViewController(animated: animated)
                
            }
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
//        view.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 10)
        return view
    }()
    lazy var searchViewNavBar = { () -> UIView in
        let view = UIView()
        view.isUserInteractionEnabled = false
        
        view.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMinYCorner], radius: 10)
        
        view.backgroundColor = .white
        return view
    }()

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideKeyboardWhenTappedAround()
        searchBarRecent.endEditing(true)
        
    }
    
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

        if isActive {
//            addSearchBar(state: "True")
            isActive = false
        }

    }


    public func addSearchBar(state : String) {
        if state == "True" {
            searchBarRecent.barStyle = .default
            searchBarRecent.isTranslucent = false
            searchBarRecent.barTintColor = UIColor.clear
            searchBarRecent.backgroundImage = UIImage()
            searchBarRecent.delegate = self
            searchbarRecentWidth = self.navigationBar.frame.size.width - 200
            
            self.navigationBar.addSubview(searchBarRecent)
            searchBarRecent.snp.makeConstraints { (make) in
                
                make.left.equalTo(self.navigationBar.snp.left).offset((self.navigationBar.bounds.width)/4)
                make.right.equalTo(self.navigationBar.snp.right).offset(((self.navigationBar.bounds.width)/4) * -1)
                make.height.equalTo(50)
                make.centerX.equalTo(self.navigationBar.snp.centerX)
                make.centerY.equalTo(self.navigationBar.snp.bottom)
            }
            
            if let textfield = searchBarRecent.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.black
                textfield.font = UIFont.igFont(ofSize: 15)
                if SMLangUtil.loadLanguage() == "fa" {
                    textfield.semanticContentAttribute = .forceRightToLeft
                }
                else {
                    textfield.semanticContentAttribute = .forceLeftToRight
                    
                }
            }
            let image = self.getImageWithColor(color: UIColor.white, size: CGSize(width: 20, height: 30))
            searchBarRecent.setSearchFieldBackgroundImage(image, for: .normal)
            
        }
        else if state == "False" {
            searchBarRecent.removeFromSuperview()
            searchBarRecent.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
        else {
            
        }
        
    }
    
    public func minimizeSearchBar(state: Bool) {
        var newWidth:CGFloat = self.navigationBar.frame.size.width - 150
        var oldWidth:CGFloat = searchBarRecent.frame.width
        var totalChangeWidth:CGFloat = newWidth - oldWidth
        
        if state {
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                
                self.searchBarRecent.snp.updateConstraints { (make) in
                    make.left.equalTo(self.navigationBar.snp.left).offset((self.navigationBar.bounds.width)/5)
                    make.right.equalTo(self.navigationBar.snp.right).offset(((self.navigationBar.bounds.width)/5) * -1)
                    make.height.equalTo(50)
                    make.centerX.equalTo(self.navigationBar.snp.centerX)
                    make.centerY.equalTo(self.navigationBar.snp.bottom)
                }
                
            }, completion: { (finished: Bool) in
                self.searchBarRecent.placeholder = "PLACE_HOLDER_SEARCH".localizedNew
            })
            
        }
        else {
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                
                self.searchBarRecent.snp.updateConstraints { (make) in
                    make.left.equalTo(self.navigationBar.snp.left).offset((self.navigationBar.bounds.width)/4)
                    make.right.equalTo(self.navigationBar.snp.right).offset(((self.navigationBar.bounds.width)/4) * -1)
                    make.height.equalTo(50)
                    make.centerX.equalTo(self.navigationBar.snp.centerX)
                    make.centerY.equalTo(self.navigationBar.snp.bottom)
                }
                
            }, completion: { (finished: Bool) in
                self.searchBarRecent.placeholder = ""
            })
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        minimizeSearchBar(state: false)
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("ENDED")
        minimizeSearchBar(state: false)
        
    }
    
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 50.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        path.fill()
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("TAPPED ON VIEW")
    }
    
    func addsearchBarToSearchView(state: Bool) {
        if state {
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
