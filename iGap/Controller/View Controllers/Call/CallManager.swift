/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import CallKit
import AVFoundation

@available(iOS 10.0, *)
private let sharedManager = CallManager.init()

protocol CallManagerDelegate : class {
    func callDidAnswer()
    func callDidEnd()
    func callDidHold(isOnHold : Bool)
    func callDidFail()
    func callDidMute(isMuted : Bool)
}

@available(iOS 10.0, *)
class CallManager: NSObject, CXProviderDelegate {
    
    var provider : CXProvider?
    var callController : CXCallController?
    var currentCall : UUID?
    
    weak var delegate : CallManagerDelegate?
    
    override init() {
        super.init()
        providerAndControllerSetup()
    }
    
    class var sharedInstance : CallManager {
        return sharedManager
    }
    
    func reportIncomingCallFor(uuid: UUID, phoneNumber: String) {
        let update = CXCallUpdate.init()
        update.remoteHandle = CXHandle.init(type: CXHandle.HandleType.phoneNumber, value: phoneNumber)
        weak var weakSelf = self
        provider!.reportNewIncomingCall(with: uuid, update: update, completion: { (error : Error?) in
            if error != nil {
                weakSelf?.delegate?.callDidFail()
            } else {
                weakSelf?.currentCall = uuid
            }
        })
    }
    
    func startCall(phoneNumber : String) {
        currentCall = UUID.init()
        if let unwrappedCurrentCall = currentCall {
            let handle = CXHandle.init(type: CXHandle.HandleType.phoneNumber, value: phoneNumber)
            let startCallAction = CXStartCallAction.init(call: unwrappedCurrentCall, handle: handle)
            let transaction = CXTransaction.init()
            transaction.addAction(startCallAction)
            requestTransaction(transaction: transaction)
        }
    }
    
    func endCall() {
        if let unwrappedCurrentCall = currentCall {
            let endCallAction = CXEndCallAction.init(call: unwrappedCurrentCall)
            let transaction = CXTransaction.init()
            transaction.addAction(endCallAction)
            requestTransaction(transaction: transaction)
        }
    }
    
    func holdCall(hold : Bool) {
        if let unwrappedCurrentCall = currentCall {
            let holdCallAction = CXSetHeldCallAction.init(call: unwrappedCurrentCall, onHold: hold)
            let transaction = CXTransaction.init()
            transaction.addAction(holdCallAction)
            requestTransaction(transaction: transaction)
        }
    }
    
    func requestTransaction(transaction : CXTransaction) {
        weak var weakSelf = self
        callController?.request(transaction, completion: { (error : Error?) in
            if error != nil {
                print(String(describing: error?.localizedDescription))
                weakSelf?.delegate?.callDidFail()
            }
        })
    }
    
    //MARK: - Setup
    func providerAndControllerSetup() {
        let configuration = CXProviderConfiguration.init(localizedName: "iGap")
        configuration.maximumCallsPerCallGroup = 1;
        configuration.supportedHandleTypes = [CXHandle.HandleType.phoneNumber]
        provider = CXProvider.init(configuration: configuration)
        provider?.setDelegate(self, queue: nil)
        callController = CXCallController.init()
    }
    
    //MARK : - CXProviderDelegate
    // Called when the provider has been fully created and is ready to send actions and receive updates
    func providerDidReset(_ provider: CXProvider) {}
    
    // If provider:executeTransaction:error: returned NO, each perform*CallAction method is called sequentially for each action in the transaction
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        //provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
        //provider.reportOutgoingCall(with: action.callUUID, connectedAt: nil)
        //action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        delegate?.callDidAnswer()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        currentCall = nil
        delegate?.callDidEnd()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        delegate?.callDidHold(isOnHold: action.isOnHold)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        delegate?.callDidMute(isMuted: action.isMuted)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {}
    
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {}
    
    // Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        // React to the action timeout if necessary, such as showing an error UI.
    }
    
    /*
    // Called when the provider's audio session activation state changes.
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
        print("CallKit || didActivate audioSession")
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // Restart any non-call related audio now that the app's audio session has been de-activated after having its priority restored to normal.
        print("CallKit || didDeactivate audioSession")
    }
    */
}
