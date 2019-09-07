//
//  NamePictureCell.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 5/21/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import UIKit
var counter = 0
var CategoriesCounter = 0

class SliderTypeTwoCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var timer = Timer()
    var photoCount:Int = 0
    var collectionCounts : Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainView : UIView!
    @IBOutlet weak var collectionHolderView : UIView!
    @IBOutlet weak var btnMore : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
//    var channelsDataArray : [FavouriteChannelsCategoryChannel] = []
//    var titleArray : [String] = []
//    var imageArray : [UIImage] = []
    var channelItem: FavouriteChannelHomeItem!

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelItem.channels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let channel = channelItem.channels?[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell", for: indexPath as IndexPath) as! IGFavouriteChannelsDashboardCollectionViewCell
        cell.lbl.text = channel?.title
        let url = URL(string: channel?.icon ?? "")
        cell.imgBG.sd_setImage(with: url, completed: nil)
        
        // set corner radius
        let collectionViewWidth = collectionView.bounds.width
        let lblHeight = cell.lbl.bounds.height + 4
        let imageviewHeight = (collectionViewWidth/4.0 + 10) - lblHeight - 12
        cell.imgBG.layer.cornerRadius = imageviewHeight / 2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
//        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: (collectionViewWidth/4.0) + 5 , height: (collectionViewWidth/4.0) + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let channel = channelItem.channels?[indexPath.item]
        if channel?.type == .Public {
            IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: UIApplication.topViewController()!, username: channel!.slug)
        } else if channel?.type == .Private {
            IGHelperJoin.getInstance(viewController: UIApplication.topViewController()!).requestToCheckInvitedLink(invitedLink: channel!.slug)
        }
    }
    
    public func initView() {
        counter += 1
        mainView?.layer.cornerRadius = 10
        collectionHolderView?.layer.cornerRadius = 10
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        
        self.collectionView.backgroundColor = .clear
//        self.getData()

//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            if counter <= self.collectionCounts {
//                self.collectionView.reloadData()
//                NotificationCenter.default.post(name: Notification.Name(SMConstants.refreshTableView), object: nil)
//            }
//        }
        ///
        
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
//        for channel in channelsDataArray {
//
//            tmptitleArray.append(channel.title!)
//            let tmpImg = UIImageView()
//            let url = URL(string: channel.icon ?? "")!
//            tmpImg.sd_setImage(with: url as URL?, completed: nil)
//            if tmpImg.image == nil {
//                tmpimageArray.append((UIImage(named : "1")!))
//            }
//            else {
//                tmpimageArray.append((tmpImg.image!))
//            }
////                let data = try? Data(contentsOf: url)
////                if let imageData = data {
////                    let image = UIImage(data: imageData)
////                    self.imageArray.append((image!))
////                }
////            } else {
////            }
//            imageArray = tmpimageArray
//
//            titleArray = tmptitleArray
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//
//                self.collectionView.reloadData()
//            }
//        }
//    }
    
    ///btnMore Action Handler
    @IBAction func didTapOnBtnMore(_ sender: Any) {
        let dashboard = IGFavouriteChannelsDashboardInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        dashboard.categoryId = channelItem.id
        UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
        
    }
}
