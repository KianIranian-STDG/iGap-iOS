/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff
import RealmSwift

class IGHelperAlert {
    
    static let shared = IGHelperAlert()
    
    func showAlert(view: UIViewController? = nil, title: String? = nil, message: String? = nil){
        
        var alertView = view
        if alertView == nil {
            alertView = UIApplication.topViewController()
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if title != nil {
            let titleFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15, weight: .bold)]
            let titleAttrString = NSMutableAttributedString(string: title!, attributes: titleFont)
            alert.setValue(titleAttrString, forKey: "attributedTitle")
        }
        
        if message != nil {
            let messageFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]
            let messageAttrString = NSMutableAttributedString(string: message!, attributes: messageFont)
            alert.setValue(messageAttrString, forKey: "attributedMessage")
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in })
        alert.addAction(okAction)
        alertView!.present(alert, animated: true, completion: nil)
    }
}
