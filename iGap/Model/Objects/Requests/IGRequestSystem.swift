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

class IGConnectionSecuringRequest : IGRequest {
    class Generator : IGRequest.Generator{
        
    }
    
    class Handler : IGRequest.Handler{
        override class func handle(responseProtoMessage: Message) {
            
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            let connectionSecuringResponseMessage = responseProtoMessage as! IGPConnectionSecuringResponse
            let sessionPublicKey = connectionSecuringResponseMessage.igpPublicKey
            let symmetricKeyLength = Int(connectionSecuringResponseMessage.igpSymmetricKeyLength)
            let secondaryChunkSize = Int(connectionSecuringResponseMessage.igpSecondaryChunkSize)
            
            IGSecurityManager.sharedManager.setConnecitonPublicKey(sessionPublicKey)
            IGWebSocketManager.sharedManager.connectionProblemTimerDelay = Double(connectionSecuringResponseMessage.igpHeartbeatInterval+5)
            
            let symmetricKey = IGSecurityManager.sharedManager.generateEncryptedSymmetricKeyData(length: symmetricKeyLength,secondaryChunkSize:secondaryChunkSize)
            IGConnectionSymmetricKeyRequest.sendRequest(symmetricKey: symmetricKey)
        }
    }
}

//MARK: -
class IGConnectionSymmetricKeyRequest : IGRequest {
    
    class func sendRequest(symmetricKey: Data) {
        IGConnectionSymmetricKeyRequest.Generator.generate(symmetricKey: symmetricKey).successPowerful({ (responseProto, requestWrapper) in
            IGConnectionSymmetricKeyRequest.Handler.interpret(response: responseProto)
        }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
            if errorCode == .timeout {
                self.sendRequest(symmetricKey: symmetricKey)
            }
        }).send()
    }
    
    class Generator : IGRequest.Generator {
        class func generate(symmetricKey: Data) -> IGRequestWrapper {
            var connectionSecuringResponseRequest = IGPConnectionSymmetricKey()
            connectionSecuringResponseRequest.igpSymmetricKey = symmetricKey
            connectionSecuringResponseRequest.igpVersion = 2
            return IGRequestWrapper(message: connectionSecuringResponseRequest, actionID: 2)
        }
    }
    
    class Handler : IGRequest.Handler {
        
        class func interpret(response responseProtoMessage: Message) {
            let symmetricKeyResponseMessage = responseProtoMessage as! IGPConnectionSymmetricKeyResponse
            if(symmetricKeyResponseMessage.igpSecurityIssue){
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Security Issue", message: "Securing the connection is not possible at the moment!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)

                }
            } else {
                //TODO: check if is accepted
                let symmetricIVSize = Int(symmetricKeyResponseMessage.igpSymmetricIvSize)
                let symmetricMethod = symmetricKeyResponseMessage.igpSymmetricMethod
                IGSecurityManager.sharedManager.setSymmetricIVSize(symmetricIVSize)
                IGSecurityManager.sharedManager.setEncryptionMethod(symmetricMethod)
                IGWebSocketManager.sharedManager.setConnectionSecure()
                IGAppManager.sharedManager.login()
            }
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            IGConnectionSymmetricKeyRequest.Handler.interpret(response: responseProtoMessage)
        }
    }
}

//MARK: -
class IGHeartBeatRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate() -> IGRequestWrapper {
            let heartbeatRequestMessage = IGPHeartbeat()
            return IGRequestWrapper(message: heartbeatRequestMessage, actionID: 3)
        }
    }
    
    class Handler : IGRequest.Handler{
        override class func handlePush(responseProtoMessage: Message) {
            let reqW = IGHeartBeatRequest.Generator.generate()
            IGRequestManager.sharedManager.addRequestIDAndSend(requestWrappers: reqW)
        }
    }
}

