/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation

struct IGStructBranchingInfo: Decodable {
    var data : BranchingDataStruct?
    var status: Int?
    var message: String?
}

struct BranchingDataStruct: Decodable {
    
    var billIdentifier: String?
    var paymentIdentifier: String?
    var companyCode : Int?
    var companyName : String?
    var phase : String?
    var voltageType : String?
    var tarifType : String?
    var customerType: String?
    var customerName : String?
    var customerFamilyName : String?
    var telNumber : String?
    var mobileNumber : String?
    var customerAddress : String?
    var customerPostalCode : String?
    var customerLoactionType : String?
    var deviceSerialNumber : String?
    var paymentDeadLine : String?
    var lastReadDate : String?
    var demandPower : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case billIdentifier = "bill_identifier"
        case paymentIdentifier = "payment_identifier"
        case companyCode = "company_code"
        case companyName = "company_name"
        case phase = "phase"
        case voltageType = "voltage_type"
        case tarifType = "tariff_type"
        case customerType = "customer_type"
        case customerName = "customer_name"
        case customerFamilyName = "customer_family"
        case telNumber = "tel_number"
        case mobileNumber = "mobile_number"
        case customerAddress = "service_add"
        case customerPostalCode = "service_post_code"
        case customerLoactionType = "location_status"
        case deviceSerialNumber = "serial_number"
        case paymentDeadLine = "payment_dead_line"
        case lastReadDate = "last_read_date"
        case demandPower = "contract_demand"

    }
}



