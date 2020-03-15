/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import SwiftyRSA
import CryptoSwift
import SwiftyJSON

class IGStickerSecurityManager: NSObject {
    static let shared = IGStickerSecurityManager()
    
    var publicKey: Data!
    var privateKey: Data!
    private let CRYPTO_BITS = 1024;
    
    private override init() {
        super.init()
        
        do {
            let (privateKey, publicKey) = try CC.RSA.generateKeyPair(CRYPTO_BITS)
            self.privateKey = privateKey
            self.publicKey = publicKey
        } catch let error {
            print(error)
        }
    }
    
    func getPublicKey() throws -> String {
        let publicKeyPEM = SwKeyConvert.PublicKey.derToPKCS8PEM(publicKey)
        return publicKeyPEM.replace("\n", withString: "\\n")
    }
    
    func decrypt(data: String) throws -> [String: Any]? {
        let encrypted = try EncryptedMessage(base64Encoded: data)
        let prKey = try PrivateKey(data: privateKey)
        let clear = try encrypted.decrypted(with: prKey, padding: .PKCS1)
        let decryptedData = try clear.string(encoding: .utf8)
        let jsonObject = try? JSONSerialization.jsonObject(with: decryptedData.data(using: String.Encoding.utf8)!, options: []) as? [String: Any]
        return jsonObject
    }
}
