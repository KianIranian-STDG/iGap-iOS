//
//  IGStructInternetPackage.swift
//  iGap
//
//  Created by MacBook Pro on 6/21/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

struct IGStructInternetCategory: Decodable {
    struct Category: Decodable {
        var type: Type?
        var value: Int?
        var subType: String?
        
        enum `Type`: String, Decodable {
            case traffic = "TRAFFIC"
            case duration = "DURATION"
        }
        
        enum CodingKeys: String, CodingKey {
            case type, value
            case subType = "sub_type"
        }
    }
    
    var category: Category?
    var id: String?
}





struct IGStructInternetPackageCategorized: Decodable {
    var data: [IGStructInternetPackage]?
    var id: String?
}

struct IGStructInternetPackage: Decodable {
    var type: String?
    var cost: Int?
    var description: String?
    var traffic: String?
    var duration: String?
}
