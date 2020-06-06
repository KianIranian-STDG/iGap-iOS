//
//  IGPSTopUpMainVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/6/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit

class IGPSTopUpMainVC : MainViewController {
    
    private var vm : IGPSTopUpMainVM!
    let scrollView = IGScrollView()
    let defaultWidth : CGFloat = 260
    private var btnSubmit : IGKCustomButton!

    var pageType : PaymentServicesType = .TopUp {
        didSet {
            if pageType == .TopUp {
                lblTitle.text = IGStringsManager.ChargeSimCard.rawValue.localized
                titlePage = IGStringsManager.ChargeSimCard.rawValue.localized


            } else if pageType == .NetworkPackage {
                lblTitle.text = IGStringsManager.BuyInternetPackage.rawValue.localized
                titlePage = IGStringsManager.BuyInternetPackage.rawValue.localized


            } else {
                lblTitle.text = IGStringsManager.ChargeSimCard.rawValue.localized
                titlePage = IGStringsManager.ChargeSimCard.rawValue.localized

            }
        }
    }
    private var titlePage : String = ""
    private let lblTitle : UILabel = {
        
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 15,weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = lbl.localizedDirection
        lbl.textColor = ThemeManager.currentTheme.LabelColor

        return lbl
    }()
    private let tfPhoneNUmber : UITextField = {
        
        let tf = UITextField()
        tf.font = UIFont.igFont(ofSize: 15,weight: .bold)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textAlignment = tf.localizedDirection
        tf.placeholder = IGStringsManager.MobileNumber.rawValue.localized
        tf.textColor = ThemeManager.currentTheme.LabelColor
        tf.backgroundColor = .clear
        tf.layer.cornerRadius = 10
        tf.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tf.layer.borderWidth = 1.0
        tf.setLeftPaddingPoints(10)
        tf.setRightPaddingPoints(10)
        tf.keyboardType = .phonePad
        return tf
    }()
    private let btnContactList : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btn.backgroundColor = UIColor.lightGray.lighter(by: 20)

