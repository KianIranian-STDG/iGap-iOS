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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupVC()
        
        self.getData(type: .none, offset: 0, limit: 15)
        
        for transactionType in IGPMplTransaction.IGPType.AllCases() {
            print(transactionType)
        }
    }
    
    private func setupVC() {
        
        self.transactionsTableView.register(IGTransactionsTVCell.nib, forCellReuseIdentifier: IGTransactionsTVCell.identifier)
        
        self.transactionTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        self.initNavigationBar(title: "FINANCIAL_TRANSACTIONS_HISTORY".localizedNew)
        
        // transform
        self.transactionTypesCollectionView.semanticContentAttribute = self.semantic
        self.transactionsTableView.semanticContentAttribute = self.semantic
        
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
                    self.transactions.append(contentsOf: response.igpTransaction)
                    print(self.transactions)
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
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionTypeCVCell", for: indexPath)
        let label = cell.viewWithTag(110) as! UILabel
        label.text = "شارژ موبایل"
//        cell.transform = self.transfotm
        cell.layer.cornerRadius = 12
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size: CGSize = "شارژ موبایل".size(withAttributes: [NSAttributedString.Key.font: UIFont.igFont(ofSize: 13)])
        return CGSize(width: size.width + 32.0, height: collectionView.bounds.size.height)
    }
}

extension IGFinancialHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: IGTransactionsTVCell.identifier, for: indexPath) as? IGTransactionsTVCell {
//            switch transactions[indexPath.row].igpType {
//            case .none:
//                <#code#>
//            case .bill:
//                cell.titleLbl.text = "".localizedNew
//                break
//            case .topup:
//                <#code#>
//            case .sales:
//                <#code#>
//            case .cardToCard:
//                <#code#>
//            case .UNRECOGNIZED(_):
//                <#code#>
//            @unknown default:
//                <#code#>
//            }
//            cell.titleLbl.text = transactions[indexPath.row].igpType
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
            
            self.getData(type: .none, offset: Int32(transactions.count), limit: 15)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
