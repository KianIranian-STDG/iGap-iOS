//
//  IGPSBillMyBillsCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/16/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import IGProtoBuff
import PecPayment

class IGPSBillMyBillsCell: BaseTableViewCell ,BillMerchantResultObserver {
    
    var indexPath : IndexPath!
    var billIUniqueID : String!
    var item : parentBillModel! {
        didSet {
            lblBillName.text = item.billTitle
            switch item.billType {
            case "ELECTRICITY" : billType = .Elec
            case "GAS" : billType = .Gas
            case "MOBILE_MCI" : billType = .Mobile
            case "PHONE" : billType = .Phone
            default : break
            }
        }
    }
    var billType : IGBillType!  {
        didSet {
            switch billType {
            case .Elec :
                lblBillID.text = IGStringsManager.BillId.rawValue.localized
                lblBillPayID.text = IGStringsManager.PayIdentifier.rawValue.localized
                lblBillPayAmount.text = IGStringsManager.BillPrice.rawValue.localized
                lblBillDeadLine.text = IGStringsManager.BillPayDate.rawValue.localized
                ivBill.image = UIImage(named: "bill_elc_pec")
                lblBillIDData.text = item.billIdentifier?.inLocalizedLanguage()
                btnOne.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
                btnTwo.setTitle(IGStringsManager.Details.rawValue.localized, for: .normal)
                billIUniqueID = item.id
                
                lblBillPayIDData.text = item.elecBill?.paymentIdentifier ?? IGStringsManager.GlobalLoading.rawValue.localized
                lblBillPayAmountData.text = item.elecBill?.totalBillDebt  ?? IGStringsManager.GlobalLoading.rawValue.localized
                lblBillDeadLineData.text = item.elecBill?.paymentDeadLine  ?? IGStringsManager.GlobalLoading.rawValue.localized
                if lblBillPayAmountData.text == "_" {
                    btnOne.isHidden = true
                    btnTwo.isHidden = true
                    btnThree.isHidden = false
                } else {
                    btnOne.isHidden = false
                    btnTwo.isHidden = false
                    btnThree.isHidden = true
                    
                }
                break
            case .Gas :
                lblBillID.text = IGStringsManager.PSSubscriptionCode.rawValue.localized
                lblBillPayID.text = IGStringsManager.PayIdentifier.rawValue.localized
                lblBillPayAmount.text = IGStringsManager.BillPrice.rawValue.localized
                lblBillDeadLine.text = IGStringsManager.BillPayDate.rawValue.localized
                ivBill.image = UIImage(named: "bill_gaz_pec")
                lblBillIDData.text = item.subsCriptionCode?.inLocalizedLanguage()
                btnOne.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
                btnTwo.setTitle(IGStringsManager.Details.rawValue.localized, for: .normal)
                billIUniqueID = item.id
                
                lblBillPayIDData.text = item.gasBill?.paymentIdentifier ?? IGStringsManager.GlobalLoading.rawValue.localized
                lblBillPayAmountData.text = item.gasBill?.totalBillDebt  ?? IGStringsManager.GlobalLoading.rawValue.localized
                lblBillDeadLineData.text = item.gasBill?.paymentDeadLine  ?? IGStringsManager.GlobalLoading.rawValue.localized
                if lblBillPayAmountData.text == "_" {
                    btnOne.isHidden = true
                    btnTwo.isHidden = true
                    btnThree.isHidden = false
                } else {
                    btnOne.isHidden = false
                    btnTwo.isHidden = false
                    btnThree.isHidden = true
                    
                }
                
                break
            case .Phone :
                lblBillID.text = IGStringsManager.PhoneNumber.rawValue.localized
                lblBillPayID.text = IGStringsManager.BillId.rawValue.localized
                lblBillPayAmount.text = IGStringsManager.PSPayMidTerm.rawValue.localized
                lblBillDeadLine.text = IGStringsManager.PSPayLastTerm.rawValue.localized
                ivBill.image = UIImage(named: "bill_telecom_pec")
                lblBillIDData.text = (item.billAreaCode?.inLocalizedLanguage())! + (item.billPhone?.inLocalizedLanguage())!
                btnOne.setTitle(IGStringsManager.PSPayMidTerm.rawValue.localized, for: .normal)
                btnTwo.setTitle(IGStringsManager.PSPayLastTerm.rawValue.localized, for: .normal)
                billIUniqueID = item.id
                if item.phoneBill?.midTermPhone?.billId == nil && item.phoneBill?.lastTermPhone?.billId == nil {
                    lblBillPayIDData.text = "_"
                    lblBillPayAmountData.text = "_"
                    lblBillDeadLineData.text = "_"
                    
                    btnOne.isHidden = true
                    btnTwo.isHidden = true
                    btnThree.isHidden = false

                } else {
                    lblBillPayIDData.text = "\(item.phoneBill?.midTermPhone?.billId ?? item.phoneBill?.lastTermPhone?.billId ?? 0)"
                    lblBillPayAmountData.text = "\(item.phoneBill?.midTermPhone?.amount ?? 0)"
                    if "\(item.phoneBill?.midTermPhone?.amount ?? 0)" == "0" {
                        lblBillPayAmountData.text = "0".inLocalizedLanguage()
                    } else {
                        lblBillPayAmountData.text = "\(item.phoneBill?.midTermPhone?.amount ?? 0)".currencyFormat()
                    }
                    if "\(item.phoneBill?.lastTermPhone?.amount ?? 0)" == "0" {
                        lblBillDeadLineData.text = "0".inLocalizedLanguage()
                    } else {
                        lblBillDeadLineData.text = "\(item.phoneBill?.lastTermPhone?.amount ?? 0)".currencyFormat()
                    }
                    btnOne.isHidden = false
                    btnTwo.isHidden = false
                    btnThree.isHidden = true

                }

           
                break
            case .Mobile :
                lblBillID.text = IGStringsManager.MobileNumber.rawValue.localized
                lblBillPayID.text = IGStringsManager.BillId.rawValue.localized
                lblBillPayAmount.text = IGStringsManager.PSPayMidTerm.rawValue.localized
                lblBillDeadLine.text = IGStringsManager.PSPayLastTerm.rawValue.localized
                ivBill.image = UIImage(named: "MCILogo")
                lblBillIDData.text = item.billPhone?.inLocalizedLanguage()
                btnOne.setTitle(IGStringsManager.PSPayMidTerm.rawValue.localized, for: .normal)
                btnTwo.setTitle(IGStringsManager.PSPayLastTerm.rawValue.localized, for: .normal)
                billIUniqueID = item.id

                if item.mobileBill?.midTermMobile?.billId == nil && item.mobileBill?.lastTermMobile?.billId == nil {
                    lblBillPayIDData.text = "_"
                    lblBillPayAmountData.text = "_"
                    lblBillDeadLineData.text = "_"
                    
                    btnOne.isHidden = true
                    btnTwo.isHidden = true
                    btnThree.isHidden = false

                } else {
                    lblBillPayIDData.text = item.mobileBill?.midTermMobile?.billId ?? (item.mobileBill?.lastTermMobile?.billId ?? "0")
                    lblBillPayAmountData.text = (item.mobileBill?.midTermMobile?.amount)?.currencyFormat() ?? "0".inLocalizedLanguage()
                    lblBillDeadLineData.text = (item.mobileBill?.lastTermMobile?.amount)?.currencyFormat() ?? "0".inLocalizedLanguage()
                    if "\(item.mobileBill?.midTermMobile?.amount ?? "0")" == "0" {
                        lblBillPayAmountData.text = "0".inLocalizedLanguage()
                    } else {
                        lblBillPayAmountData.text = "\(item.mobileBill?.midTermMobile?.amount ?? "0")".currencyFormat()
                    }
                    if "\(item.mobileBill?.lastTermMobile?.amount ?? "0")" == "0" {
                        lblBillDeadLineData.text = "0".inLocalizedLanguage()
                    } else {
                        lblBillDeadLineData.text = "\(item.mobileBill?.lastTermMobile?.amount ?? "0")".currencyFormat()
                    }

                    btnOne.isHidden = false
                    btnTwo.isHidden = false
                    btnThree.isHidden = true

                }
                
                break
            default : break
            }
            //            QueryInnerData(itemData: item)
            
        }

        
    }
    let holder : UIView = {
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
    let holderImage : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        view.layer.cornerRadius = 25
        view.layer.borderColor = ThemeManager.currentTheme.NavigationSecondColor.cgColor
        view.layer.borderWidth = 2.0
        view.clipsToBounds = true
        return view
    }()
    let ivBill : UIImageView = {
        let iv = UIImageView()
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "2")
        return iv
    }()
    
    
    
    private let lblBillName : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13,weight: .bold)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = "TEST"
        lbl.numberOfLines = 0
        lbl.textAlignment = lbl.localizedDirection
        return lbl
    }()
    
    private let btnEdit : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.iGapFonticon(ofSize: 30)
        lbl.textColor = .lightGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = ""
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    private let btnDelete : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.iGapFonticon(ofSize: 30)
        lbl.textColor = .red
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = ""
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    
    
    private let lblBillID : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.BillId.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirection
        return lbl
    }()
    
    private let lblBillPayID : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.PayIdentifier.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirection
        return lbl
    }()
    
    private let lblBillPayAmount : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.BillPrice.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirection
        return lbl
    }()
    
    private let lblBillDeadLine : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.BillPayDate.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirection
        return lbl
    }()
    
    private let lblBillIDData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirectionOposit
        return lbl
    }()
    let lblBillPayIDData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirectionOposit
        return lbl
    }()
    let lblBillPayAmountData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirectionOposit
        return lbl
    }()
    let lblBillDeadLineData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = IGStringsManager.GlobalLoading.rawValue.localized
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirectionOposit
        return lbl
    }()
    
    let btnOne : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
        return btn
    }()
    
    let btnTwo : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.Details.rawValue.localized, for: .normal)
        return btn
    }()
    let btnThree : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        btn.layer.cornerRadius = 15
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.GlobalRetry.rawValue.localized, for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
        holder.semanticContentAttribute = self.semantic
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initView() {
        addHolder()
        self.selectionStyle = .none
        manageActions()

    }
    
    private func manageActions() {
        btnDelete.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            
            IGHelperAlert.shared.showCustomAlert(view: UIApplication.topViewController(), alertType: .question, title: IGStringsManager.Delete.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.AreYouSure.rawValue.localized, doneText: IGStringsManager.Delete.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {}, done: {
                
                IGApiBills.shared.deleteBill(billType: sSelf.item.billType!, billID: sSelf.item.id!)  {[weak self] (response, error) in
                    guard let sSelf = self else {
                        return
                    }
                    if error != nil {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: response?.message, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                        
                        return
                    } else {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: response?.message, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                        (UIApplication.topViewController() as! IGPSBillMyBillsTVC).vm.items.remove(at: sSelf.indexPath.row)
                        (UIApplication.topViewController() as! IGPSBillMyBillsTVC).table.beginUpdates()
                        (UIApplication.topViewController() as! IGPSBillMyBillsTVC).table.deleteRows(at: [sSelf.indexPath], with: .fade)
                        (UIApplication.topViewController() as! IGPSBillMyBillsTVC).table.endUpdates()
                    }
                    
                }
                
                
            })
            
        })
        
        
        btnThree.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            
            switch sSelf.item.billType {
            case "ELECTRICITY" :
                (UIApplication.topViewController() as! IGPSBillMyBillsTVC).vm.queryElecBill(index: sSelf.indexPath.row, billType: sSelf.item.billType!, telNum: sSelf.item.mobileNumber!, billID: sSelf.item.billIdentifier)
                break
            case "GAS" :
                (UIApplication.topViewController() as! IGPSBillMyBillsTVC).vm.queryGasBill(index: sSelf.indexPath.row, billType: sSelf.item.billType!, billID: sSelf.item.subsCriptionCode!)
                
                break
            case "MOBILE_MCI" :
                (UIApplication.topViewController() as! IGPSBillMyBillsTVC).vm.queryMobileBill(index: sSelf.indexPath.row, billType: sSelf.item.billType!, telNum: sSelf.item.billPhone!)
                
                break
            case "PHONE" :
                (UIApplication.topViewController() as! IGPSBillMyBillsTVC).vm.queryPhoneBill(index: sSelf.indexPath.row, billType: sSelf.item.billType!, telNum: "0" + sSelf.item.billAreaCode! + sSelf.item.billPhone!)
                
                break
            default : break
            }
            
            
        })
        btnEdit.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            
            switch sSelf.item.billType {
            case "ELECTRICITY" :
                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "EDIT_BILL", billType: .Elec, bill: sSelf.item,billIndex: sSelf.indexPath.row)
                break
            case "GAS" :
                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "EDIT_BILL", billType: .Gas,bill: sSelf.item,billIndex: sSelf.indexPath.row)
                break
            case "MOBILE_MCI" :
                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "EDIT_BILL", billType: .Mobile,bill: sSelf.item,billIndex: sSelf.indexPath.row)
                break
            case "PHONE" :
                IGHelperBottomModals.shared.showEditBillName(view: UIApplication.topViewController(), mode: "EDIT_BILL", billType: .Phone,bill: sSelf.item,billIndex: sSelf.indexPath.row)
                
                break
            default : break
            }
            
            
        })
        btnOne.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            
            if sSelf.item.billIdentifier != nil || sSelf.item.billIdentifier != IGStringsManager.GlobalLoading.rawValue.localized || sSelf.item.billIdentifier != "_" {

                switch sSelf.billType {
                case .Elec :
                    if sSelf.lblBillPayAmountData.text == "0".inLocalizedLanguage() || sSelf.lblBillPayAmountData.text == "_" {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    } else {

                    sSelf.paySequence(billID : sSelf.item.billIdentifier!,payID : (sSelf.item.elecBill?.paymentIdentifier)! ,amount: Int((sSelf.item.elecBill?.totalBillDebt)!)!)
                    }
                case .Gas :
                    if sSelf.lblBillPayAmountData.text == "0".inLocalizedLanguage() || sSelf.lblBillPayAmountData.text == "_" {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    } else {

                    sSelf.paySequence(billID : sSelf.item.billIdentifier!,payID : (sSelf.item.gasBill?.paymentIdentifier)! ,amount: Int((sSelf.item.gasBill?.totalBillDebt)!)!)
                    }
                case .Phone :
                    if sSelf.lblBillPayAmountData.text == "0".inLocalizedLanguage() || sSelf.lblBillPayAmountData.text == "_"  {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    } else {

                        sSelf.paySequence(billID : sSelf.item.billIdentifier!,payID : "\(sSelf.item.phoneBill?.midTermPhone?.payId ?? 0)",amount: (sSelf.item.phoneBill?.midTermPhone?.amount)!)
                    }


                case .Mobile :
                    if sSelf.lblBillPayAmountData.text == "0".inLocalizedLanguage() || sSelf.lblBillPayAmountData.text == "_" {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    } else {
                        sSelf.paySequence(billID : sSelf.item.billIdentifier!,payID : "\(sSelf.item.mobileBill?.midTermMobile?.payId ?? "0")",amount: Int((sSelf.item.mobileBill?.midTermMobile?.amount)!)!)

                    }

                    
                default : break
                }
            }
            
            
        })
        
        btnTwo.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            if sSelf.item.billIdentifier != nil || sSelf.item.billIdentifier != IGStringsManager.GlobalLoading.rawValue.localized || sSelf.item.billIdentifier != "_" {


                switch sSelf.billType {
                case .Elec:
                        let billDataVC = IGPSBillDetailVC()
                        billDataVC.billNumber = sSelf.item.billIdentifier
                        billDataVC.billType = sSelf.billType
                        UIApplication.topViewController()?.navigationController!.pushViewController(billDataVC, animated:true)

                    

                case .Gas :
                    let billDataVC = IGPSBillDetailVC()
                    billDataVC.billNumber = sSelf.item.billIdentifier
                    billDataVC.billType = sSelf.billType
                    billDataVC.subscriptionCode = sSelf.item.subsCriptionCode
                    UIApplication.topViewController()?.navigationController!.pushViewController(billDataVC, animated:true)
                case .Phone :
                    if sSelf.lblBillDeadLineData.text == "0".inLocalizedLanguage() {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    } else {
                        sSelf.paySequence(billID : sSelf.lblBillPayIDData.text!,payID : "\(sSelf.item.phoneBill?.lastTermPhone?.payId ?? 0)",amount: (sSelf.item.phoneBill?.lastTermPhone?.amount)!)

                    }


                case .Mobile :
                    if sSelf.lblBillDeadLineData.text == "0".inLocalizedLanguage() {
                        IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.PSPayErrorAmount.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                    } else {
                        sSelf.paySequence(billID : sSelf.lblBillPayIDData.text!,payID : "\(sSelf.item.mobileBill?.lastTermMobile?.payId ?? "0")",amount: Int((sSelf.item.mobileBill?.lastTermMobile?.amount)!)!)

                    }

                    
                default : break
                }
                
            }
            
            
        })
    }
    private func addHolder () {
        //MARK: Add Holder
        addSubview(holder)
        holder.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        holder.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        holder.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 35).isActive = true
        holder.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -15).isActive = true
        holder.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.8).isActive = true
        
        //MARK: Image Bill
        addSubview(holderImage)
        holderImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        holderImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        holderImage.centerXAnchor.constraint(equalTo: holder.leadingAnchor).isActive = true
        holderImage.centerYAnchor.constraint(equalTo: holder.topAnchor,constant: 30).isActive = true
        holderImage.addSubview(ivBill)
        ivBill.topAnchor.constraint(equalTo: holderImage.topAnchor).isActive = true
        ivBill.bottomAnchor.constraint(equalTo: holderImage.bottomAnchor).isActive = true
        ivBill.leadingAnchor.constraint(equalTo: holderImage.leadingAnchor).isActive = true
        ivBill.trailingAnchor.constraint(equalTo: holderImage.trailingAnchor).isActive = true
        
        //MARK: Bill Name
        holder.addSubview(lblBillName)
        lblBillName.centerYAnchor.constraint(equalTo: holderImage.centerYAnchor).isActive = true
        lblBillName.leadingAnchor.constraint(equalTo: holderImage.trailingAnchor,constant: 10).isActive = true
        lblBillName.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.6).isActive = true
        
        //MARK: Edit Button
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.distribution = .fillEqually
        stk.addArrangedSubview(btnEdit)
        stk.addArrangedSubview(btnDelete)
        stk.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(stk)
        stk.centerYAnchor.constraint(equalTo: holderImage.centerYAnchor).isActive = true
        stk.leadingAnchor.constraint(equalTo: lblBillName.trailingAnchor,constant: 10).isActive = true
        stk.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true
        
        //MARK: Bill ID
        holder.addSubview(lblBillID)
        lblBillID.leadingAnchor.constraint(equalTo: holderImage.trailingAnchor,constant: 10).isActive = true
        lblBillID.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillID.topAnchor.constraint(equalTo: stk.bottomAnchor,constant: 25).isActive = true
        
        //MARK: Bill PayID
        holder.addSubview(lblBillPayID)
        lblBillPayID.leadingAnchor.constraint(equalTo: holderImage.trailingAnchor,constant: 10).isActive = true
        lblBillPayID.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillPayID.topAnchor.constraint(equalTo: lblBillID.bottomAnchor,constant: 25).isActive = true
        
        //MARK: Bill Pay Amount
        holder.addSubview(lblBillPayAmount)
        lblBillPayAmount.leadingAnchor.constraint(equalTo: holderImage.trailingAnchor,constant: 10).isActive = true
        lblBillPayAmount.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillPayAmount.topAnchor.constraint(equalTo: lblBillPayID.bottomAnchor,constant: 25).isActive = true
        
        //MARK: Bill Pay DeadLine
        holder.addSubview(lblBillDeadLine)
        lblBillDeadLine.leadingAnchor.constraint(equalTo: holderImage.trailingAnchor,constant: 10).isActive = true
        lblBillDeadLine.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillDeadLine.topAnchor.constraint(equalTo: lblBillPayAmount.bottomAnchor,constant: 25).isActive = true
        
        //MARK: Bill ID Data
        holder.addSubview(lblBillIDData)
        lblBillIDData.leadingAnchor.constraint(equalTo: lblBillIDData.trailingAnchor,constant: 10).isActive = true
        lblBillIDData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true
        lblBillIDData.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillIDData.topAnchor.constraint(equalTo: stk.bottomAnchor,constant: 25).isActive = true
        
        //MARK: Bill PayID Data
        holder.addSubview(lblBillPayIDData)
        lblBillPayIDData.leadingAnchor.constraint(equalTo: lblBillPayID.trailingAnchor,constant: 10).isActive = true
        lblBillPayIDData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true

        lblBillPayIDData.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillPayIDData.topAnchor.constraint(equalTo: lblBillIDData.bottomAnchor,constant: 25).isActive = true
        
        //MARK: Bill Pay Amount Data
        holder.addSubview(lblBillPayAmountData)
        lblBillPayAmountData.leadingAnchor.constraint(equalTo: lblBillPayAmount.trailingAnchor,constant: 10).isActive = true
        lblBillPayAmountData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true

        lblBillPayAmountData.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillPayAmountData.topAnchor.constraint(equalTo: lblBillPayIDData.bottomAnchor,constant: 25).isActive = true
