//
//  RootVCSwitcher.swift
//  Hossein Nazari
//
//  Created by Hossein Nazari on 7/23/19.
//  Copyright © 2019 Hossein Nazari. All rights reserved.
//

import UIKit

class RootVCSwitcher {
    
    static func updateRootVC(storyBoard: String, viewControllerID: String) {
        
        var window: UIWindow!
        
        let storyboard : UIStoryboard = UIStoryboard(name: storyBoard, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: viewControllerID)
                
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let appWindow = appDelegate.window {
            window = appWindow
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
    }
    
}
