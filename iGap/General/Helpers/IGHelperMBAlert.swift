//
//  IGHelperMBAlert.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/26/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit

// IMPORTANT TODO - convert current class to builder
class IGHelperMBAlert {
    
    enum helperAlertType : Int {
        case oneButton = 0
        case twoButton = 1
        case noButton = 2
    }
    
    private var actionDone: (() -> Void)?
    private var actionCancel: (() -> Void)?
    
    static let shared = IGHelperMBAlert()
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
    func showCustomAlert(view: UIViewController? = nil, alertType: helperAlertType! = helperAlertType.oneButton, title: String? = nil, showDoneButton: Bool? = true, showCancelButton: Bool? = true,doneTitleColor: UIColor = UIColor.darkGray, cancelTitleColor: UIColor = UIColor.darkGray,doneBackColor : UIColor = UIColor.white,cancelBackColor : UIColor = UIColor.white, message: String!, doneText: String? = nil, cancelText: String? = nil,isLoading : Bool = false, cancel: (() -> Void)? = nil, done: (() -> Void)? = nil) {
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
                    let heightOfAlert : CGFloat
                    if isLoading {
                        heightOfAlert = 250
                    } else {
                        heightOfAlert = self.detectHeightOfMessage(widthOfAlert: 230, message: message, font: UIFont.igFont(ofSize: 15)) + 150
                    }
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


                    ///set Constraints for borderView above stack of Buttons
                    self.customAlert.clipsToBounds = true
                    let btnDone = UIButton()
                    let btnCancel = UIButton()
                    btnDone.layer.cornerRadius = 15
                    btnDone.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnCancel.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnDone.setTitle(doneText, for: .normal)
                    btnDone.backgroundColor = doneBackColor
                    btnCancel.backgroundColor = cancelBackColor
                    btnCancel.setTitle(cancelText, for: .normal)
                    btnCancel.setTitleColor(cancelTitleColor, for: .normal)
                    btnDone.setTitleColor(doneTitleColor, for: .normal)
                    stackButtons.addArrangedSubview(btnCancel)
                    stackButtons.addArrangedSubview(btnDone)
                    if showDoneButton! && showCancelButton! {
                        btnCancel.isHidden = false
                        btnDone.isHidden = false
                    } else if showDoneButton! && !showCancelButton! {
                        btnCancel.isHidden = true
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
                    let stackTitleAndIcon = UIStackView()
                    stackTitleAndIcon.axis = .horizontal
                    stackTitleAndIcon.alignment = .fill
                    stackTitleAndIcon.distribution = .fill

                    let titleLabel = UILabel()
                    let titleIcon = UILabel()
                    let messageLabel = UILabel()
                    let loading = AnimateloadingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                
                    loading.stopAnimating()
//                    loading.startAnimating()

                    titleLabel.font = UIFont.igFont(ofSize: 13,weight: .bold)
                    titleIcon.font = UIFont.iGapFonticon(ofSize: 13)
                    titleIcon.text = ""
                    titleLabel.numberOfLines = 1
                    messageLabel.numberOfLines = 0
                    messageLabel.font = UIFont.igFont(ofSize: 14)
                    titleLabel.textColor = ThemeManager.currentTheme.LabelColor
                    titleIcon.textColor = ThemeManager.currentTheme.LabelColor
                    messageLabel.textColor = ThemeManager.currentTheme.LabelColor
                    messageLabel.text = message
                    messageLabel.textAlignment = .center
                    messageLabel.sizeToFit()
                    titleLabel.textAlignment = titleLabel.localizedDirection
                    titleIcon.textAlignment = titleLabel.localizedDirection
                    stackTitleAndIcon.addArrangedSubview(titleIcon)
                    stackTitleAndIcon.addArrangedSubview(titleLabel)
                    stackTitleAndMessage.addArrangedSubview(stackTitleAndIcon)
                    if isLoading {
                        stackTitleAndMessage.addArrangedSubview(messageLabel)
                        stackTitleAndMessage.addArrangedSubview(loading)
                        stackTitleAndMessage.alignment = .center
                        stackTitleAndIcon.alignment = .fill
                    }

                if isLoading {
                    messageLabel.isHidden = true
                    loading.isHidden = false
                    loading.startAnimating()
                } else {
                    messageLabel.isHidden = false
                    loading.isHidden = true


                }
                
                    if title != nil {
                        titleLabel.text = title
                        self.setConstraintsToTitleAndMessage(titleAndMessageStack: stackTitleAndMessage, titleLabel: titleLabel, messageLabel: messageLabel, customAlertView: self.customAlert,isLoadingView: isLoading,loadingView : loading)
                    } else {
                        self.customAlert.addSubview(messageLabel)
                        self.setConstraintsToTitleAndMessage(titleAndMessageStack: stackTitleAndMessage, titleLabel: nil, messageLabel: messageLabel, customAlertView: self.customAlert)
                    }
                    self.actionDone = done
                    self.actionCancel = cancel
                self.customAlert?.alpha = 0
                self.customAlert?.fadeIn(0.3)
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
    private func setConstraintsToCustomAlert(customView: UIView!,view: UIWindow? ,height : CGFloat? = 150) {
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.heightAnchor.constraint(equalToConstant: (height!)).isActive = true
        customView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        customView.centerYAnchor.constraint(equalTo: view!.centerYAnchor, constant: 0).isActive = true
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
    
    private func setConstraintsToTitleAndMessage(titleAndMessageStack: UIStackView!,titleLabel: UILabel? = nil , messageLabel: UILabel? = nil,customAlertView: UIView!,isLoadingView: Bool? = false, loadingView : UIView? = nil) {
        var hasTitle: Bool = true
        
        if titleLabel != nil {
            //            titleLabel!.translatesAutoresizingMaskIntoConstraints = false
            
            titleLabel!.heightAnchor.constraint(equalToConstant: 20).isActive = true
            titleLabel!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 5).isActive = true
            titleLabel!.leftAnchor.constraint(equalTo: titleAndMessageStack!.leftAnchor, constant: 50).isActive = true
            titleLabel!.rightAnchor.constraint(equalTo: titleAndMessageStack!.rightAnchor, constant: -30).isActive = true

            if isLoadingView! {
                loadingView!.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor, constant: 0).isActive = true
                loadingView!.centerYAnchor.constraint(equalTo: customAlertView.centerYAnchor, constant: 0).isActive = true
                loadingView!.heightAnchor.constraint(equalToConstant: 100).isActive = true
                loadingView!.widthAnchor.constraint(equalToConstant: 100).isActive = true

                
            } else {
                messageLabel!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 25).isActive = true
                messageLabel!.bottomAnchor.constraint(equalTo: titleAndMessageStack.bottomAnchor, constant: -5).isActive = true
                messageLabel!.leftAnchor.constraint(equalTo: titleAndMessageStack!.leftAnchor, constant: 5).isActive = true
                messageLabel!.rightAnchor.constraint(equalTo: titleAndMessageStack!.rightAnchor, constant: -5).isActive = true
            }



        } else {
            hasTitle = false
            titleLabel?.isHidden = true
            if isLoadingView! {
                loadingView!.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor, constant: 0).isActive = true
                loadingView!.centerYAnchor.constraint(equalTo: customAlertView.centerYAnchor, constant: 0).isActive = true
                
            } else {
                messageLabel!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 5).isActive = true
                messageLabel!.leftAnchor.constraint(equalTo: titleAndMessageStack!.leftAnchor, constant: 5).isActive = true
                messageLabel!.rightAnchor.constraint(equalTo: titleAndMessageStack!.rightAnchor, constant: -5).isActive = true
                messageLabel!.bottomAnchor.constraint(equalTo: titleAndMessageStack!.bottomAnchor, constant: -5).isActive = true
            }

        }
        
        titleAndMessageStack.translatesAutoresizingMaskIntoConstraints = false

        if isLoadingView! {
            titleAndMessageStack.leftAnchor.constraint(equalTo: customAlertView.leftAnchor, constant: 0).isActive = true
            titleAndMessageStack.rightAnchor.constraint(equalTo: customAlertView.rightAnchor, constant: 0).isActive = true

        } else {
            titleAndMessageStack.leftAnchor.constraint(equalTo: customAlertView.leftAnchor, constant: 10).isActive = true
            titleAndMessageStack.rightAnchor.constraint(equalTo: customAlertView.rightAnchor, constant: -10).isActive = true

        }
        titleAndMessageStack.bottomAnchor.constraint(equalTo: customAlertView.bottomAnchor, constant: -58).isActive = true
        ///if has Icon at top of Alert
        titleAndMessageStack.topAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 10).isActive = true

        
        
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
