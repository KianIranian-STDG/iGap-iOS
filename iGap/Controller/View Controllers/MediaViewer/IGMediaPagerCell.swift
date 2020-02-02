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
import FSPagerView
import AVKit

class IGMediaPagerCell: FSPagerViewCell {

    // Global View
    private var imgMedia: IGImageView!
    private var progress: IGProgress!
    // Video Info View
    private var viewVideoInfo: UIView!
    private var txtVideoInfo: UILabel!
    private var txtVideoIcon: UILabel!
    private var txtVideoPlay: UILabel!

    private var finalRoomMessage: IGRoomMessage!
    private var finalAvatar: IGAvatar!
    private var attachment: IGFile!
    
    class func nib() -> UINib {
        return UINib(nibName: "IGMediaPagerCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK:- Intialize Item
    public func setMessageItem(message: IGRoomMessage, size: MediaViewerCellCalculatedSize) {
        finalRoomMessage = message.getFinalMessage()
        attachment = finalRoomMessage.attachment
        manageMedia(file: attachment, cacheId: finalRoomMessage.id, size: size)
        
        if finalRoomMessage.type == .video || finalRoomMessage.type == .videoAndText {
            makeVideoInfo()
        }
    }
    
    public func setAvatarItem(avatar: IGAvatar, size: MediaViewerCellCalculatedSize) {
        finalAvatar = avatar
        attachment = avatar.file
        manageMedia(file: avatar.file!, cacheId: avatar.id, size: size)
    }
    
    private func manageMedia(file: IGFile, cacheId: Int64, size: MediaViewerCellCalculatedSize) {
        attachment = file
        makeView(size: size)
        
        if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
            self.attachment = attachmentVariableInCache.value
        } else {
            IGAttachmentManager.sharedManager.add(attachment: attachment)
            if let variable = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
                self.attachment = variable.value
            }
        }
        
        /* Rx Start */
        if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.cacheID!) {
            if let disposable = IGGlobal.dispoasDic[cacheId] {
                IGGlobal.dispoasDic.removeValue(forKey: cacheId)
                disposable.dispose()
            }
            let subscriber = variableInCache.asObservable().subscribe({ (event) in
                DispatchQueue.main.async {
                    self.showMedia()
                }
            })
            IGGlobal.dispoasDic[cacheId] = subscriber
        }
    }
    
    private func showMedia(){
        let fileExist = IGGlobal.isFileExist(path: attachment.localPath, fileSize: attachment.size)
        if fileExist {
            
            if self.finalRoomMessage != nil && (self.finalRoomMessage.type == .video || self.finalRoomMessage.type == .videoAndText) {
                makeVideoPlayView()
            }
            
            progress?.setState(attachment.status)
            progress.isHidden = true
            
            if (finalRoomMessage != nil && (finalRoomMessage.type == .image || finalRoomMessage.type == .imageAndText)) || (finalAvatar != nil) {
                let settings = Settings.defaultSettings
                    .with(actionOnDoubleTapImageView: Action.zoomIn)
                    .with(actionOnDoubleTapOverlay: Action.dismissOverlay)
                
                UIApplication.topViewController()?.addZoombehavior(for: imgMedia, in: self, settings: settings)
            }
        } else {
            progress.isHidden = false
            progress.delegate = self
            progress?.setState(attachment.status)
        }
        if attachment.status == .downloading {
            progress?.setPercentage(attachment.downloadUploadPercent)
        } else {
            progress?.setFileType(.download)
        }
        
        if finalAvatar != nil {
            imgMedia.setAvatar(avatar: attachment, type: .smallThumbnail)
        } else {
            imgMedia.setThumbnail(for: attachment, showMain: true)
        }
    }
    
    // MARK:- View Maker
    private func makeView(size: MediaViewerCellCalculatedSize){
        
        imgMedia?.removeFromSuperview()
        progress?.removeFromSuperview()
        viewVideoInfo?.removeFromSuperview()
        txtVideoPlay?.removeFromSuperview()
        
        imgMedia = IGImageView()
        self.addSubview(imgMedia)
        
        progress = IGProgress()
        progress.isHidden = true
        self.addSubview(progress)
        
        imgMedia.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(size.mediaSize.height)
        }
        
        progress.snp.makeConstraints { (make) in
            make.center.equalTo(imgMedia.snp.center)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
    }
    
    private func makeVideoInfo(){
        
        viewVideoInfo = UIView()
        viewVideoInfo.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        viewVideoInfo.layer.cornerRadius = 10
        viewVideoInfo.layer.borderWidth = 1
        viewVideoInfo.layer.borderColor = UIColor.chatBubbleBorderColor().cgColor
        self.addSubview(viewVideoInfo)
        
        txtVideoIcon = UILabel()
        txtVideoIcon.textColor = UIColor.white
        txtVideoIcon.font = UIFont.iGapFonticon(ofSize: 16)
        txtVideoIcon.text = ""
        viewVideoInfo.addSubview(txtVideoIcon)
        
        txtVideoInfo = UILabel()
        txtVideoInfo.textColor = UIColor.white
        txtVideoInfo.font = UIFont.igFont(ofSize: 10)
        viewVideoInfo.addSubview(txtVideoInfo)
        
        viewVideoInfo?.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(40) // play view height is 60, so for set this view top of play or download icon and for avoid from check with both these views
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(40)
        }
        
        txtVideoIcon?.snp.makeConstraints { (make) in
            make.leading.equalTo(viewVideoInfo.snp.leading).offset(4)
            make.centerY.equalTo(viewVideoInfo.snp.centerY)
        }
        
        txtVideoInfo?.snp.makeConstraints { (make) in
            make.leading.equalTo(txtVideoIcon.snp.trailing).offset(3)
            make.trailing.equalTo(viewVideoInfo.snp.trailing).offset(-4)
            make.centerY.equalTo(viewVideoInfo.snp.centerY)
        }
        
        let time : String! = IGAttachmentManager.sharedManager.convertFileTime(seconds: Int((finalRoomMessage.attachment?.duration)!))
        txtVideoInfo.text = "\(time!) (\(IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: (finalRoomMessage.attachment?.size)!)))"
    }
    
    private func makeVideoPlayView(){
        txtVideoPlay = UILabel()
        txtVideoPlay.font = UIFont.iGapFonticon(ofSize: 40)
        txtVideoPlay.textAlignment = NSTextAlignment.center
        txtVideoPlay.text = ""
        txtVideoPlay.textColor = UIColor.white
        txtVideoPlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        txtVideoPlay.layer.masksToBounds = true
        txtVideoPlay.layer.cornerRadius = 27.5
        self.addSubview(txtVideoPlay)
        
        txtVideoPlay?.snp.makeConstraints { (make) in
            make.width.equalTo(55)
            make.height.equalTo(55)
            make.centerX.equalTo(imgMedia.snp.centerX)
            make.centerY.equalTo(imgMedia.snp.centerY)
        }
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(didTapOnPlay(_:)))
        txtVideoPlay.addGestureRecognizer(tapOnView)
        txtVideoPlay.isUserInteractionEnabled = true
    }
    
    // MARK:- User Actions
    @objc func didTapOnPlay(_ gestureRecognizer: UITapGestureRecognizer) {
        if let path = self.attachment.localUrl {
            let player = AVPlayer(url: path)
            let avController = AVPlayerViewController()
            avController.player = player
            player.play()
            UIApplication.topViewController()?.present(avController, animated: true, completion: nil)
        }
    }
}

extension IGMediaPagerCell: IGProgressDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGProgress) {
        if let attachment = self.attachment {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
        }
    }
}
