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

struct IGStructCompany: Decodable {
    var data : [companyStruct]?
}

struct companyStruct: Decodable {
    
    var _id: String?
    var code: Int?
    var title : String?
    
    enum CodingKeys: String, CodingKey {
        
        case _id = "_id"
        case code = "code"
        case title = "title"
        
    }
}



