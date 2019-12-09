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
import SwiftProtobuf
import RealmSwift

class IGMapNearbyDistanceCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var userDistance: UILabel!
    var avatarImage: IGAvatarView!
    
    class func nib() -> UINib {
        return UINib(nibName: "IGMapNearbyDistanceCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        contentView.backgroundColor = ThemeManager.currentTheme.TableViewCellColor
        self.initialConfiguration()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.initialConfiguration()
    }
    
    private func makeAvatarImage() -> IGAvatarView {
        if avatarImage != nil {
            avatarImage.removeFromSuperview()
            avatarImage = nil
        }
        
        let frame = CGRect(x:0 ,y:0 ,width:54 ,height:54)
        avatarImage = IGAvatarView(frame: frame)
        mainView.addSubview(avatarImage)
        
        avatarImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(mainView.snp.centerY)
            make.leading.equalTo(mainView.snp.leading).offset(12)
            make.width.equalTo(54)
            make.height.equalTo(54)
        }
  
        
        return avatarImage
    }
    
    func initialConfiguration() {
        self.selectionStyle = .none
    }
    
    func setUserInfo(nearbyDistance : IGRealmMapNearbyDistance) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", nearbyDistance.id)
        if let userInfo = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            makeAvatarImage().setUser(userInfo)
            contactName.text = userInfo.displayName
            if nearbyDistance.hasComment {
                userComment.text = nearbyDistance.comment
            } else {
                userComment.text = IGStringsManager.NoStatus.rawValue.localized
            }
            userDistance.text = IGStringsManager.Around.rawValue.localized + " " + "\(nearbyDistance.distance)".inLocalizedLanguage() + " " + IGStringsManager.Meter.rawValue.localized
            
        }
    }
}









