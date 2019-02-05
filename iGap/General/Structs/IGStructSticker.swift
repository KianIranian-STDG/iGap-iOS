/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

struct StickerApi: Codable {
    let ok: Bool
    let data: [StickerTab]
}

struct StickerTab: Codable {
    let createdAt: Int
    let id: String
    let refID: Int
    let name, avatarToken: String
    let avatarSize: Int
    let avatarName: String
    let price: Int
    let isVip: Bool
    let sort: Int
    let approved: Bool
    let createdBy: Int
    let stickers: [Sticker]
    
    enum CodingKeys: String, CodingKey {
        case createdAt, id
        case refID = "refId"
        case name, avatarToken, avatarSize, avatarName, price, isVip, sort, approved, createdBy, stickers
    }
}

struct Sticker: Codable {
    let id: String
    let refID: Int
    let name, token, fileName: String
    let fileSize, sort: Int
    let groupID: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case refID = "refId"
        case name, token, fileName, fileSize, sort
        case groupID = "groupId"
    }
}
