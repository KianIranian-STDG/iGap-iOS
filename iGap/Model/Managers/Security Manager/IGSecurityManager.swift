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

enum IGCipherMethod {
    case AES
}

class IGSecurityManager: NSObject {
    static let sharedManager = IGSecurityManager()
    
    public var symmetricKey                = ""
    private var encryptedSymmetricKeyData   = Data()
    private var publicKey             : String    = ""
    private var embeddedPublicKey     : String    = "-----BEGIN PUBLIC KEY-----\n" +
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo+inlAfd8Qior8IMKaJ+\n" +
        "BREJcEc9J9RhHgh6g/LvHKsnMaiEbAL70jQBQTLpCRu5Cnpj20+isOi++Wtf/pIP\n" +
        "FdJbD/1H+5jS+ja0RA6unp93DnBuYZ2JjV60vF3Ynj6F4Vr1ts5Xg5dJlEaOcOO2\n" +
        "YzOU97ZGP0ozrXIT5S+Y0BC4M9ieQmlGREzt3UZlTBbyUYPS4mMFh88YcT3QTiTA\n" +
        "k897qlJLxkYxVyAgwAD/0ihmWEkBQe9IxwVT/x5/QbixGSl4Zvd+5d+9sTZcSZQS\n" +
        "iJInT4E6DcmgAVYu5jFMWJDTEuurOQZ1W4nbmGyoY1bZXaFoiMPfzy72VIddkoHg\n" +
        "mwIDAQAB\n" +
    "-----END PUBLIC KEY-----"
    private var encryptionMethod      : String    = ""
    private var symmetricIVSize       : Int       = 0
    private var encryptoinKeySize     : Int       = 128
    private var encryptoinPaddingType : CryptoSwift.Padding = Padding.pkcs7
    
    private override init() {
        super.init()
    }
    
    func setConnecitonPublicKey(_ publicKey :String) {
        self.publicKey = removeSpecialCharacters(pemString: publicKey)
    }
    
    func generateEncryptedSymmetricKeyData(length :Int,secondaryChunkSize:Int) -> Data {
        encryptedSymmetricKeyData = Data()
        symmetricKey = IGGlobal.randomString(length: length)
        do {
            let symmetricKeyData = symmetricKey.data(using: .utf8)
            var encSymmetricKeyData = try encrypt(rawData: symmetricKeyData!) //SwiftyRSA.encryptData(symmetricKeyData!, publicKeyPEM: publicKey)
            let publicKey = try PublicKey(pemEncoded: embeddedPublicKey)
            
            while(0<encSymmetricKeyData.count){
                let chunk = encSymmetricKeyData.subdata(in: 0..<secondaryChunkSize)
                let clear = ClearMessageLocal(data: chunk)
                let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
                encryptedSymmetricKeyData.append(contentsOf: encrypted.data)
                encSymmetricKeyData = encSymmetricKeyData.subdata(in: secondaryChunkSize..<encSymmetricKeyData.count)
            }
        } catch  {
            print(error)
        }
        return encryptedSymmetricKeyData
    }
    
    func setSymmetricIVSize(_ size: Int) {
        symmetricIVSize = size
    }
    
    func setEncryptionMethod(_ method: String) {
        var methodSections = method.components(separatedBy: "-")
        encryptoinKeySize = Int(methodSections[1])!
        encryptionMethod = methodSections[2]
    }
    
    func setEncryptionBlockMode(iv: Array<UInt8>) -> BlockMode {
        var encryptoinBlockMode: BlockMode!
        switch encryptionMethod {
        case "ECB":
            encryptoinBlockMode = ECB()
        case "CBC":
            encryptoinBlockMode = CBC(iv: iv)
        case "PCBC":
            encryptoinBlockMode = PCBC(iv: iv)
        case "CFB":
            encryptoinBlockMode = CFB(iv: iv)
        case "OFB":
            encryptoinBlockMode = OFB(iv: iv)
        case "CTR":
            encryptoinBlockMode = CTR(iv: iv)
        default:
            encryptoinBlockMode = CBC(iv: iv)
        }
        return encryptoinBlockMode
    }
    
    func encryptAndAddIV(payload :Data, addIv: Bool = true) -> Data {
        var encryptedData :Data
        var IVBytes :Data
        var encryptedPayload : Data
        do {
            IVBytes = generateIV()
            encryptedPayload = try encrypt(rawData: payload, iv: IVBytes)
        } catch  {
            return Data()
        }
        
        if addIv {
            encryptedData = IVBytes
            encryptedData.append(encryptedPayload)
            
            return encryptedData
        } else {
            return encryptedPayload
        }
    }
    
