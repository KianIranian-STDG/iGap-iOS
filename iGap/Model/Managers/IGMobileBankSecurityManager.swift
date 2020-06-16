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
