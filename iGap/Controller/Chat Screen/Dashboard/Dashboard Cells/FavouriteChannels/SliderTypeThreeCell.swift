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

class SliderTypeThreeCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var timer = Timer()
    var photoCount: Int = 0
    
    var isInnenr: Bool = false
    var channelsListObj: [FavouriteChannelCategoryInfoChannel]? // if is inner this variable will be set
    var categoryItem: FavouriteChannelHomeItem! // if is not inner this variable will be set

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initTheme()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    private func initTheme() {
        self.collectionView.backgroundColor = .clear
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInnenr {
            return channelsListObj?.count ?? 0
        } else {
            return categoryItem.categories?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell", for: indexPath as IndexPath) as! IGFavouriteChannelsDashboardCollectionViewCell
        if isInnenr {
            guard let channel = self.channelsListObj?[indexPath.item] else { return cell }
            cell.lbl.text = channel.title
            let url = URL(string: channel.icon ?? "")
            cell.imgBG.sd_setImage(with: url, completed: nil)
            
            let collectionViewWidth = collectionView.bounds.width
            let lblHeight = cell.lbl.bounds.height + 4
            let imageviewHeight = ((collectionViewWidth/4.5) + 10) - lblHeight - 12
            cell.imgBG.layer.cornerRadius = imageviewHeight / 2

        } else {
            guard let category = categoryItem.categories?[indexPath.item] else { return cell }
            cell.lbl.text = category.title
            let url = URL(string: category.icon ?? "")
            cell.imgBG.sd_setImage(with: url, completed: nil)
        }
        
//        cell.contentView.backgroundColor = ThemeManager.currentTheme.BackGroundGrayColor
        
        let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        cell.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
//        let collectionViewHeight = collectionView.bounds.height
        if isInnenr {
            return CGSize(width: (collectionViewWidth/4.5) + 5 , height: (collectionViewWidth/4.5) + 10)
        } else {
            return CGSize(width: (collectionViewWidth/4.5) + 5 , height: (collectionViewWidth/4.5) + 15)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isInnenr {
            guard let channel = channelsListObj?[indexPath.item] else { print("Error, Channel not found"); return }
            if channel.type == .Public {
                IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: UIApplication.topViewController()!, username: channel.slug!)
            } else if channel.type == .Private {
                IGHelperJoin.getInstance(viewController: UIApplication.topViewController()!).requestToCheckInvitedLink(invitedLink: channel.slug!)
            }
            
        } else {
            let dashboard = IGFavouriteChannelsDashboardInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            dashboard.categoryId = categoryItem.categories?[indexPath.item].id
            dashboard.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
        }
    }
    
    public func initView() {
        CategoriesCounter += 1
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        
        self.collectionView.backgroundColor = .clear
    }
    
    public func initViewInner() {
        CategoriesCounter += 1
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        self.collectionView.backgroundColor = .clear
    }
}
