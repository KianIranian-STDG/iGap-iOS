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
import Messages
import IGProtoBuff
import RealmSwift

@available(iOS 10.0, *)
class IGStickerCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    var imgSticker: UIImageView!
    var stickerItem: IGRealmStickerItem!
    var sectionIndex: Int!
    
    func configure(stickerItem: IGRealmStickerItem) {
        self.makeImage()
        self.mainView.backgroundColor = UIColor.clear
        self.imgSticker.backgroundColor = UIColor.clear
        
        self.stickerItem = stickerItem
        
        let onStickerClick = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnSticker(_:)))
        self.imgSticker.addGestureRecognizer(onStickerClick)
        self.imgSticker.isUserInteractionEnabled = true
        
        IGAttachmentManager.sharedManager.getFileInfo(token: stickerItem.token!, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let fileInfo = try! Realm().objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId!)).first {
                    self.imgSticker.setSticker(for: fileInfo)
                }
            }
        })
    }
    
    func configureListPage(stickerItem: Sticker, sectionIndex: Int) {
        self.makeImage()
        self.sectionIndex = sectionIndex
        self.mainView.backgroundColor = UIColor.clear
        self.imgSticker.backgroundColor = UIColor.clear
        
        let onStickerClick = UITapGestureRecognizer(target: self, action: #selector(self.openStickerPreview(_:)))
        self.imgSticker.addGestureRecognizer(onStickerClick)
        self.imgSticker.isUserInteractionEnabled = true
        
        IGAttachmentManager.sharedManager.getFileInfo(token: stickerItem.token, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let fileInfo = try! Realm().objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId!)).first {
                    self.imgSticker.setSticker(for: fileInfo)
                }
            }
        })
    }
    
    func configurePreview(stickerItem: Sticker) {
        self.makeImage()
        self.mainView.backgroundColor = UIColor.clear
        self.imgSticker.backgroundColor = UIColor.clear
        
        IGAttachmentManager.sharedManager.getFileInfo(token: stickerItem.token, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let fileInfo = try! Realm().objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId!)).first {
                    self.imgSticker.setSticker(for: fileInfo)
                }
            }
        })
    }
    
    /********************************/
    /*********** Callback ***********/
    func didTapOnSticker(_ gestureRecognizer: UITapGestureRecognizer) {
        IGStickerViewController.stickerTapListener.onStickerTap(stickerItem: self.stickerItem)
    }
    
    func openStickerPreview(_ gestureRecognizer: UITapGestureRecognizer) {
        IGStickerViewController.previewSectionIndex = self.sectionIndex
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGStickerViewController") as! IGStickerViewController
        messagesVc.stickerGroupId = ""
        messagesVc.stickerPageType = StickerPageType.PREVIEW
        UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
    }
    
    /********************************/
    /********** View Maker **********/
    private func makeImage(){
        if imgSticker != nil {
            imgSticker.removeFromSuperview()
            imgSticker = nil
        }
        imgSticker = UIImageView()
        imgSticker.contentMode = .scaleAspectFit
        mainView.addSubview(imgSticker)
        imgSticker.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.left.equalTo(mainView.snp.left)
            make.right.equalTo(mainView.snp.right)
            make.bottom.equalTo(mainView.snp.bottom)
        }
    }
}
