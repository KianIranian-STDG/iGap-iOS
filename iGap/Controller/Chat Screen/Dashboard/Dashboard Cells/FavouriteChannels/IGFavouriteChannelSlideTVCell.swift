//
//  IGFavouriteChannelSlideTVCell.swift
//  iGap
//
//  Created by hossein nazari on 9/1/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGFavouriteChannelSlideTVCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    var slidesCount = 0 {
        didSet {
            pageControl?.numberOfPages = slidesCount
        }
    }
    var slideImages: [String]?
    var scale: Float = 1
    var slideshowTimer: Timer?
    var slideshowInterval: TimeInterval = 0 {
        didSet {
            if slideshowInterval > 0 {
                self.restartTimer()
            }
        }
    }
    
    var primaryVisiblePage: Int {
        return collectionView.frame.size.width > 0 ? Int(collectionView.contentOffset.x + collectionView.frame.size.width / 2) / Int(collectionView.frame.size.width) : 0
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    class func nib() -> UINib {
        return UINib(nibName: "IGFavouriteChannelSlideTVCell", bundle: Bundle(for: self))
    }
    
    func registerCells() {
        collectionView.register(IGFavouriteChannelCVCell.nib(), forCellWithReuseIdentifier: "IGFavouriteChannelCVCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.isPagingEnabled = true
        let isEnglish = SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue
        self.collectionView.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        self.pageControl.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
    }
    
    @objc func slideshowTick(_ timer: Timer) {
        var page = collectionView.frame.size.width > 0 ? Int(collectionView.contentOffset.x / collectionView.frame.size.width) : 0

        if page == slidesCount {
            page = 0
            setScrollViewPage(page, animated: false)
        }
        
        setScrollViewPage(page + 1, animated: true)
    }
    
    open func setScrollViewPage(_ newScrollViewPage: Int, animated: Bool) {
        if newScrollViewPage <= slidesCount {
            collectionView.scrollRectToVisible(CGRect(x: collectionView.frame.size.width * CGFloat(newScrollViewPage), y: 0, width: collectionView.frame.size.width, height: collectionView.frame.size.height), animated: animated)
            pageControl.currentPage = newScrollViewPage == slidesCount ? 0 : newScrollViewPage
        }
    }
    
    func restartTimer() {
        self.pauseTimer()
        self.startTimer()
    }
    
    func pauseTimer() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }
    
    func startTimer() {
        slideshowTimer = Timer.scheduledTimer(timeInterval: slideshowInterval / 1000, target: self, selector: #selector(slideshowTick(_:)), userInfo: nil, repeats: true)
    }
}
extension IGFavouriteChannelSlideTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGFavouriteChannelCVCell", for: indexPath) as! IGFavouriteChannelCVCell
        var index = indexPath.row
        if index == 0 {
            index = slidesCount - 1
        } else {
            index -= 1
        }
        
        guard let slideImage = slideImages?[index], let imageUrl = URL(string: slideImage) else {return cell}
        cell.imageView.setImage(url: imageUrl)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return slidesCount + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension IGFavouriteChannelSlideTVCell: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let regularContentOffset = scrollView.frame.size.width * CGFloat(slidesCount)
        if scrollView.contentOffset.x > scrollView.frame.size.width * CGFloat(slidesCount) {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - regularContentOffset, y: 0)
        } else if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + regularContentOffset, y: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var page = 0
        if primaryVisiblePage == 0 {
            // first page contains the last image
            page = slidesCount - 1
        } else {
            page = primaryVisiblePage - 1
        }
        
        pageControl.currentPage = page
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pauseTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
    }
}

extension IGFavouriteChannelSlideTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = width / CGFloat(scale)
        return  CGSize(width: width, height: height)
    }
}
