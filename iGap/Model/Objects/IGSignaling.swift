/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGSignaling: Object {
    
    var voiceCalling:          Bool                  = true
    var videoCalling:          Bool                  = true
    var secretChat:            Bool                  = true
    var screenSharing:         Bool                  = true
    var iceServer = List<IGIceServer>()
    
    
    convenience init(signalingConfiguration: IGPSignalingGetConfigurationResponse) {
        self.init()
        
        self.voiceCalling = signalingConfiguration.igpVoiceCalling
        self.videoCalling = signalingConfiguration.igpVideoCalling
        self.secretChat = signalingConfiguration.igpSecretChat
        self.screenSharing = signalingConfiguration.igpScreenSharing
        
        for iceServer in signalingConfiguration.igpIceServer {
            self.iceServer.append(IGIceServer(iceServer: iceServer))
        }
    }
}

class IGIceServer: Object {
    
    var url        = ""
    var credential = ""
    var username   = ""

    convenience init(iceServer: IGPSignalingGetConfigurationResponse.IGPIceServer) {
        self.init()
        self.url = iceServer.igpURL
        self.credential = iceServer.igpCredential
        self.username = iceServer.igpUsername
    }
}



