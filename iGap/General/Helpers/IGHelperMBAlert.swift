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
    
    private var actionAccOneTap: (() -> Void)?
    private var actionAccTwoTap: (() -> Void)?
    private var actionDone: (() -> Void)?
    private var actionCancel: (() -> Void)?
    private var actionPick: (() -> Void)?

    static let shared = IGHelperMBAlert()
    var customAlert : UIView!
    var iconView : UIView!
    var bgView : UIView!
    var maxHeightOfCustomAlert : CGFloat = (UIScreen.main.bounds.height - 100)
    let window = UIApplication.shared.keyWindow
    
    
    func showPickAccount(view: UIViewController? = nil,accountsArray: [String], alertType: helperAlertType! = helperAlertType.oneButton, title: String? = nil , cancelTitleColor: UIColor = UIColor.darkGray,cancelBackColor : UIColor = UIColor.white, cancelText: String? = nil, cancel: (() -> Void)? = nil, accountOneDidTap: (() -> Void)? = nil, accountTwoDidTap: (() -> Void)? = nil) {
        
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

            
            self.setConstraintsToCustomAlert(customView: self.customAlert, view: alertView,height:250)///setConstraintsTo CustomeAlert
            ///create StackView for holding Buttons
            let stackButtons : UIStackView
            stackButtons = UIStackView()
            stackButtons.axis = .horizontal
            stackButtons.alignment = .fill
            stackButtons.distribution = .fillEqually
            stackButtons.spacing = 5
            if alertType != helperAlertType.noButton {
                self.customAlert.addSubview(stackButtons)
                ///set Constraints for stackView
                self.setConstraintsToButtonsStackView(customStack: stackButtons, customAlertView: self.customAlert)
                ///set Constraints for borderView above stack of Buttons
                self.customAlert.clipsToBounds = true
                if alertType == helperAlertType.oneButton {
                    let btnCancel = UIButton()
                    btnCancel.layer.cornerRadius = 15
                    btnCancel.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnCancel.setTitle(cancelText, for: .normal)
                    btnCancel.backgroundColor = cancelBackColor
                    btnCancel.setTitleColor(cancelTitleColor, for: .normal)

                    stackButtons.addArrangedSubview(btnCancel)
                    ////DOne Tap GEsture Handler
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didDoneGotTap))
                    tapGestureRecognizer.numberOfTapsRequired = 1
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    btnCancel.addGestureRecognizer(tapGestureRecognizer)

                }

            }
            stackButtons.translatesAutoresizingMaskIntoConstraints = false

            let stackTitleAndIcon = UIStackView()
            createCloseAndTitleStack(stk: stackTitleAndIcon,title: title!,customAlertView: self.customAlert)

            let stkAccounts = UIStackView()
            stkAccounts.axis = .vertical
            stkAccounts.spacing = 10
            stkAccounts.alignment = .fill
            stkAccounts.distribution = .fillEqually
            let tapGestureRecognizerAccOne = UITapGestureRecognizer(target: self, action: #selector(self.didAccOneGotTap))
            let tapGestureRecognizerAccTwo = UITapGestureRecognizer(target: self, action: #selector(self.didAccTwoGotTap))


            self.customAlert.addSubview(stkAccounts)
            stkAccounts.translatesAutoresizingMaskIntoConstraints = false
            stkAccounts.leadingAnchor.constraint(equalTo: self.customAlert.leadingAnchor,constant: 20).isActive = true
            stkAccounts.trailingAnchor.constraint(equalTo: self.customAlert.trailingAnchor,constant: -20).isActive = true
            stkAccounts.topAnchor.constraint(equalTo: stackTitleAndIcon.bottomAnchor,constant: 20).isActive = true
            stkAccounts.bottomAnchor.constraint(equalTo: stackButtons.topAnchor,constant: -20).isActive = true


            let btnAccOne = UIButton()
            btnAccOne.setTitle(accountsArray[0], for: .normal)
            btnAccOne.layer.borderColor = cancelBackColor.cgColor
            btnAccOne.layer.borderWidth = 1.0
            btnAccOne.layer.cornerRadius = 10
            btnAccOne.setTitleColor(.lightGray, for: .normal)
            stkAccounts.addArrangedSubview(btnAccOne)
            tapGestureRecognizerAccOne.numberOfTapsRequired = 1
            tapGestureRecognizerAccOne.numberOfTouchesRequired = 1
            btnAccOne.addGestureRecognizer(tapGestureRecognizerAccOne)

            stkAccounts.addArrangedSubview(btnAccOne)
            let btnAccTwo = UIButton()
            btnAccTwo.setTitle(accountsArray[1], for: .normal)
            btnAccTwo.layer.borderColor = cancelBackColor.cgColor
            btnAccTwo.layer.borderWidth = 1.0
            btnAccTwo.layer.cornerRadius = 10
            btnAccTwo.setTitleColor(.lightGray, for: .normal)
            stkAccounts.addArrangedSubview(btnAccTwo)
            tapGestureRecognizerAccTwo.numberOfTapsRequired = 1
            tapGestureRecognizerAccTwo.numberOfTouchesRequired = 1
            btnAccTwo.addGestureRecognizer(tapGestureRecognizerAccTwo)

            stkAccounts.addArrangedSubview(btnAccTwo)

            

            
            


            self.actionAccOneTap = accountOneDidTap
            self.actionAccTwoTap = accountTwoDidTap
            self.actionCancel = cancel
            self.customAlert?.alpha = 0
            self.customAlert?.fadeIn(0.3)
        }

        
    }
    func showMessageAlert(view: UIViewController? = nil, alertType: helperAlertType! = helperAlertType.twoButton, title: String? = nil ,doneTitleColor: UIColor = UIColor.darkGray, cancelTitleColor: UIColor = UIColor.darkGray,doneBackColor : UIColor = UIColor.white,cancelBackColor : UIColor = UIColor.white, doneText: String? = nil, cancelText: String? = nil,message: String!, cancel: (() -> Void)? = nil, done: (() -> Void)? = nil) {
        
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
            let heightOfAlert = self.detectHeightOfMessage(widthOfAlert: 230, message: message, font: UIFont.igFont(ofSize: 13)) + 150

            self.setConstraintsToCustomAlert(customView: self.customAlert, view: alertView,height:heightOfAlert)///setConstraintsTo CustomeAlert
            ///create StackView for holding Buttons
            let stackButtons : UIStackView
            stackButtons = UIStackView()
            stackButtons.axis = .horizontal
            stackButtons.alignment = .fill
            stackButtons.distribution = .fillEqually
            stackButtons.spacing = 5
            if alertType != helperAlertType.noButton {
                self.customAlert.addSubview(stackButtons)
                ///set Constraints for stackView
                self.setConstraintsToButtonsStackView(customStack: stackButtons, customAlertView: self.customAlert)
                ///set Constraints for borderView above stack of Buttons
                self.customAlert.clipsToBounds = true
                if alertType == helperAlertType.oneButton {
                    let btnDone = UIButton()
                    btnDone.layer.cornerRadius = 15
                    btnDone.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnDone.setTitle(doneText, for: .normal)
                    btnDone.backgroundColor = doneBackColor
                    btnDone.setTitleColor(doneTitleColor, for: .normal)

                    stackButtons.addArrangedSubview(btnDone)
                    ////DOne Tap GEsture Handler
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didDoneGotTap))
                    tapGestureRecognizer.numberOfTapsRequired = 1
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    btnDone.addGestureRecognizer(tapGestureRecognizer)

                

                } else {
                    let btnDone = UIButton()
                    let btnCancel = UIButton()
                    btnDone.layer.cornerRadius = 15
                    btnCancel.layer.cornerRadius = 15
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

                }

            }
            stackButtons.translatesAutoresizingMaskIntoConstraints = false

            let stackTitleAndIcon = UIStackView()
            createCloseAndTitleStack(stk: stackTitleAndIcon,title: title!,customAlertView: self.customAlert)

            let messageLabel = UILabel()
            self.customAlert.addSubview(messageLabel)
            messageLabel.font = UIFont.igFont(ofSize: 13,weight: .bold)
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            
            messageLabel.textColor = ThemeManager.currentTheme.LabelColor

            messageLabel.textAlignment = .center

            messageLabel.translatesAutoresizingMaskIntoConstraints = false

            messageLabel.leadingAnchor.constraint(equalTo: customAlert.leadingAnchor,constant: 10).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: customAlert.trailingAnchor,constant: -10).isActive = true
            messageLabel.centerYAnchor.constraint(equalTo: customAlert.centerYAnchor, constant: -30).isActive = true
            
            
            self.actionDone = done
                self.actionCancel = cancel
            self.customAlert?.alpha = 0
            self.customAlert?.fadeIn(0.3)



            
        }

        
    }
    func showAddAccount(view: UIViewController? = nil, alertType: helperAlertType! = helperAlertType.twoButton, title: String? = nil ,doneTitleColor: UIColor = UIColor.darkGray, cancelTitleColor: UIColor = UIColor.darkGray,doneBackColor : UIColor = UIColor.white,cancelBackColor : UIColor = UIColor.white, doneText: String? = nil, cancelText: String? = nil, cancel: (() -> Void)? = nil, done: (() -> Void)? = nil) {
        
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

            self.setConstraintsToCustomAlert(customView: self.customAlert, view: alertView,height:300)///setConstraintsTo CustomeAlert
            ///create StackView for holding Buttons
            let stackButtons : UIStackView
            stackButtons = UIStackView()
            stackButtons.axis = .horizontal
            stackButtons.alignment = .fill
            stackButtons.distribution = .fillEqually
            stackButtons.spacing = 5
            if alertType != helperAlertType.noButton {
                self.customAlert.addSubview(stackButtons)
                ///set Constraints for stackView
                self.setConstraintsToButtonsStackView(customStack: stackButtons, customAlertView: self.customAlert)
                ///set Constraints for borderView above stack of Buttons
                self.customAlert.clipsToBounds = true
                if alertType == helperAlertType.oneButton {
                    let btnDone = UIButton()
                    btnDone.layer.cornerRadius = 15
                    btnDone.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    btnDone.setTitle(doneText, for: .normal)
                    btnDone.backgroundColor = doneBackColor
                    btnDone.setTitleColor(doneTitleColor, for: .normal)

                    stackButtons.addArrangedSubview(btnDone)
                    ////DOne Tap GEsture Handler
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didDoneGotTap))
                    tapGestureRecognizer.numberOfTapsRequired = 1
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    btnDone.addGestureRecognizer(tapGestureRecognizer)

                

                } else {
                    let btnDone = UIButton()
                    let btnCancel = UIButton()
                    btnDone.layer.cornerRadius = 15
                    btnCancel.layer.cornerRadius = 15
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

                }

            }
            stackButtons.translatesAutoresizingMaskIntoConstraints = false

            let stackTitleAndIcon = UIStackView()
            createCloseAndTitleStack(stk: stackTitleAndIcon,title: title!,customAlertView: self.customAlert)
            addAccountData(customAlertView: self.customAlert)
            
            self.actionDone = done
                self.actionCancel = cancel
            self.customAlert?.alpha = 0
            self.customAlert?.fadeIn(0.3)



            
        }

        
    }
    private func createCloseAndTitleStack(stk : UIStackView,title : String,customAlertView: UIView) {
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.distribution = .fill

        let titleLabel = UILabel()
        let titleIcon = UILabel()
        
        titleLabel.font = UIFont.igFont(ofSize: 13,weight: .bold)
        titleIcon.font = UIFont.iGapFonticon(ofSize: 13)
        titleIcon.text = ""
        titleLabel.numberOfLines = 1
        
        titleLabel.textColor = ThemeManager.currentTheme.LabelColor
        titleIcon.textColor = ThemeManager.currentTheme.LabelColor
        
        titleLabel.textAlignment = titleLabel.localizedDirection
        titleIcon.textAlignment = .left
        stk.addArrangedSubview(titleIcon)
        stk.addArrangedSubview(titleLabel)
        titleLabel.text = title
        
        customAlertView.addSubview(stk)
        
        stk.translatesAutoresizingMaskIntoConstraints = false

        stk.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true
        stk.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true
        stk.topAnchor.constraint(equalTo: customAlertView.topAnchor,constant: 10).isActive = true



    }
    private func addAccountData(customAlertView: UIView) {
        let labelAccount = UILabel()
        let txtAccountNumber = UITextField()
        labelAccount.text = "Account Number"
        labelAccount.textAlignment = .center
        labelAccount.font = UIFont.igFont(ofSize: 13)
        
        txtAccountNumber.textContentType = .creditCardNumber
        txtAccountNumber.layer.borderColor = UIColor.black.cgColor
        txtAccountNumber.layer.borderWidth = 0.5
        txtAccountNumber.layer.cornerRadius = 5
        
        customAlertView.addSubview(labelAccount)
        customAlertView.addSubview(txtAccountNumber)
        labelAccount.translatesAutoresizingMaskIntoConstraints = false
        labelAccount.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true
        labelAccount.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true
        labelAccount.topAnchor.constraint(equalTo: customAlertView.topAnchor,constant: 50).isActive = true

        txtAccountNumber.translatesAutoresizingMaskIntoConstraints = false
        txtAccountNumber.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 40).isActive = true
        txtAccountNumber.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -40).isActive = true
        txtAccountNumber.topAnchor.constraint(equalTo: labelAccount.bottomAnchor,constant: 10).isActive = true
        txtAccountNumber.heightAnchor.constraint(equalToConstant: 30).isActive = true

        
        let lblLocalPass = UILabel()
        let txtLocalPass = UITextField()
        lblLocalPass.text = "Local Password"
        lblLocalPass.textAlignment = .center
        lblLocalPass.font = UIFont.igFont(ofSize: 13)
        
        txtLocalPass.textContentType = .password
        txtLocalPass.layer.borderColor = UIColor.black.cgColor
        txtLocalPass.layer.borderWidth = 0.5
        txtLocalPass.layer.cornerRadius = 5
        
        customAlertView.addSubview(lblLocalPass)
        customAlertView.addSubview(txtLocalPass)
        lblLocalPass.translatesAutoresizingMaskIntoConstraints = false
        lblLocalPass.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true
        lblLocalPass.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true
        lblLocalPass.topAnchor.constraint(equalTo: txtAccountNumber.bottomAnchor,constant: 30).isActive = true

        txtLocalPass.translatesAutoresizingMaskIntoConstraints = false
        txtLocalPass.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 40).isActive = true
        txtLocalPass.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -40).isActive = true
        txtLocalPass.topAnchor.constraint(equalTo: lblLocalPass.bottomAnchor,constant: 10).isActive = true
        txtLocalPass.heightAnchor.constraint(equalToConstant: 30).isActive = true


    }
    
    
    
    
    
    
    
    
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
                        heightOfAlert = 200
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
                    btnCancel.layer.cornerRadius = 15
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
                    let loading = AnimateloadingView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                
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
                titleIcon.textAlignment = .left
                    stackTitleAndIcon.addArrangedSubview(titleIcon)
                    stackTitleAndIcon.addArrangedSubview(titleLabel)
                    stackTitleAndMessage.addArrangedSubview(stackTitleAndIcon)

                stackTitleAndMessage.addArrangedSubview(messageLabel)
                        stackTitleAndMessage.addArrangedSubview(loading)
                        stackTitleAndMessage.alignment = .center
                        stackTitleAndIcon.alignment = .fill

                

                if isLoading {
                    messageLabel.isHidden = true
                    loading.isHidden = false
                    loading.startAnimating(hideBG: true, color: .iGapGreen())
                } else {
                    messageLabel.isHidden = false
                    loading.isHidden = true


                }
                
                    if title != nil {
                        titleLabel.text = title
                        self.setConstraintsToTitleAndMessage(titleAndMessageStack: stackTitleAndMessage, titleLabel: titleLabel,titleIcon: titleIcon, messageLabel: messageLabel, customAlertView: self.customAlert,isLoadingView: isLoading,loadingView : loading)
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
    @objc func didAccOneGotTap() {
        if self.actionAccOneTap != nil {
            actionAccOneTap!()
            self.removeCustomAlertView()
            
        } else {
            self.removeCustomAlertView()
        }
    }
    @objc func didAccTwoGotTap() {
        if self.actionAccTwoTap != nil {
            actionAccTwoTap!()
            self.removeCustomAlertView()
            
        } else {
            self.removeCustomAlertView()
        }
    }
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
    
    private func setConstraintsToTitleAndMessage(titleAndMessageStack: UIStackView!,titleLabel: UILabel? = nil,titleIcon: UILabel? = nil , messageLabel: UILabel? = nil,customAlertView: UIView!,isLoadingView: Bool? = false, loadingView : UIView? = nil) {
        var hasTitle: Bool = true
        
        if titleLabel != nil {
            //            titleLabel!.translatesAutoresizingMaskIntoConstraints = false
            

            titleIcon!.heightAnchor.constraint(equalToConstant: 20).isActive = true
            titleIcon!.widthAnchor.constraint(equalToConstant: 20).isActive = true
            titleIcon!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 5).isActive = true
            titleIcon!.leadingAnchor.constraint(equalTo: titleAndMessageStack!.leadingAnchor, constant: 0).isActive = true

            titleLabel!.heightAnchor.constraint(equalToConstant: 20).isActive = true
            titleLabel!.topAnchor.constraint(equalTo: titleAndMessageStack!.topAnchor, constant: 5).isActive = true
            titleLabel!.leadingAnchor.constraint(equalTo: titleIcon!.leadingAnchor, constant: 30).isActive = true
            titleLabel!.trailingAnchor.constraint(equalTo: titleAndMessageStack!.trailingAnchor, constant: 0).isActive = true


            if isLoadingView! {
                titleLabel!.trailingAnchor.constraint(equalTo: titleAndMessageStack!.trailingAnchor, constant: -20).isActive = true

                loadingView!.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor, constant: 0).isActive = true
                loadingView!.centerYAnchor.constraint(equalTo: customAlertView.centerYAnchor, constant: 0).isActive = true
                loadingView!.heightAnchor.constraint(equalToConstant: 50).isActive = true
                loadingView!.widthAnchor.constraint(equalToConstant: 50).isActive = true

                
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
            titleAndMessageStack.leftAnchor.constraint(equalTo: customAlertView.leftAnchor, constant: 10).isActive = true
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
