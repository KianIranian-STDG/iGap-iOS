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
import SnapKit

class VoiceCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewHeight: NSLayoutConstraint!
    
    var txtVoiceTime: UILabel!
    var sliderVoice: UISlider!
    
    var btnPlayPosition: Constraint!
    
    private var player = IGMusicPlayer.sharedPlayer
    
    class func nib() -> UINib {
        return UINib(nibName: "VoiceCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        removeVoiceView()
        makeVoiceView(message)
        super.setMessage(message, room: room, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        manageVoiceViewPosition()
        setVoice()
        voiceGustureRecognizers()
        checkPlayerState()
    }
    
    private func initializeView(){
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
        mainBubbleViewHeightAbs = mainBubbleViewHeight
    }
    
    private func makeVoiceView(_ message: IGRoomMessage){
        
        var finalMessage = message
        if let forward = message.forwardedFrom {
            finalMessage = forward
        }
        /* TODO - saeed : this method is exist in abstract message, don't call following method twice */
        if IGGlobal.isFileExist(path: finalMessage.attachment!.path(), fileSize: finalMessage.attachment!.size) {
            indicatorViewAbs?.isHidden = true
        } else {
            indicatorViewAbs?.isHidden = false
        }
        
        if txtVoiceTime == nil {
            txtVoiceTime = UILabel()
            txtVoiceTime.textColor = UIColor.dialogueBoxInfo()
            txtVoiceTime.font = UIFont.igFont(ofSize: 13)
            txtVoiceTime.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtVoiceTime)
        }
        
        if btnPlayAbs == nil {
            btnPlayAbs = UIButton()
            btnPlayAbs.titleLabel?.font = UIFont.iGapFonticon(ofSize: 50)
            btnPlayAbs.setTitleColor(UIColor.iGapBlue(), for: UIControl.State.normal)
            mainBubbleViewAbs.addSubview(btnPlayAbs)
        }
        
        if sliderVoice == nil {
            sliderVoice = UISlider()
            mainBubbleViewAbs.addSubview(sliderVoice)
        }
        
        if indicatorViewAbs == nil {
            indicatorViewAbs = IGProgress()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
        }
    }
    
    private func removeVoiceView(){
        if txtVoiceTime != nil {
            txtVoiceTime.removeFromSuperview()
            txtVoiceTime = nil
        }
        if btnPlayAbs != nil {
            btnPlayAbs.removeFromSuperview()
            btnPlayAbs = nil
        }
        if sliderVoice != nil {
            sliderVoice.removeFromSuperview()
            sliderVoice = nil
        }
    }
    
    private func manageVoiceViewPosition(){
        btnPlayAbs.snp.makeConstraints { (make) in
            
            if btnPlayPosition != nil { btnPlayPosition.deactivate() }
            
            if isForward {
                btnPlayPosition = make.top.equalTo(forwardViewAbs.snp.bottom).offset(5.0).constraint
            } else if isReply {
                btnPlayPosition = make.top.equalTo(replyViewAbs.snp.bottom).offset(5.0).constraint
            } else {
                btnPlayPosition = make.top.equalTo(mainBubbleViewAbs.snp.top).offset(5.0).constraint
            }
            
            if btnPlayPosition != nil { btnPlayPosition.activate() }
            
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(8)
            make.height.equalTo(50.0)
            make.width.equalTo(50.0)
        }
        
        indicatorViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(btnPlayAbs.snp.leading)
            make.trailing.equalTo(btnPlayAbs.snp.trailing)
            make.top.equalTo(btnPlayAbs.snp.top)
            make.bottom.equalTo(btnPlayAbs.snp.bottom)
        }
        
        txtVoiceTime.snp.makeConstraints { (make) in
            make.centerY.equalTo(txtTimeAbs.snp.centerY)
            make.leading.equalTo(sliderVoice.snp.leading)
            make.height.equalTo(15.0)
        }
        
        sliderVoice.snp.makeConstraints { (make) in
            make.leading.equalTo(btnPlayAbs.snp.trailing).offset(4.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-8.0)
            make.centerY.equalTo(btnPlayAbs.snp.centerY)
        }
    }
    
    private func setVoice(){
        
        let attachment: IGFile! = finalRoomMessage.attachment
        
        if isIncommingMessage {
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
            sliderVoice.minimumTrackTintColor = UIColor.organizationalColor()
            sliderVoice.maximumTrackTintColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            btnPlayAbs.setTitle("", for: UIControl.State.normal)
        } else {
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
            sliderVoice.minimumTrackTintColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            sliderVoice.maximumTrackTintColor = UIColor(red: 22.0/255.0, green: 91.0/255.0, blue: 88.0/255.0, alpha: 1.0)
            btnPlayAbs.setTitle("", for: UIControl.State.normal)
        }
        
        if self.attachment?.status != .ready {
            indicatorViewAbs.delegate = self
        }
        
        sliderVoice.setValue(0.0, animated: false)
        let timeM = Int(attachment.duration / 60)
        let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
        txtVoiceTime.text = "0:00 / \(timeM):\(timeS)".inLocalizedLanguage()
    }
    
    
    /****************************************************************************/
    /******************************* Voice Player *******************************/
    
    /** check current voice state and if is playing update values to current state */
    private func checkPlayerState(){
        IGPlayer.shared.startPlayer(btnPlayPause: btnPlayAbs, slider: sliderVoice, timer: txtVoiceTime, roomMessage: self.finalRoomMessage, justUpdate: true)
    }
    
    private func voiceGustureRecognizers() {
        let play = UITapGestureRecognizer(target: self, action: #selector(didTapOnPlay(_:)))
        btnPlayAbs?.addGestureRecognizer(play)
    }
    
    @objc func didTapOnPlay(_ gestureRecognizer: UITapGestureRecognizer) {
        IGPlayer.shared.startPlayer(btnPlayPause: btnPlayAbs, slider: sliderVoice, timer: txtVoiceTime, roomMessage: self.finalRoomMessage)
    }
}


