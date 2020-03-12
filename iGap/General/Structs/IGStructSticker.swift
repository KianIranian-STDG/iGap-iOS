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
    let data: [StickerCategory]
}

struct BuyGiftSticker: Codable {
    let token, id: String
}

struct StickerApi: Codable {
    let data: [StickerTab]
}

struct StickerCategory: Codable {
    let id, name: String
    let sort: Int
}

struct StickerTab: Codable {
    
    let id: String
    let createdAt: Int
    let updatedAt: Int
    let createdBy: Int
    let categoryId: String?
    let refID: Int64
    let name: String
    let avatarToken: String
    let avatarSize: Int
    let avatarName: String
    let price: Int
    let isVip: Bool
    let sort: Int
    let status: String
    let isInUserList, isGiftable, isNew, isReadonly: Bool?
    let stickers: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, updatedAt, categoryId
        case refID = "refId"
        case name, avatarToken, avatarSize, avatarName, price, isVip, sort, status, createdBy, isGiftable, stickers, isInUserList, isNew, isReadonly
    }
}

struct Sticker: Codable {
    
    let id: String
    let refID: Int
    let name: String
    let token: String
    let fileName: String
    let fileSize: Int
    let groupID: String
    let sort: Int
    let createdAt: Int
    let updatedAt: Int
    let status: String
    let isFavorite: Bool
    let giftAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, updatedAt
        case refID = "refId"
        case name, token, fileName, fileSize, sort, giftAmount
        case groupID = "groupId"
        case status, isFavorite
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




// MARK: - IGStructGiftFirstPageInfo
struct IGStructGiftFirstPageInfo: Codable {
    let type: String
    let info: Info
    let data: [PageData]
}

struct PageData: Codable {
    let title, titleEn: String
    let actionType: Int
    let actionLink: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case title
        case titleEn = "title_en"
        case actionType = "action_type"
        case actionLink = "action_link"
        case imageURL = "image_url"
    }
}

struct Info: Codable {
    let title, titleEn, scale: String

    enum CodingKeys: String, CodingKey {
        case title
        case titleEn = "title_en"
        case scale
    }
}

