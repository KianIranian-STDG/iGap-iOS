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

class ForwardCell: UICollectionViewCell {
    
    @IBOutlet weak var btnCheckMark: UIButtonX!
    @IBOutlet weak var viewHolder: UIViewX!
    @IBOutlet weak var imgUser: UIImageViewX!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInitials: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.height = 80.0
        self.btnCheckMark.isHidden = true
        self.viewHolder.layer.borderWidth = 0.0
    }
    
    func setImage(avatar: IGAvatar?=nil,initials: String?,color:String) {
        self.imgUser!.image = nil
        self.lblInitials!.text = initials
        let color = UIColor.hexStringToUIColor(hex: color)
        self.viewHolder!.backgroundColor = color
        
        if let avatar = avatar {
            self.imgUser!.setAvatar(avatar: avatar.file!)
        }
    }
}
