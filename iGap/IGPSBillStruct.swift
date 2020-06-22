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
struct ElecBillBranchInfoModel : Decodable {
    let totalRegisterDebt: Int?
    let paymentIdentifier: String?
    let totalBillDebt: String?
    let otherAccountDebt: String?
    let paymentDeadLine: String?
    let lastReadDate: String?
    let lastGrossAmt: Int?
    let lastSaleYear: Int?
    let lastSalePrd: Int?
    let adjustmentFactor: Int?
    let digitNumber: Int?
    let meterModelFk: Int?
    let cityFk: Int?
    let agentPhone: Int?
    let msgCode: Int?
    let isPaid: Bool?
    let billIdentifier: String?
    let companyName: String?
    let companyCode: Int?
    let phase: String?
    let voltageType: String?
    let amper: String?
    let contractDemand: Int?
    let tarrifType: String?
    let customerType: String?
    let nationalCode: String?
    let customerName: String?
    let customerFamily: String?
    let telNum: String?
    let mobileNum: String?
    let address: String?
    let locationStatus: String?
    let serialNum: String?
    let licenseExpireDate: String?
    let subscriptionCode: Int?
    let fileSerialNumber: Int?
    let servicePostCode: String?
    let lastupdatetime: String?
    let billurl: String?

    enum CodingKeys: String, CodingKey {
        case totalRegisterDebt = "total_register_debt"
        case paymentIdentifier = "payment_identifier"
        case totalBillDebt = "total_bill_debt"
        case otherAccountDebt = "other_account_debt"
        case paymentDeadLine = "payment_dead_line"
        case lastReadDate = "last_read_date"
        case lastGrossAmt = "last_gross_amt"
        case lastSaleYear = "last_sale_year"
        case lastSalePrd = "last_sale_prd"
        case adjustmentFactor = "adjustment_factor"
        case digitNumber = "digit_number"
        case meterModelFk = "meter_model_fk"
        case cityFk = "city_fk"
        case agentPhone = "agent_phone"
        case msgCode = "msg_code"
        case isPaid = "ispaid"
        case billIdentifier = "bill_identifier"
        case companyName = "company_name"
        case companyCode = "company_code"
        case phase = "phase"
        case voltageType = "voltage_type"
        case amper = "amper"
        case contractDemand = "contract_demand"
        case tarrifType = "tariff_type"
        case customerType = "customer_type"
        case nationalCode = "national_code"
        case customerName = "customer_name"
        case customerFamily = "customer_family"
        case telNum = "tel_number"
        case mobileNum = "mobile_number"
        case address = "service_add"
        case locationStatus = "location_status"
        case serialNum = "serial_number"
        case licenseExpireDate = "license_expire_date"
        case subscriptionCode = "subscription_id"
        case servicePostCode = "service_post_code"
        case fileSerialNumber = "file_serial_number"
        case lastupdatetime = "lastupdatetime"
        case billurl = "billurl"
    }

}

struct GasBillBranchInfoModel : Decodable {
    let billIdentifier: String?
    let paymentIdentifier: String?
    let paymentAmount: String?
    let paymentDeadline: String?
    let cityName: String?
    let unit: String?
    let domainCode: String?
    let buildingID: String?
    let serialNum: String?
    let capacity: String?
    let kind: String?
    let prevDate: String?
    let currentDate: String?
    let prevValue: String?
    let currentValue: String?
    let standardConsuption: String?
    let gasPriceValue: String?
    let abonmanValue: String?
    let tax: String?
    let assurance: String?
    let miscCostValue: String?
    let notMovingAmount: String?
    let movingAmount: String?
    let notPaidBills: String?
    let sequenceNumber: String?
    let prevRounding: String?
    let currentRounding: String?
    let villageTax: String?

    enum CodingKeys: String, CodingKey {
        case billIdentifier = "bill_identifier"
        case paymentIdentifier = "payment_identifier"
        case paymentAmount = "payment_amount"
        case paymentDeadline = "payment_dead_line"
        case cityName = "city_name"
        case unit = "unit"
        case domainCode = "domain_code"
        case buildingID = "building_id"
        case serialNum = "serial_no"
        case capacity = "capacity"
        case kind = "kind"
        case prevDate = "prev_date"
        case currentDate = "curr_date"
        case prevValue = "prev_value"
        case currentValue = "curr_value"
        case standardConsuption = "standard_consuption"
        case gasPriceValue = "gas_price_value"
        case abonmanValue = "abonnman_value"
        case tax = "tax"
        case assurance = "assurance"
        case miscCostValue = "misc_cost_value"
        case notMovingAmount = "not_moving_amount"
        case movingAmount = "moving_amount"
        case notPaidBills = "not_payed_bills"
        case sequenceNumber = "sequence_number"
        case prevRounding = "prev_rounding"
        case currentRounding = "curr_rounding"
        case villageTax = "village_tax"
    }

}
