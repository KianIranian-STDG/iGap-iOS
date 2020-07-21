//
//  IGStructUpload.swift
//  iGap
//
//  Created by ahmad mohammadi on 6/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

struct InitUploadStream: Decodable {
    
    var name: String?
    var size: UInt64?
    var token: String?
    var roomId: String?
    var fileExtension: String?
    
    enum CodingKeys: String, CodingKey {
        case name, size, token
        case roomId = "room_id"
        case fileExtension = "extension"
    }
    
}

struct ResumeUploadStream: Decodable {
    
    var name: String?
    var size: Int64?
    var token: String?
    var roomId: String?
    var fileExtension: String?
    var uploadedSize: UInt64?
    var fileId: String?
    
    enum CodingKeys: String, CodingKey {
        case name, size, token
        case roomId = "room_id"
        case fileExtension = "extension"
        case uploadedSize = "uploaded_size"
        case fileId = "file_id"
    }
    
}
