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
import Alamofire
import MBProgressHUD

class IGFavouriteChannelsDashboardTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var items = [FavouriteChannelHomeItem]()
    var deepLinkToken: String?
    
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
                for item in items {
                    switch item.type {
                    case .ad:
                        for slide in item.slides ?? [] {
                            if slide.id == self.deepLinkToken {
                                SliderTypeOneCell.selectSlide(selectedSlide: slide)
                                break
                            }
                        }
                        break
                    case .normalCategory:
                        for category in item.categories ?? [] {
                            if category.id == self.deepLinkToken {
                                let dashboard = IGFavouriteChannelsDashboardInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                                dashboard.categoryId = category.id
                                dashboard.hidesBottomBarWhenPushed = true
                                UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                            }
                        }
                        
                    case .featuredCategory:
                        for channel in item.channels ?? [] {
                            if channel.id == self.deepLinkToken {
                                if channel.type == .Public {
                                    IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: UIApplication.topViewController()!, username: channel.slug)
                                } else if channel.type == .Private {
                                    IGHelperJoin.getInstance(viewController: UIApplication.topViewController()!).requestToCheckInvitedLink(invitedLink: channel.slug)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            self.tableView.setEmptyMessage("PLEASE_WAIT_DATA_LOAD".localizedNew)
            let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
            self.tableView.backgroundView?.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.tableView.restore()
        }
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        let item = items[indexPath.row]

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
