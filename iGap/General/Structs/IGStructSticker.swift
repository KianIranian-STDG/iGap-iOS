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
    let type: String?
    let v: Int?
    let isInUserList, isGiftable, isNew, isReadonly: Bool?
    let stickers: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, updatedAt, categoryId
        case refID = "refId"
        case v = "__v"
        case name, avatarToken, avatarSize, avatarName, price, isVip, sort, status, createdBy, isGiftable, stickers, isInUserList, isNew, isReadonly,type
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
    let sort: Int?
    let createdAt: Int
    let updatedAt: Int
    let status: String
    let isFavorite: Bool
    let giftAmount: Int?
    let v: Int?
    let tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt, updatedAt
        case refID = "refId"
        case name, token, fileName, fileSize, sort, giftAmount
        case groupID = "groupId"
        case v = "__v"
        case status, isFavorite
        case tags
    }
}

class IGStructStickerMessage {
    
    var id : Int64!
    var name : String!
    var groupId : String!
    var token : String!
    var filename : String!
    var filesize : Int!
    var type : Int!
    var giftId : String!
    var giftAmount : Int!
    var isFavorite : Bool!
    
    init(_ json: JSON) {
        self.id = json["id"].int64Value
        self.name = json["name"].stringValue
        self.groupId = json["groupId"].stringValue
        self.token = json["token"].stringValue
        self.filename = json["filename"].stringValue
        self.filesize = json["filesize"].intValue
        
        if json["giftId"].exists() {
            self.giftId = json["giftId"].stringValue
        }
        if json["type"].exists() {
            self.type = json["type"].intValue
        }
        if json["giftAmount"].exists() {
            self.giftAmount = json["giftAmount"].intValue
        }
        if json["isFavorite"].exists() {
            self.isFavorite = json["isFavorite"].boolValue
        }
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



// MARK: - IGStructGiftCardList
struct IGStructGiftCardList: Codable {
    let data: [IGStructGiftCardListData]
}

struct IGStructGiftCardListData: Codable {
    let creation, activation: Ation
    let requestCount, amount: Int
    let sticker: IGStructGiftCardSticker
    let createdAt: String
    let rrn: Int
    let toUserId: String?
    let activationStatus, id: String

    enum CodingKeys: String, CodingKey {
        case creation, activation, requestCount, amount, sticker, createdAt, rrn
        case toUserId
        case activationStatus, id
    }
}

struct Ation: Codable {
    let status: String
}

struct IGStructGiftCardSticker: Codable {
    let tags: [String]
    let giftAmount: Int
    let name, token, fileName: String
    let fileSize: Int
    let groupId: String
    let sort: Int
    let id: String
    let isFavorite: Bool?

    enum CodingKeys: String, CodingKey {
        case tags, giftAmount, name, token, fileName, fileSize
        case groupId
        case sort, id, isFavorite
    }
}


// MARK: - IGStructGiftCardStatus
struct IGStructGiftCardStatus: Codable {
    let activation: GiftStickerActivationStatus
    let sticker: IGStructGiftCardSticker
    let isActive, isCardOwner, isForwarded: Bool
    let id: String
}

struct GiftStickerActivationStatus: Codable {
    let status: String
    
    static func convertStatus(_ status: String) -> GiftStickerListType {
        if status == "NEW" {
            return .new
        } else if status == "ACTIVE" {
            return .active
        } else if status == "FORWARDED" {
            return .forwarded
        }
        return .new
    }
}

struct IGStructStickerEncryptData: Codable {
    let data: String
}

struct IGStructGiftCardInfo {
    let expireDate: String
    let cvv2: String
    let cardNumber: String
    let secondPassword: String
    
    init(value: [String: Any]) {
        self.expireDate = value["expire_date"] as! String
        self.cvv2 = value["cvv2"] as! String
        self.cardNumber = value["card_no"] as! String
        self.secondPassword = value["second_password"] as! String
    }
}
