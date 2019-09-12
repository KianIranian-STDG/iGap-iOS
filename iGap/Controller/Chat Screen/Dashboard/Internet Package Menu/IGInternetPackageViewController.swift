//
//  IGInternetPackageViewController.swift
//  iGap
//
//  Created by MacBook Pro on 6/21/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGInternetPackageViewController: BaseViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var edtPhoneNubmer: UITextField!
    @IBOutlet weak var packageTypeLbl: UILabel!
    @IBOutlet weak var selectTimeOrVolumeBtn: UIButton!
    @IBOutlet weak var selectPackageBtn: UIButton!
    
    @IBOutlet weak var btnBuy: UIButton!
    
    // MARK: - Variables
    let PHONE_LENGTH = 11
    var latestPhoneNumber = ""
    var dispatchGroup: DispatchGroup!
    
    enum PackageType {
        case time
        case volume
    }
    var packageType: PackageType!
    var internetPackages: IGStructInternetPackage!
    var internetCategory: [IGStructInternetCategory]!
    
    var operatorDictionary: [String : IGOperator] = [
        "0910" : IGOperator.mci,
        "0911" : IGOperator.mci,
        "0912" : IGOperator.mci,
        "0913" : IGOperator.mci,
        "0914" : IGOperator.mci,
        "0915" : IGOperator.mci,
        "0916" : IGOperator.mci,
        "0917" : IGOperator.mci,
        "0918" : IGOperator.mci,
        "0919" : IGOperator.mci,
        "0990" : IGOperator.mci,
        "0991" : IGOperator.mci,
        
        "0901" : IGOperator.irancell,
        "0902" : IGOperator.irancell,
        "0903" : IGOperator.irancell,
        "0930" : IGOperator.irancell,
        "0933" : IGOperator.irancell,
        "0935" : IGOperator.irancell,
        "0936" : IGOperator.irancell,
        "0937" : IGOperator.irancell,
        "0938" : IGOperator.irancell,
        "0939" : IGOperator.irancell,
        
        "0920" : IGOperator.rightel,
        "0921" : IGOperator.rightel,
        "0922" : IGOperator.rightel
    ]
    
    var operatorType: IGOperator!

    override func viewDidLoad() {
        super.viewDidLoad()

        edtPhoneNubmer.delegate = self
        
        getData()
        
        manageButtonsView(buttons: [selectTimeOrVolumeBtn, selectPackageBtn,btnBuy])
        
        setContentVisibility(isHidden: true)
        
//        ButtonViewActivate(button: btnOperator, isEnable: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initCHangeLang()
        initNavigationBar(title: "BUY_INTERNET_PACKAGE".InternetPackageLocalization) {}
    }
    
    
    private func setContentVisibility(isHidden: Bool) {
        self.edtPhoneNubmer.isHidden = isHidden
        self.packageTypeLbl.isHidden = isHidden
        self.selectTimeOrVolumeBtn.isHidden = isHidden
        self.selectPackageBtn.isHidden = isHidden
        self.btnBuy.isHidden = isHidden
    }
    
    private func getData() {
        dispatchGroup = DispatchGroup()
        
        IGGlobal.prgShow()
        
        dispatchGroup.enter()
        IGApiInternetPackage.shared.getCategories { (success, internetCategories) in
            if success {
                self.internetCategory = internetCategories!
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        IGApiInternetPackage.shared.getPackages { (success, internetPackages) in
            if success {
                self.internetPackages = internetPackages!
            }
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            IGGlobal.prgHide()
            self.setContentVisibility(isHidden: false)
        }
    }
    
    func initCHangeLang() {
        packageTypeLbl.text = "INTERNET_PACKAGE_TYPE".InternetPackageLocalization
        packageTypeLbl.textColor = UIColor.gray
        
        edtPhoneNubmer.placeholder = "PLACE_HOLDER_MOBILE_NUM".InternetPackageLocalization
        self.selectTimeOrVolumeBtn.setTitle("CHOOSE_TIME".InternetPackageLocalization, for: .normal)
        self.selectPackageBtn.setTitle("CHOOSE_PACKAGE".InternetPackageLocalization, for: .normal)
        self.btnBuy.setTitle("BTN_PAY".InternetPackageLocalization, for: .normal)
    }
    
    private func manageButtonsView(buttons: [UIButton]) {
        for btn in buttons {
            //btn.removeUnderline()
            btn.layer.cornerRadius = 5
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.iGapColor().cgColor
        }
    }
    
    private func ButtonViewActivate(button: UIButton, isEnable: Bool) {
        if isEnable {
            button.layer.borderColor = UIColor.iGapColor().cgColor
            button.layer.backgroundColor = UIColor.white.cgColor
        } else {
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.backgroundColor = UIColor.lightGray.cgColor
        }
    }
    
    private func showModalAlertView(title: String, message: String?, subtitles: [String], alertClouser: @escaping ((_ title :String) -> Void), hasCancel: Bool = true){
        let option = UIAlertController(title: title, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        
        for subtitle in subtitles {
            let action = UIAlertAction(title: subtitle, style: .default, handler: { (action) in
                alertClouser(action.title!)
            })
            option.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
        
        option.addAction(cancel)
        
        self.present(option, animated: true, completion: {})
    }
    
    
    // MARK: - Actions
    @IBAction func chooseTimeOrVolumeTappd(_ sender: UIButton) {
        
        // should start here
//        showModalAlertView(title: selectTimeOrVolumeBtn.titleLabel?.text, message: nil, subtitles: [], alertClouser: { (title) -> Void in
//
//            switch title {
//            case self.operatorIrancell:
//                self.operatorType = IGOperator.irancell
//                self.setOperator()
//                break
//            case self.operatorMCI:
//                self.operatorType = IGOperator.mci
//                self.setOperator()
//                break
//            case self.operatorRightel:
//                self.operatorType = IGOperator.rightel
//                self.setOperator()
//                break
//            default:
//                break
//            }
//            self.view.endEditing(true)
//        })
    }
    
    @IBAction func choosePackageTappd(_ sender: UIButton) {
        
    }

}
