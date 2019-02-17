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
    @IBOutlet weak var stickerView: MSStickerView!
    @IBOutlet weak var imgSticker: UIImageView!
    
    func configure(stickerItem: IGRealmStickerItem) {
        IGAttachmentManager.sharedManager.getFileInfo(token: stickerItem.token!, completion: { (file) -> Void in
            let cacheId = file.cacheID
            DispatchQueue.main.async {
                if let fileInfo = try! Realm().objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId!)).first {
                    self.imgSticker.setThumbnail(for: fileInfo)
                }
            }
        })
    }
}
