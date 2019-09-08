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

import Alamofire
import Gloss

class Request {
}
extension Dictionary {
    
    func convertToJson() -> String{
        
        var Json : String!
        let dictionary = self
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: []) {
            let theJSONText = String(data: theJSONData,encoding: .utf8)
            Json = theJSONText
        }
        return Json
        
    }
    
}
