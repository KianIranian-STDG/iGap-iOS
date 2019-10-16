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
import UIKit

// IMPORTANT TODO - convert current class to builder
class IGHelperAlert {
    enum helperCustomAlertType : Int {
        case alert = 0
        case warning = 1
        case success = 2
    }
    private var actionDone: (() -> Void)?
    private var actionCancel: (() -> Void)?

    static let shared = IGHelperAlert()
    var customAlert : UIView!
    var bgView : UIView!
    let window = UIApplication.shared.keyWindow
    
    func showAlert(view: UIViewController? = nil, title: String? = nil, message: String? = nil, done: (() -> Void)? = nil, cancel: (() -> Void)? = nil) {
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
            let cancelAction = UIAlertAction(title: "BTN_CANCEL".localizedNew, style: .default, handler: { (action) in
                cancel?()
            })
            alert.addAction(cancelAction)
            
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
            
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 12.0
            
            var attributedString: NSAttributedString!
            if success {
                backView?.backgroundColor = UIColor.iGapGreen()
                backView?.tintColor = UIColor.iGapGreen()
                attributedString = NSAttributedString(
                    string: "",
                    attributes: [
                        NSAttributedString.Key.font : UIFont.iGapFonticon(ofSize: iconFontSize), NSAttributedString.Key.foregroundColor : UIColor.iGapGreen()
                    ]
                )
            } else {
                backView?.backgroundColor = UIColor.iGapRed()
                backView?.tintColor = UIColor.iGapRed()
                attributedString = NSAttributedString(
                    string: "",
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
    
    func showDeleteAccountAlert(title: String, cancel: (() -> Void)? = nil, done: (() -> Void)? = nil){
        DispatchQueue.main.async {
            
            let alertView = UIApplication.topViewController()
            
            var message: String!
            message = "SURE_DELETE".localizedNew
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let titleFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15, weight: .bold)]
            let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
            alert.setValue(titleAttrString, forKey: "attributedTitle")
            
            if message != nil {
                let messageFont = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]
                let messageAttrString = NSMutableAttributedString(string: message!, attributes: messageFont)
                alert.setValue(messageAttrString, forKey: "attributedMessage")
            }
            
            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { (action) in
                done?()
            })
            alert.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "BTN_CANCEL".localizedNew, style: .default, handler: { (action) in
                cancel?()
            })
            alert.addAction(cancelAction)
            
