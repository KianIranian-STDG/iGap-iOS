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

class IGStickerToolbar: UIGestureRecognizer {
    
    static let shared = IGStickerToolbar()
    
    let sectionItemsKey = "Items"
    var data = [Dictionary<String,AnyObject>]()
    static var buttonArray: [UIButton] = []
    var leftSpace = 0
    let TOOLBAR_HEIGHT = 45
    let BUTTON_SPACE = 10
    let BUTTON_SIZE = 30
    
    public func toolbarMaker() -> UIView{
        if let path = Bundle.main.path(forResource: "FoodDrawerData", ofType: ".plist") {
            let dict = NSDictionary(contentsOfFile: path) as! Dictionary<String,AnyObject>
            let allSections = dict["Sections"] as? [[String:AnyObject]]
            for index in allSections! {
                self.data.append((index))
            }
            
           return doctorBotView()
        }
        return UIView()
    }
    
    private func doctorBotView() -> UIView{
        
        let scrollView = UIScrollView()
        let child = UIView()
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.stickerToolbar()
        scrollView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: TOOLBAR_HEIGHT)
        
        scrollView.addSubview(child)
        leftSpace = BUTTON_SPACE
        
        for (index, result) in self.data.enumerated() {
            let sectionItems = result[sectionItemsKey] as? [String]
            let imageName = sectionItems![0]
            makeDoctorBotButtonView(parent: scrollView, imageName: imageName, index: index)
        }
        
        child.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top)
            make.left.equalTo(scrollView.snp.left)
            make.right.equalTo(scrollView.snp.right)
            make.bottom.equalTo(scrollView.snp.bottom)
            make.width.equalTo(leftSpace)
        }
        
        return scrollView
    }
    
    private func makeDoctorBotButtonView(parent: UIScrollView, imageName: String, index: Int){

        let image = UIImage(named: imageName)
        
        let imageView = UIImageView()
        imageView.image = image
        
        let btn = UIButton()
        IGStickerToolbar.buttonArray.append(btn)
        btn.tag = index
        btn.addTarget(self, action: #selector(IGMessageViewController.tapOnStickerToolbar), for: .touchUpInside)
        btn.backgroundColor = UIColor.clear
        btn.layer.cornerRadius = 5

        parent.addSubview(btn)
        parent.addSubview(imageView)
        
        btn.snp.makeConstraints { (make) in
            make.left.equalTo(parent.snp.left).offset(leftSpace)
            make.centerY.equalTo(parent.snp.centerY)
            make.width.equalTo(BUTTON_SIZE+5)
            make.height.equalTo(BUTTON_SIZE+5)
        }
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(parent.snp.left).offset(leftSpace)
            make.centerY.equalTo(parent.snp.centerY)
            make.width.equalTo(BUTTON_SIZE)
            make.height.equalTo(BUTTON_SIZE)
        }
        
        leftSpace += BUTTON_SPACE + BUTTON_SIZE
    }
}
