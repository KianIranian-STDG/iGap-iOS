//
//  IGHelperPaymentService.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/6/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGHelperPaymentServices {
    

    enum helperAlertType : Int {
        case oneButton = 0
        case twoButton = 1
        case noButton = 2
    }
    private var actionBtnOne: (() -> Void)?
    private var actionBtnTwo: (() -> Void)?

    private var actionAccOneTap: (() -> Void)?
    private var actionAccTwoTap: (() -> Void)?
    private var actionDone: (() -> Void)?
    private var actionCancel: (() -> Void)?
    private var actionPick: (() -> Void)?

    static let shared = IGHelperPaymentServices()
    var customAlert : UIView!
    var iconView : UIView!
    var bgView : UIView!
    var maxHeightOfCustomAlert : CGFloat = (UIScreen.main.bounds.height - 100)
    let window = UIApplication.shared.keyWindow
    var imputTextfield : UITextField!
     func showAlertView(title: String, message: String?, subtitles: [String], alertClouser: @escaping ((_ title :String) -> Void), hasCancel: Bool = true){

        
        let option = UIAlertController(title: title, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        
        for subtitle in subtitles {
            let action = UIAlertAction(title: subtitle, style: .default, handler: { (action) in
                alertClouser(action.title!)
            })
            option.addAction(action)
        }
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        option.addAction(cancel)
        
        UIApplication.topViewController()!.present(option, animated: true, completion: {})
    }
    
    
    
    //MARK: - Development funcs
    @objc func didButtonOneGotTap() {
        if self.actionBtnOne != nil {
            actionBtnOne!()
            self.removeCustomAlertView()
            
        } else {
            self.removeCustomAlertView()
        }
    }

    @objc func didButtonTwoGotTap() {
        if self.actionBtnTwo != nil {
            if imputTextfield.text == "" {
                IGHelperToast.shared.showCustomToast(view: UIApplication.topViewController()!, showCancelButton: false, message: IGStringsManager.FillForm.rawValue.localized)
            } else {
                actionBtnTwo!()
                self.removeCustomAlertView()
                
            }
        } else {
            self.removeCustomAlertView()
        }
    }

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
