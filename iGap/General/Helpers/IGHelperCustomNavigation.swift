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

        func createButton(leftAction: @escaping () -> ()) -> UIBarButtonItem {
            UIApplication.topViewController()!.navigationItem.title = "1234"

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

    @objc func  onClcikBack(sender: UIButton!)  {
        _ = UIApplication.topViewController()!.navigationController?.popViewController(animated: true)
    }

}
