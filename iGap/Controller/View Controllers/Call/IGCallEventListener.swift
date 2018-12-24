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
import CoreTelephony
import IGProtoBuff

class IGCallEventListener {
    static let sharedManager = IGCallEventListener()
    internal static var callState: String = CTCallStateDisconnected
    private static let callCenter = CTCallCenter()

    init() {
        IGCallEventListener.callCenter.callEventHandler = { (call:CTCall!) in
            IGCallEventListener.callState = call.callState
            print("CallKit || call.callState: \(call.callState)")
            
            if call.callState == CTCallStateConnected {
                if IGCall.callTypeStatic == .videoCalling {
                    self.sendSessionHold(isOnHold: true)
                }
            } else if call.callState == CTCallStateDisconnected {
                if IGCall.callTypeStatic == .videoCalling {
                    self.sendSessionHold(isOnHold: false)
                }
            }
        }
    }
    
    private func sendSessionHold(isOnHold: Bool){
        IGSignalingSessionHoldRequest.Generator.generate(isOnHold: isOnHold).success ({ (responseProtoMessage) in }).error({ (errorCode, waitTime) in }).send()
    }
}
