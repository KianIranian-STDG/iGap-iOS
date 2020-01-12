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
import SwiftEventBus

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
        IGAttachmentManager.sharedManager.syncroniseStickerQueue.async(flags: .barrier) {
            IGStickerViewController.stickerImageDic[token] = self.imgSticker
        }
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            self.fetchStickerImage(cacheId: file.cacheID!) { (file, imagaView) in
                DispatchQueue.main.async {
                    imagaView.setSticker(for: file)
                }
            }
        })
    }
    
    private func showAnimatedSticker(token: String){
        IGAttachmentManager.sharedManager.syncroniseStickerQueue.async(flags: .barrier) {
            IGStickerViewController.stickerAnimationDic[token] = self.animationView
        }
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            self.fetchStickerAnimation(cacheId: file.cacheID!) { (file, animatedView) in
                DispatchQueue.main.async {
                    animatedView.setLiveSticker(for: file)
                }
            }
        })
    }
    
    /** Hint: Temporary solution
     * sometimes sicker toolbar & sticker cell have two same files with same cacheId BUT with different token.
     * now for show sticker in toolbar and sticker cell we check all files with this token in a loop.
     * However, this loop only has two items.
     */
     private func fetchStickerImage(cacheId: String, completion: @escaping ((_ file :IGFile, _ image: UIImageView) -> Void)) {
        IGAttachmentManager.sharedManager.syncroniseStickerQueue.sync {
            for file in IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId)) {
                if let image = IGStickerViewController.stickerImageDic[file.token!] {
                    completion(file, image)
                }
            }
        }
    }
    
    private func fetchStickerAnimation(cacheId: String, completion: @escaping ((_ file :IGFile, _ animatedView: AnimationView) -> Void)) {
        IGAttachmentManager.sharedManager.syncroniseStickerQueue.sync {
            for file in IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId)) {
                if let animation = IGStickerViewController.stickerAnimationDic[file.token!] {
                    completion(file, animation)
                }
            }
        }
    }
    
    /********************************/
    /*********** Callback ***********/
    @objc func didTapOnSticker(_ gestureRecognizer: UITapGestureRecognizer) {
        if let visibleRoomId = IGGlobal.getVisibleRoomId() {
            SwiftEventBus.postToMainThread("\(visibleRoomId)", sender: self.stickerItemRealm)
        }
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
