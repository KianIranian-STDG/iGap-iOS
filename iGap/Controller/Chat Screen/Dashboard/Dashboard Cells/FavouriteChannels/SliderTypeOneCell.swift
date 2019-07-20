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

struct channels {
    var titleEn: String
    var titleFa: String
    var id: String
    var iconUrl : String
}
struct categories {
    var titleEn: String
    var titleFa: String
    var id: String
    var iconUrl : String
}

class SliderTypeOneCell: UITableViewCell {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var timer = Timer()
    var photoCount:Int = 0
    var galleryScale : String = "8:5"
    var imageUrl : [String] = []
    @IBOutlet weak var btnPRV: UIButton?
    @IBOutlet weak var btnNXT: UIButton?
    @IBOutlet weak var pictureImageView: IGImageView?
    var images : [UIImage?] = []
    var tmpIIimages : [UIImage?] = []

    var channels: [channels] = []

    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func computeHeight(scale: String) -> CGFloat{
        let split = scale.split(separator: ":")
        let heightScale = NumberFormatter().number(from: split[1].description)
        let widthScale = NumberFormatter().number(from: split[0].description)
        let scale = CGFloat(truncating: heightScale!) / CGFloat(truncating: widthScale!)
        let height: CGFloat = IGGlobal.fetchUIScreen().width * scale
        return height
    }
    func btnConfig() {
        btnNXT?.roundCorners(corners: [.layerMinXMinYCorner,.layerMinXMaxYCorner], radius: 15.0)
        btnPRV?.roundCorners(corners: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner], radius: 15.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    public func initView(images: [UIImage] = [] , scale : String , loopTime : Int, imageUrlll : [String]){
        heightConstraint.constant = computeHeight(scale: galleryScale)
        
        pictureImageView?.layer.cornerRadius = 15
        pictureImageView?.clipsToBounds = true
        pictureImageView?.contentMode = .scaleAspectFill
        pictureImageView?.backgroundColor = UIColor.lightGray
        
        sliderImages(imageUrlll : imageUrlll,loopTime: loopTime)
        btnConfig()

    }
    func sliderImages(imageUrlll : [String],loopTime: Int) {

        var tmpImages : [UIImage?] = []
        if tmpImages.count > 0 {
            tmpImages.removeAll()
        }

        
        for item in imageUrlll {
            let tmpImg = UIImageView()
            let url = NSURL(string: item)!
//            print(url as URL)
            tmpImg.sd_setImage(with: url as URL?, completed: nil)
            if tmpImg.image == nil {
                tmpImages.append((UIImage(named: "1")))
            } else {
                tmpImages.append((tmpImg.image))
            }
        }
        

        
//        print(tmpImages)
        self.images = tmpImages
        scheduledTimerWithTimeInterval(loopTime: loopTime)

//        self.pictureImageView!.image = UIImage(named : "1")

    }
    
    
    func scheduledTimerWithTimeInterval(loopTime : Int = 5){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        if !(timer.isValid) {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(loopTime), target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateCounting(){
        onTransition()
    }
    func onTransition() {
        if (photoCount < images.count - 1){
            photoCount = photoCount  + 1
        } else{
            photoCount = 0
        }
//        print("-=-=-=-==-=-=-=-")
        UIView.transition(with: pictureImageView!, duration: 2.0, options: .transitionCrossDissolve, animations: {
            self.pictureImageView!.image = self.images[self.photoCount]
        }, completion: nil)
    }

    @IBAction func btnPRVtaped(_ sender: Any) {
//        print(images.count)
        if SMLangUtil.loadLanguage() == "fa" {

            if (photoCount < images.count - 1){
                photoCount = photoCount + 1
            } else{
                photoCount = 0
            }
        } else {

            if (photoCount == 0){
                photoCount = 0
            } else{
                photoCount = photoCount - 1
            }
        }
        
        UIView.transition(with: pictureImageView!, duration: 2.0, options: .transitionCrossDissolve, animations: {
            self.pictureImageView!.image = self.images[self.photoCount]
        }, completion: nil)

    }
    @IBAction func btnNXTtaped(_ sender: Any) {

        
        if SMLangUtil.loadLanguage() == "fa" {

            if (photoCount == 0){
                photoCount = 0
            } else{
                photoCount = photoCount - 1
            }
        } else {

            if (photoCount < images.count - 1){
                photoCount = photoCount + 1
            } else{
                photoCount = 0
            }
        }
        
        UIView.transition(with: pictureImageView!, duration: 2.0, options: .transitionCrossDissolve, animations: {
            self.pictureImageView!.image = self.images[self.photoCount]
        }, completion: nil)
    }
}
