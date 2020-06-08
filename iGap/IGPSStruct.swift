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
