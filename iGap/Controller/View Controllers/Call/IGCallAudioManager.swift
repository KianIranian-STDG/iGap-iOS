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
import AVFoundation
import CoreBluetooth

private let sharedManager = IGCallAudioManager.init()

class IGCallAudioManager {
    
    private static var audioSession: AVAudioSession?
    var isSpeakerEnable = false
    var blutoothDevice: String?
    var btnAudioState: UIButton?
    
    class var sharedInstance : IGCallAudioManager {
        return sharedManager
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonRaw.uintValue)
            else { fatalError("Strange... could not get routeChange")
        }
        
        if reason == .oldDeviceUnavailable || reason == .newDeviceAvailable {
            if btnAudioState != nil {
                fetchAudioState(btnAudioState: btnAudioState!)
            }
        }
    }
    
    public func setSpeaker(button: UIButton) {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            button.setTitle("", for: UIControl.State.normal)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    private func setAudioCategory(){
        if #available(iOS 10.0, *) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode :AVAudioSession.Mode(rawValue: convertFromAVAudioSessionMode(AVAudioSession.Mode.voiceChat)))
            } catch {
                print("error AVAudioSessionModeVideoChat")
            }
        }
    }
    
    private func setVideoCategory(){
        if #available(iOS 10.0, *) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode :AVAudioSession.Mode(rawValue: convertFromAVAudioSessionMode(AVAudioSession.Mode.videoChat)))
            } catch {
                print("error AVAudioSessionModeVideoChat")
            }
        }
    }
    
    public func manageAudioState(viewController: UIViewController, btnAudioState: UIButton){
        self.btnAudioState = btnAudioState
        var deviceAction = UIAlertAction()
        var headphonesExist = false
        
        let audioSession = AVAudioSession.sharedInstance()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let currentRoute = audioSession.currentRoute
        for input in audioSession.availableInputs!{
            if convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothA2DP) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothLE){
                let localAction = UIAlertAction(title: input.portName, style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    do {
                        self.setAudioCategory()
                        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        btnAudioState.setTitle("", for: UIControl.State.normal)
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
                    if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothA2DP) {
                        localAction.setValue(true, forKey: "checked")
                        btnAudioState.setTitle("", for: UIControl.State.normal)
                        break
                    }else if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP) {
                        localAction.setValue(true, forKey: "checked")
                        btnAudioState.setTitle("", for: UIControl.State.normal)
                        break
                    }else if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothLE){
                        localAction.setValue(true, forKey: "checked")
                        btnAudioState.setTitle("", for: UIControl.State.normal)
                        break
                    }
                }
                localAction.setValue(UIImage(named:"bluetooth.png"), forKey: "image")
                optionMenu.addAction(localAction)
                
            } else if convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInMic) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInReceiver)  {
                
                deviceAction = UIAlertAction(title: "iPhone", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    do {
                        self.setAudioCategory()
                        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        btnAudioState.setTitle("", for: UIControl.State.normal)
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
                    if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInMic) || convertFromAVAudioSessionPort(description.portType)  == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInReceiver) {
                        deviceAction.setValue(true, forKey: "checked")
                        btnAudioState.setTitle("", for: UIControl.State.normal)
                        break
                    }
                }
                
            } else if convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headphones) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headsetMic) {
                headphonesExist = true
                let localAction = UIAlertAction(title: "Headphones", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    do {
                        self.setAudioCategory()
                        try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        btnAudioState.setTitle("", for: UIControl.State.normal)
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
                    if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headphones) {
                        localAction.setValue(true, forKey: "checked")
                        btnAudioState.setTitle("", for: UIControl.State.normal)
                        break
                    } else if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headsetMic) {
                        localAction.setValue(true, forKey: "checked")
                        btnAudioState.setTitle("", for: UIControl.State.normal)
                        break
                    }
                }
                
                optionMenu.addAction(localAction)
            }
        }
        
        if !headphonesExist {
            optionMenu.addAction(deviceAction)
        }
        
        let speakerOutput = UIAlertAction(title: "Speaker", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            do {
                self.setVideoCategory()
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                btnAudioState.setTitle("", for: UIControl.State.normal)
            } catch let error as NSError {
                print("audioSession error turning on speaker: \(error.localizedDescription)")
            }
        })
        for description in currentRoute.outputs {
            if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInSpeaker){
                speakerOutput.setValue(true, forKey: "checked")
                btnAudioState.setTitle("", for: UIControl.State.normal)
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
    
    public func fetchAudioState(btnAudioState: UIButton){
        DispatchQueue.main.async {
            self.btnAudioState = btnAudioState
            btnAudioState.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
            let audioSession = AVAudioSession.sharedInstance()
            let currentRoute = audioSession.currentRoute
            for input in audioSession.availableInputs!{
                if convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothA2DP) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothLE){
                    
                    for description in currentRoute.outputs {
                        if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothA2DP) {
                            btnAudioState.setTitle("", for: UIControl.State.normal)
                            break
                        }else if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP) {
                            btnAudioState.setTitle("", for: UIControl.State.normal)
                            break
                        }else if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothLE){
                            btnAudioState.setTitle("", for: UIControl.State.normal)
                            break
                        }
                    }
                    
                } else if convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInMic) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInReceiver)  {
                    
                    for description in currentRoute.outputs {
                        if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInMic) || convertFromAVAudioSessionPort(description.portType)  == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInReceiver) {
                            btnAudioState.setTitle("", for: UIControl.State.normal)
                            break
                        }
                    }
                    
                } else if convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headphones) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headsetMic) {
                    for description in currentRoute.outputs {
                        if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headphones) {
                            btnAudioState.setTitle("", for: UIControl.State.normal)
                            break
                        } else if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headsetMic) {
                            btnAudioState.setTitle("", for: UIControl.State.normal)
                            break
                        }
                    }
                }
            }
            
            for description in currentRoute.outputs {
                if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.builtInSpeaker){
                    btnAudioState.setTitle("", for: UIControl.State.normal)
                    break
                }
            }
        }
    }
    
    public func hasBluetoothDevice() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        for input in audioSession.availableInputs!{
            if convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothA2DP) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP) || convertFromAVAudioSessionPort(input.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothLE){
                for description in currentRoute.outputs {
                    if convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothA2DP) || convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP) || convertFromAVAudioSessionPort(description.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothLE){
                        return true
                    }
                }
            }
        }
        return false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionMode(_ input: AVAudioSession.Mode) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionPort(_ input: AVAudioSession.Port) -> String {
	return input.rawValue
}
