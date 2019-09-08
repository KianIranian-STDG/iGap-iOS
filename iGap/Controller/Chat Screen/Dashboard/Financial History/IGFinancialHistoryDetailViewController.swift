//
//  IGFinancialHistoryDetailViewController.swift
//  iGap
//
//  Created by hossein nazari on 9/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import IGProtoBuff

class IGFinancialHistoryDetailViewController: BaseViewController {
    
    @IBOutlet weak var statusIconLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var payTimeLbl: UILabel!
    @IBOutlet weak var payDateLbl: UILabel!
    @IBOutlet weak var transactionInfoTableView: UITableView!
    
    var TransactionInfoKeys: Dictionary<String, Array<String>>!
    var igpTransaction: IGPMplTransaction!
    
    var transactionToken: String! {
        didSet {
            getData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transactionInfoTableView.semanticContentAttribute = self.semantic

        initNavigationBar(title: "PAYMENT_HISTORY".FinancialHistoryLocalization, rightItemText: "", iGapFont: true) {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size,true,0.0)
            self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imagesToShare = [image as AnyObject]
            let activityViewController = UIActivityViewController(activityItems: imagesToShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.mail]
            activityViewController.modalPresentationStyle = .overCurrentContext
            self.present(activityViewController, animated: true, completion: {
                
            })
        }
        
        transactionInfoTableView.dataSource = self
        transactionInfoTableView.delegate = self
        
        readTransactionInfoKeysDictionary()
        
        self.payTimeLbl.text = "_"
        self.payDateLbl.text = "_"
        self.statusLbl.text = "_"
    }
    
