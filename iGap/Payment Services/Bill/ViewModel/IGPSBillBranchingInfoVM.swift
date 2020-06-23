//
//  IGPSBillMyBillsTVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/18/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSBillBranchingInfoTVM : NSObject,UITableViewDelegate,UITableViewDataSource {
    weak var vc : IGPSBillBranchingInfoTVC?
    var itemGas : GasBillBranchInfoModel!
    var itemElec : ElecBillBranchInfoModel!
    var billType : IGBillType!
    init(viewController: IGPSBillBranchingInfoTVC) {
        self.vc = viewController
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        switch billType {
        case .Elec :
            if itemElec != nil {
                return 17
            } else {
                return 0
            }
        case .Gas :
            if itemGas != nil {
                return 20
            } else {
                return 0
            }
        default : return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGPSBillBranchInfoCell", for: indexPath) as! IGPSBillBranchInfoCell
        switch billType {
        case .Elec :
            
            switch indexPath.row {
                case 0 :
                    cell.lblInfo.text = "شناسه قبض"
                    cell.lblData.text = itemElec.billIdentifier ?? ""
                    return cell
                case 1 :
                    cell.lblInfo.text = "شناسه پرداخت"
                    cell.lblData.text = itemElec.paymentIdentifier ?? ""
                    return cell
                case 2 :
                    cell.lblInfo.text = "کد شرکت توزیع"
                    cell.lblData.text = "\(itemElec.companyCode ?? 0)"
                    return cell
                case 3 :
                    cell.lblInfo.text = "نام شرکت توزیع"
                    cell.lblData.text = itemElec.companyName ?? ""
                    return cell
                case 4 :
                    cell.lblInfo.text = "نوع مشترک"
                    cell.lblData.text = itemElec.customerType ?? ""
                    return cell
                case 5 :
                    cell.lblInfo.text = "تلفن مشترک"
                    cell.lblData.text = itemElec.telNum ?? ""
                    return cell
                case 6 :
                    cell.lblInfo.text = "شماره همراه"
                    cell.lblData.text = itemElec.mobileNum ?? ""

                    return cell
                case 7 :
                    cell.lblInfo.text = "ولتاژ"
                    cell.lblData.text = itemElec.voltageType ?? ""
                    return cell
                case 8 :
                    cell.lblInfo.text = "قدرت"
                    cell.lblData.text = ""
                    return cell
                case 9 :
                    cell.lblInfo.text = "مبلغ قبض"
                    cell.lblData.text = itemElec.totalBillDebt?.inRialFormat() ?? "0" + IGStringsManager.Currency.rawValue.localized ?? ""

                    return cell
                case 10 :
                    cell.lblInfo.text = "آخرین مهلت پرداخت"
                    cell.lblData.text = itemElec.paymentDeadLine ?? ""
                    return cell
                case 11 :
                    cell.lblInfo.text = "آخرین تاریخ مشاهده کنتور"
                    cell.lblData.text = itemElec.lastReadDate ?? ""
                    return cell
                case 12 :
                    cell.lblInfo.text = "آدرس"
                    cell.lblData.text = itemElec.address ?? ""
                    return cell
                case 13 :
                    cell.lblInfo.text = "آمپر"
                    cell.lblData.text = itemElec.amper ?? ""
                    return cell
                case 14 :
                    cell.lblInfo.text = "کد اشتراک"
                    cell.lblData.text = "\(itemElec.subscriptionCode ?? 0)"
                    return cell
                case 15 :
                    cell.lblInfo.text = "تعرفه"
                    cell.lblData.text = itemElec.tarrifType ?? ""
                    return cell
                case 16 :
                    cell.lblInfo.text = "فاز"
                    cell.lblData.text = itemElec.phase ?? ""
                    return cell

            default : return cell

            }
        case .Gas :
            switch indexPath.row {
                
                case 0 :
                    cell.lblInfo.text = "شناسه قبض"
                    cell.lblData.text = itemGas.billIdentifier ?? ""
                    return cell
                case 1 :
                    cell.lblInfo.text = "شناسه پرداخت"
                    cell.lblData.text = itemGas.paymentIdentifier ?? ""
                    return cell
                case 2 :
                    cell.lblInfo.text = "شهر"
                    cell.lblData.text = itemGas.cityName ?? ""
                    return cell
                case 3 :
                    cell.lblInfo.text = "تعداد واحد"
                    cell.lblData.text = itemGas.unit ?? ""
                    return cell
                case 4 :
                    cell.lblInfo.text = "شماره اشتراک"
                    cell.lblData.text = itemGas.buildingID ?? ""
                    return cell
                case 5 :
                    cell.lblInfo.text = "سریال کنتور"
                    cell.lblData.text = itemGas.serialNum ?? ""
                    return cell
                case 6 :
                    cell.lblInfo.text = "ظرفیت"
                    cell.lblData.text = itemGas.capacity ?? ""
                    return cell
                case 7 :
                    cell.lblInfo.text = "نوع مصرف"
                    cell.lblData.text = itemGas.kind ?? ""
                    return cell
                case 8 :
                    cell.lblInfo.text = "تاریخ قرائت پیشین"
                    cell.lblData.text = itemGas.prevDate ?? ""
                    return cell
                case 9 :
                    cell.lblInfo.text = "تاریخ قرائت فعلی"
                    cell.lblData.text = itemGas.currentDate ?? ""
                    return cell
                case 10 :
                    cell.lblInfo.text = "رقم کنتور پیشین"
                    cell.lblData.text = itemGas.prevValue ?? ""
                    return cell
                case 11 :
                    cell.lblInfo.text = "رقم کنتور فعلی"
                    cell.lblData.text = itemGas.currentValue ?? ""
                    return cell
                case 12 :
                    cell.lblInfo.text = "مصرف"
                    cell.lblData.text = itemGas.standardConsuption ?? ""
                    return cell
                case 13 :
                    cell.lblInfo.text = "بهای گاز مصرفی"
                    cell.lblData.text = itemGas.gasPriceValue?.inRialFormat() ?? "0" + IGStringsManager.Currency.rawValue.localized ?? ""
                    return cell
                case 14 :
                    cell.lblInfo.text = "آبونمان"
                    cell.lblData.text = itemGas.abonmanValue ?? ""
                    return cell
                case 15 :
                    cell.lblInfo.text = "مالیات"
                    cell.lblData.text = itemGas.tax ?? ""
                    return cell
                case 16 :
                    cell.lblInfo.text = "عوارض گازرسانی"
                    cell.lblData.text = itemGas.villageTax  ?? ""
                    return cell
                case 17 :
                    cell.lblInfo.text = "بیمه"
                    cell.lblData.text = itemGas.assurance  ?? ""
                    return cell
                case 18 :
                    cell.lblInfo.text = "کسر هزار ریال"
                    cell.lblData.text = itemGas.currentRounding  ?? ""
                    return cell
                case 19 :
                    cell.lblInfo.text = "شماره سری"
                    cell.lblData.text = itemGas.sequenceNumber ?? ""

                    return cell
            default : return cell

            }
        default : return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func getBillBranchInfo(billType: String, billIdentifier: String? = nil , subscriptionCode : String? = nil) {
        if billType == "ELECTRICITY" {
            IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
            IGApiBills.shared.getElecBillBranchInfo(billType: billType, billIdentifier: billIdentifier!) {[weak self] (response, error) in
                guard let sSelf = self else { return }
                if error != nil {
                    IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.ServerError.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
                } else {
                    sSelf.itemElec = response
                    sSelf.vc?.table.reloadData()

                }
                IGLoading.hideLoadingPage()

            }
        } else {
            IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
            IGApiBills.shared.getGasBillBranchInfo(billType: billType, subscriptionCode: subscriptionCode!) {[weak self] (response, error) in
                guard let sSelf = self else { return }
                if error != nil {
                    IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.ServerError.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
                } else {
                    sSelf.itemGas = response
                    sSelf.vc?.table.reloadData()

                }
                IGLoading.hideLoadingPage()

            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}
