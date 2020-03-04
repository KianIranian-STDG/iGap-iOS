/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import SwiftyJSON

struct StickerCategories: Codable {
    let ok: Bool
    let data: [StickerCategory]
}

struct StickerApi: Codable {
    let ok: Bool
    let data: [StickerTab]
}

struct StickerGroup: Codable {
    let ok: Bool
    let data: StickerTab
}

struct StickerCategory: Codable {
    let createdAt, updatedAt: Int
    let id, name: String
    let sort: Int
    let status: String
}

struct StickerTab: Codable {
    let createdAt, updatedAt: Int64
    let id: String
    let refID: Int64
    let name, avatarToken: String
    let avatarSize: Int
    let avatarName: String
    let price: Int
    let isVip: Bool
    let sort: Int
    let status: String
    let createdBy: Int64
    let isGiftable: Bool?
    let stickers: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case createdAt, updatedAt, id
        case refID = "refId"
        case name, avatarToken, avatarSize, avatarName, price, isVip, sort, status, createdBy, isGiftable, stickers
    }
}

struct Sticker: Codable {
    let createdAt, updatedAt: Int
    let id: String
    let refID: Int
    let name, token, fileName: String
    let fileSize, sort: Int
    let groupID, status: String
    let giftAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case createdAt, updatedAt, id
        case refID = "refId"
        case name, token, fileName, fileSize, sort, giftAmount
        case groupID = "groupId"
        case status
    }
}

class IGStructStickerMessage {
    
    var id : Int64!
    var name : String!
    var groupId : String!
    var token : String!
    var filename : String!
    var filesize : Int!
    
    init(_ json: JSON) {
        self.id = json["id"].int64Value
        self.name = json["name"].stringValue
        self.groupId = json["groupId"].stringValue
        self.token = json["token"].stringValue
        self.filename = json["filename"].stringValue
        self.filesize = json["filesize"].intValue
    }
}

