//
//  IGFavouriteChannelsDashboardTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/15/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class IGFavouriteChannelsDashboardTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var items = [FavouriteChannelHomeItem]()
    
    let slideTVCellReuseIdentifier = "IGFavouriteChannelSlideTVCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.register(IGFavouriteChannelSlideTVCell.nib(), forCellReuseIdentifier: slideTVCellReuseIdentifier)
        tableView?.register(SliderTypeOneCell.nib, forCellReuseIdentifier: SliderTypeOneCell.identifier)
        tableView?.register(SliderTypeTwoCell.nib, forCellReuseIdentifier: SliderTypeTwoCell.identifier)
        tableView?.register(SliderTypeThreeCell.nib, forCellReuseIdentifier: SliderTypeThreeCell.identifier)
        
        let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        tableView.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        
        getData()
        
        initNavigationBar()
    }
    
    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_ACCOUNT_INTERESTING_CHANNELS".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    func getData() {
        
        IGApiFavouriteChannels.shared.homeItems { (isSuccess, items) in
            if isSuccess {
                self.items = items
                self.tableView.reloadWithAnimation()
            }
        }
        
//        guard let data = IGGlobal.dataFromFile("ServerData") else {
//            return
//        }
        
//        debugPrint("=========Request Url=========")
//        debugPrint("https://api.igap.net/services/v1.0/channel")
//        debugPrint("=========Request Headers=========")
//        debugPrint(getHeaders())
//
//        Alamofire.request("https://api.igap.net/services/v1.0/channel", method: .get, headers: getHeaders()).responseJSON { response in
//
//            debugPrint("=========Response Headers=========")
//            debugPrint(response.response ?? "no headers")
//            debugPrint("=========Response Body=========")
//            debugPrint(response.result.value ?? "NO RESPONSE BODY")
//
//            switch response.result {
//            case .success(let value):
        
//                let json = JSON(value)
//
//                print(json["data"].arrayValue)
//            }
//
//        }
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        let item = items[indexPath.row]
        print(IGGlobal.getTime("Hossein_0"))
        switch item.type {
        case .ad:
            
            let adCell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
            
            adCell.slides = (item.slides)!
            adCell.initView(scale: item.info?.scale ?? "8:5", loopTime: item.info?.playbackTime ?? 1000)
            
            cell = adCell

        case .featuredCategory:
            let featuredCategoryCell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeTwoCell", for: indexPath as IndexPath) as! SliderTypeTwoCell

            featuredCategoryCell.lblTitle.text = item.info?.title
//            cell.collectionCounts = self.items.filter({$0.type == .featuredCategory}).count
            featuredCategoryCell.channelItem = item

            featuredCategoryCell.initView()
            
            cell = featuredCategoryCell

        case .normalCategory:
            let normalCategoryCell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
            
            normalCategoryCell.isInnenr = false
            normalCategoryCell.categoryItem = item
            normalCategoryCell.initView()
            
            cell = normalCategoryCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = items[indexPath.row]
        
        switch item.type {
        case .ad:
            return UITableView.automaticDimension
            
        case .featuredCategory:
            return UITableView.automaticDimension
            
        case .normalCategory:
            let numberOfRows = ceilf(Float(item.categories?.count ?? 0) / 4)
            return ((tableView.bounds.width/4.5) + 30) * CGFloat(numberOfRows)
        }
    }

}
