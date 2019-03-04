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
import RealmSwift
import IGProtoBuff

class IGStickerToolbar: UIGestureRecognizer {
    
    static let shared = IGStickerToolbar()
    
    let sectionItemsKey = "Items"
    static var buttonArray: [UIButton] = []
    var stickerTabs: Results<IGRealmSticker>!
    var leftSpace: Double = 0
    let TOOLBAR_HEIGHT: Double = 45
    let ICON_SPACE: Double = 10
    let ICON_SIZE: Double = 30
    let ICON_BACKGROUDN_SIZE: Double = 38
    let STICKER_ADD = 1000000
    let STICKER_SETTING = 2000000
    
    public func toolbarMaker() -> UIView{
        fetchStickerInfo()
        return doctorBotView()
    }
    
    private func fetchStickerInfo(){
        stickerTabs = try! Realm().objects(IGRealmSticker.self)
    }
    
    private func doctorBotView() -> UIView{
        
        let scrollView = UIScrollView()
        let child = UIView()
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.stickerToolbar()
        scrollView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int(TOOLBAR_HEIGHT))
        
        scrollView.addSubview(child)
        leftSpace = ICON_SPACE
        
        for (index, realmSticker) in self.stickerTabs.enumerated() {
            makeTabIcon(parent: scrollView, index: index, realmSticker: realmSticker)
        }
        makeTabIcon(parent: scrollView, index: STICKER_ADD, imageName: "")
        //makeTabIcon(parent: scrollView, index: STICKER_SETTING, imageName: "")
        
        child.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top)
            make.left.equalTo(scrollView.snp.left)
            make.right.equalTo(scrollView.snp.right)
            make.bottom.equalTo(scrollView.snp.bottom)
            make.width.equalTo(leftSpace)
        }
        
        return scrollView
    }
    
    private func makeTabIcon(parent: UIScrollView, index: Int, realmSticker: IGRealmSticker? = nil, imageName: String? = nil){

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        let btn = UIButton()
        IGStickerToolbar.buttonArray.append(btn)
        btn.tag = index
        btn.addTarget(self, action: #selector(IGMessageViewController.tapOnStickerToolbar), for: .touchUpInside)
        btn.backgroundColor = UIColor.clear
        btn.layer.cornerRadius = 5
        
        parent.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.left.equalTo(parent.snp.left).offset(leftSpace - ((ICON_BACKGROUDN_SIZE-ICON_SIZE)/2))
            make.centerY.equalTo(parent.snp.centerY)
            make.width.equalTo(ICON_BACKGROUDN_SIZE)
            make.height.equalTo(ICON_BACKGROUDN_SIZE)
        }
        
        if imageName != nil {
            btn.setTitle(imageName, for: UIControlState.normal)
            btn.titleLabel?.font = UIFont.iGapFontico(ofSize: 20)
            btn.setTitleColor(UIColor.messageText(), for: .normal)
            btn.removeUnderline()
        } else {
            
            IGAttachmentManager.sharedManager.getStickerFileInfo(token: (realmSticker?.avatarToken)!, completion: { (file) -> Void in
                let cacheId = file.cacheID
                DispatchQueue.main.async {
                    if let fileInfo = try! Realm().objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId!)).first {
                        imageView.setSticker(for: fileInfo)
                    }
                }
            })
            
            parent.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.left.equalTo(parent.snp.left).offset(leftSpace)
                make.centerY.equalTo(parent.snp.centerY)
                make.width.equalTo(ICON_SIZE)
                make.height.equalTo(ICON_SIZE)
            }
        }
        
        leftSpace += ICON_SPACE + ICON_SIZE
    }
}
