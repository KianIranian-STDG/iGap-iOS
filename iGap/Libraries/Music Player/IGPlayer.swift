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
import MediaPlayer
import SwiftEventBus

class IGPlayer {
    
    static let shared = IGPlayer()
    
    var btnPlayPause: UIButton!
    var slider: UISlider!
    var timer: UILabel!
    var flag: Bool = false
    var roomMessage: IGRoomMessage?
    var attachment: IGFile?
    var attachmentStringTime: String!
    var attachmentFloatTime: Float!
    var attachmentTimeScale: CMTimeScale!
    
    private var player = IGMusicPlayer.sharedPlayer
    private var playerWatcherIndex = 0
    private var latestTimeValue: String?
    private var latestSliderValue: Float?
    private var latestButtonValue: String!
    private var singerName : String! = "UNKNOWN_ARTIST".MessageViewlocalizedNew
    private var songName : String! = "VOICES_MESSAGE".MessageViewlocalizedNew
    private var songTime : Float! = 0
    var currentTimeOfSong : Float! = 0

    /**
     * @param attachment media info for make player session
     * @param justUpdate if set true player view will be update with current state otherwise will be started new player with attachment param
     */
    func startPlayer(btnPlayPause: UIButton, slider: UISlider, timer: UILabel, roomMessage: IGRoomMessage, justUpdate: Bool = false){

        if justUpdate {
            if self.roomMessage?.id == roomMessage.id {
                btnPlayPause.setTitle(latestButtonValue, for: UIControl.State.normal)
                slider.value = latestSliderValue ?? 0
                timer.text = latestTimeValue
                
                self.btnPlayPause = btnPlayPause
                self.slider = slider
                self.slider.maximumValue = attachmentFloatTime
                self.timer = timer
                self.removeGestureRecognizer()
                self.addGestureRecognizer()
            }
        } else {
            /* if is new file reset previous if exist reset otherwise manage play/pause for current player */
            if self.roomMessage?.id != roomMessage.id {
                self.resetOldSession()
                self.btnPlayPause = btnPlayPause
                self.slider = slider
                self.timer = timer
                self.roomMessage = roomMessage
                self.attachment = roomMessage.getFinalMessage().attachment
                self.addGestureRecognizer()
                self.fetchAttachmentTime()
                self.slider.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
                slider.value = 0.0
                latestSliderValue = 0.0
                slider.maximumValue = attachmentFloatTime
                playerWatcherIndex = player.addWatcher(self)
                self.playMedia()
            } else {
                self.didTapOnbtnPlayPause(btnPlayPause)
            }
        }

    }
    
    /** if another voice or audio is playing remove old valus and reset slider and timer */
    private func resetOldSession(){
        if btnPlayPause != nil {
            self.latestButtonValue = ""
            self.btnPlayPause.setTitle("", for: UIControl.State.normal) // play icon
            self.slider.value = 0.0
            latestSliderValue = 0.0
            updateTimer(currentTime: Float(0))
            if player.checkPlayerControlStatus() { // is playing
                self.pauseMedia()

            }
            self.player.removeItemsFromList()
            
            removeGestureRecognizer()
        }
    }

    private func fetchAttachmentTime(){
        let path = attachment!.path()
        let asset = AVURLAsset(url: path!)
        let playerItem = AVPlayerItem(asset: asset)
        let timeScale = playerItem.asset.duration.timescale
        let time = (CMTimeGetSeconds(asset.duration))
        let timeInt = Int(time)
        songTime = Float(time)
        let remainingSeconds = timeInt%60
        let remainingMiuntes = timeInt/60
        //fetching song metadata
        let metadataList = playerItem.asset.commonMetadata as! [AVMetadataItem]
        var hasSingerName : Bool = false
        var hasSongName : Bool = false
        if IGGlobal.isVoice {
            
                songName = "VOICES_MESSAGE".MessageViewlocalizedNew
            if roomMessage?.authorUser != nil {
                singerName = roomMessage?.authorUser?.user?.displayName
            }
            

        } else {
            for item in metadataList {
                if item.commonKey!.rawValue == "title" {
                    songName = item.stringValue!
                    hasSongName = true
                    print("SONG NAME:",songName)
                }
                if item.commonKey!.rawValue == "artist" {
                    singerName = item.stringValue!
                    hasSingerName = true
                    print("SINGER NAME:",singerName)

                }
            }
            if !hasSingerName {
                singerName = "UNKNOWN_ARTIST".MessageViewlocalizedNew
            }
            if !hasSongName {
                songName = "VOICES_MESSAGE".MessageViewlocalizedNew
            }
            print("BEFORE BEFORE FINAL SONG SINGER NAME",singerName)
            print("BEFORE BEFORE FINAL SONG SONG NAME",songName)

        }

        //end
        attachmentStringTime = "\(remainingMiuntes):\(remainingSeconds)"
        attachmentFloatTime = Float(time)
        attachmentTimeScale = timeScale
    }
    
