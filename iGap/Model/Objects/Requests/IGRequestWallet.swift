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
import IGProtoBuff
import SwiftProtobuf
import KeychainSwift
import messages
import webservice
import KeychainSwift
func callCards() {
    
    SMCard.getAllCardsFromServer({ cards in
        if cards != nil{
            if (cards as? [SMCard]) != nil{
                if (cards as! [SMCard]).count > 0 {
                    
                    
                }
            }
        }
    }, onFailed: {err in
        //            SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
    })
}
func extractTokenFromAccessToken(token : String) -> String {
    let desString = token
    let quote: Character = "."
    
    let tmpBase64Token: Substring = desString
        .drop(while: { $0 != quote }).dropFirst() // Drop everything until the first "
        .prefix(while: { $0 != quote }).dropLast() // Take until the next "
    let base64Token : String = String(tmpBase64Token)
    return base64Token
}
func getUserIDFrmToken(token : String) -> String {

let auth = WS_SecurityManager()
    let tmpUserId : String = auth.getSSOId()
    SMUserManager.accountId = tmpUserId
    return tmpUserId
}
class IGRequestWalletGetAccessToken : IGRequest {
    
    class func sendRequest(){
//        IGRequestWalletGetAccessToken.Generator.generate().success({ (protoResponse) in
//            
//            if let response = protoResponse as? IGPWalletGetAccessTokenResponse {
//                    let keychain = KeychainSwift()
//                keychain.set(response.igpAccessToken , forKey: "accesstoken")
//                keychain.set("bearer" , forKey: "tokentype")
//                keychain.set(nil ?? "", forKey: "refreshtoken")
//
//                let securitymanager = WS_SecurityManager()
////                let auth = WS_main()
//                securitymanager.setJWT(response.igpAccessToken)
//                print(response.igpAccessToken)
//                getUserIDFrmToken(token: "1234")
////                getUserIDFrmToken(token: response.igpAccessToken)
//                let _ : String =  extractTokenFromAccessToken(token: response.igpAccessToken)
////                getUserIDFrmToken(token: tmpBase64Token)
//
//                securitymanager.setTokenType("bearer")
//                
//                callCards()
//                SMUserManager.getUserProfileFromServer()
//
//
//                SMUserManager.saveDataToKeyChain()
//            }
//            
//            
//        }).error ({ (errorCode, waitTime) in
//            switch errorCode {
//            case .timeout:
//                sendRequest()
//                break
//            default:
//                break
//            }
//        }).send()
    }

    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let requestGetAccessToken = IGPWalletGetAccessToken()
            return IGRequestWrapper(message: requestGetAccessToken, actionID: 9000)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPWalletGetAccessTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}
class IGRequestWalletPaymentInit : IGRequest {
    
    class func sendRequest(jwt: String,amount: Int64,userID: Int64,description: String,language: IGPLanguage){
        IGRequestWalletPaymentInit.Generator.generate(jwt: jwt,amount: amount,userID: userID,description: description,language: language).success({ (protoResponse) in
            if let response = protoResponse as? IGPWalletPaymentInitResponse {
                
                SMUserManager.publicKey = response.igpPublicKey
                SMUserManager.payToken = response.igpToken

            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                sendRequest(jwt: jwt,amount: amount,userID: userID,description: description,language: language)
            default:
                break
            }
        }).send()
    }
    
    class Generator : IGRequest.Generator{
        class func generate(jwt: String,amount: Int64,userID: Int64,description: String,language: IGPLanguage) -> IGRequestWrapper {
            var requestPaymentInit = IGPWalletPaymentInit()
            requestPaymentInit.igpJwt = jwt
            requestPaymentInit.igpAmount = amount
            requestPaymentInit.igpToUserID = userID
            requestPaymentInit.igpDescription = description
            requestPaymentInit.igpLanguage = language
            return IGRequestWrapper(message: requestPaymentInit, actionID: 9001)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPWalletPaymentInitResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}
class IGRequestWalletRegister : IGRequest {
    
    class func sendRequest(){
        IGRequestWalletRegister.Generator.generate().success({ (protoResponse) in
            
            IGRequestWalletGetAccessToken.sendRequest()
            
            
            
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                sendRequest()
                break
            default:
                break
            }
        }).send()
    }
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let requestRegister = IGPWalletRegister()
           
            return IGRequestWrapper(message: requestRegister, actionID: 9002)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPWalletPaymentInitResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}



extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
