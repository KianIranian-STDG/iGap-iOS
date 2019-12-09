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

class IGMediaPagerCell: FSPagerViewCell {

    var imgMedia: IGImageView!
    var progress: IGProgress!
    
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
    
    public func setMessageItem(message: IGRoomMessage, size: MediaViewerCellCalculatedSize) {
        let finalMessage = message.getFinalMessage()
        attachment = finalMessage.attachment
        
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
            if let disposable = IGGlobal.dispoasDic[finalMessage.id] {
                IGGlobal.dispoasDic.removeValue(forKey: finalMessage.id)
                disposable.dispose()
            }
            let subscriber = variableInCache.asObservable().subscribe({ (event) in
                DispatchQueue.main.async {
                    self.showMedia()
                }
            })
            IGGlobal.dispoasDic[finalMessage.id] = subscriber
        }
    }
    
    public func setAvatarItem(message: IGRoomMessage, size: MediaViewerCellCalculatedSize) {
        imgMedia.setThumbnaill(for: message.attachment!)
    }
    
    private func showMedia(){
        let fileExist = IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size)
        if !fileExist {
            progress.isHidden = false
            progress.delegate = self
        }
        progress?.setState(attachment.status)
        if attachment.status == .downloading || attachment.status == .uploading {
            progress?.setPercentage(attachment.downloadUploadPercent)
        }
        imgMedia.setThumbnail(for: attachment, showMain: false)
    }
    
    
    private func makeView(size: MediaViewerCellCalculatedSize){
        
        imgMedia?.removeFromSuperview()
        progress?.removeFromSuperview()
        
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
}

extension IGMediaPagerCell: IGProgressDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGProgress) {
        if let attachment = self.attachment {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
        }
    }
}
