//
//  NamePictureCell.swift
//  TableViewWithMultipleCellTypes
//
//  Created by Stanislav Ostrovskiy on 5/21/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class SliderTypeOneCell: UITableViewCell {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var backPageView: UIView!
    
    var slides: [FavouriteChannelsAddSlide]!
    var playbackTime : Int = 2000
    var dispatchGroup: DispatchGroup!
    
    var timer: Timer!
    var counter = 0
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sliderCollectionView.register(slideImageCVCell.nib, forCellWithReuseIdentifier: slideImageCVCell.identifier)
        
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        
        sliderCollectionView.layer.cornerRadius = 14
        
        backPageView.layer.cornerRadius = 8
    }
    
    private func computeHeight(scale: String) -> CGFloat {
        let split = scale.split(separator: ":")
        let heightScale = NumberFormatter().number(from: split[1].description)
        let widthScale = NumberFormatter().number(from: split[0].description)
        let scale = CGFloat(truncating: heightScale!) / CGFloat(truncating: widthScale!)
        let height: CGFloat = IGGlobal.fetchUIScreen().width * scale
        return height
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        slides.removeAll()
    }
    
    public func initView(scale: String, loopTime: Int) {
        heightConstraint.constant = computeHeight(scale: scale)
        
        pageView.numberOfPages = slides.count
        pageView.currentPage = 0
        
        pageView.hidesForSinglePage = true
        backPageView.isHidden = pageView.isHidden
        
        self.playbackTime = loopTime
        
        DispatchQueue.main.async {
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(loopTime / 1000), target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
            }
        }
        
        sliderCollectionView.reloadData()
    }
    
    @objc func changeImage() {
        if counter < slides.count {
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter
            counter += 1
            
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter
            counter = 1
        }
    }
    
}

extension SliderTypeOneCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slideImageCVCell", for: indexPath) as! slideImageCVCell
        let slide = slides[indexPath.item]
        let url = URL(string: slide.imageURL!)
        cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named :"1"), completed: nil)
        let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        cell.imageView.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let pageIndex = scrollView.auk.currentPageIndex else { return }
        guard let selectedSlide = self.slides?[indexPath.item] else { return }
        switch selectedSlide.actionType {
        case 3:
            IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: UIApplication.topViewController()!, username: selectedSlide.actionLink)
            break
            
        case 4:
            // check if user has choosen in app browser then open browser in app else open safari
            if IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyInAppBrowser) {
                for ignoreLink in IGHelperOpenLink.ignoreLinks {
                    if selectedSlide.actionLink.contains(ignoreLink) {
                        UIApplication.shared.open(URL(string: selectedSlide.actionLink)!, options: [:], completionHandler: nil)
                        return
                    }
                }
                UIApplication.topViewController()!.navigationController?.pushViewController(SwiftWebVC(urlString: selectedSlide.actionLink), animated: true)
            } else {
                UIApplication.shared.open(URL(string: selectedSlide.actionLink)!, options: [:], completionHandler: nil)
            }
            break
            
        case 5:
            // open url in app without showing it to user
            let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)
            iGapBrowser.url = selectedSlide.actionLink
            iGapBrowser.htmlString = nil
            UIApplication.topViewController()!.navigationController?.pushViewController(iGapBrowser, animated: true)
            break
            
        case 12:
            let dashboard = IGFavouriteChannelsDashboardInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            dashboard.categoryId = selectedSlide.actionLink
            UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated: true)
            break
            
        default:
            break
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        self.pageView.currentPage = indexPath.item
//    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer.invalidate()
        timer = nil
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(playbackTime / 1000), target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        pageView.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        counter = pageView.currentPage
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageView.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        counter = pageView.currentPage
    }
}

extension SliderTypeOneCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

