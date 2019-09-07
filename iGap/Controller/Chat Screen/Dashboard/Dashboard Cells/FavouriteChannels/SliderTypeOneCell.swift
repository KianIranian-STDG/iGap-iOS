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

class SliderTypeOneCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var btnPRV: UIButton!
//    @IBOutlet weak var btnNXT: UIButton!
//    @IBOutlet weak var pictureImageView: IGImageView!
    
    var photoCount: Int = 0
    var playbackTime : Int = 2000
//    var images : [UIImage?] = []
    var dispatchGroup: DispatchGroup!
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.delegate = self
        scrollView.layer.cornerRadius = 14
        
        scrollView.auk.settings.contentMode = .scaleAspectFill
        scrollView.auk.settings.placeholderImage = UIImage(named: "1")
        scrollView.auk.settings.preloadRemoteImagesAround = 1
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
    }
    
    public func initView(images: [UIImage] = [] ,scale : String , loopTime : Int, imageUrl : [String]){
        heightConstraint.constant = computeHeight(scale: scale)
        
        if scrollView.auk.images.count == 0 {
            for url in imageUrl {
                scrollView.auk.show(url: url)
            }
            self.playbackTime = loopTime
            scrollView.auk.startAutoScroll(delaySeconds: Double(loopTime / 1000))
        }
    }
    public func initViewInner(scale : String , loopTime : Int, slides : [FavouriteChannelsAddSlide]){
        heightConstraint.constant = computeHeight(scale: scale)
        
        heightConstraint.constant = computeHeight(scale: scale)
        
        if scrollView.auk.images.count == 0 {
            for url in slides.map({ $0.imageURL }) as! [String] {
                scrollView.auk.show(url: url)
            }
            self.playbackTime = loopTime
            scrollView.auk.startAutoScroll(delaySeconds: Double(loopTime / 1000))
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.auk.startAutoScroll(delaySeconds: Double(playbackTime / 1000))
    }
    
//    func sliderImages(imageUrl: [String], loopTime: Int) {
//
//        var tmpImages : [UIImage?] = []
//        if tmpImages.count > 0 {
//            tmpImages.removeAll()
//        }
//
//        dispatchGroup = DispatchGroup()
//
//        for item in imageUrl {
//            let tmpImg = UIImageView()
//            let url = URL(string: item)!
//            dispatchGroup.enter()
//            tmpImg.sd_setImage(with: url) { (image, error, cacheType, url) in
//                if tmpImg.image == nil {
//                    tmpImages.append((UIImage(named: "1")))
//                } else {
//                    tmpImages.append((tmpImg.image))
//                }
//                self.dispatchGroup.leave()
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            self.images = tmpImages
//            self.scheduledTimerWithTimeInterval(loopTime: loopTime / 1000)
//        }
//    }
    
//    func scheduledTimerWithTimeInterval(loopTime : Int = 5){
//        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
//        if !(timer.isValid) {
//            self.updateCounting()
//            timer = Timer.scheduledTimer(timeInterval: TimeInterval(loopTime), target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
//        }
//    }
//
//    @objc func updateCounting(){
//        onTransition()
//    }
    
//    func onTransition() {
//        if (photoCount < images.count - 1){
//            photoCount = photoCount  + 1
//        } else{
//            photoCount = 0
//        }
////        print("-=-=-=-==-=-=-=-")
//        UIView.transition(with: pictureImageView!, duration: 1.0, options: .transitionCrossDissolve, animations: {
//            self.pictureImageView!.image = self.images[self.photoCount]
//        }, completion: nil)
//    }

//    @IBAction func btnPRVtaped(_ sender: Any) {
////        print(images.count)
//        if SMLangUtil.loadLanguage() == "fa" {
//
//            if (photoCount < images.count - 1) {
//                photoCount = photoCount + 1
//            } else{
//                photoCount = 0
//            }
//        } else {
//
//            if (photoCount == 0){
//                photoCount = 0
//            } else{
//                photoCount = photoCount - 1
//            }
//        }
//
//        UIView.transition(with: pictureImageView!, duration: 2.0, options: .transitionCrossDissolve, animations: {
//            self.pictureImageView!.image = self.images[self.photoCount]
//        }, completion: nil)
//
//    }
//    @IBAction func btnNXTtaped(_ sender: Any) {
//
//
//        if SMLangUtil.loadLanguage() == "fa" {
//
//            if (photoCount == 0){
//                photoCount = 0
//            } else{
//                photoCount = photoCount - 1
//            }
//        } else {
//
//            if (photoCount < images.count - 1){
//                photoCount = photoCount + 1
//            } else{
//                photoCount = 0
//            }
//        }
//
//        UIView.transition(with: pictureImageView!, duration: 2.0, options: .transitionCrossDissolve, animations: {
//            self.pictureImageView!.image = self.images[self.photoCount]
//        }, completion: nil)
//    }
}
