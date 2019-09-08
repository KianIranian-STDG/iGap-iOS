/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import IGProtoBuff

class IGFinancialHistoryViewController: BaseViewController {
    
    @IBOutlet weak var transactionTypesCollectionView: UICollectionView!
    @IBOutlet weak var transactionsTableView: UITableView!
    
    var transactions = [IGPMplTransaction]()
    var transactionTypes: [IGPMplTransaction.IGPType]!
    var selectedType = IGPMplTransaction.IGPType.none
    var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionTypes = IGPMplTransaction.IGPType.allCases

        self.setupVC()
        
        self.getData(type: selectedType, offset: 0, limit: 15)
    }
    
    override func viewDidLayoutSubviews() {
        let firstIndex = IndexPath(item: 0, section: 0)
        self.transactionTypesCollectionView.scrollToItem(at: firstIndex, at: .centeredHorizontally, animated: false)
    }
    
    private func setupVC() {
        
        self.transactionsTableView.register(IGTransactionsTVCell.nib, forCellReuseIdentifier: IGTransactionsTVCell.identifier)
        
        self.transactionTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        self.initNavigationBar(title: "FINANCIAL_TRANSACTIONS_HISTORY".localizedNew)
        
        // transform
        self.transactionTypesCollectionView.semanticContentAttribute = self.semantic
        self.transactionsTableView.semanticContentAttribute = self.semantic
        self.transactionTypesCollectionView.transform = self.transform
        
        self.transactionTypesCollectionView.dataSource = self
        self.transactionTypesCollectionView.delegate = self
        
        self.transactionsTableView.dataSource = self
        self.transactionsTableView.delegate = self
    }
    
    private func getData(type: IGPMplTransaction.IGPType, offset: Int32, limit: Int32) {
        IGMplTransactionList.Generator.generate(type: type, offset: offset, limit: limit).success ({ (responseProtoMessage) in
            DispatchQueue.main.async {
                switch responseProtoMessage {
                case let response as IGPMplTransactionListResponse:
//                    self.numberOfRoomFetchedInLastRequest
//                    let x = IGMplTransactionList.Handler.interpret(response: response)
                    for _ in 1...30 {
                        self.transactions.append(contentsOf: response.igpTransaction)
                    }
                    self.transactionsTableView.reloadWithAnimation()
                default:
                    break;
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
}

extension IGFinancialHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactionTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionTypeCVCell", for: indexPath)
        let label = cell.viewWithTag(110) as! UILabel
        
        switch transactionTypes[indexPath.item] {
        case .none:
            label.text = "TRANSACTIONS_HISTORY_NONE".localizedNew
            break
        case .bill:
            label.text = "TRANSACTIONS_HISTORY_BILL".localizedNew
            break
        case .topup:
            label.text = "TRANSACTIONS_HISTORY_ُTOPUP".localizedNew
            break
        case .sales:
            label.text = "TRANSACTIONS_HISTORY_ُSALES".localizedNew
            break
        case .cardToCard:
            label.text = "TRANSACTIONS_HISTORY_CARD_TO_CARD".localizedNew
            break
        default:
            break
        }
        
        cell.layer.cornerRadius = 12
        cell.transform = self.transform
        
        if indexPath.item == selectedIndex {
            cell.backgroundColor = UIColor.iGapGreen()
            label.textColor = UIColor.white
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            label.textColor = UIColor.iGapDarkGray()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var typeStr = ""
        
        switch transactionTypes[indexPath.item] {
        case .none:
            typeStr = "TRANSACTIONS_HISTORY_NONE".localizedNew
            break
        case .bill:
            typeStr = "TRANSACTIONS_HISTORY_BILL".localizedNew
            break
        case .topup:
            typeStr = "TRANSACTIONS_HISTORY_ُTOPUP".localizedNew
            break
        case .sales:
            typeStr = "TRANSACTIONS_HISTORY_ُSALES".localizedNew
            break
        case .cardToCard:
            typeStr = "TRANSACTIONS_HISTORY_CARD_TO_CARD".localizedNew
            break
        default:
            break
        }
        
        let size: CGSize = typeStr.size(withAttributes: [NSAttributedString.Key.font: UIFont.igFont(ofSize: 13)])
        return CGSize(width: size.width + 32.0, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let label = cell.viewWithTag(110) as! UILabel
        cell.backgroundColor = UIColor.iGapGreen()
        label.textColor = UIColor.white
        
        selectedIndex = indexPath.item
        
        if selectedType != transactionTypes[indexPath.item] {
            
            self.transactions.removeAll()
            selectedType = transactionTypes[indexPath.item]
            self.transactionsTableView.reloadData()
            self.getData(type: selectedType, offset: 0, limit: 15)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let label = cell.viewWithTag(110) as! UILabel
        cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        label.textColor = UIColor.iGapDarkGray()
    }
}

extension IGFinancialHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: IGTransactionsTVCell.identifier, for: indexPath) as? IGTransactionsTVCell {
            
            let transaction = transactions[indexPath.row]
            
            switch transaction.igpType {
            case .none:
                cell.titleLbl.text = "TRANSACTIONS_HISTORY_NONE".localizedNew
                break
            case .bill:
                cell.titleLbl.text = "TRANSACTIONS_HISTORY_BILL".localizedNew
                break
            case .topup:
                cell.titleLbl.text = "TRANSACTIONS_HISTORY_ُTOPUP".localizedNew
                break
            case .sales:
                cell.titleLbl.text = "TRANSACTIONS_HISTORY_ُSALES".localizedNew
                break
            case .cardToCard:
                cell.titleLbl.text = "TRANSACTIONS_HISTORY_CARD_TO_CARD".localizedNew
                break
            case .UNRECOGNIZED(_):
                cell.titleLbl.text = "TRANSACTIONS_HISTORY_UNRECOGNIZED".localizedNew
                break
            }
            
            cell.tokenLbl.text = "TRANSACTIONS_HISTORY_ORDER_ID".localizedNew + ": " + "\(transaction.igpOrderID)".inLocalizedLanguage()
            
            let payTimeSecond = Double(transaction.igpPayTime)
            var dateComps: (Int?, Int?, Int?, Int?, Int?)!
            
            if self.isAppEnglish {
                dateComps = SMDateUtil.toGregorianYearMonthDayHoureMinute(payTimeSecond)
            } else {
                dateComps = SMDateUtil.toPersianYearMonthDayHoureMinute(payTimeSecond)
            }
            
            cell.dateLbl.text = "\(dateComps.0 ?? 0)/\(dateComps.1 ?? 0)/\(dateComps.2 ?? 0)".inLocalizedLanguage()
            cell.timeLbl.text = "\(dateComps.3 ?? 0):\(dateComps.4 ?? 0)".inLocalizedLanguage()
            
            return cell
            
        } else {
            return IGTransactionsTVCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if transactions.count < 14 {
            return
        }
        if indexPath.row == transactions.count - 2 {  //number of item count
            
            self.getData(type: selectedType, offset: Int32(transactions.count), limit: 15)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
