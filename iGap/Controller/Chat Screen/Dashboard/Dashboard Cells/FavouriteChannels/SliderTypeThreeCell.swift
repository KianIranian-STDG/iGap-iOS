//
//  NamePictureCell.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 5/21/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import UIKit

class SliderTypeThreeCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var timer = Timer()
    var photoCount: Int = 0
//    var titleArray: [String] = []
//    var imageArray: [UIImage] = []
    
    var isInnenr: Bool = false
    // if is inner this variable will be set
    var channelsListObj: [FavouriteChannelCategoryInfoChannel]?
    // if is not inner this variable will be set
    var categoryItem: FavouriteChannelHomeItem!

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
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
        cell.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
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
            UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
        }
        
    }
    
    public func initView() {
        CategoriesCounter += 1
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        
        self.collectionView.backgroundColor = .clear
//        self.getData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            if CategoriesCounter <= 3 {
//                self.collectionView.reloadData()
//            }
//        }
    }
    
    public func initViewInner() {
        CategoriesCounter += 1
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        self.collectionView.backgroundColor = .clear
//        getDataInner()
    }
    
    
//    private func getData() {
//        var tmptitleArray : [String] = []
//        var tmpimageArray : [UIImage] = []
//        if tmptitleArray.count > 0 {
//            tmptitleArray.removeAll()
//        }
//        if tmpimageArray.count > 0 {
//            tmpimageArray.removeAll()
//        }
//        for category in categoryItem.categories ?? [] {
//
//            tmptitleArray.append(category.title!)
//            let tmpImg = UIImageView()
//            let url = URL(string: category.icon ?? "")
//            tmpImg.sd_setImage(with: url as URL?, completed: nil)
//            if tmpImg.image == nil {
//                tmpimageArray.append((UIImage(named : "1")!))
//            }
//            else {
//                tmpimageArray.append((tmpImg.image!))
//            }
//
//            imageArray = tmpimageArray
//
//            titleArray = tmptitleArray
//
//        }
//    }
    
//    private func getDataInner() {
//        var tmpimageArray : [UIImage] = []
//
//        if tmpimageArray.count > 0 {
//            tmpimageArray.removeAll()
//        }
//        if channelsListObj != nil {
//            for channel in channelsListObj! {
//
//                let tmpImg = UIImageView()
//                let url = URL(string: channel.icon ?? "")!
//                tmpImg.sd_setImage(with: url as URL?, completed: nil)
//                if tmpImg.image == nil {
//                    tmpimageArray.append((UIImage(named : "1")!))
//                }
//                else {
//                    tmpimageArray.append((tmpImg.image!))
//                }
//                imageArray = tmpimageArray
//                self.collectionView.reloadData()
//            }
//        }
//    }
}
