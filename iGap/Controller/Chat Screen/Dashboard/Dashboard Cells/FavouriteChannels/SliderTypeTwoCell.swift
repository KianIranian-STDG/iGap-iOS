//
//  NamePictureCell.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 5/21/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import UIKit
var counter = 0

class SliderTypeTwoCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    var timer = Timer()
    var photoCount:Int = 0
    var collectionCounts : Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainView : UIView!
    @IBOutlet weak var collectionHolderView : UIView!
    @IBOutlet weak var btnMore : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    var channelsDataArray : [channels] = []
    var titleArray : [String] = []
    var imageArray : [UIImage] = []

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
        return titleArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell", for: indexPath as IndexPath) as! IGFavouriteChannelsDashboardCollectionViewCell


        cell.lbl.text = titleArray[indexPath.item]
        cell.imgBG.image = imageArray[indexPath.item]
//        tmpIMG.sd_setImage(with: channelsDataArray[inde], completed: nil)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: collectionViewWidth/4.0 , height: collectionViewWidth/4.0)
    }
    public func initView(){
        counter += 1
        mainView?.layer.cornerRadius = 10
        collectionHolderView?.layer.cornerRadius = 10
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        
        self.collectionView.backgroundColor = .clear
        self.getData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let t = counter
            let h = self.collectionCounts
            if counter <= self.collectionCounts {
                self.collectionView.reloadData()
                NotificationCenter.default.post(name: Notification.Name(SMConstants.refreshTableView), object: nil)
            }
        }
        ///
        
    }

    
    private func getData() {
        var tmptitleArray : [String] = []
        var tmpimageArray : [UIImage] = []
        if tmptitleArray.count > 0 {
            tmptitleArray.removeAll()
        }
        if tmpimageArray.count > 0 {
            tmpimageArray.removeAll()
        }
        for i in channelsDataArray {
        
    
            tmptitleArray.append(i.titleFa)
            let tmpImg = UIImageView()
            let url = URL(string: i.iconUrl)!
            tmpImg.sd_setImage(with: url as URL?, completed: nil)
            if tmpImg.image == nil {
                tmpimageArray.append((UIImage(named : "1")!))
            }
            else {
                tmpimageArray.append((tmpImg.image!))
            }
//                let data = try? Data(contentsOf: url)
//                if let imageData = data {
//                    let image = UIImage(data: imageData)
//                    self.imageArray.append((image!))
//                }
//            } else {
//            }
            imageArray = tmpimageArray
            
            titleArray = tmptitleArray
    
    }
}
}
