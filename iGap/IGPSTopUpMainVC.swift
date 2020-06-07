//
//  IGPSTopUpMainVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/6/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit

protocol chargeDelegate {
    func passData(charge: String)
}

class IGPSTopUpMainVC : MainViewController,chargeDelegate {
    
    private var vm : IGPSTopUpMainVM!
    let scrollView = IGScrollView()
    let defaultWidth : CGFloat = 260
    private var btnSubmit : IGKCustomButton!
    let P1000: Int64 = 10000
    let P2000: Int64 = 20000
    let P5000: Int64 = 50000
    let P10000: Int64 = 100000
    let P20000: Int64 = 200000
    let rials = IGStringsManager.Currency.rawValue.localized
    var chargePrice = [String]()
    var chargeAmount: Int64!

    private var selectedOperator : selectedOperator = .MTN
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

    private let btnMTN : UIView = {
        let btn = UIView()
        btn.backgroundColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 10)?.cgColor
        btn.layer.borderWidth = 2.0

        return btn

    }()
    private let btnMCI : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 10)?.cgColor
        btn.layer.borderWidth = 0.0

        return btn

    }()
    private let btnRightel : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 10)?.cgColor
        btn.layer.borderWidth = 0.0
        return btn

    }()
    private let attensionView : UIView = {
        let av = UIView()
        av.translatesAutoresizingMaskIntoConstraints = false
        av.backgroundColor = .clear
        av.layer.cornerRadius = 8
        av.layer.borderColor = UIColor.iGapRed().cgColor
        av.layer.borderWidth = 1.0
        return av

    }()


    private let btnChargeAmount : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 10), for: .normal)
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 10)?.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        return btn
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
        addOperators()
        addAttentionView()
        addChildView(type: pageType)
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

    private func addOperators() {
        self.scrollView.contentView.addSubview(btnMTN)

        btnMTN.topAnchor.constraint(equalTo: lblOperatorTitle.bottomAnchor,constant: 25).isActive = true
        btnMTN.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnMTN.heightAnchor.constraint(equalToConstant: 70).isActive = true
        btnMTN.centerXAnchor.constraint(equalTo: self.lblTitle.centerXAnchor).isActive = true

        self.scrollView.contentView.addSubview(btnMCI)

        btnMCI.topAnchor.constraint(equalTo: lblOperatorTitle.bottomAnchor,constant: 25).isActive = true
        btnMCI.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnMCI.heightAnchor.constraint(equalToConstant: 70).isActive = true
        btnMCI.leadingAnchor.constraint(equalTo: btnMTN.trailingAnchor,constant: 20).isActive = true

        self.scrollView.contentView.addSubview(btnRightel)

        btnRightel.topAnchor.constraint(equalTo: lblOperatorTitle.bottomAnchor,constant: 25).isActive = true
        btnRightel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnRightel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        btnRightel.trailingAnchor.constraint(equalTo: btnMTN.leadingAnchor,constant: -20).isActive = true


        let imgMCI = UIImageView()
        imgMCI.contentMode = .scaleAspectFit
        imgMCI.image = UIImage(named: "MCILogo")
        imgMCI.translatesAutoresizingMaskIntoConstraints = false
        btnMCI.addSubview(imgMCI)
        imgMCI.centerYAnchor.constraint(equalTo: btnMCI.centerYAnchor).isActive = true
        imgMCI.centerXAnchor.constraint(equalTo: btnMCI.centerXAnchor).isActive = true
        imgMCI.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imgMCI.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let imgMTN = UIImageView()
        imgMTN.contentMode = .scaleAspectFit

        imgMTN.image = UIImage(named: "MTNLogo")
        imgMTN.translatesAutoresizingMaskIntoConstraints = false
        btnMTN.addSubview(imgMTN)
        imgMTN.centerYAnchor.constraint(equalTo: btnMTN.centerYAnchor).isActive = true
        imgMTN.centerXAnchor.constraint(equalTo: btnMTN.centerXAnchor).isActive = true
        imgMTN.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imgMTN.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let imgRightel = UIImageView()
        imgRightel.contentMode = .scaleAspectFit

        imgRightel.image = UIImage(named: "RightelLogo")
        imgRightel.translatesAutoresizingMaskIntoConstraints = false
        btnRightel.addSubview(imgRightel)
        imgRightel.centerYAnchor.constraint(equalTo: btnRightel.centerYAnchor).isActive = true
        imgRightel.centerXAnchor.constraint(equalTo: btnRightel.centerXAnchor).isActive = true
        imgRightel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imgRightel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        
    }
    private func addAttentionView() {
        self.scrollView.contentView.addSubview(attensionView)

        attensionView.topAnchor.constraint(equalTo: btnMCI.bottomAnchor,constant: 10).isActive = true
        attensionView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        attensionView.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor,constant: 0).isActive = true
        attensionView.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor,constant: 0).isActive = true
        
        let lbl = UILabel()
        lbl.text = IGStringsManager.PSChoseOperatorMessage.rawValue.localized
        lbl.font = UIFont.igFont(ofSize: 10)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = ThemeManager.currentTheme.LabelColor

        let lblIcon = UILabel()
        lblIcon.text = ""
        lblIcon.font = UIFont.iGapFonticon(ofSize: 20)
        lblIcon.textAlignment = .center
        lblIcon.translatesAutoresizingMaskIntoConstraints = false
        lblIcon.textColor = UIColor.iGapRed()
        lblIcon.sizeToFit()

        attensionView.addSubview(lbl)
        attensionView.addSubview(lblIcon)
        lbl.centerYAnchor.constraint(equalTo: attensionView.centerYAnchor).isActive = true
        lbl.centerXAnchor.constraint(equalTo: attensionView.centerXAnchor).isActive = true

        lblIcon.centerYAnchor.constraint(equalTo: attensionView.centerYAnchor).isActive = true
        lblIcon.leadingAnchor.constraint(equalTo: lbl.trailingAnchor,constant: 2).isActive = true
        lblIcon.trailingAnchor.constraint(equalTo: attensionView.trailingAnchor,constant: -2).isActive = true
        lblIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true


    }
    private func addChildView(type : PaymentServicesType) {
        if type == .TopUp {
            addTOPUPView()
        } else {
            
        }
    }
    private func addTOPUPView() {
        self.scrollView.contentView.addSubview(btnChargeAmount)

        btnChargeAmount.topAnchor.constraint(equalTo: attensionView.bottomAnchor,constant: 25).isActive = true
        btnChargeAmount.widthAnchor.constraint(equalTo: lblTitle.widthAnchor,multiplier: 0.7).isActive = true
        btnChargeAmount.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnChargeAmount.centerXAnchor.constraint(equalTo: lblTitle.centerXAnchor).isActive = true
        btnChargeAmount.addTarget(self, action: #selector(didTapOnChargeAmount), for: .touchUpInside)
        
        let btnPlus = UIButton()
        btnPlus.setTitle("+", for: .normal)
        btnPlus.titleLabel?.font = UIFont.igFont(ofSize: 30)
        btnPlus.setTitleColor(.white, for: .normal)
        btnPlus.backgroundColor = UIColor.iGapGreen()
        btnPlus.layer.cornerRadius = 10
        btnPlus.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentView.addSubview(btnPlus)

        btnPlus.topAnchor.constraint(equalTo: attensionView.bottomAnchor,constant: 25).isActive = true
        btnPlus.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btnPlus.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnPlus.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor,constant: 0).isActive = true
        btnPlus.addTarget(self, action: #selector(didTapOnPlus), for: .touchUpInside)

        let btnMines = UIButton()
        btnMines.setTitle("-", for: .normal)
        btnMines.titleLabel?.font = UIFont.igFont(ofSize: 30)
        btnMines.setTitleColor(.white, for: .normal)
        btnMines.backgroundColor = UIColor.iGapRed()
        btnMines.layer.cornerRadius = 10
        btnMines.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentView.addSubview(btnMines)

        btnMines.topAnchor.constraint(equalTo: attensionView.bottomAnchor,constant: 25).isActive = true
        btnMines.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btnMines.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnMines.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor,constant: 0).isActive = true
        btnMines.addTarget(self, action: #selector(didTapOnMines), for: .touchUpInside)

        btnChargeAmount.setTitle("\(self.P5000) \(self.rials)".inLocalizedLanguage(), for: .normal)
    }
    @objc func didTapOnPlus() {
        print("DIDTAPONPLUS")
    }
    @objc func didTapOnMines() {
        print("DIDTAPONMINES")

    }
    @objc func didTapOnChargeAmount() {
        chargePrice = ["\(P1000) \(rials)" , "\(P2000) \(rials)" , "\(P5000) \(rials)", "\(P10000) \(rials)", "\(P20000) \(rials)"]
        IGHelperBottomModals.shared.showChargeList(view: self, chargeList: chargePrice)

        
    }
    private func addPackageView() {
        
    }
    private func addButtonSubmit() {
        manageButoonColor() // this method is forced because the button initializer is being called once
        scrollView.contentView.addSubview(btnSubmit)
        btnSubmit.cornerValue = 10
        btnSubmit.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor).isActive = true
        if pageType == .TopUp {
            btnSubmit.topAnchor.constraint(equalTo: btnChargeAmount.bottomAnchor, constant: 25).isActive = true

        } else {
            btnSubmit.topAnchor.constraint(equalTo: attensionView.bottomAnchor, constant: 25).isActive = true

        }
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
        btnMTN.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.btnRightel.layer.borderWidth = 0.0
            sSelf.btnMCI.layer.borderWidth = 0.0
            sSelf.btnMTN.layer.borderWidth = 2.0
        })
        btnMCI.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.btnRightel.layer.borderWidth = 0.0
            sSelf.btnMCI.layer.borderWidth = 2.0
            sSelf.btnMTN.layer.borderWidth = 0.0
        })
        btnRightel.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.btnRightel.layer.borderWidth = 2.0
            sSelf.btnMCI.layer.borderWidth = 0.0
            sSelf.btnMTN.layer.borderWidth = 0.0
        })
    }
    func passData(charge: String) {
        btnChargeAmount.setTitle(code, for: .normal)
    }

    
}
