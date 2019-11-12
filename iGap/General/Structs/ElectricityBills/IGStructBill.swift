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

struct IGStructBill: Decodable {
    var data : BillStruct?
    var status: Int?
    var message: String?
    var traceno : String?
}

struct BillStruct: Decodable {
    var email: String?
    var billData : [billObject]
    enum CodingKeys: String, CodingKey {
        
        case email = "email"
        case billData = "billdata"

    }
}
struct billObject: Decodable {
    var billIdentifier: String?
    var billTitle: String?
    var viaSMS : Bool?
    var viaEMAIL : Bool?
    var viaAP : Bool?
    var viaPRINT : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case billIdentifier = "bill_identifier"
        case billTitle = "billtitle"
        case viaSMS = "viasms"
        case viaEMAIL = "viaemail"
        case viaAP = "viaap"
        case viaPRINT = "viaprint"

        
    }
}



