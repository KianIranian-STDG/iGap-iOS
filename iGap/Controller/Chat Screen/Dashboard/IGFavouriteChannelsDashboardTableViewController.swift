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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshOnCall(_:)), name: (NSNotification.Name(rawValue: SMConstants.refreshTableView)), object: nil)
//
//    }
    
//    @objc func refreshOnCall(_ nofication: Notification)  {
//        self.tableView.reloadData()
//    }

    private func getHeaders() -> HTTPHeaders {
        let authorization = "Bearer " + IGAppManager.sharedManager.getAccessToken()!
        let headers: HTTPHeaders = ["Authorization": authorization]
        return headers
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
        
        let item = items[indexPath.row]
        
        switch item.type {
        case .ad:
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: slideTVCellReuseIdentifier, for: indexPath) as! IGFavouriteChannelSlideTVCell
//            cell.collectionView.tag = indexPath.section
//            cell.slideImages = galleryImageUrlArray[indexPath.row]
//            cell.slidesCount = galleryImageUrlArray[indexPath.row].count
//            cell.scale = galleryScaleArrayFloat[indexPath.section]
//            cell.slideshowInterval = TimeInterval(galleryLoopTimeArray[indexPath.section])
//            cell.registerCells()
//            return cell
            
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
//            cell.galleryScale = item.info?.scale ?? "8:5"
//
//            if item.slides?.count ?? 0 <= 1 {
//                cell.btnNXT.isHidden = true
//                cell.btnPRV.isHidden = true
//            } else {
//                cell.btnNXT.isHidden = false
//                cell.btnPRV.isHidden = false
//            }

            cell.initView(scale: item.info?.scale ?? "8:5", loopTime: item.info?.playbackTime ?? 1000, imageUrl: item.slides?.map({ $0.imageURL }) as! [String])

            return cell

        case .featuredCategory:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeTwoCell", for: indexPath as IndexPath) as! SliderTypeTwoCell
//            cell.textLabel!.text = "\(sectionArrays[indexPath.section])"

            cell.lblTitle.text = item.info?.title
            cell.collectionCounts = self.items.filter({$0.type == .featuredCategory}).count
            cell.channelItem = item

            cell.initView()

            return cell

        case .normalCategory:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
            cell.isInnenr = false
            cell.categoryItem = item
            cell.initView()

            return cell
        }
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
            return ((tableView.bounds.width/4.5) + 20) * CGFloat(numberOfRows)
        }
    }

}


