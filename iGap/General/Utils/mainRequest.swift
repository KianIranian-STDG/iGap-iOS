//
//  mainRequest.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/8/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


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
