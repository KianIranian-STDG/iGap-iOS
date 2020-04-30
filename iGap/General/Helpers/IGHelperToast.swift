//
//  IGHelperToast.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/30/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import Foundation
import UIKit

// IMPORTANT TODO - convert current class to builder
class IGHelperToast {
    
    enum helperAlertType : Int {
        case oneButton = 0
        case twoButton = 1
        case noButton = 2
    }
    
    private var actionDone: (() -> Void)?
    private var actionCancel: (() -> Void)?
    
    static let shared = IGHelperToast()
    var customAlert : UIView!
    var iconView : UIView!
    var bgView : UIView!
    var maxHeightOfCustomAlert : CGFloat = (UIScreen.main.bounds.height - 100)
    let window = UIApplication.shared.keyWindow
    
    
    ///Custome Alert By Benjamin
    ///showCancelButton:  which is of Type Bool represent for showing cancel button or not - Default is True
    ///showDoneButton : which is of Type Bool represent for showing Done button or not - Default is True
    ///showIconView : which is of Type Bool is responsible for showing icon above alert or not - Default is True
    ///
    func showCustomToast(view: UIViewController? = nil, showCancelButton: Bool? = true, cancelTitleColor: UIColor = UIColor.darkGray ,cancelBackColor : UIColor = UIColor.white, message: String!, cancelText: String? = nil, cancel: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertView : UIWindow? = UIApplication.shared.keyWindow

            UIApplication.topViewController()?.view.endEditing(true)
            ///check if there's already one customAlert on screen remove it and creat a new one
            if self.customAlert != nil {
                self.removeCustomAlertView()
            }
            
            if self.customAlert == nil {
                
                self.creatBlackBackgroundView()///view for black transparet on back of alert
                
                self.customAlert = self.creatCustomAlertView()///creat customAlertView
                
                //UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionFlipFromTop, animations: {
                    self.window!.addSubview(self.customAlert)
                    self.customAlert = self.creatCustomAlertView()///creat customAlertView
                    self.window!.addSubview(self.customAlert)

                    self.setConstraintsToCustomAlert(customView: self.customAlert, view: alertView)///setConstraintsTo CustomeAlert
                    ///create StackView for holding Buttons
                ///
                

                    ///set Constraints for borderView above stack of Buttons
                    self.customAlert.clipsToBounds = true
                
                    ///create stack of title and Message
                    let stackMessage = UIStackView()
                    stackMessage.axis = .horizontal
                    stackMessage.alignment = .fill
                    stackMessage.distribution = .fill

                
                
                
                
                

                    let messageLabel = UILabel()
                


                    messageLabel.numberOfLines = 1
                    messageLabel.font = UIFont.igFont(ofSize: 14)

                    messageLabel.textColor = ThemeManager.currentTheme.LabelColor
                    messageLabel.text = message
                    messageLabel.textAlignment = messageLabel.localizedDirection
                    messageLabel.sizeToFit()

                        stackMessage.addArrangedSubview(messageLabel)
                        stackMessage.alignment = .center
                //CANCEL BUTTON
                if showCancelButton! {
                    let btnCancel = UIButton()
                    btnCancel.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnCancel.backgroundColor = cancelBackColor
                    btnCancel.setTitle(cancelText, for: .normal)
                    btnCancel.setTitleColor(cancelTitleColor, for: .normal)


                    ////Cancel Tap GEsture Handler
                    let tapGestureRecognizerCancel = UITapGestureRecognizer(target: self, action: #selector(self.didCancelGotTap))
                    tapGestureRecognizerCancel.numberOfTapsRequired = 1
                    tapGestureRecognizerCancel.numberOfTouchesRequired = 1
                    btnCancel.addGestureRecognizer(tapGestureRecognizerCancel)
                    self.actionCancel = cancel

                    stackMessage.addArrangedSubview(btnCancel)
                    self.customAlert.addSubview(stackMessage)

                    self.setConstraintForMessageStack(MessageStack: stackMessage, messageLabel: messageLabel, customAlertView: self.customAlert ,button: btnCancel)

                } else {
                    self.customAlert.addSubview(stackMessage)

                    self.setConstraintForMessageStack(MessageStack: stackMessage, messageLabel: messageLabel, customAlertView: self.customAlert)

                }
                
         
                


                self.customAlert?.alpha = 0
                self.customAlert?.fadeIn(0.3)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0 ) {
                    self.actionCancel!()
                    self.removeCustomAlertView()

                }
            }
            
        }
    }
    
    
    //MARK: - Development funcs
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
        bgView.alpha = 0
        bgView.fadeIn(0.3)
        
    }
    private func removeCustomAlertView()  {
        //UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionCrossDissolve, animations: {
        self.bgView?.fadeOut(0.3)
        self.customAlert?.fadeOut(0.3)
        self.iconView?.fadeOut(0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.bgView?.removeFromSuperview()
            self.customAlert?.removeFromSuperview()
            self.customAlert = nil
            self.iconView?.removeFromSuperview()
        }
        //},completion: {(value: Bool) in })
    }
    private func creatCustomAlertView() -> UIView {
        let view = UIView()
        view.tag = 303
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 10
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
    private func setConstraintsToCustomAlert(customView: UIView!,view: UIWindow? ,height : CGFloat? = 50) {
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.heightAnchor.constraint(equalToConstant: (70)).isActive = true
        customView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 30).isActive = true
//        customView.centerYAnchor.constraint(equalTo: view!.centerYAnchor, constant: 0).isActive = true
        customView.bottomAnchor.constraint(equalTo: view!.bottomAnchor, constant: -20).isActive = true
        customView.centerXAnchor.constraint(equalTo: view!.centerXAnchor, constant: 0).isActive = true
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
    
    private func setConstraintForMessageStack(MessageStack: UIStackView! , messageLabel: UILabel? = nil,customAlertView: UIView!,button : UIButton? = nil) {
        MessageStack.translatesAutoresizingMaskIntoConstraints = false
        MessageStack.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor, constant: 10).isActive = true
        MessageStack.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor, constant: -10).isActive = true
        MessageStack.topAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 0).isActive = true
        MessageStack.bottomAnchor.constraint(equalTo: customAlertView.bottomAnchor, constant: 0).isActive = true
        
        if button != nil {
            button!.translatesAutoresizingMaskIntoConstraints = false
            button?.widthAnchor.constraint(equalToConstant: 50).isActive = true
            button?.trailingAnchor.constraint(equalTo: MessageStack.trailingAnchor,constant: 0).isActive = true
            button?.topAnchor.constraint(equalTo: MessageStack.topAnchor,constant: 0).isActive = true
            button?.bottomAnchor.constraint(equalTo: MessageStack.bottomAnchor,constant: 0).isActive = true

            messageLabel!.translatesAutoresizingMaskIntoConstraints = false
            messageLabel?.leadingAnchor.constraint(equalTo: MessageStack.leadingAnchor,constant: 0).isActive = true
            messageLabel?.trailingAnchor.constraint(equalTo: button!.leadingAnchor,constant: 0).isActive = true
            messageLabel?.topAnchor.constraint(equalTo: MessageStack.topAnchor,constant: 0).isActive = true
            messageLabel?.bottomAnchor.constraint(equalTo: MessageStack.bottomAnchor,constant: 0).isActive = true
            if LocaleManager.isRTL {
                messageLabel?.semanticContentAttribute = .forceRightToLeft
                button?.semanticContentAttribute = .forceRightToLeft
            } else {
                messageLabel?.semanticContentAttribute = .forceLeftToRight
                button?.semanticContentAttribute = .forceLeftToRight

            }

        } else {
            messageLabel!.translatesAutoresizingMaskIntoConstraints = false
            messageLabel?.leadingAnchor.constraint(equalTo: MessageStack.leadingAnchor,constant: 0).isActive = true
            messageLabel?.trailingAnchor.constraint(equalTo: MessageStack.trailingAnchor,constant: 0).isActive = true
            messageLabel?.topAnchor.constraint(equalTo: MessageStack.topAnchor,constant: 0).isActive = true
            messageLabel?.bottomAnchor.constraint(equalTo: MessageStack.bottomAnchor,constant: 0).isActive = true
            if LocaleManager.isRTL {
                messageLabel?.semanticContentAttribute = .forceRightToLeft

            } else {
                messageLabel?.semanticContentAttribute = .forceLeftToRight

            }

        }
        if LocaleManager.isRTL {
            MessageStack.semanticContentAttribute = .forceRightToLeft
        } else {
            MessageStack.semanticContentAttribute = .forceLeftToRight

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
        customStack.leftAnchor.constraint(equalTo: customAlertView.leftAnchor, constant: 20).isActive = true
        customStack.rightAnchor.constraint(equalTo: customAlertView.rightAnchor, constant: -20).isActive = true
        customStack.bottomAnchor.constraint(equalTo: customAlertView.bottomAnchor, constant: -20).isActive = true
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
