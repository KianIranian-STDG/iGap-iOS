//
//  NamePictureCell.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 5/21/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import UIKit


class SliderTypeThreeCell: UITableViewCell,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var timer = Timer()
    var photoCount:Int = 0
    @IBOutlet weak var collectionView: UICollectionView!
    var categoriesDataArray : [categories] = []
    var titleArray : [String] = []
    var imageArray : [UIImage] = []
    var channelsList: [channels] = []
    var isInnenr : Bool = false

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
            return channelsList.count
        } else {
            return categoriesDataArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell", for: indexPath as IndexPath) as! IGFavouriteChannelsDashboardCollectionViewCell
        if isInnenr {
            cell.lbl.text = channelsList[indexPath.item].titleFa
        } else {
            cell.lbl.text = titleArray[indexPath.item]
        }
        cell.imgBG.image = imageArray[indexPath.item]
        cell.backgroundColor = .lightGray

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: collectionViewWidth/4.5 , height: collectionViewWidth/4.5)
    }
    
    public func initView() {
        
        CategoriesCounter += 1
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        
        
        self.collectionView.backgroundColor = .clear
        self.getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let t = CategoriesCounter
            if CategoriesCounter <= 3 {
                self.collectionView.reloadData()
            }
        }
        ///
        
    }
    
    public func initViewInner(){
        CategoriesCounter += 1
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        self.collectionView.backgroundColor = .clear
        getDataInner()
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
        for i in categoriesDataArray {
            
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
    
    private func getDataInner() {
        var tmpimageArray : [UIImage] = []

        if tmpimageArray.count > 0 {
            tmpimageArray.removeAll()
        }
        for i in channelsList {
            
            
            let tmpImg = UIImageView()
            let url = URL(string: i.iconUrl)!
            tmpImg.sd_setImage(with: url as URL?, completed: nil)
            if tmpImg.image == nil {
                tmpimageArray.append((UIImage(named : "1")!))
            }
            else {
                tmpimageArray.append((tmpImg.image!))
            }
            imageArray = tmpimageArray
            self.collectionView.reloadData()
        }
    }
}
