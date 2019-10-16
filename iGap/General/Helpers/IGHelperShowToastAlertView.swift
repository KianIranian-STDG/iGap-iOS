//
//  IGHelperShowToastAlertView.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 10/15/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import IGProtoBuff
import RealmSwift
// IMPORTANT TODO - convert current class to builder
enum helperToastType : Int {
    case alert = 0
    case success = 1
}


class IGHelperShowToastAlertView {
    var tempTimer : Int = 0
    var counter : Timer!
    var popView : UIView!
    let window = UIApplication.shared.keyWindow
    
    static let shared = IGHelperShowToastAlertView()
    
    func showPopAlert(view: UIViewController? = nil,innerView: UIView? = nil,  message: String? = nil, time: CGFloat! = 2.0 , type: helperToastType! = helperToastType.alert ) {
        DispatchQueue.main.async {
            var alertView = view
            if alertView == nil {
                alertView = UIApplication.topViewController()
            }
            self.popView = UIView()
            self.popView.tag = 202
            self.popView.backgroundColor = UIColor(named : themeColor.backgroundColor.rawValue)
            self.popView.layer.cornerRadius = 10
            
            switch type {
            case .alert :
                self.popView.layer.borderColor = (UIColor(named : themeColor.labelColor.rawValue)?.cgColor)
            case .success :
                self.popView.layer.borderColor = (UIColor.iGapGreen().cgColor)
            default :
                break
            }
            self.popView.layer.borderWidth = 1.0
            self.popView.alpha = 0.0
            UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionFlipFromLeft, animations: {

                self.popView.alpha = 1.0
                alertView?.view.addSubview(self.popView)
                self.popView.translatesAutoresizingMaskIntoConstraints = false
                self.popView.heightAnchor.constraint(equalToConstant: 40).isActive = true
                self.popView.rightAnchor.constraint(equalTo: alertView!.view.rightAnchor, constant: -10).isActive = true
                self.popView.leftAnchor.constraint(equalTo: alertView!.view.leftAnchor, constant: 20).isActive = true
                self.popView.bottomAnchor.constraint(equalTo: innerView!.topAnchor, constant: -5).isActive = true
                self.popView.layoutIfNeeded()
            },
                           completion: {(value: Bool) in
            })
            
            
            
            
            
            let lblMessage = UILabel()
            let lblIcon = UILabel()
            lblIcon.textColor = UIColor(named : themeColor.labelColor.rawValue)
            lblMessage.textColor = UIColor(named : themeColor.labelColor.rawValue)
            lblIcon.font = UIFont.iGapFonticon(ofSize: 20)
            lblIcon.textAlignment = .center
            lblMessage.textAlignment = lblMessage.localizedNewDirection
            lblMessage.font = UIFont.igFont(ofSize: 15,weight : .light)
            lblMessage.text = message
            switch type {
            case .alert :
                lblIcon.text = ""
            case .success :
                lblIcon.text = ""
            default :
                break
                
            }
            
            
            self.popView.addSubview(lblIcon)
            self.popView.addSubview(lblMessage)
            
            //creat icon label
            lblIcon.translatesAutoresizingMaskIntoConstraints = false
            lblIcon.widthAnchor.constraint(equalToConstant: 25).isActive = true
            lblIcon.heightAnchor.constraint(equalToConstant: 25).isActive = true
            lblIcon.rightAnchor.constraint(equalTo: self.popView.rightAnchor, constant: -10).isActive = true
            lblIcon.centerYAnchor.constraint(equalTo: self.popView.centerYAnchor, constant: 0).isActive = true
            
            
            //creat message label
            
            lblMessage.translatesAutoresizingMaskIntoConstraints = false
            lblMessage.rightAnchor.constraint(equalTo: lblIcon.leftAnchor, constant: -10).isActive = true
            lblMessage.leftAnchor.constraint(equalTo: self.popView.leftAnchor, constant: 10).isActive = true
            lblMessage.centerYAnchor.constraint(equalTo: self.popView.centerYAnchor, constant: 0).isActive = true
            lblMessage.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            
            
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Change `time` to the desired number of seconds.
                
                self.removeAutomatically(view: alertView)
                
            }
            
            
        }
        
    }
    private func removeAutomatically(view: UIViewController? = nil) {
        for view in view!.view.subviews {
            if view.tag == 202 {
                UIView.animate(withDuration: 0.2, animations: {view.alpha = 0.0},
                               completion: {(value: Bool) in
                                view.removeFromSuperview()
                })
                
                
                
            }
        }
    }
}
