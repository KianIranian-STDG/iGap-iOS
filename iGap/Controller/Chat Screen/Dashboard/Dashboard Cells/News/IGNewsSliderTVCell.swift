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
import SnapKit
import SDWebImage

class IGNewsSliderTVCell: UITableViewCell {

    @IBOutlet weak var heightConstraintValue: NSLayoutConstraint!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var backPageView: UIView!
    
    var slides: [newsInner]!
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
        
        sliderCollectionView.register(SliderImageWithTextCVCell.nib, forCellWithReuseIdentifier: SliderImageWithTextCVCell.identifier)
        
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        
        sliderCollectionView.layer.cornerRadius = 5
        
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
        heightConstraintValue.constant = computeHeight(scale: scale)
        
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
    
    public static func selectSlide(selectedSlide: newsInner) {
        let articleID = selectedSlide.contents?.id
        gotToNewsPage(articleID: articleID!)
    }
    
}
private func gotToNewsPage(articleID: String) {
    SMLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
     IGApiNews.shared.getNewsDetail(articleId: articleID) { (isSuccess, response) in
         SMLoading.hideLoadingPage()
         if isSuccess {
             let newsDetail = IGNewsDetailTableViewController.instantiateFromAppStroryboard(appStoryboard: .News)
             newsDetail.item = response!
             UIApplication.topViewController()!.navigationController!.pushViewController(newsDetail, animated: true)

         } else {
             return
         }
     }
 }

extension IGNewsSliderTVCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderImageWithTextCVCell", for: indexPath) as! SliderImageWithTextCVCell
        let slide = slides[indexPath.item]
        let url = URL(string: (slide.contents?.image![0].Original)!)
        cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named :"1"), completed: nil)
        cell.backgroundColor = UIColor.hexStringToUIColor(hex: slide.color!)
        cell.lblTitle.textColor = UIColor.hexStringToUIColor(hex: slide.colorTitr!)
//        cell.lblAlias.textColor = UIColor.black
        cell.lblTitle.text = slide.contents?.titr
//        cell.lblAlias.text = slide.contents?.lead
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedSlide = self.slides?[indexPath.item] else { return }
        IGNewsSliderTVCell.selectSlide(selectedSlide: selectedSlide)
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageView.currentPage = indexPath.item
    }
    */
    
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

extension IGNewsSliderTVCell: UICollectionViewDelegateFlowLayout {
    
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

