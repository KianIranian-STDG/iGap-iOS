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
import AVFoundation
import CoreBluetooth

private let sharedManager = IGCallAudioManager.init()

class IGCallAudioManager {
    
    private static var audioSession: AVAudioSession?
    var isSpeakerEnable = false
    var blutoothDevice: String?
    
    class var sharedInstance : IGCallAudioManager {
        return sharedManager
    }
    
    class var sharedAudioInstance : AVAudioSession {
        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()
        }
        return audioSession!
    }
    
    init() {
        // TODO - fetch current audio state
    }
    
    public func setSpeaker(button: UIButton) {
        do {
            try IGCallAudioManager.sharedAudioInstance.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            button.setTitle("", for: UIControlState.normal)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    public func manageAudioState(viewController: UIViewController){
        var deviceAction = UIAlertAction()
        var headphonesExist = false
        
        let audioSession = AVAudioSession.sharedInstance()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let currentRoute = audioSession.currentRoute
        for input in audioSession.availableInputs!{
            if input.portType == AVAudioSessionPortBluetoothA2DP || input.portType == AVAudioSessionPortBluetoothHFP || input.portType == AVAudioSessionPortBluetoothLE{
                let localAction = UIAlertAction(title: input.portName, style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    do {
                        try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                    } catch let error as NSError {
                        print("audioSession error turning off speaker: \(error.localizedDescription)")
                    }
                    
                    do {
                        try audioSession.setPreferredInput(input)
                    }catch _ {
                        print("cannot set mic ")
                    }
                })
                
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSessionPortBluetoothA2DP {
                        localAction.setValue(true, forKey: "checked")
                        break
                    }else if description.portType == AVAudioSessionPortBluetoothHFP {
                        localAction.setValue(true, forKey: "checked")
                        break
                    }else if description.portType == AVAudioSessionPortBluetoothLE{
                        localAction.setValue(true, forKey: "checked")
                        break
                    }
                }
                localAction.setValue(UIImage(named:"bluetooth.png"), forKey: "image")
                optionMenu.addAction(localAction)
                
            } else if input.portType == AVAudioSessionPortBuiltInMic || input.portType == AVAudioSessionPortBuiltInReceiver  {
                
                deviceAction = UIAlertAction(title: "iPhone", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    do {
                        try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                    } catch let error as NSError {
                        print("audioSession error turning off speaker: \(error.localizedDescription)")
                    }
                    
                    do {
                        try audioSession.setPreferredInput(input)
                    } catch _ {
                        print("cannot set mic ")
                    }
                })
                
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSessionPortBuiltInMic || description.portType  == AVAudioSessionPortBuiltInReceiver {
                        deviceAction.setValue(true, forKey: "checked")
                        break
                    }
                }
                
            } else if input.portType == AVAudioSessionPortHeadphones || input.portType == AVAudioSessionPortHeadsetMic {
                headphonesExist = true
                let localAction = UIAlertAction(title: "Headphones", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    do {
                        try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                    } catch let error as NSError {
                        print("audioSession error turning off speaker: \(error.localizedDescription)")
                    }
                    
                    do {
                        try audioSession.setPreferredInput(input)
                    }catch _ {
                        print("cannot set mic ")
                    }
                })
                for description in currentRoute.outputs {
                    if description.portType == AVAudioSessionPortHeadphones {
                        localAction.setValue(true, forKey: "checked")
                        break
                    } else if description.portType == AVAudioSessionPortHeadsetMic {
                        localAction.setValue(true, forKey: "checked")
                        break
                    }
                }
                
                optionMenu.addAction(localAction)
            }
        }
        
        if !headphonesExist {
            optionMenu.addAction(deviceAction)
        }
        
        let speakerOutput = UIAlertAction(title: "Speaker", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch let error as NSError {
                print("audioSession error turning on speaker: \(error.localizedDescription)")
            }
        })
        for description in currentRoute.outputs {
            if description.portType == AVAudioSessionPortBuiltInSpeaker{
                speakerOutput.setValue(true, forKey: "checked")
                break
            }
        }
        speakerOutput.setValue(UIImage(named:"speaker.png"), forKey: "image")
        optionMenu.addAction(speakerOutput)
        
        let cancelAction = UIAlertAction(title: "Hide", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(cancelAction)
        viewController.present(optionMenu, animated: true, completion: nil)
    }
}
