/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import RealmSwift
import Foundation

class IGRealmSticker: Object {

    @objc dynamic var id: String?
    @objc dynamic var createdAt: Int = 0
    @objc dynamic var refID: Int64 = 0
    @objc dynamic var name: String?
    @objc dynamic var avatarToken: String?
    @objc dynamic var avatarSize: Int = 0
    @objc dynamic var avatarName: String?
    @objc dynamic var price: Int = 0
    @objc dynamic var isVip: Bool = false
    @objc dynamic var sort: Int = 0
    @objc dynamic var status: String?
    @objc dynamic var createdBy: Int = 0
    var stickerItems: List<IGRealmStickerItem> = List<IGRealmStickerItem>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(sticker: StickerTab, stickerItems: List<IGRealmStickerItem>) {
        self.init()
        
        self.id = sticker.id
        self.createdAt = sticker.createdAt
        self.refID = sticker.refID
        self.name = sticker.name
        self.avatarToken = sticker.avatarToken
        self.avatarSize = sticker.avatarSize
        self.avatarName = sticker.avatarName
        self.price = sticker.price
        self.isVip = sticker.isVip
        self.sort = sticker.sort
        self.status = sticker.status
        self.createdBy = sticker.createdBy
        self.stickerItems = stickerItems
    }
    
    internal static func isMySticker(id: String) -> Bool {
        if let _ = try! Realm().objects(IGRealmSticker.self).filter("id = %@", id).first {
            return true
        }
        return false
    }
}


class IGRealmStickerItem: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var refID: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var token: String?
    @objc dynamic var fileName: String?
    @objc dynamic var fileSize: Int = 0
    @objc dynamic var sort: Int = 0
    @objc dynamic var groupID: String?
    @objc dynamic var giftAmount: Int = 0
    @objc dynamic var giftId: String!
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(sticker: Sticker) {
        self.init()
        
        self.id = sticker.id
        self.refID = sticker.refID
        self.name = sticker.name
        self.token = sticker.token
        self.fileName = sticker.fileName
        self.fileSize = sticker.fileSize
        self.sort = sticker.sort
        self.groupID = sticker.groupID
        self.giftAmount = sticker.giftAmount ?? 0
    }
    
    convenience init(sticker: IGStructGiftCardSticker, giftId: String) {
        self.init()
        
        self.id = sticker.id
        self.name = sticker.name
        self.token = sticker.token
        self.fileName = sticker.fileName
        self.fileSize = sticker.fileSize
        self.sort = sticker.sort
        self.groupID = sticker.groupId
        self.giftId = giftId
        self.giftAmount = sticker.giftAmount
    }
}
