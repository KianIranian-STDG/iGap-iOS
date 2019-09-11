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

// IMPORTANT TODO - convert current class to builder
class IGHelperAlert {
    
    static let shared = IGHelperAlert()
    
    func showAlert(view: UIViewController? = nil, title: String? = nil, message: String? = nil, done: (() -> Void)? = nil) {
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
            
            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { (action) in
                done?()
            })
            alert.addAction(okAction)
            alertView!.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert(data: String) {
        let alert = CustomAlertDirectPay(data: data)
        alert.show(animated: true)
    }

    
    func showAlert(data: IGStructAdditionalButton) {
        if let value = data.value, !value.isEmpty {
            let alert = CustomAlertDirectPay(data: value)
            alert.show(animated: true)
        } else if let valueJson = data.valueJson, let finalData = IGHelperJson.parseAdditionalPayDirect(data: valueJson) {
            let alert = CustomAlertDirectPay(data: finalData)
            alert.show(animated: true)
        }
    }
    func showAlertInputField(view: UIViewController? = nil, message: String? = nil,title: String? = nil, success: Bool = true, done: (() -> Void)? = nil) {

        DispatchQueue.main.async {
            
            let iconFontSize: CGFloat = 32
            
            var alertView = view
            if alertView == nil {
                alertView = UIApplication.topViewController()
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField()
            
            if message != nil {
                let messageFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]
                let messageAttrString = NSMutableAttributedString(string: message!, attributes: messageFont)
                alert.setValue(messageAttrString, forKey: "attributedMessage")
            }
            
            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { (action) in
                done?()
            })
            
            alert.addAction(okAction)
            alertView!.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showSuccessAlert(view: UIViewController? = nil, message: String? = nil, success: Bool = true, done: (() -> Void)? = nil) {

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
                        NSAttributedString.Key.font : UIFont.iGapFonticon(ofSize: iconFontSize), NSAttributedString.Key.foregroundColor : UIColor.iGapGreen()
                    ]
                )
            } else {
                backView?.backgroundColor = UIColor.iGapRed()
                backView?.tintColor = UIColor.iGapRed()
                attributedString = NSAttributedString(
                    string: "",
                    attributes: [
                        NSAttributedString.Key.font : UIFont.iGapFonticon(ofSize: iconFontSize), NSAttributedString.Key.foregroundColor : UIColor.iGapRed()
                    ]
                )
            }
            alert.setValue(attributedString, forKey: "attributedTitle")
            
            if message != nil {
                let messageFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]
                let messageAttrString = NSMutableAttributedString(string: message!, attributes: messageFont)
                alert.setValue(messageAttrString, forKey: "attributedMessage")
            }
            
            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { (action) in
                done?()
            })
            
            alert.addAction(okAction)
            alertView!.present(alert, animated: true, completion: nil)
        }
    }
    
    func showErrorAlert(done: (() -> Void)? = nil){
        showAlert(title: "GLOBAL_WARNING".localizedNew, message: "UNSSUCCESS_OTP".localizedNew)
    }

    
    func showForwardAlert(title: String, isForbidden: Bool = false, cancelForward: (() -> Void)? = nil, done: (() -> Void)? = nil){
        DispatchQueue.main.async {
            
            let alertView = UIApplication.topViewController()
            
            var message: String!
            if isForbidden {
                message = "FORWARD_PERMISSION".localizedNew
            } else {
                message = "FORWARD_QUESTION".localizedNew
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let titleFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15, weight: .bold)]
            let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
            alert.setValue(titleAttrString, forKey: "attributedTitle")
            
            if message != nil {
                let messageFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]
                let messageAttrString = NSMutableAttributedString(string: message!, attributes: messageFont)
                alert.setValue(messageAttrString, forKey: "attributedMessage")
            }
            
            if !isForbidden {
                let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { (action) in
                    done?()
                })
                alert.addAction(okAction)
            }
            
            let cancelAction = UIAlertAction(title: "FORWARD_CANCEL".localizedNew, style: .default, handler: { (action) in
                cancelForward?()
            })
            alert.addAction(cancelAction)
            
            let anotherRoom = UIAlertAction(title: "ANOTHER_ROOM".localizedNew, style: .default, handler: nil)
            alert.addAction(anotherRoom)
            
            alertView!.present(alert, animated: true, completion: nil)
        }
    }
 
 
}