    private func getData() {
        IGMplTransactionInfo.Generator.generate(transactionToken: self.transactionToken).success ({ (responseProtoMessage) in
            DispatchQueue.main.async {
                switch responseProtoMessage {
                case let response as IGPMplTransactionInfoResponse:
                    if response.igpStatus == 0 {
                        self.statusIconLbl.textColor = UIColor.iGapGreen()
                        self.statusIconLbl.text = ""
                        self.statusLbl.textColor = UIColor.iGapGreen()
                        self.statusLbl.text = "SUCCESSFULL_PAYMENT".FinancialHistoryLocalization
                        self.setupTransactionInfo(info: response.igpTransaction)
                        
                    } else {
                        // false status
                        self.statusIconLbl.textColor = UIColor.iGapRed()
                        self.statusIconLbl.text = ""
                        self.statusLbl.textColor = UIColor.iGapRed()
                        self.statusLbl.text = "UNSUCCESSFULL_PAYMENT".FinancialHistoryLocalization
                    }
                    
                default:
                    break;
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
    
    private func setupTransactionInfo(info: IGPMplTransaction) {
        self.igpTransaction = info
        self.transactionInfoTableView.reloadWithAnimation()
        
        let payTimeSecond = Double(info.igpPayTime)
        var dateComps: (Int?, Int?, Int?, Int?, Int?, String?)!
        
        if self.isAppEnglish {
            dateComps = SMDateUtil.toGregorianYearMonthDayHoureMinuteWeekDay(payTimeSecond)
        } else {
            dateComps = SMDateUtil.toPersianYearMonthDayHoureMinuteWeekDay(payTimeSecond)
        }
        
        self.payDateLbl.text = "\(dateComps.5 ?? "")\n\(dateComps.0 ?? 0)/\(dateComps.1 ?? 0)/\(dateComps.2 ?? 0)".inLocalizedLanguage()
        self.payTimeLbl.text = "\(dateComps.3 ?? 0):\(dateComps.4 ?? 0)".inLocalizedLanguage()
    }
    
    func readTransactionInfoKeysDictionary() {
        var settingDic: NSDictionary?
        if let path = Bundle.main.path(forResource: "TransactionInfoKeys", ofType: "stringsdict") {
            settingDic = NSDictionary(contentsOfFile: path)
        }
        if let dict = settingDic {
            // Use your dict here
            if let typesDict = dict["TransactionInfoKeys"] {
                self.TransactionInfoKeys = typesDict as? Dictionary<String, Array<String>>
            }
        }
    }
}

extension IGFinancialHistoryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TransactionInfoKeys != nil, self.igpTransaction != nil {
            switch self.igpTransaction.igpType {
            case .none:
                return 0
            case .bill:
                return TransactionInfoKeys["BILL"]?.count ?? 0
            case .topup:
                return TransactionInfoKeys["TOPUP"]?.count ?? 0
            case .sales:
                return TransactionInfoKeys["SALES"]?.count ?? 0
            case .cardToCard:
                return TransactionInfoKeys["CARD_TO_CARD"]?.count ?? 0
            case .UNRECOGNIZED(_):
                return 0
            }
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionInfoTVCell", for: indexPath) as? TransactionInfoTVCell else { return TransactionInfoTVCell() }
        cell.setupCell(transaction: self.igpTransaction, indexPath: indexPath, transactionInfoKeys: TransactionInfoKeys)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
}

class TransactionInfoTVCell: UITableViewCell {
    @IBOutlet weak var keyLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    
    public func setupCell(transaction: IGPMplTransaction, indexPath: IndexPath, transactionInfoKeys: Dictionary<String, Array<String>>) {
        switch transaction.igpType {
        case .none:
            break
        case .bill:
            let bill = transaction.igpBill
            let keyValue = transactionInfoKeys["BILL"]?[indexPath.row]
            self.keyLbl.text = keyValue?.FinancialHistoryLocalization
            self.setupBill(keyValue: keyValue!, bill: bill)
            
        case .topup:
            let topup = transaction.igpTopup
            let keyValue = transactionInfoKeys["TOPUP"]?[indexPath.row]
            self.keyLbl.text = keyValue?.FinancialHistoryLocalization
            self.setupTopup(keyValue: keyValue!, topup: topup)
            
        case .sales:
            let sales = transaction.igpSales
            let keyValue = transactionInfoKeys["SALES"]?[indexPath.row]
            self.keyLbl.text = keyValue?.FinancialHistoryLocalization
            self.setupSales(keyValue: keyValue!, sales: sales)
            
        case .cardToCard:
            let cardtocard = transaction.igpCardtocard
            let keyValue = transactionInfoKeys["CARD_TO_CARD"]?[indexPath.row]
            self.keyLbl.text = keyValue?.FinancialHistoryLocalization
            self.setupCardtoCard(keyValue: keyValue!, cardToCard: cardtocard)
            
        case .UNRECOGNIZED(_):
            break
        }
    }
    
    private func setupCardtoCard(keyValue: String, cardToCard: IGPMplTransaction.IGPCardToCard) {
        if keyValue == "BANK" {
            self.valueLbl.text = cardToCard.igpBankName.inLocalizedLanguage()
        } else if keyValue == "CARD_OWNER" {
            self.valueLbl.text = cardToCard.igpCardOwnerName.inLocalizedLanguage()
        } else if keyValue == "DESTINATION_BANK" {
            self.valueLbl.text = cardToCard.igpDestBankName.inLocalizedLanguage()
        } else if keyValue == "DESTINATION_CARD" {
            self.valueLbl.text = cardToCard.igpDestCardNumber.inLocalizedLanguage()
        } else if keyValue == "SOURCE_CARD" {
            self.valueLbl.text = cardToCard.igpSourceCardNumber.inLocalizedLanguage()
        } else if keyValue == "AMOUNT" {
            self.valueLbl.text = "\(cardToCard.igpAmount)".inRialFormat()
        } else if keyValue == "MPL_TRANSACTION_ORDER_ID" {
            self.valueLbl.text = "\(cardToCard.igpOrderID)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_RRN" {
            self.valueLbl.text = "\(cardToCard.igpRrn)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_TRACE_NO" {
            self.valueLbl.text = "\(cardToCard.igpTraceNo)".inLocalizedLanguage()
        }
    }
    
    private func setupSales(keyValue: String, sales: IGPMplTransaction.IGPSales) {
        if keyValue == "MERCHANT_NAME" {
            self.valueLbl.text = sales.igpMerchantName.inLocalizedLanguage()
        } else if keyValue == "CARD_NUMBER" {
            self.valueLbl.text = sales.igpCardNumber.inLocalizedLanguage()
        } else if keyValue == "MPL_TERMINAL_NO" {
            self.valueLbl.text = "\(sales.igpTerminalNo)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_TRACE_NO" {
            self.valueLbl.text = "\(sales.igpTraceNo)".inLocalizedLanguage()
        } else if keyValue == "AMOUNT" {
            self.valueLbl.text = "\(sales.igpAmount)".inRialFormat()
        } else if keyValue == "MPL_TRANSACTION_ORDER_ID" {
            self.valueLbl.text = "\(sales.igpOrderID)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_RRN" {
            self.valueLbl.text = "\(sales.igpRrn)".inLocalizedLanguage()
        }
    }
    
    private func setupTopup(keyValue: String, topup: IGPMplTransaction.IGPTopup) {
        if keyValue == "MERCHANT_NAME" {
            self.valueLbl.text = topup.igpMerchantName.inLocalizedLanguage()
        } else if keyValue == "CARD_NUMBER" {
            self.valueLbl.text = topup.igpCardNumber.inLocalizedLanguage()
        } else if keyValue == "MPL_TERMINAL_NO" {
            self.valueLbl.text = "\(topup.igpTerminalNo)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_TRACE_NO" {
            self.valueLbl.text = "\(topup.igpTraceNo)".inLocalizedLanguage()
        } else if keyValue == "AMOUNT" {
            self.valueLbl.text = "\(topup.igpAmount)".inRialFormat()
        } else if keyValue == "MOBILE_NUMBER" {
            self.valueLbl.text = "\(topup.igpChargeMobileNumber)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_ORDER_ID" {
            self.valueLbl.text = "\(topup.igpOrderID)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_RRN" {
            self.valueLbl.text = "\(topup.igpRrn)".inLocalizedLanguage()
        }
    }
    
    private func setupBill(keyValue: String, bill: IGPMplTransaction.IGPBill) {
        if keyValue == "BILLING_ID" {
            self.valueLbl.text = bill.igpBillID.inLocalizedLanguage()
        } else if keyValue == "BILL_TYPE" {
            self.valueLbl.text = bill.igpBillType.inLocalizedLanguage()
        } else if keyValue == "CARD_NUMBER" {
            self.valueLbl.text = bill.igpCardNumber.inLocalizedLanguage()
        } else if keyValue == "MERCHANT_NAME" {
            self.valueLbl.text = bill.igpMerchantName.inLocalizedLanguage()
        } else if keyValue == "PAY_ID" {
            self.valueLbl.text = bill.igpPayID.inRialFormat()
        } else if keyValue == "AMOUNT" {
            self.valueLbl.text = "\(bill.igpAmount)".inRialFormat()
        } else if keyValue == "MPL_TRANSACTION_ORDER_ID" {
            self.valueLbl.text = "\(bill.igpOrderID)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_RRN" {
            self.valueLbl.text = "\(bill.igpRrn)".inLocalizedLanguage()
        } else if keyValue == "MPL_TERMINAL_NO" {
            self.valueLbl.text = "\(bill.igpTerminalNo)".inLocalizedLanguage()
        } else if keyValue == "MPL_TRANSACTION_TRACE_NO" {
            self.valueLbl.text = "\(bill.igpTraceNo)".inLocalizedLanguage()
        }
    }
}
