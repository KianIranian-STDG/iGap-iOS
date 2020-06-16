//
//  IGPSInternetPackagesVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/9/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSInternetPackagesVM : NSObject {
    weak var vc : IGPSInternetPackagesVC?
    var selectedPhone : String!
    var selectedOp : IGSelectedOperator!
    var selectedType : String!
    var currentSelectedCellIndexPath : IndexPath?
    var internetPackages: [IGPSInternetPackages]!
    var specialPackages = [IGPSInternetPackages]()
    var normalPackages = [IGPSInternetPackages]()

    var filteredPackages = [IGPSInternetPackages]() {
        didSet {
            vc?.table.reloadData()
        }
    }
    var selectedCategory : IGPSInternetCategory!
    var selectedPackage : IGPSInternetPackages!
    var selectedLastPackage : IGPSLastInternetPackagesPurchases!
    var selectedVolume: IGPSInternetCategory? {
        didSet {
            filterData()
        }
    }
    var seletedDuration: IGPSInternetCategory? {
        didSet {
            filterData()
        }
    }
    
    private func filterData() {
        if selectedVolume == nil && seletedDuration == nil{
            filteredPackages = internetPackages
        }else if selectedVolume != nil && seletedDuration != nil {
            filteredPackages = internetPackages.filter({ (pack) -> Bool in
                return pack.traffic == selectedVolume?.id
            }).filter({ (pack) -> Bool in
                return pack.duration == seletedDuration?.id
            })
        } else if seletedDuration == nil && selectedVolume != nil {
            filteredPackages = internetPackages.filter({ (pack) -> Bool in
                return pack.traffic == selectedVolume?.id
            })
        }else {
            filteredPackages = internetPackages.filter({ (pack) -> Bool in
                return pack.duration == seletedDuration?.id
            })
        }
        vc?.table.reloadData()
    }
    var indexOfSelectedPackage : IndexPath!  {
        didSet {
            currentSelectedCellIndexPath = indexOfSelectedPackage

            switch  indexOfSelectedPackage.section {
            case 0 :
                let items = filteredPackages.filter { (pack) -> Bool in
                    return (pack.isSpecial == true)
                }
                    selectedPackage = items[indexOfSelectedPackage.row]
                
            case 1 :
                let items = filteredPackages.filter { (pack) -> Bool in
                    return (pack.isSpecial == false)
                }
                    selectedPackage = items[indexOfSelectedPackage.row]

            default : break
            }
            
            vc?.table.reloadData()
            
        }
    }
    
    
    
    init(viewController: IGPSInternetPackagesVC) {
        self.vc = viewController
        
    }
    
    func addToHistory() {
        var userOperator : String!
        switch selectedOp {
        case .MCI :
            userOperator = "MCI"
        case .MTN :
            userOperator = "MTN"

        case .Rightel :
            userOperator = "RIGHTEL"

        default : break
        }

//        let chargeAmount = (selectedAmount.onlyDigitChars())

        IGApiInternetPackage.shared.saveToHistory(opType: userOperator, telNum: selectedPhone!.inEnglishNumbersNew(), chargeType: selectedPackage.chargeType!.description, packageType: selectedPackage.type!) { (success) in
            
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.PSAdeddSuccessFully.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                })

            } else {
                IGGlobal.prgHide()
            }
        }
    }
    
    func buyInternetPackage() {
        if selectedPackage == nil {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalCheckFields.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return
        }

        IGApiInternetPackage.shared.purchase(opType: selectedOp!, telNum: String(selectedPhone!.remove98().dropFirst()) , type: selectedPackage.type!) { (success, token) in
            
            if success {
                guard let token = token else { return }
                print("Success: " + token)
                IGApiPayment.shared.orderCheck(token: token, completion: { (success, payment, errorMessage) in
                    IGGlobal.prgHide()
                    let paymentView = IGPaymentView.sharedInstance
                    if success {
                        guard let paymentData = payment else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            return
                        }
                        paymentView.show(on: UIApplication.shared.keyWindow!, title: IGStringsManager.BuyInternetPackage.rawValue.localized, payToken: token, payment: paymentData)
                        IGGlobal.isTopUpResult = true

                    } else {
                        
                        paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.BuyInternetPackage.rawValue.localized, message: errorMessage ?? "", payToken: token)
                    }
                })
                
            } else {
                IGGlobal.prgHide()
            }
        }
    }
    //MARK: - Fetch Data
    func reloadData(selectedCat : IGPSInternetCategory) {
        selectedCategory = selectedCat
        let items = internetPackages.filter { (newPack) -> Bool in
            if selectedCategory.category?.type == "DURATION" {
                return newPack.duration == selectedCategory.id
            } else {
                return newPack.traffic == selectedCategory.id
            }
        }
        filteredPackages.removeAll()
        filteredPackages = items
        
        vc?.table.reloadData()
    }
}

extension IGPSInternetPackagesVM : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            let items = filteredPackages.filter { (pack) -> Bool in
                return (pack.isSpecial == true)
            }
                return items.count

        case 1 :
            let items = filteredPackages.filter { (pack) -> Bool in
            return pack.isSpecial == false
            }
                return items.count

        default : return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "IGPSInternetPackagesCell", for: indexPath) as! IGPSInternetPackagesCell
        if currentSelectedCellIndexPath != nil && indexPath == currentSelectedCellIndexPath {
            cell.holder.backgroundColor = ThemeManager.currentTheme.iVandColor.lighter(by: 10)
        } else {
            cell.holder.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
        }

        switch indexPath.section {
        case 0 :
            let items = filteredPackages.filter { (pack) -> Bool in
                return (pack.isSpecial == true)
            }
            cell.item = items[indexPath.row]
        case 1 :
            let items = filteredPackages.filter { (cat) -> Bool in
                return cat.isSpecial == false
            }
            cell.item = items[indexPath.row]
        default : return UITableViewCell()
        }
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? IGPSInternetPackagesCell else { return }
        cell.holder.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 20)
        currentSelectedCellIndexPath = indexPath
        switch indexPath.section {
            case 0 :
                let items = filteredPackages.filter { (pack) -> Bool in
                    return (pack.isSpecial == true)
                }
                    selectedPackage = items[indexPath.row]
            case 1 :
                let items = filteredPackages.filter { (cat) -> Bool in
                return cat.isSpecial == false
                }
                    selectedPackage = items[indexPath.row]
            default : break
            }
        vc?.table.reloadData()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? IGPSInternetPackagesCell else { return }
        cell.holder.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
        currentSelectedCellIndexPath = nil
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        let lbl = UILabel()
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.textAlignment = lbl.localizedDirection
        lbl.font = UIFont.igFont(ofSize: 13,weight: .bold)
        v.addSubview(lbl)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
        lbl.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
        lbl.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
        lbl.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
        switch section {
        case 0 : lbl.text = IGStringsManager.PSSuggestedPackages.rawValue.localized
        case 1 : lbl.text = IGStringsManager.PSNormalPackages.rawValue.localized
        default : return nil
        }
        return v

    }
    
    
}
