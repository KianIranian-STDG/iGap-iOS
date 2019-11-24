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
import messages
import IGProtoBuff
import RealmSwift

@available(iOS 10.0, *)
class IGStickerCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    var imgSticker: UIImageView!
    var stickerItemRealm: IGRealmStickerItem!
    var stickerItemStruct: Sticker!
    var sectionIndex: Int!
    
    func configure(stickerItem: IGRealmStickerItem) {
        self.makeImage()
        self.mainView.backgroundColor = UIColor.clear
        self.imgSticker.backgroundColor = UIColor.clear
        
        self.stickerItemRealm = stickerItem
        
        let onStickerClick = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnSticker(_:)))
        self.imgSticker.addGestureRecognizer(onStickerClick)
        self.imgSticker.isUserInteractionEnabled = true
        
        IGStickerViewController.stickerImageDic[stickerItem.token!] = self.imgSticker
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerItem.token!, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let stickerInfo = self.fetchStickerImage(cacheId: cacheId!){
                    stickerInfo.image.setSticker(for: stickerInfo.file)
                }
            }
        })
    }
    
    func configureListPage(stickerItem: Sticker, sectionIndex: Int) {
        self.makeImage()
        self.sectionIndex = sectionIndex
        self.stickerItemStruct = stickerItem
        self.mainView.backgroundColor = UIColor.clear
        self.imgSticker.backgroundColor = UIColor.clear
        
        let onStickerClick = UITapGestureRecognizer(target: self, action: #selector(self.openStickerPreview(_:)))
        self.imgSticker.addGestureRecognizer(onStickerClick)
        self.imgSticker.isUserInteractionEnabled = true
        
        IGStickerViewController.stickerImageDic[stickerItem.token] = self.imgSticker
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerItem.token, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let stickerInfo = self.fetchStickerImage(cacheId: cacheId!){
                    stickerInfo.image.setSticker(for: stickerInfo.file)
                }
            }
        })
    }
    
    func configurePreview(stickerItem: Sticker) {
        self.stickerItemStruct = stickerItem
        self.makeImage()
        self.mainView.backgroundColor = UIColor.clear
        self.imgSticker.backgroundColor = UIColor.clear
        
        IGStickerViewController.stickerImageDic[stickerItem.token] = self.imgSticker
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerItem.token, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let stickerInfo = self.fetchStickerImage(cacheId: cacheId!){
                    stickerInfo.image.setSticker(for: stickerInfo.file)
                }
            }
        })
    }
    
    /** Hint: Temporary solution
     * sometimes sicker toolbar & sticker cell have two same files with same cacheId BUT with different token.
     * now for show sticker in toolbar and sticker cell we check all files with this token in a loop.
     * However, this loop only has two items.
     */
    private func fetchStickerImage(cacheId: String) -> (file: IGFile, image: UIImageView)? {
        for file in IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId)) {
            if let image = IGStickerViewController.stickerImageDic[file.token!] {
                return (file, image)
            }
        }
        return nil
    }
    
    /********************************/
    /*********** Callback ***********/
    @objc func didTapOnSticker(_ gestureRecognizer: UITapGestureRecognizer) {
        IGStickerViewController.stickerTapListener.onStickerTap(stickerItem: self.stickerItemRealm)
    }
    
    @objc func openStickerPreview(_ gestureRecognizer: UITapGestureRecognizer) {
        IGStickerViewController.previewSectionIndex = self.sectionIndex
        let stickerViewController = IGStickerViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        stickerViewController.stickerGroupId = self.stickerItemStruct.groupID
        stickerViewController.stickerPageType = StickerPageType.PREVIEW
        stickerViewController.hidesBottomBarWhenPushed = true
        UIApplication.topNavigationController()!.pushViewController(stickerViewController, animated: true)
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
