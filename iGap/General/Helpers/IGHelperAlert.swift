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
    
    func showAlert(view: UIViewController? = nil, title: String? = nil, message: String? = nil, done: (() -> Void)? = nil){
        DispatchQueue.main.async {
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
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                done?()
            })
            alert.addAction(okAction)
            alertView!.present(alert, animated: true, completion: nil)
        }
    }
    
    func showSuccessAlert(view: UIViewController? = nil, message: String? = nil, success: Bool = true, done: (() -> Void)? = nil){
        DispatchQueue.main.async {
            
            let iconFontSize: CGFloat = 32
            
            var alertView = view
            if alertView == nil {
                alertView = UIApplication.topViewController()
            }
            
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 12.0
            
            var attributedString: NSAttributedString!
            if success {
                backView?.backgroundColor = UIColor.iGapGreen()
                backView?.tintColor = UIColor.iGapGreen()
                attributedString = NSAttributedString(
                    string: "",
                    attributes: [
                        NSAttributedString.Key.font : UIFont.iGapFontico(ofSize: iconFontSize), NSAttributedString.Key.foregroundColor : UIColor.iGapGreen()
                    ]
                )
            } else {
                backView?.backgroundColor = UIColor.iGapRed()
                backView?.tintColor = UIColor.iGapRed()
                attributedString = NSAttributedString(
                    string: "",
                    attributes: [
                        NSAttributedString.Key.font : UIFont.iGapFontico(ofSize: iconFontSize), NSAttributedString.Key.foregroundColor : UIColor.iGapRed()
                    ]
                )
            }
            alert.setValue(attributedString, forKey: "attributedTitle")
            
            if message != nil {
                let messageFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]
                let messageAttrString = NSMutableAttributedString(string: message!, attributes: messageFont)
                alert.setValue(messageAttrString, forKey: "attributedMessage")
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                done?()
            })
            
            alert.addAction(okAction)
            alertView!.present(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorAlert(done: (() -> Void)? = nil){
        showAlert(title: "Error", message: "an error occurred!\n please try later!", done: done)
    }
}
