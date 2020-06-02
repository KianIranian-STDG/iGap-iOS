//
//  IGStructPayment.swift
//  iGap
//
//  Created by MacBook Pro on 6/20/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

struct IGStructPayment: Decodable {
    struct Info: Decodable {
        var product: Product?
        var price: Int?
        var vendor: String?
        var orderId: String?
        
        struct Product: Codable {
            let title, productDescription, telNum, telCharger: String?
            let type, vendor, productRefType, refType: String?

            enum CodingKeys: String, CodingKey {
                case title
                case productDescription = "description"
                case telNum = "tel_num"
                case telCharger = "tel_charger"
                case type, vendor
                case productRefType = "ref_type"
                case refType
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case product, price, vendor
            case orderId = "order_id"
        }
    }
    
    var info: Info
    var features: [Feature]?
    var redirectUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case info
        case features
        case redirectUrl = "redirect_url"
    }
}

struct Feature: Codable {
    let ceil, unit, floor, spent: Int
    let type: String
    let discount, userScore, priceWithFeature: Int
    let title: String
}

struct IGStructPaymentStatus: Decodable {
    struct Info: Decodable {
        var price: Int?
        var vendor: String?
        var orderId: String?
        var product: Product?
        var createdAt: String?
        var rrn: Int64?
        
        struct Product: Decodable {
            var title: String?
            var description: String?
            var tel_num: String?
            var type: String?
            var vendor: String?
            var refType: String?
            var user: User?
            
            struct User: Decodable {
                var id: String?
                var agent: String?
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case price, vendor, orderId, product, rrn
            case createdAt = "created_at"
        }
    }
    
    var info: Info?
    var status: String?
    var message: String?
}


/********************* Sticker Payment Struct *********************/
struct IGStructGiftCardPayment: Codable {
    let info: IGStructGiftCardPaymentInfo
    let features: [Feature]?
    let redirectURL: String

    enum CodingKeys: String, CodingKey {
        case info, features
        case redirectURL = "redirect_url"
    }
}

struct IGStructGiftCardPaymentInfo: Codable {
    let product: Product
    let price: Int
    let vendor, orderID: String

    enum CodingKeys: String, CodingKey {
        case product, price, vendor
        case orderID = "order_id"
    }
}

struct Product: Codable {
    let title, productDescription: String
    let quantity: Int
    let refType: String
    let info: ProductInfo

    enum CodingKeys: String, CodingKey {
        case title
        case productDescription = "description"
        case quantity, refType, info
    }
}

struct ProductInfo: Codable {
    let creation: Creation
    let activation: Activation
    let requestCount, amount: Int
    let sticker: String
    //let forwardHistory: [String]
    let createdAt, id: String
}

struct Activation: Codable {
    let status: String
}

struct Creation: Codable {
    let status, mobileNumber, nationalCode, userId: String

    enum CodingKeys: String, CodingKey {
        case status, mobileNumber, nationalCode
        case userId
    }
}
