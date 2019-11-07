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

struct IGStructInqueryBill: Decodable {
    var data : InqueryDataStruct?
    var status: Int?
    var message: String?
}

struct InqueryDataStruct: Decodable {
    var billIdentifier: String?
    var paymentIdentifier: String?
    var totalBillDebt : String?
    var paymentDeadLine : String?
    
    enum CodingKeys: String, CodingKey {
        
        case billIdentifier = "bill_identifier"
        case paymentIdentifier = "payment_identifier"
        case totalBillDebt = "total_bill_debt"
        case paymentDeadLine = "payment_dead_line"
        
    }
}



