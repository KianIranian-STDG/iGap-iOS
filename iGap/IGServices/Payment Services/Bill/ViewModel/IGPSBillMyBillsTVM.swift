//
//  IGPSBillMyBillsTVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/18/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSBillMyBillsTVM : NSObject,UITableViewDelegate,UITableViewDataSource {
    weak var vc : IGPSBillMyBillsTVC?
    var items = [parentBillModel]()
    
    init(viewController: IGPSBillMyBillsTVC) {
        self.vc = viewController
        
    }
    func queryInnerData(){

        for i in 0...items.count-1 {
            let item = items[i]
            
            switch item.billType {
            case "ELECTRICITY" :
                queryElecBill(index: i, billType: item.billType!, telNum: item.mobileNumber!, billID: item.billIdentifier!)
                break
            case "GAS" :
                queryGasBill(index: i, billType: item.billType!, billID: item.subsCriptionCode!)
                break
            case "MOBILE_MCI" :
                queryMobileBill(index: i, billType: item.billType!, telNum: item.billPhone!)
                break
            case "PHONE" :
                queryPhoneBill(index: i, billType: item.billType!, telNum: "0" + item.billAreaCode! + item.billPhone!)
                break
            default : break
            }
            
        }

    }
    
    
    func getAllBills() {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)

        IGApiBills.shared.getAllBills(){[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: error!, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            }
            if response!.count > 0 {
                  let vc = IGPSBillMyBillsTVC()
                sSelf.items.removeAll()
                vc.table.reloadData()
                sSelf.items = response!
                vc.table.reloadData()
                sSelf.queryInnerData()
                
            } else {

            }
            IGLoading.hideLoadingPage()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGPSBillMyBillsCell", for: indexPath) as! IGPSBillMyBillsCell
        cell.item = items[indexPath.row]
        //        cell.billType = items[indexPath.row].billType
        
        cell.indexPath = indexPath
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    
    
    //    MARK: -ELEC
    func queryElecBill(index: Int, billType: String, telNum: String? = nil, billID: String? = nil) {

        IGApiBills.shared.queryElecBill(billType: billType, telNum: telNum!, billID: billID!)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            
            
            
            
            
                if error != nil {
                    var elecBill = parentBillModel.elecModel()
                    elecBill.paymentIdentifier = "_"
                    elecBill.paymentDeadLine = "_"
                    elecBill.totalBillDebt = "_"
                    sSelf.items[index].elecBill = elecBill
                } else {
                    sSelf.items[index].billIdentifier = sSelf.items[index].billIdentifier
                    var elecBill = parentBillModel.elecModel()
                    elecBill.billIdentifier = sSelf.items[index].billIdentifier
                    elecBill.paymentIdentifier = response?.paymentIdentifier
                    elecBill.paymentDeadLine = response?.paymentDeadLine
                    elecBill.totalBillDebt = response?.totalBillDebt
                    sSelf.items[index].elecBill = elecBill
            }
                sSelf.vc?.table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
        
    }
    //MARK: -GAS
    func queryGasBill(index: Int, billType: String, billID: String? = nil) {
        IGApiBills.shared.queryGasBill(billType: billType, billID: billID!)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            
            
            var gasBill = parentBillModel.gasModel()
                if error != nil {
                    gasBill.paymentIdentifier = "_"
                    gasBill.paymentDeadLine = "_"
                    gasBill.totalBillDebt = "_"
                    sSelf.items[index].gasBill = gasBill
                } else {
                    sSelf.items[index].billIdentifier = sSelf.items[index].subsCriptionCode
                    gasBill.billIdentifier = response?.billIdentifier
                    gasBill.paymentIdentifier = response?.paymentIdentifier
                    gasBill.paymentDeadLine = response?.paymentDeadLine
                    gasBill.totalBillDebt = response?.totalBillDebt
                    sSelf.items[index].gasBill = gasBill
            }
                sSelf.vc?.table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
//            }

        }
        
    }
    //MARK: -PHONE
    func queryPhoneBill(index: Int, billType: String, telNum: String) {
        IGApiBills.shared.queryPhoneBill(billType: billType, telNum: telNum)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            var phoneBill = parentBillModel.phoneModel()
                if error != nil {
                    phoneBill.midTermPhone?.billId = nil
                    phoneBill.lastTermPhone?.billId = nil
                    sSelf.items[index].phoneBill = phoneBill
                } else {
                    sSelf.items[index].billIdentifier = sSelf.items[index].billIdentifier
                    if response?.midTerm?.billId == nil {
                        var lt = parentBillModel.phoneModel.PhoneLastTermInner()
                        lt.billId = response?.lastTerm?.billId
                        lt.payId = response?.lastTerm?.payId
                        lt.amount = response?.lastTerm?.amount
                        phoneBill.lastTermPhone = lt
                    } else {
                        var mt = parentBillModel.phoneModel.PhoneMidTermInner()

                        mt.billId = response?.midTerm?.billId
                        mt.payId = response?.midTerm?.payId
                        mt.amount = response?.midTerm?.amount
                        phoneBill.midTermPhone = mt

                    }
                    if  response?.lastTerm?.billId == nil {
                        var mt = parentBillModel.phoneModel.PhoneMidTermInner()

                        mt.billId = response?.midTerm?.billId
                        mt.payId = response?.midTerm?.payId
                        mt.amount = response?.midTerm?.amount
                        phoneBill.midTermPhone = mt

                    } else {
                        var lt = parentBillModel.phoneModel.PhoneLastTermInner()
                        lt.billId = response?.lastTerm?.billId
                        lt.payId = response?.lastTerm?.payId
                        lt.amount = response?.lastTerm?.amount
                        phoneBill.lastTermPhone = lt

                    }
                    sSelf.items[index].phoneBill = phoneBill
            }
                sSelf.vc?.table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)

            
        }
        
    }
    
    //    //MARK: -MOBILE
    func queryMobileBill(index: Int, billType: String, telNum: String) {
        IGApiBills.shared.queryMobileBill(billType: billType, telNum: telNum)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            
            var mobileBill = parentBillModel.mobileModel()
                if error != nil {
                    mobileBill.midTermMobile?.billId = nil
                    mobileBill.lastTermMobile?.billId = nil
                    sSelf.items[index].mobileBill = mobileBill
                } else {
                        sSelf.items[index].billIdentifier = sSelf.items[index].billIdentifier
                        if response?.midTerm?.billId == nil {
                            var lt = parentBillModel.mobileModel.MobileLastTermInner()
                            lt.billId = response?.lastTerm?.billId
                            lt.payId = response?.lastTerm?.payId
                            lt.amount = response?.lastTerm?.amount
                            mobileBill.lastTermMobile = lt
                        } else {
                            var mt = parentBillModel.mobileModel.MobileMidTermInner()

                            mt.billId = response?.midTerm?.billId
                            mt.payId = response?.midTerm?.payId
                            mt.amount = response?.midTerm?.amount
                            mobileBill.midTermMobile = mt

                    }
                        if  response?.lastTerm?.billId == nil {
                            var mt = parentBillModel.mobileModel.MobileMidTermInner()

                            mt.billId = response?.midTerm?.billId
                            mt.payId = response?.midTerm?.payId
                            mt.amount = response?.midTerm?.amount
                            mobileBill.midTermMobile = mt

                        } else {
                            var lt = parentBillModel.mobileModel.MobileLastTermInner()
                            lt.billId = response?.lastTerm?.billId
                            lt.payId = response?.lastTerm?.payId
                            lt.amount = response?.lastTerm?.amount
                            mobileBill.lastTermMobile = lt

                    }
                        sSelf.items[index].mobileBill = mobileBill
                }
                sSelf.vc?.table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)

        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
