/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import AsyncDisplayKit
import SnapKit


class ASImageView: ASNetworkImageNode {
    var attachmentId: String?
    
    func setThumbnaill(for attachment: IGFile) {
        attachmentId = attachment.cacheID
        setOrFetchThumbnail(for: attachment)
    }
    
    func setOrFetchThumbnail(for attachment: IGFile) {
        if attachment.cacheID != self.attachmentId {
            return
        }
        if let path = attachment.path() {
            if FileManager.default.fileExists(atPath: path.path) {
                if let image = UIImage(contentsOfFile: path.path) {
                    self.image = image
                    return
                }
            }
        }
        
        if let thumbnail = attachment.smallThumbnail {
            do {
                var path = URL(string: "")
                if attachment.attachedImage != nil {
                    self.image = attachment.attachedImage
                } else {
                    var image: UIImage?
                    path = thumbnail.path()
                    if FileManager.default.fileExists(atPath: path!.path) {
                        image = UIImage(contentsOfFile: path!.path)
                    }
                    
                    if image != nil {
                        self.image = image
                    } else {
                        throw NSError(domain: "asa", code: 1234, userInfo: nil)
                    }
                }
            } catch {
                IGDownloadManager.sharedManager.download(file: thumbnail, previewType:.smallThumbnail, completion: { (attachment) -> Void in
                    DispatchQueue.main.async {
                        self.setOrFetchThumbnail(for: attachment)
                    }
                }, failure: {
                    
                })
            }
        } else {
            switch attachment.type {
            case .image:
                self.image = nil
                break
            case .gif:
                break
            case .video:
                break
            case .audio:
                self.image = UIImage(named:"IG_Message_Cell_Player_Default_Cover")
                break
            case .voice:
                break
            case .file:
                break
            case .sticker:
                break
            }
        }
    }
}
