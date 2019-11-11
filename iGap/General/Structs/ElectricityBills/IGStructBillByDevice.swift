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

struct IGStructBillByDevice: Decodable {
    var data : [billByDeviceStruct]?
    var status: Int?
    var message: String?
}

struct billByDeviceStruct: Decodable {
    
    var billIdentifier: String?
    var customerFamily: String?
    var customerName : String?
    var serviceAdd : String?
    
    enum CodingKeys: String, CodingKey {
        
        case billIdentifier = "bill_identifier"
        case customerFamily = "customer_name"
        case customerName = "customer_family"
        case serviceAdd = "service_add"
        
    }
}



