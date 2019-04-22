//
//  IGRequestWallet.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

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
        //            SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
    })
}
func extractTokenFromAccessToken(token : String) -> String {
    let desString = token
    let quote: Character = "."
    
    let tmpBase64Token: Substring = desString
        .drop(while: { $0 != quote }).dropFirst() // Drop everything until the first "
        .prefix(while: { $0 != quote }).dropLast() // Take until the next "
    let base64Token : String = String(tmpBase64Token)
    let base64TokenData : Data = Data(base64Token.utf8)
    print(base64Token)
    return base64Token
}
func getUserIDFrmToken(token : String) -> String {

let auth = WS_SecurityManager()
    let tmpUserId : String = auth.getSSOId()
    print(tmpUserId)
    SMUserManager.accountId = tmpUserId
    return tmpUserId
}
class IGRequestWalletGetAccessToken : IGRequest {
    
    class func sendRequest(){
        IGRequestWalletGetAccessToken.Generator.generate().success({ (protoResponse) in
            
            if let response = protoResponse as? IGPWalletGetAccessTokenResponse {
                    let keychain = KeychainSwift()
                keychain.set(response.igpAccessToken ?? "", forKey: "accesstoken")
                keychain.set("bearer" ?? "", forKey: "tokentype")
                keychain.set(nil ?? "", forKey: "refreshtoken")

                print("||||||||||||||||||||||||| \n")
                print("\n")
                print(response.igpAccessToken)
                print("\n")
                print("||||||||||||||||||||||||| \n")
                let securitymanager = WS_SecurityManager()
                let auth = WS_main()
                securitymanager.setJWT(response.igpAccessToken)
//                getUserIDFrmToken(token: response.igpAccessToken)
                let tmpBase64Token : String =  extractTokenFromAccessToken(token: response.igpAccessToken)
                getUserIDFrmToken(token: tmpBase64Token)

                securitymanager.setTokenType("bearer")
                
                callCards()
                SMUserManager.getUserProfileFromServer()


                SMUserManager.saveDataToKeyChain()
            }
            
            
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
            var requestRegister = IGPWalletRegister()
           
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
        print(data)
        return String(data: data, encoding: .utf8)
    }
}
