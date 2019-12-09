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
        case question = 3
    }
    
    private var actionDone: (() -> Void)?
    private var actionCancel: (() -> Void)?
    
    static let shared = IGHelperAlert()
    var customAlert : UIView!
    var iconView : UIView!
    var bgView : UIView!
    var maxHeightOfCustomAlert : CGFloat = (UIScreen.main.bounds.height - 100)
    let window = UIApplication.shared.keyWindow
    
    
    func showAlert(data: IGStructAdditionalButton) {
        if let value = data.value, !value.isEmpty {
            let alert = CustomAlertDirectPay(data: value)
            alert.show(animated: true)
        } else if let valueJson = data.valueJson, let finalData = IGHelperJson.parseAdditionalPayDirect(data: valueJson) {
            let alert = CustomAlertDirectPay(data: finalData)
            alert.show(animated: true)
        }
    }
    
    
    func showForwardAlert(title: String, isForbidden: Bool = false, cancelForward: (() -> Void)? = nil, done: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertView = UIApplication.topViewController()
            
            var message: String!
            if isForbidden {
                message = IGStringsManager.ForwardPermissionError.rawValue.localized
            } else {
                message = IGStringsManager.SureToForward.rawValue.localized
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
                let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { (action) in
                    done?()
                })
                alert.addAction(okAction)
            }
            
            let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .default, handler: { (action) in
                cancelForward?()
            })
            alert.addAction(cancelAction)
            
            let anotherRoom = UIAlertAction(title: IGStringsManager.AnotherRoom.rawValue.localized, style: .default, handler: nil)
            alert.addAction(anotherRoom)
            
            alertView!.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    ///Custome Alert By Benjamin
    ///showCancelButton:  which is of Type Bool represent for showing cancel button or not - Default is True
    ///showDoneButton : which is of Type Bool represent for showing Done button or not - Default is True
    ///showIconView : which is of Type Bool is responsible for showing icon above alert or not - Default is True
    ///
    func showCustomAlert(view: UIViewController? = nil, alertType: helperCustomAlertType! = helperCustomAlertType.alert, title: String? = nil, showIconView: Bool? = true, showDoneButton: Bool? = true, showCancelButton: Bool? = true, message: String!, doneText: String? = nil, cancelText: String? = nil, cancel: (() -> Void)? = nil, done: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            var alertView = view
            
            if alertView == nil {
                alertView = UIApplication.topViewController()
            }
            alertView?.view.layoutIfNeeded()
            UIApplication.topViewController()?.view.endEditing(true)
            ///check if there's already one customAlert on screen remove it and creat a new one
            if self.customAlert != nil {
                self.removeCustomAlertView()
            }
            
            if self.customAlert == nil {
                
                self.creatBlackBackgroundView()///view for black transparet on back of alert
                
                self.customAlert = self.creatCustomAlertView()///creat customAlertView
                if showIconView! {
                    self.iconView = self.creatIconView()
                }
                self.customAlert.layoutIfNeeded()
                UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionFlipFromTop, animations: {
                    self.window!.addSubview(self.customAlert)
                    self.customAlert = self.creatCustomAlertView()///creat customAlertView
                    self.window!.addSubview(self.customAlert)
                    if showIconView! {
                        self.window!.addSubview(self.iconView)
                    }
                    let heightOfAlert = self.detectHeightOfMessage(widthOfAlert: 230, message: message, font: UIFont.igFont(ofSize: 15)) + 150
                    
                    let height = min(heightOfAlert,self.maxHeightOfCustomAlert)//return min value between message height and maximum allowed height of alert
                    self.setConstraintsToCustomAlert(customView: self.customAlert, view: alertView,height:height)///setConstraintsTo CustomeAlert
                    ///create StackView for holding Buttons
                    let stackButtons = UIStackView()
                    stackButtons.axis = .horizontal
                    stackButtons.alignment = .fill
                    stackButtons.distribution = .fillEqually
                    self.customAlert.addSubview(stackButtons)
                    ///set Constraints for stackView
                    self.setConstraintsToButtonsStackView(customStack: stackButtons, customAlertView: self.customAlert)
                    if showIconView! {
                        self.setConstraintsToIconView(customView: self.iconView, customAlertView: self.customAlert)
                    }
                    let borderView = UIView()
                    let borderCenterView = UIView()///border Between buttons
                    let borderTopView = UIView()///border for Top Of CustomAlert
                    let lblIcon = UILabel()
                    lblIcon.font = UIFont.iGapFonticon(ofSize: 50)
                    lblIcon.textAlignment = .center
                    switch alertType {
                    case .alert:
                        borderTopView.backgroundColor = UIColor.iGapRed()
                        lblIcon.textColor = UIColor.iGapRed()
                        lblIcon.text = "🌩"
                        if showIconView! {
                            self.iconView.layer.borderColor = UIColor.iGapRed().cgColor
                        }
                        break
                    case .success:
                        borderTopView.backgroundColor = UIColor.iGapGreen()
                        lblIcon.textColor = UIColor.iGapGreen()
                        lblIcon.text = "🌫"
                        if showIconView! {
                            self.iconView.layer.borderColor = UIColor.iGapGreen().cgColor
                        }
                        break
                    case .warning :
                        lblIcon.text = "🌨"
                        borderTopView.backgroundColor = UIColor.iGapGold()
                        lblIcon.textColor = UIColor.iGapGold()
                        if showIconView! {
                            self.iconView.layer.borderColor = UIColor.iGapGold().cgColor
                        }
                        break
                    case .question :
                        lblIcon.text = "🌪"
                        borderTopView.backgroundColor = UIColor.iGapSkyBlue()
                        lblIcon.textColor = UIColor.iGapSkyBlue()
                        if showIconView! {
                            self.iconView.layer.borderColor = UIColor.iGapSkyBlue().cgColor
                        }
                        break
                    default :
                        borderTopView.backgroundColor = UIColor.iGapRed()
                        lblIcon.textColor = UIColor.iGapRed()
                        if showIconView! {
                            self.iconView.layer.borderColor = UIColor.iGapRed().cgColor
                        }
                        break
                    }
                    if showIconView! {
                        self.iconView.addSubview(lblIcon)
                        self.setConstraintsToLabelInIconView(label: lblIcon, iconView: self.iconView)
                    }

                    borderView.backgroundColor = ThemeManager.currentTheme.CustomAlertBorderColor
                    borderCenterView.backgroundColor = ThemeManager.currentTheme.CustomAlertBorderColor
                    self.customAlert.addSubview(borderView)
                    if showDoneButton! , showCancelButton! {
                        self.customAlert.addSubview(borderCenterView)
                        self.setConstraintsToBorderInStackView(borderView: borderCenterView, customAlertView: self.customAlert)
                    }
                    self.customAlert.addSubview(borderTopView)
                    ///set Constraints for borderView above stack of Buttons
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
                    btnDone.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
                    stackButtons.addArrangedSubview(btnCancel)
                    stackButtons.addArrangedSubview(btnDone)
                    if showDoneButton! && showCancelButton! {
                        btnCancel.isHidden = false
                        btnDone.isHidden = false
                    } else if showDoneButton! && !showCancelButton! {
                        btnCancel.isHidden = false
                        btnDone.isHidden = false
                        
                    } else {
                        btnCancel.isHidden = false
                        btnDone.isHidden = true
                    }
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
                    ///create stack of title and Message
                    let stackTitleAndMessage = UIStackView()
                    stackTitleAndMessage.axis = .vertical
                    stackTitleAndMessage.alignment = .fill
                    stackTitleAndMessage.distribution = .fill
                    self.customAlert.addSubview(stackTitleAndMessage)
                    
                    let titleLabel = UILabel()
                    let messageLabel = UILabel()
                    titleLabel.font = UIFont.igFont(ofSize: 13,weight: .bold)
                    titleLabel.numberOfLines = 1
                    messageLabel.numberOfLines = 0
//                    messageLabel.adjustsFontSizeToFitWidth = true
                    messageLabel.font = UIFont.igFont(ofSize: 14)
                    titleLabel.textColor = ThemeManager.currentTheme.LabelColor
                    messageLabel.textColor = ThemeManager.currentTheme.LabelColor
                    messageLabel.text = message
                    messageLabel.textAlignment = .center
                    messageLabel.sizeToFit()
                    titleLabel.textAlignment = .center
                    stackTitleAndMessage.addArrangedSubview(titleLabel)
                    stackTitleAndMessage.addArrangedSubview(messageLabel)
                    
                    if title != nil {
                        titleLabel.text = title
                        self.setConstraintsToTitleAndMessage(titleAndMessageStack: stackTitleAndMessage, titleLabel: titleLabel, messageLabel: messageLabel, customAlertView: self.customAlert, iconViewIsVisible: showIconView)
                    } else {
                        self.customAlert.addSubview(messageLabel)
                        self.setConstraintsToTitleAndMessage(titleAndMessageStack: stackTitleAndMessage, titleLabel: nil, messageLabel: messageLabel, customAlertView: self.customAlert, iconViewIsVisible: showIconView)
                        
                    }
                    self.actionDone = done
                    self.actionCancel = cancel
                    
                    
                    self.customAlert.layoutIfNeeded()
                    if showIconView! {
                        self.iconView.layoutIfNeeded()
                    }
                    
                    alertView!.view?.superview?.layoutIfNeeded()
                    
                },completion: {(value: Bool) in
                    
                })
            }
            
        }
    }
    
    
    //MARK: - Development funcs
    
    @objc func didDoneGotTap() {
        if self.actionDone != nil {
            actionDone!()
            self.removeCustomAlertView()
            
        } else {
            self.removeCustomAlertView()
        }
    }
    @objc func didCancelGotTap() {
        if self.actionCancel != nil {
            actionCancel!()
            self.removeCustomAlertView()
            
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
            if self.iconView != nil {
                self.iconView.removeFromSuperview()
            }
        },completion: {(value: Bool) in })
    }
    private func creatCustomAlertView() -> UIView {
        let view = UIView()
        view.tag = 303
        view.backgroundColor = ThemeManager.currentTheme.CustomAlertBGColor
        view.layer.cornerRadius = 15
        return view
    }
    private func creatIconView() -> UIView {
        let view = UIView()
        view.backgroundColor = ThemeManager.currentTheme.CustomAlertBGColor
        view.layer.cornerRadius = 30
        view.layer.borderWidth = 5.0
        return view
    }
    
    
    //MARK: - constraints funcs
    private func setConstraintsToCustomAlert(customView: UIView!,view: UIViewController? = UIApplication.topViewController(),height : CGFloat? = 150) {
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.heightAnchor.constraint(equalToConstant: (height!)).isActive = true
        customView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        customView.centerYAnchor.constraint(equalTo: view!.view!.centerYAnchor, constant: 0).isActive = true
        customView.centerXAnchor.constraint(equalTo: view!.view!.centerXAnchor, constant: 0).isActive = true
    }
    
    private func setConstraintsToIconView(customView: UIView!,customAlertView: UIView!) {
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        customView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        customView.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor, constant: 0).isActive = true
        customView.bottomAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 30).isActive = true
    }
    private func setConstraintsToLabelInIconView(label: UILabel!,iconView: UIView!) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor, constant: 0).isActive = true
        label.centerXAnchor.constraint(equalTo: iconView.centerXAnchor, constant: 0).isActive = true
    }
    
    private func setConstraintsToTitleAndMessage(titleAndMessageStack: UIStackView!,titleLabel: UILabel? = nil , messageLabel: UILabel? = nil,customAlertView: UIView!,iconViewIsVisible: Bool? = true) {
        var hasTitle: Bool = true
        
        if titleLabel != nil {
            //            titleLabel!.translatesAutoresizingMaskIntoConstraints = false
            titleLabel!.heightAnchor.constraint(equalToConstant: 20).isActive = true
            titleLabel!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 5).isActive = true
            titleLabel!.leftAnchor.constraint(equalTo: titleAndMessageStack!.leftAnchor, constant: 5).isActive = true
            titleLabel!.rightAnchor.constraint(equalTo: titleAndMessageStack!.rightAnchor, constant: -5).isActive = true

            messageLabel!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 25).isActive = true
            messageLabel!.bottomAnchor.constraint(equalTo: titleAndMessageStack.bottomAnchor, constant: -5).isActive = true
            messageLabel!.leftAnchor.constraint(equalTo: titleAndMessageStack!.leftAnchor, constant: 5).isActive = true
            messageLabel!.rightAnchor.constraint(equalTo: titleAndMessageStack!.rightAnchor, constant: -5).isActive = true

        } else {
            hasTitle = false
            titleLabel?.isHidden = true
            messageLabel!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 5).isActive = true
            messageLabel!.leftAnchor.constraint(equalTo: titleAndMessageStack!.leftAnchor, constant: 5).isActive = true
            messageLabel!.rightAnchor.constraint(equalTo: titleAndMessageStack!.rightAnchor, constant: -5).isActive = true
            messageLabel!.bottomAnchor.constraint(equalTo: titleAndMessageStack!.bottomAnchor, constant: -5).isActive = true

        }
        
        
        titleAndMessageStack.translatesAutoresizingMaskIntoConstraints = false
        titleAndMessageStack.leftAnchor.constraint(equalTo: customAlertView.leftAnchor, constant: 10).isActive = true
        titleAndMessageStack.rightAnchor.constraint(equalTo: customAlertView.rightAnchor, constant: -10).isActive = true
        titleAndMessageStack.bottomAnchor.constraint(equalTo: customAlertView.bottomAnchor, constant: -58).isActive = true
        ///if has Icon at top of Alert
        if iconViewIsVisible! {
            titleAndMessageStack.topAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 35).isActive = true
            
        } else {
            titleAndMessageStack.topAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 10).isActive = true
        }
        
        
        
    }
    
    private func detectHeightOfMessage(widthOfAlert: CGFloat,message: String,font : UIFont) -> CGFloat {
        let constraintRect = CGSize(width: widthOfAlert, height: .greatestFiniteMagnitude)
        let boundingBox = message.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return (ceil(boundingBox.height))
        
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
