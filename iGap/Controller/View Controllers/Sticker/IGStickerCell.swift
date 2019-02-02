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

@available(iOS 10.0, *)
class IGStickerCell: UICollectionViewCell {
    @IBOutlet weak var stickerView: MSStickerView!
    func configure(usingImageName imageName:String) {
        guard let imagePath = Bundle.main.path(forResource: imageName, ofType: ".png") else {
            return
        }
        let path =  URL(fileURLWithPath: imagePath)
        do {
            //let description = NSLocalizedString("Food Sticker", comment: "")
            let sticker = try MSSticker(contentsOfFileURL: path , localizedDescription: description)
            stickerView.sticker = sticker
        }
        catch {
            fatalError("Failed to create sticker: \(error)")
        }
    }
}
