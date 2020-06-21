//
//  IGKStruct.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/7/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
struct IGPSBaseBillResponseArrayModel<T: Decodable>: Decodable {
    let docs: [T]?
}

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
    var billIdentifier: String?
    var paymentIdentifier: String?
    var totalBillDebt: String?
    var paymentDeadLine: String?
    
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

//MARK: - Phone
struct IGPSMobileBillQuery: Decodable {
    let midTerm: midTerm?
    let lastTerm: lastTerm?
    
    enum CodingKeys: String, CodingKey {
        case midTerm = "mid_term_bill_info"
        case lastTerm = "last_term_bill_info"
    }
    struct midTerm : Decodable {
        let billId: String?
        let payId: String?
        let amount: String?
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
        let billId: String?
        let payId: String?
        let amount: String?
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
//MARK: - All Bills
struct IGPSAllBillsBillQuery: Decodable {
    let id: String?
    let billType: String?
    let billTitle: String?
    let mobileNumber: String?
    let billID: String?
    let subsCriptionCode: String?
    let billPhone: String?
    let billAreaCode: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case billType = "bill_type"
        case billTitle = "bill_title"
        case mobileNumber = "mobile_number"
        case billID = "bill_identifier"
        case subsCriptionCode = "subscription_code"
        case billPhone = "phone_number"
        case billAreaCode = "area_code"
    }

}
//MARK: - All Bills
struct IGPSBillInnerData  {
    var billID: String?
    var billPayId: String?
    var BillPrice: String?
    var BillPriceLastTerm: String?
    var billDeadLine: String?

}



struct parentBillModel {
    
    var id: String?
    var billType: String?
    var billTitle : String?
    var mobileNumber: String?
    var billIdentifier: String?
    var subsCriptionCode: String?
    var billPhone: String?
    var billAreaCode: String?

    var elecBill : elecModel?
    var gasBill: gasModel?
    var phoneBill: phoneModel?
    var mobileBill: mobileModel?

    struct gasModel {
        var billIdentifier: String?
        var paymentIdentifier: String?
        var totalBillDebt: String?
        var paymentDeadLine: String?
        init() { }
    }
    struct elecModel {
        var billIdentifier: String?
        var totalRegisterDebt: Int?
        var paymentIdentifier: String?
        var totalBillDebt: String?
        var otherAccountDebt: String?
        var paymentDeadLine: String?
        init() {}
    }
    struct phoneModel {
        var midTermPhone: PhoneMidTermInner?
        var lastTermPhone: PhoneLastTermInner?
        init() {}
        struct PhoneMidTermInner  {
            var billId: Int?
            var payId: Int?
            var amount: Int?
            var status: Int?
            var message: String?
            init() {}

        }
        struct PhoneLastTermInner  {
            var billId: Int?
            var payId: Int?
            var amount: Int?
            var status: Int?
            var message: String?
            init() {}
        }
    }
    
    struct mobileModel {
        var midTermMobile: MobileMidTermInner?
        var lastTermMobile: MobileLastTermInner?
        init() {}
        struct MobileMidTermInner  {
            var billId: String?
            var payId: String?
            var amount: String?
            var status: Int?
            var message: String?
            init() {}

        }
        struct MobileLastTermInner  {
            var billId: String?
            var payId: String?
            var amount: String?
            var status: Int?
            var message: String?
            init() {}
        }
    }
    init() {}
    
}
