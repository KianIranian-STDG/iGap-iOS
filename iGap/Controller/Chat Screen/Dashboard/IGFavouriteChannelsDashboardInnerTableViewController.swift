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
import SwiftyJSON

class IGFavouriteChannelsDashboardInnerTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var categoryId: String!
    
    var categoryInfo: FavouriteChannelCategoryInfo!
    var showSlider = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.register(SliderTypeOneCell.nib, forCellReuseIdentifier: SliderTypeOneCell.identifier)
        tableView?.register(SliderTypeThreeCell.nib, forCellReuseIdentifier: SliderTypeThreeCell.identifier)
        
        let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        tableView.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        
        getData(page: 1)
    }
    
    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: categoryInfo.info?.title)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - Table view data source

    func getData(page: Int) {
        
        IGApiFavouriteChannels.shared.getCategoryInfo(for: categoryId, start: 0 , display: 100) { (isSuccess, categoryInfo) in
            if isSuccess {
                self.categoryInfo = categoryInfo
                self.initNavigationBar()
                if categoryInfo?.info?.hasAd ?? false {
                    self.showSlider = true
                } else {
                    self.showSlider = false
                }
                self.tableView.reloadData()
            } else {
                return
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.categoryInfo != nil else { return 0 }
        if showSlider {
            return 2
        } else {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if showSlider {
            switch indexPath.row {
            case 0 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
                let advertisment = self.categoryInfo.info?.advertisement
                cell.slides = (advertisment?.slides)!
                cell.initView(scale: advertisment?.scale ?? "1:1", loopTime: (advertisment?.playbackTime ?? 2000))
                return cell
                
            case 1 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
                cell.isInnenr = true
                cell.channelsListObj = self.categoryInfo.channels
                cell.initViewInner()
                
                return cell
                
            default :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
                return cell
                
            }
        } else {
            
            switch indexPath.row {
            case 0 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
                cell.isInnenr = true
                cell.channelsListObj = self.categoryInfo.channels

                cell.initViewInner()

                return cell
                
            default :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
                cell.isInnenr = true
                cell.channelsListObj = self.categoryInfo.channels

                cell.initViewInner()

                return cell
                
            }
            
        }
    }
    
    
}
