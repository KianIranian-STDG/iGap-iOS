//
//  IGMobileBankSecurityManager.swift
//  iGap
//
//  Created by ahmad mohammadi on 4/21/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import SwiftyRSA

class IGMobileBankSecurityManager {
    
    static func encrypt(publicKey: String, str: Data) -> String {
        var encryptedMsg : String = ""
        do {
            let publicKey = try PublicKey(pemEncoded: publicKey)
            let clear = ClearMessage(data: str)
            let encrypted = try clear.encrypted(with: publicKey, padding: .OAEP)
            encryptedMsg = encrypted.base64String
        } catch  {
            print(error)
        }
        return encryptedMsg
    }
    
}
