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
import Lottie

@available(iOS 10.0, *)
class IGStickerCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    var animationView : AnimationView!

    var imgSticker: UIImageView!
    var stickerItemRealm: IGRealmStickerItem!
    var stickerItemStruct: Sticker!
    var sectionIndex: Int!
    var stickerPageType: StickerPageType!
    
    func configure(stickerItem: IGRealmStickerItem) {
        self.stickerPageType = StickerPageType.MAIN
        self.stickerItemRealm = stickerItem
        
        if (stickerItem.fileName?.contains(".json"))! {
            makeAnimationView()
            showAnimatedSticker(token: stickerItem.token!)
            
        } else {
            makeImage()
            showSticker(token: stickerItem.token!)
        }
    }
    
    func configureListPage(stickerItem: Sticker, sectionIndex: Int) {
        self.stickerPageType = StickerPageType.CATEGORY
        self.sectionIndex = sectionIndex
        self.stickerItemStruct = stickerItem
        
        if (stickerItem.fileName.contains(".json")) {
            makeAnimationView()
            showAnimatedSticker(token: stickerItem.token)
        } else {
            makeImage()
            showSticker(token: stickerItem.token)
        }
    }
    
    func configurePreview(stickerItem: Sticker) {
        self.stickerPageType = StickerPageType.PREVIEW
        self.stickerItemStruct = stickerItem

        if (stickerItem.fileName.contains(".json")) {
            makeAnimationView()
            showAnimatedSticker(token: stickerItem.token)
        } else {
            makeImage()
            showSticker(token: stickerItem.token)
        }
    }
    
    private func showSticker(token: String){
        IGStickerViewController.stickerImageDic[token] = self.imgSticker
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let stickerInfo = self.fetchStickerImage(cacheId: cacheId!){
                    stickerInfo.image.setSticker(for: stickerInfo.file)
                }
            }
        })
    }
    
    private func showAnimatedSticker(token: String){
        IGStickerViewController.stickerAnimationDic[token] = self.animationView
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let stickerInfo = self.fetchStickerAnimation(cacheId: cacheId!){
                    stickerInfo.animation.setLiveSticker(for: stickerInfo.file)
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
    
    private func fetchStickerAnimation(cacheId: String) -> (file: IGFile, animation: AnimationView)? {
        for file in IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId)) {
            if let animation = IGStickerViewController.stickerAnimationDic[file.token!] {
                return (file, animation)
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
    private func makeAnimationView() {
        animationView?.removeFromSuperview()
        imgSticker?.removeFromSuperview()
        animationView = nil
        imgSticker = nil

        animationView = AnimationView()
        animationView.layer.masksToBounds = true
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .clear
        mainView.addSubview(animationView)
        
        if stickerPageType == StickerPageType.MAIN {
            animationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnSticker(_:))))
            animationView.isUserInteractionEnabled = true
        } else if stickerPageType == StickerPageType.CATEGORY {
            animationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openStickerPreview(_:))))
            animationView.isUserInteractionEnabled = true
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true

    }

    private func makeImage() {
        imgSticker?.removeFromSuperview()
        animationView?.removeFromSuperview()
        imgSticker = nil
        animationView = nil
        
        imgSticker = UIImageView()
        imgSticker.contentMode = .scaleAspectFit
        imgSticker.backgroundColor = UIColor.clear
        mainView.addSubview(imgSticker)
        
        if stickerPageType == StickerPageType.MAIN {
            imgSticker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnSticker(_:))))
            imgSticker.isUserInteractionEnabled = true
        } else if stickerPageType == StickerPageType.CATEGORY {
            imgSticker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openStickerPreview(_:))))
            imgSticker.isUserInteractionEnabled = true
        }
        
        imgSticker.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.left.equalTo(mainView.snp.left)
            make.right.equalTo(mainView.snp.right)
            make.bottom.equalTo(mainView.snp.bottom)
        }
    }
    
    
    override func prepareForReuse() {
        imgSticker?.removeFromSuperview()
        animationView?.removeFromSuperview()
        imgSticker = nil
        animationView = nil
    }
}