        return btn
    }()
    private let btnLastPurchases : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btn.backgroundColor = UIColor.lightGray.lighter(by: 20)

        return btn
    }()
    
    private let lblOperatorTitle : UILabel = {
        
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 15,weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = lbl.localizedDirection
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.ChooseOperatorTitle.rawValue.localized
        return lbl
    }()
    private let  operatorsHolder : UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.distribution = .fillEqually
        stk.alignment = .fill
        stk.spacing = 10
        return stk
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = IGPSTopUpMainVM(viewController: self)
        initView()
        initCustomtNav(title: titlePage)
        self.view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor

    }
    private func initView() {
        setupScrollView()
        addContents()
        manageSemantic()
    }
    private func manageSemantic() {
        self.scrollView.contentView.semanticContentAttribute = self.semantic
    }
    private func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    private func addContents() {
        addTitleLabel()
        addPhoneTextField()
        addButtonsContacts()
        addButtonLastPurchases()
        addOperatorTitle()
        addOperatorsHolder()
        addButtonSubmit()
        manageActions()
    }
    private func addTitleLabel() {
        self.scrollView.contentView.addSubview(lblTitle)

        lblTitle.topAnchor.constraint(equalTo: self.scrollView.contentView.topAnchor,constant: 25).isActive = true
        lblTitle.centerXAnchor.constraint(equalTo: self.scrollView.contentView.centerXAnchor).isActive = true
        lblTitle.leadingAnchor.constraint(equalTo: self.scrollView.contentView.leadingAnchor , constant: 30).isActive = true
        lblTitle.trailingAnchor.constraint(equalTo: self.scrollView.contentView.trailingAnchor , constant: -30).isActive = true
    }
    private func addPhoneTextField() {
        self.scrollView.contentView.addSubview(tfPhoneNUmber)

        tfPhoneNUmber.topAnchor.constraint(equalTo: lblTitle.bottomAnchor,constant: 10).isActive = true
        tfPhoneNUmber.centerXAnchor.constraint(equalTo: self.scrollView.contentView.centerXAnchor).isActive = true
        tfPhoneNUmber.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tfPhoneNUmber.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor , constant: 0).isActive = true
        tfPhoneNUmber.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor , constant: 0).isActive = true

    }
    private func addButtonsContacts() {
        self.scrollView.contentView.addSubview(btnContactList)

        btnContactList.topAnchor.constraint(equalTo: tfPhoneNUmber.bottomAnchor,constant: 10).isActive = true
        btnContactList.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnContactList.leadingAnchor.constraint(equalTo: self.scrollView.contentView.centerXAnchor,constant: 10).isActive = true
        btnContactList.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor,constant: 0).isActive = true
        
        let lbl = UILabel()
        lbl.text = IGStringsManager.Contacts.rawValue.localized
        lbl.font = UIFont.igFont(ofSize: 10)
        lbl.textAlignment = .center
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        let lblIcon = UILabel()
        lblIcon.text = ""
        lblIcon.font = UIFont.iGapFonticon(ofSize: 20)
        lblIcon.textAlignment = .center
        lblIcon.textColor = ThemeManager.currentTheme.LabelColor
        lblIcon.translatesAutoresizingMaskIntoConstraints = false
        
        btnContactList.addSubview(lbl)
        btnContactList.addSubview(lblIcon)
        lbl.centerYAnchor.constraint(equalTo: btnContactList.centerYAnchor).isActive = true
        lbl.leadingAnchor.constraint(equalTo: btnContactList.leadingAnchor,constant: 25).isActive = true
        lbl.trailingAnchor.constraint(equalTo: btnContactList.trailingAnchor,constant: -25).isActive = true

        lblIcon.centerYAnchor.constraint(equalTo: btnContactList.centerYAnchor).isActive = true
        lblIcon.trailingAnchor.constraint(equalTo: btnContactList.trailingAnchor,constant: -5).isActive = true
        lblIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true


    }
    private func addButtonLastPurchases() {
        self.scrollView.contentView.addSubview(btnLastPurchases)

        btnLastPurchases.topAnchor.constraint(equalTo: tfPhoneNUmber.bottomAnchor,constant: 10).isActive = true
        btnLastPurchases.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnLastPurchases.trailingAnchor.constraint(equalTo: self.scrollView.contentView.centerXAnchor,constant: -10).isActive = true
        btnLastPurchases.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor,constant: 0).isActive = true
        
        
        let lbl = UILabel()
        lbl.text = IGStringsManager.PSLastPurchases.rawValue.localized
        lbl.font = UIFont.igFont(ofSize: 10)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = ThemeManager.currentTheme.LabelColor

        let lblIcon = UILabel()
        lblIcon.text = ""
        lblIcon.font = UIFont.iGapFonticon(ofSize: 20)
        lblIcon.textAlignment = .center
        lblIcon.translatesAutoresizingMaskIntoConstraints = false
        lblIcon.textColor = ThemeManager.currentTheme.LabelColor

        btnLastPurchases.addSubview(lbl)
        btnLastPurchases.addSubview(lblIcon)
        lbl.centerYAnchor.constraint(equalTo: btnLastPurchases.centerYAnchor).isActive = true
        lbl.leadingAnchor.constraint(equalTo: btnLastPurchases.leadingAnchor,constant: 25).isActive = true
        lbl.trailingAnchor.constraint(equalTo: btnLastPurchases.trailingAnchor,constant: -25).isActive = true

        lblIcon.centerYAnchor.constraint(equalTo: btnLastPurchases.centerYAnchor).isActive = true
        lblIcon.trailingAnchor.constraint(equalTo: btnLastPurchases.trailingAnchor,constant: -5).isActive = true
        lblIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        


    }
    private func addOperatorTitle() {
        self.scrollView.contentView.addSubview(lblOperatorTitle)

        lblOperatorTitle.topAnchor.constraint(equalTo: btnLastPurchases.bottomAnchor,constant: 25).isActive = true
        lblOperatorTitle.leadingAnchor.constraint(equalTo: self.scrollView.contentView.leadingAnchor , constant: 30).isActive = true
        lblOperatorTitle.trailingAnchor.constraint(equalTo: self.scrollView.contentView.trailingAnchor , constant: -30).isActive = true
    }

    private func addOperatorsHolder() {
        self.scrollView.contentView.addSubview(operatorsHolder)

        operatorsHolder.topAnchor.constraint(equalTo: lblOperatorTitle.bottomAnchor,constant: 25).isActive = true
        operatorsHolder.heightAnchor.constraint(equalToConstant: 80).isActive = true
        operatorsHolder.leadingAnchor.constraint(equalTo: self.scrollView.contentView.leadingAnchor , constant: 30).isActive = true
        operatorsHolder.trailingAnchor.constraint(equalTo: self.scrollView.contentView.trailingAnchor , constant: -30).isActive = true
        
//        let btnMCI = UIView()
//        let btnMTN = UIView()
//        let btnRightel = UIView()
//        
//        
//        btnMCI.translatesAutoresizingMaskIntoConstraints = false
//        btnMTN.translatesAutoresizingMaskIntoConstraints = false
//        btnRightel.translatesAutoresizingMaskIntoConstraints = false
//
//        btnRightel.backgroundColor = .red
//        btnMTN.backgroundColor = .red
//        btnMCI.backgroundColor = .red
//        operatorsHolder.addArrangedSubview(btnMCI)
//        operatorsHolder.addArrangedSubview(btnMTN)
//        operatorsHolder.addArrangedSubview(btnRightel)

        
    }
    private func addButtonSubmit() {
        manageButoonColor() // this method is forced because the button initializer is being called once
        scrollView.contentView.addSubview(btnSubmit)
        btnSubmit.cornerValue = 10
        btnSubmit.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor).isActive = true
        btnSubmit.topAnchor.constraint(equalTo: lblOperatorTitle.bottomAnchor, constant: 25).isActive = true
        btnSubmit.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor, multiplier: 3/4).isActive = true
        btnSubmit.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnSubmit.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor).isActive = true

    }
    private func manageButoonColor() {
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                btnSubmit = IGKCustomButton(title: IGStringsManager.Send.rawValue.localized ,backColor: ThemeManager.currentTheme.NavigationSecondColor)
            case .dark:
                btnSubmit = IGKCustomButton(title: IGStringsManager.Send.rawValue.localized ,backColor: ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 20)!)
            default :
                break            }
        } else {
            btnSubmit = IGKCustomButton(title: IGStringsManager.Send.rawValue.localized ,backColor: ThemeManager.currentTheme.NavigationSecondColor)
        }
    }
    private func manageActions() {
        btnSubmit.addAction {
        }
    }

    
}
