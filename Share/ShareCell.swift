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
import RealmSwift
import IGProtoBuff

class ShareCell: UITableViewCell {
  
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var imgAvatar: ShareAvatar!
    @IBOutlet weak var imgType: UIImageView!
    var shareInfo: IGShareInfo!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setShareInfo(shareInfo: IGShareInfo){
        self.shareInfo = shareInfo
        self.txtTitle.text = shareInfo.title
        self.imgAvatar.setAvatar(imageData: shareInfo.imageData, initilas: shareInfo.initials!, initilasColor: shareInfo.initialsColor!)
        
        if shareInfo.type == IGPRoom.IGPType.chat.rawValue || shareInfo.type == 4 {
            self.imgType.image = UIImage(named: "IG_Tabbar_Chat_On")
        } else if shareInfo.type == IGPRoom.IGPType.group.rawValue {
            self.imgType.image = UIImage(named: "IG_Tabbar_Group_On")
        } else if shareInfo.type == IGPRoom.IGPType.channel.rawValue {
            self.imgType.image = UIImage(named: "IG_Tabbar_Channel_On")
        }
        self.imgType.image = self.imgType.image!.withRenderingMode(.alwaysTemplate)
        self.imgType.tintColor = UIColor.black
    }
}