            alertView!.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    ///Custome Alert By Benjamin
    func showCustomAlert(view: UIViewController? = nil,alertType: helperCustomAlertType! = helperCustomAlertType.alert,title: String? = nil,message: String? = nil,doneText: String? = nil,cancelText: String? = nil, cancel: (() -> Void)? = nil, done: (() -> Void)? = nil){
        DispatchQueue.main.async {
            var alertView = view
            if alertView == nil {
                alertView = UIApplication.topViewController()
            }
            ///check if there's already one customAlert on screen remove it and creat a new one
            if self.customAlert != nil {
                self.removeCustomAlertView()
            }
            
            if self.customAlert == nil {
                
                self.creatBlackBackgroundView()///view for black transparet on back of alert
                self.customAlert = self.creatCustomAlertView()///creat customAlertView

                UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionFlipFromTop, animations: {
                    self.window!.addSubview(self.customAlert)
                    self.customAlert = self.creatCustomAlertView()///creat customAlertView
                    self.window!.addSubview(self.customAlert)
                    self.setConstraintsToCustomAlert(customView: self.customAlert, view: view)///setConstraintsTo CustomeAlert
                    ///create StackView for holding Buttons
                    let stackButtons = UIStackView()
                    stackButtons.axis = .horizontal
                    stackButtons.alignment = .fill
                    stackButtons.distribution = .fillEqually
                    self.customAlert.addSubview(stackButtons)
                    ///set Constraints for stackView
                    self.setConstraintsToButtonsStackView(customStack: stackButtons, customAlertView: self.customAlert)
                    let borderView = UIView()
                    let borderCenterView = UIView()///border Between buttons
                    let borderTopView = UIView()///border for Top Of CustomAlert
                    switch alertType {
                    case .alert:
                        borderTopView.backgroundColor = UIColor.iGapRed()
                        break
                    case .success:
                        borderTopView.backgroundColor = UIColor.iGapGreen()
                        break
                    case .warning :
                        borderTopView.backgroundColor = UIColor.iGapGold()
                        break
                    default :
                        borderTopView.backgroundColor = UIColor.iGapRed()
                        break
                    }
                    borderView.backgroundColor = UIColor(named : themeColor.customAlertBorderColor.rawValue)
                    borderCenterView.backgroundColor = UIColor(named : themeColor.customAlertBorderColor.rawValue)
                    self.customAlert.addSubview(borderView)
                    self.customAlert.addSubview(borderCenterView)
                    self.customAlert.addSubview(borderTopView)
                    ///set Constraints for borderView above stack of Buttons
                    self.setConstraintsToBorderInStackView(borderView: borderCenterView, customAlertView: self.customAlert)
                    self.setConstraintsToBorderViewAboveStackView(borderView: borderView, customStack: stackButtons)
                    self.setConstraintsToTopBorder(borderView: borderTopView, customAlertView: self.customAlert)                ///create Buttons
                    self.customAlert.clipsToBounds = true
                    let btnDone = UIButton()
                    let btnCancel = UIButton()
                    btnDone.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnCancel.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnDone.setTitle(doneText, for: .normal)
                    btnCancel.setTitle(cancelText, for: .normal)
                    btnCancel.setTitleColor(UIColor.iGapRed(), for: .normal)
                    btnDone.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
                    stackButtons.addArrangedSubview(btnCancel)
                    stackButtons.addArrangedSubview(btnDone)
                    stackButtons.translatesAutoresizingMaskIntoConstraints = false
                    ////DOne Tap GEsture Handler
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didDoneGotTap))
                    tapGestureRecognizer.numberOfTapsRequired = 1
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    btnDone.addGestureRecognizer(tapGestureRecognizer)
                    ////Cancel Tap GEsture Handler
                    let tapGestureRecognizerCancel = UITapGestureRecognizer(target: self, action: #selector(self.didCancelGotTap))
                    tapGestureRecognizerCancel.numberOfTapsRequired = 1
                    tapGestureRecognizerCancel.numberOfTouchesRequired = 1
                    btnCancel.addGestureRecognizer(tapGestureRecognizerCancel)

                    self.actionDone = done
                    self.actionCancel = cancel

                    
                    self.customAlert.layoutIfNeeded()
                    
                },completion: {(value: Bool) in
                    
                })
            }
            
        }
    }
    //MARK: - Development funcs

    @objc func didDoneGotTap() {
        if self.actionDone != nil {
        actionDone!()
        } else {
            self.removeCustomAlertView()
        }
    }
    @objc func didCancelGotTap() {
        if self.actionCancel != nil {
        actionCancel!()
        } else {
            self.removeCustomAlertView()
        }
    }
    //MARK: - Create / Remove funcs

    private func creatBlackBackgroundView()  {
        bgView = UIView()
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        bgView.frame = self.window!.frame
        self.window?.addSubview(bgView)
    }
    private func removeCustomAlertView()  {
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionCrossDissolve, animations: {
            self.bgView.removeFromSuperview()
            self.customAlert.removeFromSuperview()
            self.customAlert = nil
        },completion: {(value: Bool) in })
    }
    private func creatCustomAlertView() -> UIView {
        let view = UIView()
        view.tag = 303
        view.backgroundColor = UIColor(named : themeColor.customAlertBGColor.rawValue)
        view.layer.cornerRadius = 15
        return view
    }
    private func creatIconView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(named : themeColor.customAlertBGColor.rawValue)
        view.layer.cornerRadius = 40
        return view
    }
    
    //MARK: - constraints funcs
    private func setConstraintsToCustomAlert(customView: UIView!,view: UIViewController? = nil) {
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        customView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        customView.centerYAnchor.constraint(equalTo: view!.view!.centerYAnchor, constant: 0).isActive = true
        customView.centerXAnchor.constraint(equalTo: view!.view!.centerXAnchor, constant: 0).isActive = true
    }

    private func setConstraintsToIconView(customView: UIView!,customAlertView: UIView!) {
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        customView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        customView.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor, constant: 0).isActive = true
    }

    private func setConstraintsToButtonsStackView(customStack: UIStackView!,customAlertView: UIView!) {
        customStack.translatesAutoresizingMaskIntoConstraints = false
        customStack.heightAnchor.constraint(equalToConstant: 45).isActive = true
        customStack.leftAnchor.constraint(equalTo: customAlertView.leftAnchor, constant: 0).isActive = true
        customStack.rightAnchor.constraint(equalTo: customAlertView.rightAnchor, constant: 0).isActive = true
        customStack.bottomAnchor.constraint(equalTo: customAlertView.bottomAnchor, constant: 0).isActive = true
    }
    private func setConstraintsToBorderViewAboveStackView(borderView: UIView!,customStack: UIStackView!) {
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        borderView.leftAnchor.constraint(equalTo: customStack.leftAnchor, constant: 0).isActive = true
        borderView.rightAnchor.constraint(equalTo: customStack.rightAnchor, constant: 0).isActive = true
        borderView.bottomAnchor.constraint(equalTo: customStack.topAnchor, constant: 0).isActive = true
    }

    private func setConstraintsToBorderInStackView(borderView: UIView!,customAlertView: UIView!) {
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        borderView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        borderView.bottomAnchor.constraint(equalTo: customAlertView.bottomAnchor, constant: 0).isActive = true
        borderView.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor, constant: 0).isActive = true
    }

    private func setConstraintsToTopBorder(borderView: UIView!,customAlertView: UIView!) {
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        borderView.leftAnchor.constraint(equalTo: customAlertView.leftAnchor, constant: 0).isActive = true
        borderView.rightAnchor.constraint(equalTo: customAlertView.rightAnchor, constant: 0).isActive = true
        borderView.topAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 0).isActive = true
    }

    
    
}
