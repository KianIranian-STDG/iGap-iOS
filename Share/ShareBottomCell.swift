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

protocol BottomCellDelegate {
    func removeSelected(cell: ShareBottomCell)
}


class ShareBottomCell: UICollectionViewCell {

    @IBOutlet weak var avatar: ShareAvatar!
    @IBOutlet weak var name: UILabel!
    
    var itemId: Int64!
    var tableViewSelectedIndexPath: IndexPath!
    var deselectDelegate : BottomCellDelegate!
    
    @IBAction func btnDeselectClick(_ sender: UIButton) {
        deselectDelegate.removeSelected(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setInfo(info: IGShareInfo){
        self.itemId = info.itemId
        name.text = info.title
        avatar.setAvatar(imageData: info.imageData, initilas: info.initials!, initilasColor: info.initialsColor!)
    }
}
