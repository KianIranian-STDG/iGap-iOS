//
//  SMBottomButtonViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/17/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit




class SMBottomButtonViewController: UIViewController {
    
    let background = UIView()
    let blackBar = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    func setupUI(){
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onBackTapped(gesture:))))
        
        self.background.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(background)
        self.view.sendSubviewToBack(background)
        
        
     
        
        self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        if #available(iOS 11.0, *) {
            self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        } else {
             self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        }
        self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        
    }
    
    @objc func onBackTapped(gesture:UITapGestureRecognizer){
        
        self.view.endEditing(true)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

            let frm = (self.view.window?.frame)!

            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.tabBarController?.tabBar.alpha = 1.0
                self.view.window?.frame = CGRect(x: 0, y: 0, width: frm.width, height: frm.height)
                blackBar.frame = CGRect(x: 0, y: 0, width: blackBar.frame.width, height: UIApplication.shared.statusBarFrame.height)
                blackBar.alpha = 1
                blackBar.removeFromSuperview()
            } else {
                let bottomGap = endFrame?.size.height ?? 0.0
                self.view.window?.frame = CGRect(x: 0, y: -bottomGap, width: frm.width, height: frm.height )
                blackBar.frame = CGRect(x: 0, y: bottomGap, width: blackBar.frame.width, height: UIApplication.shared.statusBarFrame.height)
                blackBar.backgroundColor = SMColor.PrimaryColor
                self.tabBarController?.tabBar.alpha = 0.0
                blackBar.alpha = 0
                SMMainTabBarController.currentSubNavNavigation.view.addSubview(blackBar)
            }


            SMLog.SMPrint("keyboard anim \(duration)")

            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.blackBar.alpha = (self.blackBar.alpha == 0) ? 1 : 0
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}
