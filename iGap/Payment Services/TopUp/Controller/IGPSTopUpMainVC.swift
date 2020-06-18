//
//  IGPSTopUpMainVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/6/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus

protocol chargeDelegate {
    func passData(phone: [String: String], currentOperator: String)
    func passDataInternet(phone: [String: String], currentOperator: String, selectedPackage: IGPSLastInternetPackagesPurchases)

}

class IGPSTopUpMainVC : MainViewController,chargeDelegate {
    
    private var vm : IGPSTopUpMainVM!
    let scrollView = IGScrollView()
    let defaultWidth : CGFloat = 260
    var heightC : NSLayoutConstraint!
    private var btnSubmit : IGKCustomButton!
    let P1000: Int64 = 10000
    let P2000: Int64 = 20000
    let P5000: Int64 = 50000
    let P10000: Int64 = 100000
    let P20000: Int64 = 200000
    let rials = IGStringsManager.Currency.rawValue.localized
    var chargePrice = [String]()
    var chargeType = [String]()
    var selectedCharge = [String : Int]()
    var selectedChargeType : [String : Int]! {
        didSet {
            btnChargeType.setTitle(selectedChargeType.keys.first, for: .normal)
        }
    }
    var selectedPackage : IGPSLastInternetPackagesPurchases!
    var selectedSimcardType : String!
    var chargeAmount: String! {
        didSet {
                self.tfChargeAmount.text = self.chargeAmount.currencyFormat()
        }
    }
    
    var operatorDictionary: [String:IGSelectedOperator] =
        ["0910": IGSelectedOperator.MCI,
         "0911":IGSelectedOperator.MCI,
         "0912":IGSelectedOperator.MCI,
         "0913":IGSelectedOperator.MCI,
         "0914":IGSelectedOperator.MCI,
         "0915":IGSelectedOperator.MCI,
         "0916":IGSelectedOperator.MCI,
         "0917":IGSelectedOperator.MCI,
         "0918":IGSelectedOperator.MCI,
         "0919":IGSelectedOperator.MCI,
         "0990":IGSelectedOperator.MCI,
         "0991":IGSelectedOperator.MCI,
         "0992":IGSelectedOperator.MCI,
         
         "0901":IGSelectedOperator.MTN,
         "0902":IGSelectedOperator.MTN,
         "0903":IGSelectedOperator.MTN,
         "0930":IGSelectedOperator.MTN,
         "0933":IGSelectedOperator.MTN,
         "0935":IGSelectedOperator.MTN,
         "0936":IGSelectedOperator.MTN,
         "0937":IGSelectedOperator.MTN,
         "0938":IGSelectedOperator.MTN,
         "0939":IGSelectedOperator.MTN,
         
         "0920":IGSelectedOperator.Rightel,
         "0921":IGSelectedOperator.Rightel,
         "0922":IGSelectedOperator.Rightel
    ]

