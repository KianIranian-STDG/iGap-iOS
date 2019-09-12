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
        var type: String?
        var value: Int?
        var subType: String?
        
        enum CodingKeys: String, CodingKey {
            case type, value
            case subType = "sub_type"
        }
    }
    
    var category: Category?
    var id: String?
}

struct IGStructInternetPackage: Decodable {
    struct package: Decodable {
        var type: String?
        var cost: Int?
        var description: String?
        var traffic: String?
        var duration: String?
    }

    var data: [package]?
    var id: String?
}
