//
//  IGPSBillMainVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/14/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

protocol billBarcodeDelegate {
    func passData(code: String)
}

class IGPSBillMainVC : MainViewController {

    private var vm : IGPSBillMainVM!
    let scrollView = IGScrollView()
    private var holderHeightC : NSLayoutConstraint!
    private var btnQRWidthC : NSLayoutConstraint!
    private var tfTrailingC : NSLayoutConstraint!
    private let holder : UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4.0
        return view
    }()

    private let btnMYBills : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.MyBills.rawValue.localized, for: .normal)
        return btn
    }()
    private let btnQuery : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.Inquiry.rawValue.localized, for: .normal)
        return btn
    }()
    
    private let lblTitle : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.PSInquiryTitle.rawValue.localized
        lbl.textAlignment = .center
        return lbl
    }()
    private let sgBillType : UISegmentedControl = {
        let items = [IGStringsManager.PSBillTypeSegment2.rawValue.localized , IGStringsManager.PSBillTypeSegment1.rawValue.localized]
        let segmentedControl = UISegmentedControl(items : items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.frame = CGRect(x: 35, y: 200, width: 250, height: 50)
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.layer.cornerRadius = 15.0
        segmentedControl.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        segmentedControl.tintColor = ThemeManager.currentTheme.NavigationSecondColor
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font : UIFont.igFont(ofSize: 12)], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme.LabelColor,NSAttributedString.Key.font : UIFont.igFont(ofSize: 12)], for: .normal)
        return segmentedControl
    }()
    private let btnQRscan : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("", for: .normal)
        btn.titleLabel?.font = UIFont.iGapFonticon(ofSize: 30)
        btn.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        return btn
    }()
    private let tfBillNumber : UITextField = {
        
        let tf = UITextField()
        tf.font = UIFont.igFont(ofSize: 15,weight: .bold)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textAlignment = .center
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
    private let lblPhoneDesc : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.text = IGStringsManager.PSPhoneNUmberEnterDesc.rawValue.localized
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    var btnServcieBillTYpe : UIButton = {
          let btn = UIButton()
          btn.translatesAutoresizingMaskIntoConstraints = false
          btn.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
          btn.layer.cornerRadius = 15
          btn.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
          btn.layer.borderWidth = 1.0
          btn.setTitleColor(ThemeManager.currentTheme.NavigationSecondColor, for: .normal)
          btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
          btn.setTitle(IGStringsManager.PSChooseBill.rawValue.localized, for: .normal)
          return btn
      }()
    var billType : IGBillType!  {
        didSet
        {
            switch billType {
            case .Gas :    btnServcieBillTYpe.setTitle(IGStringsManager.PSGasBill.rawValue.localized,for : .normal)
                btnQRWidthC.constant = 0
                tfTrailingC.constant = -5
                tfBillNumber.placeholder = IGStringsManager.PSSubscriptionCode.rawValue.localized

            case .Elec :    btnServcieBillTYpe.setTitle(IGStringsManager.PSElecBill.rawValue.localized,for : .normal)
                btnQRWidthC.constant = 40
                tfTrailingC.constant = -5
                tfBillNumber.placeholder = IGStringsManager.ElecBillID.rawValue.localized

            default :   btnServcieBillTYpe.setTitle(IGStringsManager.PSChooseBill.rawValue.localized, for: .normal)
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }


        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = IGPSBillMainVM(viewController: self)
        initView()
        initCustomtNav(title: IGStringsManager.BillOperations.rawValue.localized)
        self.view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        sgBillType.addTarget(self, action: #selector(didSegmentChange(_:)), for: .valueChanged)
    }
   
    private func initView() {
        setupScrollView()
        addContent()
        manageSemantic()
        manageActions()
        billType = .Elec
        
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
    private func addContent() {
        scrollView.addSubview(holder)
        holderHeightC = holder.heightAnchor.constraint(equalToConstant: 300)
        holder.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: 0.9).isActive = true
        holder.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 25).isActive = true
        holder.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        holderHeightC.isActive = true

        holder.addSubview(lblTitle)
        lblTitle.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.9).isActive = true
        lblTitle.topAnchor.constraint(equalTo: holder.topAnchor,constant: 25).isActive = true
        lblTitle.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true

        holder.addSubview(sgBillType)
        sgBillType.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.9).isActive = true
        sgBillType.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sgBillType.topAnchor.constraint(equalTo: lblTitle.bottomAnchor,constant: 25).isActive = true
        sgBillType.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true

        holder.addSubview(btnQuery)
        btnQuery.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.9).isActive = true
        btnQuery.bottomAnchor.constraint(equalTo: holder.bottomAnchor,constant: -25).isActive = true
        btnQuery.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnQuery.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true

        holder.addSubview(btnQRscan)
        btnQRWidthC = btnQRscan.widthAnchor.constraint(equalToConstant: 40)
        btnQRscan.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnQRscan.bottomAnchor.constraint(equalTo: btnQuery.topAnchor,constant: -10).isActive = true
        btnQRscan.trailingAnchor.constraint(equalTo: sgBillType.trailingAnchor).isActive = true
        btnQRWidthC.isActive = true
        
        holder.addSubview(lblPhoneDesc)
        lblPhoneDesc.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.9).isActive = true
        lblPhoneDesc.topAnchor.constraint(equalTo: sgBillType.bottomAnchor,constant: 25).isActive = true
        lblPhoneDesc.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true
        lblPhoneDesc.isHidden = true

        holder.addSubview(btnServcieBillTYpe)
        btnServcieBillTYpe.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.9).isActive = true
        btnServcieBillTYpe.topAnchor.constraint(equalTo: sgBillType.bottomAnchor,constant: 10).isActive = true
        btnServcieBillTYpe.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true
        btnServcieBillTYpe.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnServcieBillTYpe.isHidden = false

        holder.addSubview(tfBillNumber)
        tfBillNumber.heightAnchor.constraint(equalToConstant: 40).isActive = true
        tfBillNumber.bottomAnchor.constraint(equalTo: btnQuery.topAnchor,constant: -10).isActive = true
        tfBillNumber.leadingAnchor.constraint(equalTo: sgBillType.leadingAnchor).isActive = true
        tfTrailingC = tfBillNumber.trailingAnchor.constraint(equalTo: btnQRscan.leadingAnchor,constant: -5)
        tfTrailingC.isActive = true

        
        scrollView.addSubview(btnMYBills)
        btnMYBills.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnMYBills.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: 0.9).isActive = true
        btnMYBills.topAnchor.constraint(equalTo: holder.bottomAnchor,constant: 25).isActive = true
        btnMYBills.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,constant: -10).isActive = true
        btnMYBills.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        
        
    }
    private func manageActions() {
        btnQuery.addTarget(self, action: #selector(didTapOnQuery), for: .touchUpInside)
        btnMYBills.addTarget(self, action: #selector(didTapOnMyBills), for: .touchUpInside)
        btnServcieBillTYpe.addTarget(self, action: #selector(didTapOnBillType), for: .touchUpInside)
        btnQRscan.addTarget(self, action: #selector(didTapOnScanBarcode), for: .touchUpInside)
    }
    @objc private func didSegmentChange(_ sender : UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1 :
            print("1")
            holderHeightC.constant = 300
            btnQRWidthC.constant = 40
            tfTrailingC.constant = -5
            lblPhoneDesc.isHidden = true
            btnServcieBillTYpe.isHidden = false
            billType = .Elec
            btnServcieBillTYpe.setTitle(IGStringsManager.PSElecBill.rawValue.localized, for: .normal)
            tfBillNumber.text = nil
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }

        case 0 :
            print("0")
            holderHeightC.constant = 350
            btnQRWidthC.constant = 0
            tfTrailingC.constant = -5
            lblPhoneDesc.isHidden = false
            btnServcieBillTYpe.isHidden = true
            billType = .Phone
            tfBillNumber.placeholder = IGStringsManager.PhoneNumber.rawValue.localized
            tfBillNumber.text = nil

            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }

            
        default : break
            
        }
        
    }
    @objc private func didTapOnQuery() {
        print("DIDTAP")
        if billType == IGBillType.Elec {
            if tfBillNumber.text == "" || tfBillNumber.text!.count >= 13{
                tfBillNumber.shake()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.BillID13.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            } else {
                let billDataVC = IGPSBillDetailVC()
                billDataVC.billNumber = tfBillNumber.text!
                billDataVC.billType = billType
                UIApplication.topViewController()?.navigationController!.pushViewController(billDataVC, animated:true)

            }

        } else if billType == IGBillType.Gas {
            if tfBillNumber.text == "" || tfBillNumber.text!.count <= 7{
                tfBillNumber.shake()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.SubsCriptionError.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            } else {
                let billDataVC = IGPSBillDetailVC()
                billDataVC.billNumber = tfBillNumber.text!
                billDataVC.billType = billType
                UIApplication.topViewController()?.navigationController!.pushViewController(billDataVC, animated:true)

            }

        } else if billType == IGBillType.Mobile {
            let billDataVC = IGPSBillDetailVC()

            billDataVC.billType = billType
            UIApplication.topViewController()?.navigationController!.pushViewController(billDataVC, animated:true)

        } else if billType == IGBillType.Phone {
            let billDataVC = IGPSBillDetailVC()

            billDataVC.billType = billType
            UIApplication.topViewController()?.navigationController!.pushViewController(billDataVC, animated:true)

        }
        

    }
    @objc private func didTapOnMyBills() {
        print("DIDTAP")
    }
    @objc private func didTapOnBillType() {
        print("DIDTAP")
        IGHelperBottomModals.shared.showBillTypes(types: [IGStringsManager.PSGasBill.rawValue.localized,IGStringsManager.PSElecBill.rawValue.localized])
    }
    @objc private func didTapOnScanBarcode() {
        let scanner = IGSettingQrScannerViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        scanner.scannerPageType = .BillBarcode
        scanner.billDelegate = self
        scanner.billType = billType
        self.navigationController!.pushViewController(scanner, animated:true)
    }
    @objc private func tapAction() {
        view.endEditing(true)
    }

}
extension IGPSBillMainVC : billBarcodeDelegate {
    func passData(code: String) {
        tfBillNumber.text = code
    }
}
