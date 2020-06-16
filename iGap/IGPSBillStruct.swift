//
//  IGKStruct.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/7/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

    //MARK: - Elec
struct IGPSElecBillQuery: Decodable {
    let billIdentifier: String?
    let totalRegisterDebt: Int?
    let paymentIdentifier: String?
    let totalBillDebt: String?
    let otherAccountDebt: String?
    let paymentDeadLine: String?
    
    enum CodingKeys: String, CodingKey {
        case billIdentifier = "bill_identifier"
        case totalRegisterDebt = "total_register_debt"
        case paymentIdentifier = "payment_identifier"
        case totalBillDebt = "total_bill_debt"
        case otherAccountDebt = "other_account_debt"
        case paymentDeadLine = "payment_dead_line"
    }
}
//MARK: - Gas

struct IGPSGasBillQuery: Decodable {
    let billIdentifier: String?
    let paymentIdentifier: String?
    let totalBillDebt: String?
    let paymentDeadLine: String?
    
    enum CodingKeys: String, CodingKey {
        case billIdentifier = "bill_identifier"
        case paymentIdentifier = "payment_identifier"
        case totalBillDebt = "payment_amount"
        case paymentDeadLine = "payment_dead_line"
    }
}

//MARK: - Phone
struct IGPSPhoneBillQuery: Decodable {
    let midTerm: midTerm?
    let lastTerm: lastTerm?
    
    enum CodingKeys: String, CodingKey {
        case midTerm = "mid_term_bill_info"
        case lastTerm = "last_term_bill_info"
    }
    struct midTerm : Decodable {
        let billId: Int?
        let payId: Int?
        let amount: Int?
        let status: Int?
        let message: String?
        
        enum CodingKeys: String, CodingKey {
            case billId = "bill_id"
            case payId = "pay_id"
            case amount = "amount"
            case status = "status"
            case message = "message"
        }

    }
    struct lastTerm : Decodable {
        let billId: Int?
        let payId: Int?
        let amount: Int?
        let status: Int?
        let message: String?
        
        enum CodingKeys: String, CodingKey {
            case billId = "bill_id"
            case payId = "pay_id"
            case amount = "amount"
            case status = "status"
            case message = "message"
        }

    }

}



