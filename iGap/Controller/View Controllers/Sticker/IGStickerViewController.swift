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

private let reuseIdentifier = "StickerCell"

@available(iOS 10.0, *)
class IGStickerViewController: UICollectionViewController {

    let numberOfItemsPerRow = 3.0 as CGFloat
    let interItemSpacing = 1.0 as CGFloat
    let interRowSpacing = 1.0 as CGFloat
    let sectionTitleKey = "SectionTitle"
    let sectionItemsKey = "Items"
    var data = [Dictionary<String,AnyObject>]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        if let path = Bundle.main.path(forResource: "FoodDrawerData", ofType: ".plist") {
            let dict = NSDictionary(contentsOfFile: path) as! Dictionary<String,AnyObject>
            print("DDD || dic: \(dict)")
            let allSections = dict["Sections"] as? [[String:AnyObject]]
            for index in allSections! {
                self.data.append((index))
            }
            
//            if let selectedSections = UserDefaults.standard.array(forKey: "selectedSections") as? [Int] {
//                for index in selectedSections {
//                    self.data.append((allSections![index]))
//                }
//            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (data[section][sectionItemsKey] as! NSArray).count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Configure the cell
        guard let stickerItem = cell as? IGStickerCell else {
            return
        }
        let sectionItems = self.data[indexPath.section][sectionItemsKey] as? [String]
        let imageName = sectionItems![indexPath.row]
        stickerItem.configure(usingImageName: imageName)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:String(describing: IGStickerSectionHeader.self), for: indexPath)
        
        if let foodHeader = headerView as? IGStickerSectionHeader {
            let section = self.data[indexPath.section]
            let sectionTitle = section[sectionTitleKey] as! String
            foodHeader.configure(usingTitle: sectionTitle)
        }
        return headerView
        
    }
}

@available(iOS 10.0, *)
extension IGStickerViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = (numberOfItemsPerRow - 1.0)  * interItemSpacing
        let width = (view.frame.size.width - padding) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interRowSpacing
    }
}
