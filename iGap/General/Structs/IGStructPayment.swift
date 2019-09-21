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
        
        struct Product: Decodable {
            var title: String?
            var description: String?
            var tel_num: String?
            var type: String?
            var vendor: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case product, price, vendor
            case orderId = "order_id"
        }
    }
    
    var info: Info
    var redirectUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case info
        case redirectUrl = "redirect_url"
    }
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
