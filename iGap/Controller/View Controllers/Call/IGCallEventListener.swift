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
import CoreTelephony
import IGProtoBuff

class IGCallEventListener {
    static let sharedManager = IGCallEventListener()
    internal static var callState: String = CTCallStateDisconnected
    internal static var playHoldSound: Bool = true // allow to play sound when receive another call
    private static let callCenter = CTCallCenter()
    private static var player: AVAudioPlayer?

    init() {
        IGCallEventListener.callCenter.callEventHandler = { (call:CTCall!) in
            IGCallEventListener.callState = call.callState
            
            if call.callState == CTCallStateIncoming {
                if let connectionState = IGCall.staticConnectionState {
                    if IGCall.callTypeStatic == .voiceCalling && connectionState == .Connected {
                        IGCallEventListener.playHoldSound = true
                        IGCallEventListener.playSound(sound: "tone")
                    }
                }
            } else if call.callState == CTCallStateConnected {
                IGCallEventListener.playHoldSound = false
                if IGCall.callTypeStatic == .videoCalling {
                    self.sendSessionHold(isOnHold: true)
                }
            } else if call.callState == CTCallStateDisconnected {
                IGCallEventListener.playHoldSound = false
                if IGCall.callTypeStatic == .videoCalling {
                    self.sendSessionHold(isOnHold: false)
                }
            }
        }
    }
    
    static func playSound(sound: String) {
        
        if !IGCallEventListener.playHoldSound { return }
        
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            
            IGCallEventListener.player = try AVAudioPlayer(contentsOf: url)
            guard let player = IGCallEventListener.player else { return }
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            IGCallEventListener.playSound(sound: "tone")
            IGCallEventListener.playHoldSound = false
        }
    }
    
    private func sendSessionHold(isOnHold: Bool){
        IGSignalingSessionHoldRequest.Generator.generate(isOnHold: isOnHold).success ({ (responseProtoMessage) in }).error({ (errorCode, waitTime) in }).send()
    }
}
