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

class IGMediaViewerCell: UICollectionViewCell {

    @IBOutlet weak var imgMedia: IGImageView!
    @IBOutlet weak var imgMediaHeight: NSLayoutConstraint!
    @IBOutlet weak var imgMediaWidth: NSLayoutConstraint!
    @IBOutlet weak var txtMedia: UILabel!
    @IBOutlet weak var txtMediaHeight: NSLayoutConstraint!
    
    class func nib() -> UINib {
        return UINib(nibName: "IGMediaViewerCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setMessageItem(message: IGRoomMessage, size: MediaViewerCellCalculatedSize) {
        imgMedia.setThumbnaill(for: message.attachment!)
        
        imgMediaHeight.constant = size.mediaSize.height
        imgMediaWidth.constant = size.mediaSize.width
        
        if let text = message.message {
            txtMedia.text = text
            txtMediaHeight.constant = size.messageHeight.height
        }
    }
    
    public func setAvatarItem(message: IGRoomMessage, size: MediaViewerCellCalculatedSize) {
        imgMedia.setThumbnaill(for: message.attachment!)
    }
}
