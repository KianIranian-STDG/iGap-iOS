//
//  IGPSBillDetailVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/15/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import RealmSwift

class IGPSBillDetailVC : MainViewController {

    private var vm : IGPSBillDetailVM!
    let scrollView = IGScrollView()
    private var holderHeightC : NSLayoutConstraint!
    private var showBillImageC : NSLayoutConstraint!
    private var branchIndoC : NSLayoutConstraint!
    var billIsOK : Bool = false
    var hasQureed : Bool = false
    var billNumber : String! {
        didSet {
            lblBillNumberData.text = billNumber.inLocalizedLanguage()
        }
    }
    var userNumber : String!
    var phoneNumber : String!
    var canEditBill : Bool = false {
        didSet {
            btnAddToMyBills.setTitle(canEditBill ? IGStringsManager.BillEditMode.rawValue.localized : IGStringsManager.BillAddMode.rawValue.localized, for: .normal)
        }
    }
    var billTitle : String!
    var subscriptionCode : String!
    var billPayNumber : String! {
        didSet {
            lblBillPayNumberData.text = billPayNumber.inLocalizedLanguage()
        }
    }
    var billPayNumberLastTerm : String!
    var billPayAmount : String! {
        didSet {
            lblBillPayAmountData.text = billPayAmount.inRialFormat() + IGStringsManager.Currency.rawValue.localized
        }
    }
    var billPayDeadLine : String! {
        didSet {
            switch billType {
            case .Mobile , .Phone :
                lblBillPayDeadLineData.text = billPayDeadLine.inRialFormat() + IGStringsManager.Currency.rawValue.localized

            default :
                lblBillPayDeadLineData.text = billPayDeadLine.inLocalizedLanguage()

            }
        }
    }
    private let holder : UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4.0
        return view
    }()

    private let imgBillType : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        iv.layer.borderColor = ThemeManager.currentTheme.NavigationFirstColor.cgColor
        iv.layer.borderWidth = 2.0
        iv.clipsToBounds = true
        iv.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        return iv
    }()
    private let btnMYBills : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.MyBills.rawValue.localized, for: .normal)
        return btn
    }()

    
    private let btnPay : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
        return btn
    }()
    private let btnPayMid : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.PSPayMidTerm.rawValue.localized, for: .normal)
        return btn
    }()
    private let btnBranchInfo : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.BillBranchingInfo.rawValue.localized, for: .normal)
        return btn
    }()
    private let btnAddToMyBills : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.BillAddMode.rawValue.localized, for: .normal)
        return btn
    }()
    private let btnShowBillImage : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.BillImage.rawValue.localized, for: .normal)
        return btn
    }()
    private let lblBillNumber : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirection
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.BillId.rawValue.localized
        return lbl
    }()
    private let lblBillNumberData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirectionOposit
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.text = lbl.text?.inLocalizedLanguage()
        return lbl
    }()
    private let lblBillPayNumber : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirection
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.PayIdentifier.rawValue.localized
        return lbl
    }()
    private let lblBillPayNumberData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirectionOposit
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.text = lbl.text?.inLocalizedLanguage()
        
        return lbl
    }()
    private let lblBillPayAmount : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirection
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.BillPrice.rawValue.localized
        return lbl
    }()
    private let lblBillPayAmountData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirectionOposit
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.text = lbl.text?.inLocalizedLanguage()
        
        return lbl
    }()
    private let lblBillPayDeadLine : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirection
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.BillPayDate.rawValue.localized
        return lbl
    }()
    private let lblBillPayDeadLineData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textAlignment = lbl.localizedDirectionOposit
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.text = lbl.text?.inLocalizedLanguage()
        
        return lbl
    }()
    var billType : IGBillType!  {
        didSet
        {
            switch billType {
            case .Gas :
                imgBillType.image = UIImage(named: "bill_gaz_pec")
            case .Elec :
                imgBillType.image = UIImage(named: "bill_elc_pec")
            case .Phone :
                imgBillType.image = UIImage(named: "bill_telecom_pec")
            case .Mobile :
                imgBillType.image = UIImage(named: "MCILogo")
                
            default : break
            }

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = IGPSBillDetailVM(viewController: self)
        initView()
        initCustomtNav(title: IGStringsManager.BillOperations.rawValue.localized)
        self.view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        initServices()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                btnBranchInfo.setTitleColor(.white, for: .normal)
                btnBranchInfo.layer.borderColor = UIColor.white.cgColor

                btnAddToMyBills.setTitleColor(.white, for: .normal)
                btnAddToMyBills.layer.borderColor = UIColor.white.cgColor

                btnShowBillImage.setTitleColor(.white, for: .normal)
                btnShowBillImage.layer.borderColor = UIColor.white.cgColor
                imgBillType.layer.borderColor = UIColor.white.cgColor
            } else {
                btnBranchInfo.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
                btnBranchInfo.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor

                btnAddToMyBills.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
                btnAddToMyBills.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor

                btnShowBillImage.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
                btnShowBillImage.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
                imgBillType.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
            }
        } else {
            // Fallback on earlier versions
        }

    }
    private func initView() {
        setupScrollView()
        addContent()
        manageSemantic()
        manageActions()
        
    }
    private func initServices() {
                    let realm = try! Realm()
                    let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
                    let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first
                    let userPhoneNumber =  IGGlobal.validaatePhoneNUmber(phone: userInDb?.phone)
                    userNumber = userPhoneNumber
                    if billType == .Gas {
                        vm?.queryGasBill(billType: "GAS", billID: subscriptionCode.inEnglishNumbersNew())
                    } else if billType == .Elec {
                        vm?.queryElecBill(billType: "ELECTRICITY", telNum: userPhoneNumber, billID: billNumber)
                    } else if billType == .Phone {
                        vm?.queryPhoneBill(billType: "PHONE", telNum: phoneNumber.inEnglishNumbersNew())
                    } else if billType == .Mobile {
                        vm?.queryMobileBill(billType: "MOBILE_MCI", telNum: phoneNumber.inEnglishNumbersNew())
                    }
    
    }
    private func manageSemantic() {
        self.scrollView.semanticContentAttribute = self.semantic
        self.holder.semanticContentAttribute = self.semantic
    }
    private func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    private func addContent() {
        scrollView.addSubview(holder)
        holderHeightC = holder.heightAnchor.constraint(equalToConstant: 250)
        holder.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: 0.9).isActive = true
        holder.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 75).isActive = true
        holder.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        holderHeightC.isActive = true

        scrollView.addSubview(imgBillType)
        imgBillType.heightAnchor.constraint(equalToConstant : 100).isActive = true
        imgBillType.widthAnchor.constraint(equalToConstant : 100).isActive = true
        imgBillType.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imgBillType.centerYAnchor.constraint(equalTo: holder.topAnchor).isActive = true
        holderHeightC.isActive = true
        //MARK: Bill ID
        holder.addSubview(lblBillNumber)
        lblBillNumber.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblBillNumber.topAnchor.constraint(equalTo: imgBillType.bottomAnchor,constant: 25).isActive = true
        lblBillNumber.leadingAnchor.constraint(equalTo: holder.leadingAnchor,constant: 10).isActive = true

        holder.addSubview(lblBillNumberData)
        lblBillNumberData.topAnchor.constraint(equalTo: imgBillType.bottomAnchor,constant: 25).isActive = true
        lblBillNumberData.leadingAnchor.constraint(equalTo: lblBillNumber.trailingAnchor,constant: 25).isActive = true
        lblBillNumberData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true
        //MARK: Bill PAY ID
        holder.addSubview(lblBillPayNumber)
        lblBillPayNumber.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblBillPayNumber.topAnchor.constraint(equalTo: lblBillNumber.bottomAnchor,constant: 25).isActive = true
        lblBillPayNumber.leadingAnchor.constraint(equalTo: holder.leadingAnchor,constant: 10).isActive = true

        holder.addSubview(lblBillPayNumberData)
        lblBillPayNumberData.topAnchor.constraint(equalTo: lblBillNumberData.bottomAnchor,constant: 25).isActive = true
        lblBillPayNumberData.leadingAnchor.constraint(equalTo: lblBillPayNumber.trailingAnchor,constant: 25).isActive = true
        lblBillPayNumberData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true
        //MARK: Bill Amount
        holder.addSubview(lblBillPayAmount)
        lblBillPayAmount.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblBillPayAmount.topAnchor.constraint(equalTo: lblBillPayNumber.bottomAnchor,constant: 25).isActive = true
        lblBillPayAmount.leadingAnchor.constraint(equalTo: holder.leadingAnchor,constant: 10).isActive = true

        holder.addSubview(lblBillPayAmountData)
        lblBillPayAmountData.topAnchor.constraint(equalTo: lblBillPayNumberData.bottomAnchor,constant: 25).isActive = true
        lblBillPayAmountData.leadingAnchor.constraint(equalTo: lblBillPayAmount.trailingAnchor,constant: 25).isActive = true
        lblBillPayAmountData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true
        //MARK: Bill PAY DeadLine
        holder.addSubview(lblBillPayDeadLine)
        lblBillPayDeadLine.widthAnchor.constraint(equalToConstant: 100).isActive = true
        lblBillPayDeadLine.topAnchor.constraint(equalTo: lblBillPayAmount.bottomAnchor,constant: 25).isActive = true
        lblBillPayDeadLine.leadingAnchor.constraint(equalTo: holder.leadingAnchor,constant: 10).isActive = true

        holder.addSubview(lblBillPayDeadLineData)
        lblBillPayDeadLineData.topAnchor.constraint(equalTo: lblBillPayAmountData.bottomAnchor,constant: 25).isActive = true
        lblBillPayDeadLineData.leadingAnchor.constraint(equalTo: lblBillPayDeadLine.trailingAnchor,constant: 25).isActive = true
        lblBillPayDeadLineData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true

        let stk = UIStackView()
        stk.alignment = .center
        stk.axis = .horizontal
        stk.distribution = .fillEqually
        stk.spacing = 10
        stk.addArrangedSubview(btnPay)
        stk.addArrangedSubview(btnPayMid)
        stk.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stk)

        stk.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stk.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: 0.9).isActive = true
        stk.topAnchor.constraint(equalTo: holder.bottomAnchor,constant: 25).isActive = true
        stk.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        btnPay.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnPayMid.heightAnchor.constraint(equalToConstant: 50).isActive = true

        scrollView.addSubview(btnBranchInfo)
        branchIndoC = btnBranchInfo.heightAnchor.constraint(equalToConstant: 50)
        btnBranchInfo.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: 0.9).isActive = true
        btnBranchInfo.topAnchor.constraint(equalTo: btnPay.bottomAnchor,constant: 50).isActive = true
        btnBranchInfo.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        branchIndoC.isActive = true
        scrollView.addSubview(btnAddToMyBills)
        btnAddToMyBills.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnAddToMyBills.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: 0.9).isActive = true
        btnAddToMyBills.topAnchor.constraint(equalTo: btnBranchInfo.bottomAnchor,constant: 10).isActive = true
        btnAddToMyBills.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true

        scrollView.addSubview(btnShowBillImage)
        showBillImageC = btnShowBillImage.heightAnchor.constraint(equalToConstant: 50)
        btnShowBillImage.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: 0.9).isActive = true
        btnShowBillImage.topAnchor.constraint(equalTo: btnAddToMyBills.bottomAnchor,constant: 10).isActive = true
        btnShowBillImage.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,constant: -10).isActive = true
        btnShowBillImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        showBillImageC.isActive = true
        manageBtnSHowImage()
        
        
    }
    private func manageBtnSHowImage() {
        switch billType {
        case .Elec :
            showBillImageC.constant = 50
            branchIndoC.constant = 50
            btnPay.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
            btnPayMid.isHidden = true
            
        case .Gas :
            showBillImageC.constant = 0
            branchIndoC.constant = 50
            btnShowBillImage.setTitle(nil, for: .normal)
            btnPay.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
            btnPayMid.isHidden = true

        case .Phone :
            btnPay.setTitle(IGStringsManager.PSPayLastTerm.rawValue.localized, for: .normal)
            btnPayMid.setTitle(IGStringsManager.PSPayMidTerm.rawValue.localized, for: .normal)
            btnPayMid.isHidden = false
            branchIndoC.constant = 0
            showBillImageC.constant = 0
            btnBranchInfo.setTitle(nil, for: .normal)
            btnShowBillImage.setTitle(nil, for: .normal)
            lblBillPayAmount.text = IGStringsManager.MidTerm.rawValue.localized
            lblBillPayDeadLine.text = IGStringsManager.LastTerm.rawValue.localized

        case .Mobile :
            btnPay.setTitle(IGStringsManager.PSPayLastTerm.rawValue.localized, for: .normal)
            btnPayMid.setTitle(IGStringsManager.PSPayMidTerm.rawValue.localized, for: .normal)
            btnPayMid.isHidden = false
            branchIndoC.constant = 0
            showBillImageC.constant = 0
            btnBranchInfo.setTitle(nil, for: .normal)
            btnShowBillImage.setTitle(nil, for: .normal)
            lblBillPayAmount.text = IGStringsManager.MidTerm.rawValue.localized
            lblBillPayDeadLine.text = IGStringsManager.LastTerm.rawValue.localized

        default : break
            
        }


    }
    private func manageActions() {
        
        btnShowBillImage.addTarget(self, action: #selector(didTapOnShowImage), for: .touchUpInside)
        btnAddToMyBills.addTarget(self, action: #selector(didTapOnAddToMyBills), for: .touchUpInside)
        btnPay.addTarget(self, action: #selector(didTapOnPay), for: .touchUpInside)
        switch billType {
        case .Elec,.Gas : break
        case .Phone , .Mobile :
            btnPayMid.addTarget(self, action: #selector(didTapOnPayMid), for: .touchUpInside)
        default : break
            
            
        }

        btnBranchInfo.addTarget(self, action: #selector(didTapOnBranchInfo), for: .touchUpInside)
        
    }
    @objc private func didTapOnPayMid() {
        print("DIDTAP")
        if lblBillPayAmountData.text?.inEnglishNumbersNew().onlyDigitChars() == "0" {
            IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
        } else {
            vm?.paySequence(billID: billNumber.inEnglishNumbersNew(), payID: billPayNumber.inEnglishNumbersNew(), amount: Int(billPayAmount.inEnglishNumbersNew())!)
        }

        
    }
    @objc private func didTapOnShowImage() {
        if billIsOK {
            print("DIDTAP")
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
            let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

            let userPhoneNumber =  IGGlobal.validaatePhoneNUmber(phone: userInDb?.phone)
            IGLoading.showLoadingPage(viewcontroller: self)
            vm?.getImageOfBill(userPhoneNumber: userPhoneNumber,billNumber : billNumber.inEnglishNumbersNew(),payDate : lblBillPayNumberData.text!.inEnglishNumbersNew())

        }
        
    }
    
    @objc private func didTapOnPay() {
        if billIsOK {
            print("DIDTAP")
            switch billType {
            case .Elec,.Gas :
                if billPayAmount.inEnglishNumbersNew().onlyDigitChars() == "0" {
                    IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                } else {
                    vm?.paySequence(billID: billNumber.inEnglishNumbersNew(), payID: billPayNumber.inEnglishNumbersNew(), amount: Int(billPayAmount.inEnglishNumbersNew())!)
                }
                case .Phone,.Mobile :
                    if lblBillPayDeadLineData.text!.inEnglishNumbersNew().onlyDigitChars() == "0" {
                    IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                } else {
                        vm?.paySequence(billID: billNumber.inEnglishNumbersNew(), payID: billPayNumberLastTerm.inEnglishNumbersNew(), amount: Int(lblBillPayDeadLineData.text!.inEnglishNumbersNew().onlyDigitChars())!)
                }

            default : break
            }

        }
    }
    
    @objc func didTapOnAddToMyBills() {
        if billIsOK {
            var bill = parentBillModel()

            switch billType {
            case .Elec:
                bill.billType = "ELECTRICITY"
                bill.billTitle = billTitle
                bill.billIdentifier = lblBillNumberData.text?.inEnglishNumbersNew()

                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "ADD_BILL", billType: billType, bill: bill)
            case.Gas :
                bill.billType = "GAS"
                bill.billTitle = billTitle
                bill.subsCriptionCode = subscriptionCode.inEnglishNumbersNew()
                bill.billIdentifier = billNumber.inEnglishNumbersNew()

                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "ADD_BILL", billType: billType, bill: bill)

                break
            case .Phone:
                bill.billType = "PHONE"
                bill.billTitle = nil
                bill.billPhone = phoneNumber.inEnglishNumbersNew()
                bill.billIdentifier = billNumber.inEnglishNumbersNew()
                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "ADD_BILL", billType: billType, bill: bill)

            case .Mobile :

                bill.billType = "MOBILE_MCI"
                bill.billTitle = nil
                bill.billPhone = phoneNumber.inEnglishNumbersNew()
                bill.billIdentifier = billNumber.inEnglishNumbersNew()
                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "ADD_BILL", billType: billType, bill: bill)

            default : break
            }

        }
    }
    @objc func didTapOnBranchInfo() {

        if billIsOK {
            let bvc = IGPSBillBranchingInfoTVC()
            bvc.billType = billType
            var newbill = parentBillModel()
            switch billType {
            case .Elec :
                newbill.billIdentifier = billNumber.inEnglishNumbersNew()
                newbill.subsCriptionCode = nil
                newbill.billType = "ELECTRICITY"

            case .Gas:
                newbill.billIdentifier = nil
                newbill.subsCriptionCode = subscriptionCode.inEnglishNumbersNew()
                newbill.billType = "GAS"

            default : break
            }
            bvc.bill = newbill
            UIApplication.topViewController()?.navigationController?.pushViewController(bvc, animated: true)

            
        }
    }

    @objc private func tapAction() {
        view.endEditing(true)
    }

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                btnBranchInfo.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
                btnBranchInfo.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor

                btnAddToMyBills.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
                btnAddToMyBills.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor

                btnShowBillImage.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
                btnShowBillImage.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
                imgBillType.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor

            case .dark :
                btnBranchInfo.setTitleColor(.white, for: .normal)
                btnBranchInfo.layer.borderColor = UIColor.white.cgColor

                btnAddToMyBills.setTitleColor(.white, for: .normal)
                btnAddToMyBills.layer.borderColor = UIColor.white.cgColor

                btnShowBillImage.setTitleColor(.white, for: .normal)
                btnShowBillImage.layer.borderColor = UIColor.white.cgColor
                imgBillType.layer.borderColor = UIColor.white.cgColor

            }
        } else {
            // Fallback on earlier versions
            btnBranchInfo.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
            btnBranchInfo.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor

            btnAddToMyBills.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
            btnAddToMyBills.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor

            btnShowBillImage.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
            btnShowBillImage.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor


        }
    }
}