    private var selectedOperator : IGSelectedOperator = .MTN
    
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
        tf.textAlignment = .center
        tf.placeholder = IGStringsManager.MobileNumber.rawValue.localized
        tf.textColor = ThemeManager.currentTheme.LabelColor
        tf.backgroundColor = .clear
        tf.layer.cornerRadius = 10
        tf.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tf.layer.borderWidth = 1.0
        tf.setLeftPaddingPoints(10)
        tf.setRightPaddingPoints(10)
        tf.keyboardType = .phonePad
        if let userInfo = IGRegisteredUser.getUserInfo(id: IGAppManager.sharedManager.userID()!) {
            let phoneformatted = NSString(string: String(userInfo.phone)).replacingCharacters(in: NSRange(location: 0, length: 2), with: "0")
            tf.text = phoneformatted
        }
        return tf
    }()
    
    private let btnContactList : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btn.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
        return btn
    }()
    private let btnLastPurchases : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btn.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
        
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
        btn.layer.cornerRadius = 8
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.withAlphaComponent(0.7).cgColor
        btn.layer.borderWidth = 2.0
        return btn
    }()
    
    private let btnMCI : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 8
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.withAlphaComponent(0.7).cgColor
        btn.layer.borderWidth = 0.0
        
        return btn
        
    }()
    
    private let btnRightel : UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 8
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.withAlphaComponent(0.7).cgColor
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
    
    var tfChargeAmount : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        tf.textAlignment = .center
        tf.borderStyle = .none
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1.0
        tf.textColor = ThemeManager.currentTheme.iVandColor
        tf.layer.borderColor = ThemeManager.currentTheme.iVandColor.cgColor
        tf.font = UIFont.igFont(ofSize: 13)
        return tf
    }()
    
    var btnChargeType : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.iVandColor, for: .normal)
        btn.layer.borderColor = ThemeManager.currentTheme.iVandColor.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        return btn
    }()
    
    //MCI
    var btnSimTypeOne : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.2
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitleColor(ThemeManager.currentTheme.iVandColor, for: .normal)
        btn.layer.borderColor = ThemeManager.currentTheme.iVandColor.cgColor
        return btn
    }()
    
    var btnSimTypeTwo : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.2
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        return btn
    }()
    
    var btnSimTypeThree : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.2
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        return btn
    }()
    
    var btnSimTypeFour : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.2
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = IGPSTopUpMainVM(viewController: self)
        initView()
        chargePrice = ["\(P1000) \(rials)" , "\(P2000) \(rials)" , "\(P5000) \(rials)", "\(P10000) \(rials)", "\(P20000) \(rials)"]
        chargeType = [IGStringsManager.NormalCharge.rawValue.localized,IGStringsManager.AmazingCharge.rawValue.localized]
        chargeAmount = "\(P5000) \(rials)".inLocalizedLanguage()
        initCustomtNav(title: titlePage)
        self.view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        tfChargeAmount.delegate = self
        if pageType == .TopUp {
            tfPhoneNUmber.delegate = self
        }
        vm.pageType = pageType
        initEventBus()
        
    }
    private func initEventBus() {

        SwiftEventBus.onMainThread(self, name: EventBusManager.TopUpAddToFavourite) { result in
            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: nil, showIconView: true, showDoneButton: true, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.PSAddToLastPurchases.rawValue.localized, doneText: IGStringsManager.Add.rawValue.localized, cancelText: IGStringsManager.GlobalCancel.rawValue.localized, cancel: {
                print("TAP CANCEL")
            }, done: {
                self.vm.addToHistory()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwiftEventBus.unregister(self)
    }
    private let packagesHolder : UIView = {
        let av = UIView()
        av.translatesAutoresizingMaskIntoConstraints = false
        return av
        
    }()
    
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
        switch pageType {
        case .NetworkPackage :
            btnSubmit.setTitle = IGStringsManager.GlobalContinue.rawValue.localized
            selectedSimcardType = "CREDIT"
        case .TopUp :
            btnSubmit.setTitle = IGStringsManager.KSubmit.rawValue.localized
        default : break
        }
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
        btnContactList.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
        
        btnContactList.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.openContact()
        })
    }
    private func addButtonLastPurchases() {
        self.scrollView.contentView.addSubview(btnLastPurchases)
        
        btnLastPurchases.topAnchor.constraint(equalTo: tfPhoneNUmber.bottomAnchor,constant: 10).isActive = true
        btnLastPurchases.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
        
        btnLastPurchases.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}

            sSelf.vm.requestGetLastTopUpPurchases(type: sSelf.pageType)

        })

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
            addPACKAGEView()
        }
    }
    private func addTOPUPView() {
        self.scrollView.contentView.addSubview(tfChargeAmount)

        tfChargeAmount.topAnchor.constraint(equalTo: attensionView.bottomAnchor,constant: 25).isActive = true
        tfChargeAmount.widthAnchor.constraint(equalTo: lblTitle.widthAnchor,multiplier: 0.7).isActive = true
        tfChargeAmount.heightAnchor.constraint(equalToConstant: 30).isActive = true
        tfChargeAmount.centerXAnchor.constraint(equalTo: lblTitle.centerXAnchor).isActive = true

        tfChargeAmount.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.didTapOnChargeAmount()
        })

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
        
        self.scrollView.contentView.addSubview(btnChargeType)
        
        btnChargeType.topAnchor.constraint(equalTo: tfChargeAmount.bottomAnchor,constant: 10).isActive = true
        btnChargeType.widthAnchor.constraint(equalTo: lblTitle.widthAnchor,multiplier: 1.0).isActive = true
        btnChargeType.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnChargeType.centerXAnchor.constraint(equalTo: lblTitle.centerXAnchor).isActive = true
        btnChargeType.addTarget(self, action: #selector(didTapOnChargeType), for: .touchUpInside)
        
        selectedCharge = ["\(P5000) \(rials)".inLocalizedLanguage() : 2]
//        btnChargeAmount.setTitle(selectedCharge.keys.first, for: .normal)
        tfChargeAmount.text = selectedCharge.keys.first
        selectedChargeType = [IGStringsManager.NormalCharge.rawValue.localized : 0]
        btnChargeType.setTitle(selectedChargeType.keys.first, for: .normal)
        
        
    }
    
    private func addPACKAGEView() {
        //        packagesHolder.backgroundColor = .red
        packagesHolder.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentView.addSubview(packagesHolder)
        packagesHolder.topAnchor.constraint(equalTo: self.attensionView.bottomAnchor,constant: 25).isActive = true
        packagesHolder.widthAnchor.constraint(equalTo: self.lblTitle.widthAnchor).isActive = true
        heightC = packagesHolder.heightAnchor.constraint(equalToConstant: 200)
        heightC.isActive = true
        packagesHolder.centerXAnchor.constraint(equalTo: self.lblTitle.centerXAnchor).isActive = true
        
        let stk = UIStackView()
        stk.axis = .vertical
        stk.alignment = .fill
        stk.distribution = .fillEqually
        stk.spacing = 5
        stk.translatesAutoresizingMaskIntoConstraints = false
        packagesHolder.addSubview(stk)
        stk.topAnchor.constraint(equalTo: packagesHolder.topAnchor,constant: 10).isActive = true
        stk.bottomAnchor.constraint(equalTo: packagesHolder.bottomAnchor,constant: -10).isActive = true
        stk.leadingAnchor.constraint(equalTo: packagesHolder.leadingAnchor,constant: 10).isActive = true
        stk.trailingAnchor.constraint(equalTo: packagesHolder.trailingAnchor,constant: -10).isActive = true
        
        stk.addArrangedSubview(btnSimTypeOne)
        stk.addArrangedSubview(btnSimTypeTwo)
        stk.addArrangedSubview(btnSimTypeThree)
        stk.addArrangedSubview(btnSimTypeFour)
        
        btnSimTypeOne.setTitle(IGStringsManager.PSCreditSim.rawValue.localized, for: .normal)
        btnSimTypeTwo.setTitle(IGStringsManager.PSPermanentSim.rawValue.localized, for: .normal)
        btnSimTypeThree.setTitle(IGStringsManager.PSCreditTDLTE.rawValue.localized, for: .normal)
        btnSimTypeFour.setTitle(IGStringsManager.PSPermanentTDLTE.rawValue.localized, for: .normal)
        btnSimTypeOne.addTarget(self, action: #selector(didTapOnSimOne), for: .touchUpInside)
        btnSimTypeTwo.addTarget(self, action: #selector(didTapOnSimTwo), for: .touchUpInside)
        btnSimTypeThree.addTarget(self, action: #selector(didTapOnSimThree), for: .touchUpInside)
        btnSimTypeFour.addTarget(self, action: #selector(didTapOnSimFour), for: .touchUpInside)
        
        
        
        
    }
    private func updateMTNPackages() {
        self.heightC.constant = 200
        btnSimTypeThree.isHidden = false
        btnSimTypeFour.isHidden = false
        btnSimTypeOne.setTitle(IGStringsManager.PSCreditSim.rawValue.localized, for: .normal)
        btnSimTypeTwo.setTitle(IGStringsManager.PSPermanentSim.rawValue.localized, for: .normal)
        btnSimTypeThree.setTitle(IGStringsManager.PSCreditTDLTE.rawValue.localized, for: .normal)
        btnSimTypeFour.setTitle(IGStringsManager.PSPermanentTDLTE.rawValue.localized, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    private func updateMCIPackages() {
        self.heightC.constant = 100
        btnSimTypeThree.isHidden = true
        btnSimTypeFour.isHidden = true
        btnSimTypeOne.setTitle(IGStringsManager.PSCreditSim.rawValue.localized, for: .normal)
        btnSimTypeTwo.setTitle(IGStringsManager.PSPermanentSim.rawValue.localized, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateRIGHTELPackages() {
        self.heightC.constant = 150
        btnSimTypeThree.isHidden = false
        btnSimTypeFour.isHidden = true
        btnSimTypeOne.setTitle(IGStringsManager.PSCreditSim.rawValue.localized, for: .normal)
        btnSimTypeTwo.setTitle(IGStringsManager.PSPermanentSim.rawValue.localized, for: .normal)
        btnSimTypeThree.setTitle(IGStringsManager.PSDataSim.rawValue.localized, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func addButtonSubmit() {
        manageButoonColor() // this method is forced because the button initializer is being called once
        scrollView.contentView.addSubview(btnSubmit)
        btnSubmit.cornerValue = 10
        btnSubmit.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor).isActive = true
        if pageType == .TopUp {
            btnSubmit.topAnchor.constraint(equalTo: btnChargeType.bottomAnchor, constant: 25).isActive = true
            
        } else {
            btnSubmit.topAnchor.constraint(equalTo: packagesHolder.bottomAnchor, constant: 25).isActive = true
            
        }
        btnSubmit.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor, multiplier: 3/4).isActive = true
        btnSubmit.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnSubmit.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor,constant: -10).isActive = true
        
    }
    private func manageButoonColor() {
        updateConstantColors()
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                btnSubmit = IGKCustomButton(title: IGStringsManager.KSubmit.rawValue.localized ,backColor: ThemeManager.currentTheme.NavigationSecondColor)
                
            case .dark:
                btnSubmit = IGKCustomButton(title: IGStringsManager.KSubmit.rawValue.localized ,backColor: ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 20)!)
                
            default :
                break
            }
        } else {
            btnSubmit = IGKCustomButton(title: IGStringsManager.KSubmit.rawValue.localized ,backColor: ThemeManager.currentTheme.NavigationSecondColor)
        }
    }
    
    private func updateConstantColors() {
        tfPhoneNUmber.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btnMTN.layer.borderColor = ThemeManager.currentTheme.LabelColor.withAlphaComponent(0.6).cgColor
        btnMCI.layer.borderColor = ThemeManager.currentTheme.LabelColor.withAlphaComponent(0.6).cgColor
        btnRightel.layer.borderColor = ThemeManager.currentTheme.LabelColor.withAlphaComponent(0.6).cgColor
    }
    
    private func manageActions() {
        btnSubmit.addAction {
            [weak self] in
            guard let sSelf = self else {return}

            guard let phoneNumber: String = sSelf.tfPhoneNUmber.text?.inEnglishNumbersNew() else {
                return
            }
            
            if (phoneNumber.count) < 11 || !phoneNumber.isNumber ||  (sSelf.operatorDictionary[(phoneNumber.substring(offset: 4))] == nil) {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.WrongPhoneNUmber.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                return
            }
            sSelf.vm.selectedPhone = sSelf.tfPhoneNUmber.text!
            sSelf.vm.selectedOp = sSelf.selectedOperator

            switch sSelf.pageType {
            case .TopUp :
                sSelf.handleTopUpBuy()
            case .NetworkPackage :
                sSelf.handleNetworkPackageBuy()
            default: break
            }
        }
        btnMTN.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.btnMTNAction()
        })
        btnMCI.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.btnMCIAction()
            
        })
        btnRightel.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.btnRightelAction()
        })
    }
    
    private func handleTopUpBuy() {


        vm.selectedAmount = tfChargeAmount.text!
        switch selectedOperator {
        case .MCI:
            switch selectedChargeType.first?.value {
            case 0 :
                vm.selectedType = "DIRECT"
            case 1 :
                vm.selectedType = "YOUTH"
            case 2 :
                vm.selectedType = "LADIES"
            default :
                vm.selectedType = "DIRECT"
            }
        case .MTN:
            switch selectedChargeType.first?.value {
            case 0 :
                vm.selectedType = "MTN_NORMAL"
            case 1 :
                vm.selectedType = "MTN_AMAZING"
            default :
                vm.selectedType = "MTN_NORMAL"
            }

        case .Rightel :
            switch selectedChargeType.first?.value {
            case 0 :
                vm.selectedType = "RIGHTEL_NORMAL"
            case 1 :
                vm.selectedType = "RIGHTEL_EXCITING"
            default :
                vm.selectedType = "RIGHTEL_NORMAL"
            }
        }
        vm.buyRequest()

    }
    private func handleNetworkPackageBuy() {
        
        vm.selectedType = selectedSimcardType
        if self.selectedPackage != nil {
            vm.selectedPackage = self.selectedPackage
        }
        vm.getInternetPackages()
    }
    private func btnMTNAction() {
        
        btnRightel.layer.borderWidth = 0.0
        btnMCI.layer.borderWidth = 0.0
        btnMTN.layer.borderWidth = 2.0
        selectedOperator = .MTN
        if pageType == .NetworkPackage {
            updateMTNPackages()
        } else {
            chargeType = [IGStringsManager.NormalCharge.rawValue.localized,IGStringsManager.AmazingCharge.rawValue.localized]
            chargeAmount = "\(P5000) \(rials)"
            selectedChargeType = [IGStringsManager.NormalCharge.rawValue.localized : 0]

        }
        
    }
    
    private func btnMCIAction() {
        
        btnRightel.layer.borderWidth = 0.0
        btnMCI.layer.borderWidth = 2.0
        btnMTN.layer.borderWidth = 0.0
        selectedOperator = .MCI
        if pageType == .NetworkPackage {
            updateMCIPackages()
        } else {
            chargeType = [IGStringsManager.NormalCharge.rawValue.localized,IGStringsManager.PSYouthCharge.rawValue.localized,IGStringsManager.PSLadiesCharge.rawValue.localized]
            chargeAmount = "\(P5000) \(rials)"
            selectedChargeType = [IGStringsManager.NormalCharge.rawValue.localized : 0]

        }
        
    }
    
    private func btnRightelAction() {
        
        btnRightel.layer.borderWidth = 2.0
        btnMCI.layer.borderWidth = 0.0
        btnMTN.layer.borderWidth = 0.0
        selectedOperator = .Rightel
        if pageType == .NetworkPackage {
            updateRIGHTELPackages()
        } else {
            chargeType = [IGStringsManager.NormalCharge.rawValue.localized,IGStringsManager.AmazingCharge.rawValue.localized]
            chargeAmount = "\(P5000) \(rials)"
            selectedChargeType = [IGStringsManager.NormalCharge.rawValue.localized : 0]

        }
    }
    func passDataInternet(phone: [String: String], currentOperator: String, selectedPackage: IGPSLastInternetPackagesPurchases) {
        print("CHANGE CHARGE AMOUNT")
        if phone.first!.key.starts(with: "0") {
            tfPhoneNUmber.text = (phone.first!.key).inLocalizedLanguage()
            
        }else {
            tfPhoneNUmber.text = ("0" + phone.first!.key).inLocalizedLanguage()
            
        }
        
        selectedCharge.removeAll()
        
        if currentOperator == "mci" {
            btnMCIAction()
        }else if currentOperator == "mtn" {
            btnMTNAction()
        }else if currentOperator == "rightel" {
            btnRightelAction()
        }
        if pageType == .NetworkPackage {
            self.selectedPackage = selectedPackage
            if self.selectedPackage.simOperator == "mtn" ||  self.selectedPackage.simOperator == "mci" {
                switch self.selectedPackage.chargeType {
                case "CREDIT" : didTapOnSimOne()
                    
                case "PERMANENT" : didTapOnSimTwo()
                    
                case "CREDIT_TD_LTE" : didTapOnSimThree()
                    
                case "PERMANENT_TD_LTE" : didTapOnSimFour()
                default : break
                }
            }  else {
                switch self.selectedPackage.chargeType {
                case "CREDIT" : didTapOnSimOne()
                    
                case "PERMANENT" : didTapOnSimTwo()
                    
                case "DATA" : didTapOnSimThree()
                default : break
                    
                }
            }
        } else {
            chargeAmount = phone.first!.value + " " + rials
        }
        
    }

    func passData(phone: [String: String], currentOperator: String) {
        print("CHANGE CHARGE AMOUNT")
        if phone.first!.key.starts(with: "0") {
            tfPhoneNUmber.text = (phone.first!.key).inLocalizedLanguage()

        }else {
            tfPhoneNUmber.text = ("0" + phone.first!.key).inLocalizedLanguage()

        }

        selectedCharge.removeAll()
        
        if currentOperator == "mci" {
            btnMCIAction()
        }else if currentOperator == "mtn" {
            btnMTNAction()
        }else if currentOperator == "rightel" {
            btnRightelAction()
        }
        if pageType == .NetworkPackage {
            
        } else {
            chargeAmount = phone.first!.value + " " + rials
        }

    }
    
    //MARK: - ACTIONS
    
    @objc func didTapOnPlus() {
        if chargePrice.count > 0 {
            var amount = Int64(chargeAmount.onlyDigitChars())!


            print("DIDTAPONMINES")
            switch selectedOperator {
            case .MCI :
                if amount < 1000000 {
                    amount += 10000
                    chargeAmount = "\(amount) \(rials)"
                }
            case .MTN :
                if amount < 20000000 {
                    amount += 10000
                    chargeAmount = "\(amount) \(rials)"
                }
            case .Rightel :
                if amount < 20000000 {
                    amount += 10000
                    chargeAmount = "\(amount) \(rials)"
                }
            }
        }
    }
    
    @objc func didTapOnMines() {

        if chargePrice.count > 0 {
            var amount = Int64(chargeAmount.onlyDigitChars())!

            if amount > P1000 {
                print("DIDTAPONMINES")
                amount -= 10000
                chargeAmount = "\(amount) \(rials)"
            }
        }
    }
    
    @objc func didTapOnChargeAmount() {
        IGHelperBottomModals.shared.showChargeList(view: self, chargeList: chargePrice)
    }
    
    @objc func didTapOnChargeType() {
        IGHelperBottomModals.shared.showChargeType(view: self, chargeTypes: chargeType,selectedOperator: selectedOperator)
    }
    
    @objc func didTapOnSimOne() {
        btnSimTypeOne.layer.borderColor = ThemeManager.currentTheme.iVandColor.cgColor
        btnSimTypeOne.setTitleColor(ThemeManager.currentTheme.iVandColor, for: .normal)
        btnSimTypeThree.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeTwo.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeFour.layer.borderColor = UIColor.lightGray.cgColor
        
        btnSimTypeThree.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeTwo.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeFour.setTitleColor(UIColor.lightGray, for: .normal)

        selectedSimcardType = "CREDIT"

    }
    
    @objc func didTapOnSimTwo() {
        btnSimTypeTwo.layer.borderColor = ThemeManager.currentTheme.iVandColor.cgColor
        btnSimTypeTwo.setTitleColor(ThemeManager.currentTheme.iVandColor, for: .normal)
        btnSimTypeOne.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeThree.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeFour.layer.borderColor = UIColor.lightGray.cgColor

        btnSimTypeOne.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeThree.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeFour.setTitleColor(UIColor.lightGray, for: .normal)

        selectedSimcardType = "PERMANENT"

    }
    
    @objc func didTapOnSimThree() {
        btnSimTypeThree.layer.borderColor = ThemeManager.currentTheme.iVandColor.cgColor
        btnSimTypeThree.setTitleColor(ThemeManager.currentTheme.iVandColor, for: .normal)
        btnSimTypeOne.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeTwo.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeFour.layer.borderColor = UIColor.lightGray.cgColor
        
        btnSimTypeOne.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeTwo.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeFour.setTitleColor(UIColor.lightGray, for: .normal)

        if selectedOperator == .Rightel {
            selectedSimcardType = "DATA"
        } else {
            selectedSimcardType = "CREDIT_TD_LTE"
        }

    }
    
    @objc func didTapOnSimFour() {
        btnSimTypeFour.layer.borderColor = ThemeManager.currentTheme.iVandColor.cgColor
        btnSimTypeFour.setTitleColor(ThemeManager.currentTheme.iVandColor, for: .normal)
        
        btnSimTypeOne.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeTwo.setTitleColor(UIColor.lightGray, for: .normal)
        btnSimTypeThree.setTitleColor(UIColor.lightGray, for: .normal)

        btnSimTypeOne.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeTwo.layer.borderColor = UIColor.lightGray.cgColor
        btnSimTypeThree.layer.borderColor = UIColor.lightGray.cgColor
        selectedSimcardType = "PERMANENT_TD_LTE"

    }
    @objc private func tapAction() {
        view.endEditing(true)
    }

    
    private func openContact(){
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:false, subtitleCellType: SubtitleCellValue.email)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        self.present(navigationController, animated: true, completion: nil)
    }
    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        manageButoonColor()
        switch pageType {
        case .NetworkPackage :
            btnSubmit.setTitle = IGStringsManager.GlobalContinue.rawValue.localized
        case .TopUp :
            btnSubmit.setTitle = IGStringsManager.KSubmit.rawValue.localized
        default : break
        }

    }
}