    private func updateTimer(currentTime: Float){
        let valueInt = Int(currentTime)
        let remainingSeconds = valueInt%60
        let remainingMiuntes = valueInt/60
        let finalValue = "\(remainingMiuntes):\(remainingSeconds) / \(attachmentStringTime ?? "00:00")"
        timer.text = finalValue
        latestTimeValue = finalValue
    }
    
    private func updateSliderValue() {
        if flag == false {
            slider.isContinuous = true
            let currentTime = player.getCurrentTime()
            let currentTimeFloat = (CMTimeGetSeconds(currentTime))
            let currentValue = Float(currentTimeFloat)
            SwiftEventBus.post(EventBusManager.updateMediaTimer,sender: currentValue)

            if currentValue <=  slider.maximumValue {
                slider.setValue(Float(currentTimeFloat),animated: true)
                updateTimer(currentTime: Float((CMTimeGetSeconds(currentTime))))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateSliderValue()
                }
            }
            
            //Hint: sometimes value of 'currentValue' is nan after reach to end of media
            if currentValue >= slider.maximumValue || currentValue.isNaN {
                self.slider.value = 0.0
                latestSliderValue = 0.0
                IGGlobal.songState = .ended
                self.didTapOnbtnPlayPause(btnPlayPause)
                self.player.removeItemsFromList()
            }
        }
    }
    
    private func sliderValueChanged() {
        latestSliderValue = slider.value
        player.seekToTime(value: CMTimeMakeWithSeconds(Float64(slider.value), preferredTimescale: attachmentTimeScale))
        flag = false
        updateSliderValue()
    }
    
    private func playMedia(){
        if let file = attachment {
            IGGlobal.songState = .playing
            let files = [file]
            self.latestButtonValue = ""
            btnPlayPause.setTitle("", for: UIControl.State.normal) // pause icon
            player.play(index: 0, from: files)
            flag = false
            updateSliderValue()
            if !(IGGlobal.isAlreadyOpen) {
                SwiftEventBus.post(EventBusManager.showTopMusicPlayer,sender: MusicFile(songName: songName, singerName: singerName, songTime: songTime, currentTime: 0.0))
                IGGlobal.isAlreadyOpen = !IGGlobal.isAlreadyOpen
            }
        }
    }
    
    private func pauseMedia(){
        IGGlobal.songState = .paused
        self.latestButtonValue = ""
        btnPlayPause.setTitle("", for: UIControl.State.normal) // play icon
        player.pause()
        flag = true
    }
    func stopMedia(){
        IGGlobal.songState = .ended
        self.latestButtonValue = ""
        btnPlayPause.setTitle("", for: UIControl.State.normal) // play icon
        player.removeItemsFromList()
        flag = false
    }
    func pauseMusic(){
        IGGlobal.songState = .paused
        self.latestButtonValue = ""
        btnPlayPause.setTitle("", for: UIControl.State.normal) // play icon
        player.pause()
        flag = true

    }
    func playMusic(){
        if let file = attachment {
            IGGlobal.songState = .playing
            let files = [file]
            self.latestButtonValue = ""
            btnPlayPause.setTitle("", for: UIControl.State.normal) // pause icon
            player.play(index: 0, from: files)
            flag = false
            updateSliderValue()


        }
    }

    private func addGestureRecognizer(){
        slider.addTarget(self, action: #selector(sliderTouchUpInside(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUpOutside(_:)), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    private func removeGestureRecognizer(){
        slider.removeTarget(self, action: #selector(sliderTouchUpInside(_:)), for: .touchUpInside)
        slider.removeTarget(self, action: #selector(sliderTouchUpOutside(_:)), for: .touchUpOutside)
        slider.removeTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        slider.removeTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    
    /*************************************************************************/
    /**************************** Gesture Manager ****************************/
    
    @objc func sliderTouchUpInside(_ sender: UISlider) {
        sliderValueChanged()
    }
    @objc func sliderTouchUpOutside(_ sender: UISlider) {
        sliderValueChanged()
    }
    @objc func sliderTouchDown(_ sender: UISlider) {
        flag = true
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        flag = true
        latestSliderValue = slider.value
        updateTimer(currentTime: slider.value)
    }

    
    @objc func didTapOnbtnPlayPause(_ sender: UIButton) {
        let isPlaying = player.checkPlayerControlStatus()
        if isPlaying {
            self.pauseMedia()
            SwiftEventBus.post(EventBusManager.changePlayState,sender: false)

        } else {
            self.playMedia()
            SwiftEventBus.post(EventBusManager.changePlayState,sender: true)
        }
    }
}

extension IGPlayer:IGMusicPlayerDelegate {
    func player(_ player:IGMusicPlayer, didStartPlaying item:AVPlayerItem) {
        
    }
    
    func player(_ player:IGMusicPlayer, didPausePlaying item:AVPlayerItem) {
        
    }
    
    func player(_ player:IGMusicPlayer, didStopPlaying item:AVPlayerItem) {
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalAVMetadataKey(_ input: AVMetadataKey?) -> String? {
    guard let input = input else { return nil }
    return input.rawValue
}
