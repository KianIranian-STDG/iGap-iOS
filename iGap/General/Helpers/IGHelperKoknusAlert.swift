//
//  IGHelperKoknusAlert.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/1/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import Foundation
import UIKit

// IMPORTANT TODO - convert current class to builder
class IGHelperKoknusAlert {
    
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

    static let shared = IGHelperKoknusAlert()
    var customAlert : UIView!
    var iconView : UIView!
    var bgView : UIView!
    var maxHeightOfCustomAlert : CGFloat = (UIScreen.main.bounds.height - 100)
    let window = UIApplication.shared.keyWindow
    var imputTextfield : UITextField!
    
    func showResult(view: UIViewController? = nil, title: String? = nil , buttonOneTitleColor: UIColor = UIColor.darkGray,buttonOneBackColor : UIColor = UIColor.white, buttonOneText: String? = nil, buttonOneAction: (() -> Void)? = nil,data1: String,data2: String,data3: String?,data4: String) {
        
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

            
            self.setConstraintsToCustomAlert(customView: self.customAlert, view: alertView,height:280)///setConstraintsTo CustomeAlert
            ///create StackView for holding Buttons
            let stackButtons : UIStackView
            stackButtons = UIStackView()
            stackButtons.axis = .horizontal
            stackButtons.alignment = .fill
            stackButtons.distribution = .fillEqually
            stackButtons.spacing = 5
            self.customAlert.addSubview(stackButtons)
            ///set Constraints for stackView
            self.setConstraintsToButtonsStackView(customStack: stackButtons, customAlertView: self.customAlert)
            ///set Constraints for borderView above stack of Buttons
            self.customAlert.clipsToBounds = true

            
            let btnOne = UIButton()
            btnOne.layer.cornerRadius = 15
            btnOne.titleLabel!.font = UIFont.igFont(ofSize: 15,weight: .bold)
            btnOne.setTitle(buttonOneText, for: .normal)
            btnOne.backgroundColor = buttonOneBackColor
            btnOne.setTitleColor(buttonOneTitleColor, for: .normal)
            
            stackButtons.addArrangedSubview(btnOne)
            ////DOne Tap GEsture Handler
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didButtonOneGotTap))
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.numberOfTouchesRequired = 1
            btnOne.addGestureRecognizer(tapGestureRecognizer)
                
                
            stackButtons.translatesAutoresizingMaskIntoConstraints = false

            let stackTitleAndIcon = UIStackView()
            createCloseAndTitleStack(stk: stackTitleAndIcon,title: title!,customAlertView: self.customAlert)
            createLabels(stk : stackTitleAndIcon ,customAlertView: self.customAlert,data1: data1,data2: data2, data3: data3! ,data4: data4 ,button: btnOne)

            self.actionBtnOne = buttonOneAction
            self.customAlert?.alpha = 0
            self.customAlert?.fadeIn(0.3)
        }

        
    }
    
    private func createLabels(stk : UIStackView,customAlertView: UIView,data1: String,data2: String,data3: String,data4: String,button: UIButton) {
        let lblOneTitle = UILabel()
        let lblTwoTitle = UILabel()
        let lblThreeTitle = UILabel()
        let lblFourTitle = UILabel()
        
        lblOneTitle.text = IGStringsManager.KAssetCount.rawValue.localized
        lblTwoTitle.text = IGStringsManager.KAssetPrice.rawValue.localized
        lblThreeTitle.text = IGStringsManager.KTotalPrice.rawValue.localized
        lblFourTitle.text = IGStringsManager.KHash.rawValue.localized

        lblOneTitle.font = UIFont.igFont(ofSize: 13)
        lblTwoTitle.font = UIFont.igFont(ofSize: 13)
        lblThreeTitle.font = UIFont.igFont(ofSize: 13)
        lblFourTitle.font = UIFont.igFont(ofSize: 13)

        lblOneTitle.textAlignment = lblOneTitle.localizedDirection
        lblTwoTitle.textAlignment = lblTwoTitle.localizedDirection
        lblThreeTitle.textAlignment = lblThreeTitle.localizedDirection
        lblFourTitle.textAlignment = lblFourTitle.localizedDirection

        lblOneTitle.translatesAutoresizingMaskIntoConstraints = false
        lblTwoTitle.translatesAutoresizingMaskIntoConstraints = false
        lblThreeTitle.translatesAutoresizingMaskIntoConstraints = false
        lblFourTitle.translatesAutoresizingMaskIntoConstraints = false

        let lblOneData = UILabel()
        let lblTwoData = UILabel()
        let lblThreeData = UILabel()
        let lblFourData = UILabel()
        
        lblOneData.translatesAutoresizingMaskIntoConstraints = false
        lblTwoData.translatesAutoresizingMaskIntoConstraints = false
        lblThreeData.translatesAutoresizingMaskIntoConstraints = false
        lblFourData.translatesAutoresizingMaskIntoConstraints = false

        lblOneData.text = data1
        lblTwoData.text = data2 + IGStringsManager.Currency.rawValue.localized
        lblThreeData.text = data3 + IGStringsManager.Currency.rawValue.localized
        lblFourData.text = data4

        lblOneData.textAlignment = lblOneData.localizedDirection
        lblTwoData.textAlignment = lblTwoData.localizedDirection
        lblThreeData.textAlignment = lblThreeData.localizedDirection
        lblFourData.textAlignment = lblFourData.localizedDirection

        lblOneData.font = UIFont.igFont(ofSize: 13)
        lblTwoData.font = UIFont.igFont(ofSize: 13)
        lblThreeData.font = UIFont.igFont(ofSize: 13)
        lblFourData.font = UIFont.igFont(ofSize: 13)
        lblFourData.numberOfLines = 2
        
        customAlertView.addSubview(lblOneTitle)
        customAlertView.addSubview(lblTwoTitle)
        customAlertView.addSubview(lblThreeTitle)
        customAlertView.addSubview(lblFourTitle)
        
        lblOneTitle.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblOneTitle.topAnchor.constraint(equalTo: stk.bottomAnchor,constant: 10).isActive = true
        lblOneTitle.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true

        lblTwoTitle.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblTwoTitle.topAnchor.constraint(equalTo: lblOneTitle.bottomAnchor,constant: 10).isActive = true
        lblTwoTitle.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true

        lblThreeTitle.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblThreeTitle.topAnchor.constraint(equalTo: lblTwoTitle.bottomAnchor,constant: 10).isActive = true
        lblThreeTitle.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true

        lblFourTitle.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblFourTitle.topAnchor.constraint(equalTo: lblThreeTitle.bottomAnchor,constant: 10).isActive = true
        lblFourTitle.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true
        lblFourTitle.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true

        customAlertView.addSubview(lblOneData)
        customAlertView.addSubview(lblTwoData)
        customAlertView.addSubview(lblThreeData)
        customAlertView.addSubview(lblFourData)
        
        lblOneData.topAnchor.constraint(equalTo: lblOneTitle.topAnchor).isActive = true
        lblOneData.leadingAnchor.constraint(equalTo: lblOneTitle.trailingAnchor,constant: 10).isActive = true
        lblOneData.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true

        lblTwoData.topAnchor.constraint(equalTo: lblOneData.bottomAnchor,constant: 10).isActive = true
        lblTwoData.leadingAnchor.constraint(equalTo: lblTwoTitle.trailingAnchor,constant: 10).isActive = true
        lblTwoData.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true

        lblThreeData.topAnchor.constraint(equalTo: lblTwoData.bottomAnchor,constant: 10).isActive = true
        lblThreeData.leadingAnchor.constraint(equalTo: lblThreeTitle.trailingAnchor,constant: 10).isActive = true
        lblThreeData.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true

        lblFourData.topAnchor.constraint(equalTo: lblFourTitle.bottomAnchor,constant: 10).isActive = true
        lblFourData.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor,constant: 10).isActive = true
        lblFourData.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor,constant: -10).isActive = true


        if LocaleManager.isRTL {
            customAlertView.semanticContentAttribute = .forceRightToLeft
        } else {
            customAlertView.semanticContentAttribute = .forceLeftToRight
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
        
        titleLabel.textAlignment = .center
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
