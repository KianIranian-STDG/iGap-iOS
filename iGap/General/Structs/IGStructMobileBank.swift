//
//  IGStructMobileBank.swift
//  iGap
//
//  Created by ahmad mohammadi on 4/29/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire

struct IGMBCardResponse<T: Codable>: Codable {
    let message: String
    let data: [T]
}

struct IGMBCard: Codable {
    let status: String
    let statusCause: String?
    let type, holderFirstName, holderLastName, expireDate: String
    let issueDate, number: String

    enum CodingKeys: String, CodingKey {
        case status = "card_status"
        case statusCause = "card_status_cause"
        case type = "card_type"
        case holderFirstName = "customer_first_name"
        case holderLastName = "customer_last_name"
        case expireDate = "expire_date"
        case issueDate = "issue_date"
        case number = "pan"
    }
}