//
        //MARK: Bill Pay DeadLine Data
        holder.addSubview(lblBillDeadLineData)
        lblBillDeadLineData.leadingAnchor.constraint(equalTo: lblBillDeadLine.trailingAnchor,constant: 10).isActive = true
        lblBillDeadLineData.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true

        lblBillDeadLineData.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.5).isActive = true
        lblBillDeadLineData.topAnchor.constraint(equalTo: lblBillPayAmountData.bottomAnchor,constant: 25).isActive = true
        
        
        let stkB = UIStackView()
        stkB.axis = .horizontal
        stkB.alignment = .fill
        stkB.distribution = .fillEqually
        stkB.addArrangedSubview(btnOne)
        stkB.addArrangedSubview(btnTwo)
        stkB.addArrangedSubview(btnThree)
        stkB.translatesAutoresizingMaskIntoConstraints = false
        stkB.spacing = 10
        holder.addSubview(stkB)
        stkB.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true
        stkB.centerYAnchor.constraint(equalTo: holder.bottomAnchor).isActive = true
        stkB.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stkB.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.8).isActive = true
        
        
    }
    
    
    private func initBillPaymanet(token: String){
        let initpayment = InitPayment()
        initpayment.registerBill(merchant: self)
        initpayment.initBillPayment(Token: token, MerchantVCArg: UIApplication.topViewController()!, TSPEnabled: 0)
    }
    
    func paySequence(billID : String,payID : String,amount: Int) {
        
        if amount < 10000 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.LessThan10000.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            
        } else {
            IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
            IGMplGetBillToken.Generator.generate(billId: Int64(billID.inEnglishNumbersNew())!, payId: Int64(payID.inEnglishNumbersNew())!).success({ (protoResponse) in
                IGLoading.hideLoadingPage()
                if let mplGetBillTokenResponse = protoResponse as? IGPMplGetBillTokenResponse {
                    if mplGetBillTokenResponse.igpStatus == 0 { //success
                        self.initBillPaymanet(token: mplGetBillTokenResponse.igpToken)
                    } else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: mplGetBillTokenResponse.igpMessage, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    }
                }
                
            }).error ({ (errorCode, waitTime) in
                IGLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    
                    break
                default:
                    break
                }
            }).send()
            
            
        }
    }
    func BillMerchantUpdate(encData: String, message: String, status: Int) {
        UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
    }
    
    func BillMerchantError(errorType: Int) {
    }

}