extension IGPSTopUpMainVC : EPPickerDelegate {
    func epContactPicker(_: EPContactsPicker, didCancel error: NSError) {
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact){
        DispatchQueue.main.async {
            var phones : [String] = []
            for phone in contact.phoneNumbers {
                phones.append(phone.phoneNumber)
            }
            self.tfPhoneNUmber.text = (phones.first)?.replacingOccurrences(of: " ", with: "").remove98()
        }
    }
}

extension IGPSTopUpMainVC : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let textFieldText = tfPhoneNUmber.text,
                let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
            }
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            

        if textFieldText.starts(with: "۰") || textFieldText.starts(with: "0") || textFieldText.starts(with: "0".inLocalizedLanguage()) {
            
            if  textFieldText.inEnglishNumbersNew().substring(offset: 4).count > 3 {
                if operatorDictionary[textFieldText.inEnglishNumbersNew().substring(offset: 4)] != nil {
                    selectedOperator = operatorDictionary[textFieldText.inEnglishNumbersNew().substring(offset: 4)]!

                    switch selectedOperator {
                    case .MCI : btnMCIAction()
                    case .MTN: btnMTNAction()
                    case .Rightel: btnRightelAction()
                    }
                    
                }
            }
        }
        
        if operatorDictionary[textFieldText.inEnglishNumbersNew().substring(offset: 4)] != nil {
            return count <= 11
        } else {
            return count <= 4
        }

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfChargeAmount {

            selectedCharge = ["\(P5000) \(rials)".inLocalizedLanguage() : 2]
            if chargeAmount == "" || textField.text == "" {
                        tfChargeAmount.text = selectedCharge.keys.first
            } else {
                let amount = textField.text!
                switch selectedOperator {
                case .MCI :
                    let price : String! = amount
                    if (price! as NSString).longLongValue > Int64(1000000) {
                        textField.text = "1000000".currencyFormat()
                    }
                case .MTN :
                    let price : String! = amount
                    if (price! as NSString).longLongValue > Int64(20000000) {
                        textField.text = "20000000".currencyFormat()
                    }
                case .Rightel :
                    let price : String! = amount
                    if (price! as NSString).longLongValue > Int64(20000000) {
                        textField.text = "20000000".currencyFormat()
                    }
                }
            }
        }
    }
    
}
