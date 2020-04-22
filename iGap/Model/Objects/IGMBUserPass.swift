//
//  IGMBUserPass.swift
//  iGap
//
//  Created by ahmad mohammadi on 4/21/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGMBUserPass {
    
    var username: String
    var password: String

    init(username: String, password:String) {
        self.username = username
        self.password = password
    }
    
    func json() -> Data? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(UserPass(username: username, password: password))
            return data
        } catch {
            return nil
        }
    }
    
}


fileprivate struct UserPass: Codable {
    
    var username: String
    var password: String
    
}
