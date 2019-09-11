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

class IGFavouriteChannelCVCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageViewX!
    
    class func nib() -> UINib {
        return UINib(nibName: "IGFavouriteChannelCVCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let isEnglish = SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue
        self.contentView.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        imageView.layer.cornerRadius = 8
    }
}
