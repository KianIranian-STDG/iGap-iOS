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

class IGStickerSecurityManager: NSObject {
    static let shared = IGStickerSecurityManager()
    
    var publicKey: PublicKey!
    var privateKey: PrivateKey!
    private let CRYPTO_BITS = 1024;
    private var encryptoinPaddingType : CryptoSwift.Padding = Padding.pkcs7
    private var embeddedPublicKey     : String    = "-----BEGIN PUBLIC KEY-----\n" +
           "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo+inlAfd8Qior8IMKaJ+\n" +
           "BREJcEc9J9RhHgh6g/LvHKsnMaiEbAL70jQBQTLpCRu5Cnpj20+isOi++Wtf/pIP\n" +
           "FdJbD/1H+5jS+ja0RA6unp93DnBuYZ2JjV60vF3Ynj6F4Vr1ts5Xg5dJlEaOcOO2\n" +
           "YzOU97ZGP0ozrXIT5S+Y0BC4M9ieQmlGREzt3UZlTBbyUYPS4mMFh88YcT3QTiTA\n" +
           "k897qlJLxkYxVyAgwAD/0ihmWEkBQe9IxwVT/x5/QbixGSl4Zvd+5d+9sTZcSZQS\n" +
           "iJInT4E6DcmgAVYu5jFMWJDTEuurOQZ1W4nbmGyoY1bZXaFoiMPfzy72VIddkoHg\n" +
           "mwIDAQAB\n" +
       "-----END PUBLIC KEY-----"
    
    private var publicKeyTest = "-----BEGIN PUBLIC KEY-----\n" +
    "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC6UNB3jaFbrMJOJB8XbQBxW3Q5\n" +
    "VYU9DfUinOIzCbdoOruW/+bBZ5A+dwC741QPnBChOLCXL29+EGyLa4oxGIVkqzKx\n" +
    "wCQPsVJaWCo6rOlcK9nT162kGEh0viEFrjE0iW8LwQd2FZulGv+LmyR+Dn1d1ECl\n" +
    "OZIbWEx2pQm32PkqIQIDAQABz\n" +
    "-----END PUBLIC KEY-----"
    
    private var publicKeyTest1 = "-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCw/wy/ZOStIDI63XgtceP8hWjutJKJI8ZsuBduIJdyvgx45ul/r0jPJ8B/Y9uS8ChNodLD/6Hh0fSpzk7x8cNkk60gXOLyN/13AdfJTDDiHJH2/14XarZ+NDv681ndiAeODPZc7ekCPb/btilip62oLd/saqEFZALhImIsCgiDUQIDAQAB-----END PUBLIC KEY-----"
     
    
    private override init() {
        super.init()
        
        do {
            let keyPair = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: CRYPTO_BITS)
            self.privateKey = keyPair.privateKey
            self.publicKey = keyPair.publicKey
        } catch let error {
            print(error)
        }
    }
    
    func getPublicKey() throws -> String {
        
        let (privateKey, publicKey) = try! CC.RSA.generateKeyPair(CRYPTO_BITS)
        let privateKeyPEM = try SwKeyConvert.PrivateKey.derToPKCS1PEM(privateKey)
        let publicKeyPEM = SwKeyConvert.PublicKey.derToPKCS8PEM(publicKey)
        return publicKeyPEM.replace("\n", withString: "\\n")
        print("PPP || Public Data")
//        var statusCode: OSStatus
//        var publicKey: SecKey?
//        var privateKey: SecKey?
//
//        //let publicKeyAttr: [NSObject: NSObject] = [kSecAttrIsPermanent:true, kSecAttrApplicationTag:"publicTag".dataUsingEncoding(NSUTF8StringEncoding)!]
//        //let privateKeyAttr: [NSObject: NSObject] = [kSecAttrIsPermanent:true, kSecAttrApplicationTag:"privateTag".dataUsingEncoding(NSUTF8StringEncoding)!]
//
//        var keyPairAttr = [NSObject: NSObject]()
//        keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
//        keyPairAttr[kSecAttrKeySizeInBits] = 1024 as NSObject
//        //keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr
//        //keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr
//
//        statusCode = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)
//
//        if statusCode == noErr && publicKey != nil && privateKey != nil {
//            print("NNN || Success")
//            print("Public Key: \(publicKey!)")
//            print("Private Key: \(privateKey!)")
//        } else {
//            print("NNN || Error")
//        }
//
//        //try PublicKey(reference: publicKey!)
//        return publicKeyTest1
        
//        KeyPairGenerator keygenerator;
//        keygenerator = KeyPairGenerator.getInstance("RSA");
//        keygenerator.initialize(4096);
//
//        KeyPair keypair = keygenerator.generateKeyPair();
//        PrivateKey privateKey = keypair.getPrivate().getEncoded();
//        PublicKey publicKey = keypair.getPublic().getEncoded();

        
        //let publicKey1 = try PublicKey(pemEncoded: embeddedPublicKey)
       // publicKey1.pemString()
        
//        let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
//        let privateKey = keyPair.privateKey
//        let publicKey = keyPair.publicKey
//
//
//        let pem = try publicKey.pemString()
//        let base64 = try publicKey.base64String()
//        let data = try publicKey.data()
//        let reference = publicKey.reference
//        let originalData = publicKey.originalData
        
        
        
//        let pub = try! PublicKey(pemEncoded: "pkcs1")
//        print("PPP || public pub.pemString() pkcs1 : \(try! pub.pemString())")
//
//        let pub2 = try! PublicKey(pemEncoded: "pkcs8")
//        print("PPP || public pub.pemString() pkcs8 : \(try! pub2.pemString())")
        
//        print("PPP || public: \(try! self.publicKey.pemString())")
//        print("PPP || public base64String: \(try! self.publicKey.base64String())")
//        print("PPP || public base64EncodedString: \(try! self.publicKey.data().base64EncodedString())")
//
//        print("PPP || ====================")
//        print("PPP || ====================")
//        print("PPP || ====================")
//
//
//        print("PPP || private: \(try! self.privateKey.pemString())")
//        print("PPP || private base64String: \(try! self.privateKey.base64String())")
//        let base64PublicKey = try self.publicKey.pemString().base64Encoded()
//        var pkcsPem = "-----BEGIN PUBLIC KEY-----\n";
//        pkcsPem = pkcsPem + base64PublicKey!
//        pkcsPem = pkcsPem + "-----END PUBLIC KEY-----";
//        return pkcsPem//.replace("\n", withString: "\\n")
        return ""
    }
    
    func dycrypt(data: String) throws -> String? {
        let aes = try AES(key: try self.privateKey.data().bytes, blockMode: ECB(), padding: encryptoinPaddingType)
        return String(bytes: try aes.decrypt(data.base64Decoded()!.bytes), encoding: .utf8)
    }
}
