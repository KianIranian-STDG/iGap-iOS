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

class IGGiftCardsListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var giftCardType: GiftStickerListType = .new
    var giftCardList: [IGStructGiftCardListData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        initNavigationBar()
        manageShowActivties(isFirst: true)
        fetchGiftCards()
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(title: IGStringsManager.GiftCardReport.rawValue.localized, width: 200)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func manageShowActivties(isFirst: Bool = false){
        if isFirst {
            self.tableView!.setEmptyMessage(IGStringsManager.WaitDataFetch.rawValue.localized)
        } else if giftCardList.count == 0 {
            self.tableView!.setEmptyMessage(IGStringsManager.GlobalNoHistory.rawValue.localized)
        } else {
            self.tableView!.restore()
        }
    }
    
    private func fetchGiftCards(){
        IGApiSticker.shared.giftStickerCardsList(status: giftCardType) { [weak self] giftCardList in
            for giftCard in giftCardList.data {
                self?.giftCardList.append(giftCard)
            }
            self?.manageShowActivties()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return giftCardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GiftCardListCell", for: indexPath) as! IGGiftCardListCell
        cell.setInfo(giftCard: giftCardList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
 }