    func encryptAndAddIV(payload :Data, iv:Data, addIv: Bool = true) -> Data {
        var encryptedData :Data
        var IVBytes :Data
        var encryptedPayload : Data
        do {
            IVBytes = iv
            print("=-=-=-=-=-=-=-")
            print(IVBytes.bytes)
            print("=-=-=-=-=-=--=-")
            encryptedPayload = try encrypt(rawData: payload, iv: IVBytes)
        } catch  {
            return Data()
        }
        
        if addIv {
            encryptedData = IVBytes
            encryptedData.append(encryptedPayload)
            
            return encryptedData
        } else {
            return encryptedPayload
        }
    }
    
    func decrypt(encryptedData :Data) -> Data! {
        var decryptedData = Data()
        do {
            decryptedData = try decryptUsingAES(encryptedData: encryptedData)
            return decryptedData
        } catch  {
            return  nil
        }
    }
    func getIVAndKey(encryptedData :Data) -> [String: Data] {
        var keyIV = [String: Data]()
        let convertedData = NSData(data: encryptedData)
        let iv =  convertedData.subdata(with: NSMakeRange(0, symmetricIVSize))
        let keyData = symmetricKey.data(using: .utf8)!
        let encryptedPayload = convertedData.subdata(with: NSMakeRange(symmetricIVSize, convertedData.length-symmetricIVSize))

        keyIV["key"] = keyData
        keyIV["iv"] = iv
        keyIV["firstchunk"] = encryptedPayload

        return keyIV
    }
    func TEMPdecrypt(encryptedData :Data) -> Data! {
        var decryptedData = Data()
        do {
            decryptedData = try TEMPdecryptUsingAES(encryptedData: encryptedData)
            return decryptedData
        } catch  {
            return  nil
        }
    }
    
    //MARK: private functions
    
    
    private func removeSpecialCharacters(pemString : String) -> String {
        return pemString.replacingOccurrences(of: "\r", with: "")
    }
    
    private func encrypt(rawData :Data) throws -> Data {
        let publicKey = try PublicKey(pemEncoded: self.publicKey)
        let clear = ClearMessageLocal(data: rawData)
        let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
        return encrypted.data
    }
    
    private func encrypt(rawData :Data, iv: Data) throws -> Data {
        let keyData = symmetricKey.data(using: .utf8)!
        let aes = try AES(key: [UInt8](keyData), blockMode: setEncryptionBlockMode(iv: [UInt8](iv)), padding: encryptoinPaddingType)
        let ciphered = try aes.encrypt(Array(rawData))
        return Data(ciphered)
    }
    
    func generateEncryptor(iv: String) throws -> Cryptor & Updatable {
        return try AES(key: symmetricKey, iv: iv).makeEncryptor()
    }
    
    func generateIV() -> Data {
        let IVData = IGGlobal.randomString(length: symmetricIVSize).data(using: .utf8)!
        return IVData
    }
    
    func generateIVString() -> String {
        let IVData = IGGlobal.randomString(length: 16)
        return IVData
    }
    
    private func decryptUsingAES(encryptedData :Data) throws -> Data {
        let convertedData = NSData(data: encryptedData)
        let iv =  convertedData.subdata(with: NSMakeRange(0, symmetricIVSize))
        let encryptedPayload = convertedData.subdata(with: NSMakeRange(symmetricIVSize, convertedData.length-symmetricIVSize))
        
        let keyData = symmetricKey.data(using: .utf8)!
        let aes = try AES(key: [UInt8](keyData), blockMode: setEncryptionBlockMode(iv: [UInt8](iv)), padding: encryptoinPaddingType)
        
        let deciphered = try aes.decrypt(Array(encryptedPayload))
        return Data(deciphered)
    }
    
    private func TEMPdecryptUsingAES(encryptedData :Data) throws -> Data {
        let convertedData = NSData(data: encryptedData)
        let iv =  Data("5183666c72eec9e4".utf8)
        let keyData = Data("bf3c199c2470cb477d907b1e0917c17b".utf8)
        let aes = try AES(key: [UInt8](keyData), blockMode: setEncryptionBlockMode(iv: [UInt8](iv)), padding: encryptoinPaddingType)
        
        let deciphered = try aes.decrypt(Array(encryptedData))
        return Data(deciphered)
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
}
