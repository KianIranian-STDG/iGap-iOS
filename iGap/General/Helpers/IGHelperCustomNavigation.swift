//
//  IGHelperCustomNavigation.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/6/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit

class IGHelperCustomNavigation {
    static let shared = IGHelperCustomNavigation()

        var rightViewContainer:  IGTappableView?

        func createLeftButton() -> UIBarButtonItem {
            UIApplication.topViewController()!.navigationItem.title = ""

//            let rightViewFrame = CGRect(x: 0, y: 0, width: 50, height: 27/2)
//            rightViewContainer = IGTappableView(frame: rightViewFrame)
            
            let btnLeftMenu: UIButton = UIButton()
            btnLeftMenu.setTitle("", for: .normal)
            btnLeftMenu.addTarget(self, action: #selector(self.onClcikBack(sender:)), for: UIControl.Event.touchUpInside)
            btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33/2, height: 27/2)
            btnLeftMenu.titleLabel!.font = UIFont.iGapFonticon(ofSize: 25)
            btnLeftMenu.titleLabel!.textAlignment = .left
//            rightViewContainer?.addSubview(btnLeftMenu)
//            rightViewContainer?.addAction(leftAction)

            let barButton = UIBarButtonItem(customView: btnLeftMenu)
            return barButton

        }

    func createTitle(title: String? = nil, font: UIFont = UIFont.igFont(ofSize: 17.0, weight: .bold)) -> UIView {
        
        let viewTitle = UIView()
        //        view.frame = UIApplication.topViewController()!.navigationItem.titleView?.frame as! CGRect
        viewTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        let lblTitle = UILabel()
        lblTitle.text = title
        lblTitle.font = font
        lblTitle.textColor = .white
        viewTitle.addSubview(lblTitle)
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTitle.topAnchor.constraint(equalTo: viewTitle.topAnchor, constant: 0).isActive = true
        lblTitle.leadingAnchor.constraint(equalTo: viewTitle.leadingAnchor, constant: 0).isActive = true
        lblTitle.trailingAnchor.constraint(equalTo: viewTitle.trailingAnchor, constant: 0).isActive = true
        lblTitle.bottomAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: 0).isActive = true

        
        return viewTitle
        
        
    }
    @objc func  onClcikBack(sender: UIButton!)  {
        // isMBAuthError is true when the Auth is expired so the param will be true


        
        if isMBAuthError {
            if let vcToPOP = UIApplication.topViewController()!.navigationController?.viewControllers[indexOfMBLogin - 1] {
                _ = UIApplication.topViewController()!.navigationController?.popToViewController(vcToPOP, animated: true)
            } else {
                _ = UIApplication.topViewController()!.navigationController?.popToRootViewController(animated: true)
            }
            isMBAuthError = false
        } else {
            if UIApplication.topViewController()!.navigationController?.viewControllers.last! is IGMBMainContainerVC {
                if let vcToPOP = UIApplication.topViewController()!.navigationController?.viewControllers[indexOfMBLogin - 1] {
                    _ = UIApplication.topViewController()!.navigationController?.popToViewController(vcToPOP, animated: true)

                }


            } else {
                _ = UIApplication.topViewController()!.navigationController?.popViewController(animated: true)

            }

        }
    }

}
