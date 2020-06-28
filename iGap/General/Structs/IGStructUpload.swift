//
//  IGStructUpload.swift
//  iGap
//
//  Created by ahmad mohammadi on 6/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

struct InitUpload: Decodable {
    
    var name: String?
    var size: Int64?
    var token: String?
    var roomId: String?
    var fileExtension: String?
    
    enum CodingKeys: String, CodingKey {
        case name, size, token
        case roomId = "room_id"
        case fileExtension = "extension"
    }
    
}
