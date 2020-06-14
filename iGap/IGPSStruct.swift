//
//  IGKStruct.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/7/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

struct IGPSBaseResponseModel<T: Decodable>: Decodable {
    let data: T?
}
struct IGPSBaseResponseArrayModel<T: Decodable>: Decodable {
    let data: [T]?
}
    //MARK: - IGKPayment
struct IGPSLastTopUpPurchases: Codable {
    let type: String?
    let phoneNumber: String?
    let simOperator: String?
    let simOperatorTitle: String?
    let chargeType: String?
    let chargeTypeDescription: String?
    let amount: Int?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case phoneNumber = "phone_number"
        case simOperator = "operator"
        case simOperatorTitle = "operator_title"
        case chargeType = "charge_type"
        case chargeTypeDescription = "charge_type_description"
        case amount = "amount"
    }
}

struct IGPSLastInternetPackagesPurchases: Codable {
    let type: String?
    let phoneNumber: String?
    let simOperator: String?
    let simOperatorTitle: String?
    let chargeType: String?
    let chargeTypeDescription: String?
    let packageType: String?
    let packageDesc: String?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case phoneNumber = "phone_number"
        case simOperator = "operator"
        case simOperatorTitle = "operator_title"
        case chargeType = "charge_type"
        case chargeTypeDescription = "charge_type_description"
        case packageType = "package_type"
        case packageDesc = "package_description"
    }
}
struct IGPSInternetPackages : Codable {
    let type: String?
    let cost: Int?
    let description: String?
    let duration: String?
    let traffic: String?
    let isSpecial: Bool?
    let chargeType: Int?
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case cost = "cost"
        case description = "description"
        case duration = "duration"
        case traffic = "traffic"
        case isSpecial = "isSpecial"
        case chargeType = "chargeType"
    }

}

struct IGPSInternetCategory: Codable {
    let category: Category?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case category = "category"
        case id = "id"
    }

    struct Category: Codable {
        var type: String?
        var value: CGFloat?
        var subType: String?
        
        enum CodingKeys: String, CodingKey {
            case type = "type"
            case value = "value"
            case subType = "sub_type"
        }
    }
    
}
