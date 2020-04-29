//
//  IGMBLoginResponse.swift
//  iGap
//
//  Created by ahmad mohammadi on 4/21/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGMBUser: Codable {
    
    static let current = IGMBUser()
    
    var first_name = String()
    var last_name = String()
    
    enum CodingKeys: String, CodingKey {
        case first_name = ""
    }
    
}
