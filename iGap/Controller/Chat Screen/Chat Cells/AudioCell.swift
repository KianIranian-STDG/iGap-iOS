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
import SwiftEventBus

class AudioCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var txtMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtMessage: ActiveLabel!
    
    var btnPlayPosition: Constraint!
    
    var txtAudioName: UILabel!
    var txtAudioTime: UILabel!
    var sliderAudio: UISlider!
    
    class func nib() -> UINib {
        return UINib(nibName: "AudioCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        makeAudioView()
        super.setMessage(message, room: room, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        manageAudioViewPosition()
        setAudio()
        voiceGustureRecognizers()
        checkPlayerState()
    }
    
    private func initializeView(){
        
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
        mainBubbleViewHeightAbs = mainBubbleViewHeight
        messageViewAbs = messageView
        
        /********** lable **********/
        txtMessageAbs = txtMessage
        
        /******** constraint ********/
        txtMessageHeightConstraintAbs = txtMessageHeightConstraint
    }
    
    
    /*
     * for this cell we need evaluate views before call setMessage because in setMessage indicatorViewAbs
     * will be managed for download/upload state so indicatorViewAbs should have a value and for evaluate
     * position of views after setMessage we call manageFileViewPosition because first we need evaluate
     * forwardViewAbs/replyViewAbs in AbstractCell
     */
    private func makeAudioView(){
        removeAudioView() //remove views for avoid from reuse seekbar and time
        
        if btnPlayAbs == nil {
            btnPlayAbs = UIButton()
            btnPlayAbs.titleLabel?.font = UIFont.iGapFonticon(ofSize: 55)
            btnPlayAbs.setTitleColor(UIColor.iGapBlue(), for: UIControl.State.normal)
            mainBubbleViewAbs.addSubview(btnPlayAbs)
        }
        
        if indicatorViewAbs == nil {
            indicatorViewAbs = IGProgress()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
        }
        
        if txtAudioName == nil {
            txtAudioName = UILabel()
            txtAudioName.textColor = UIColor.dialogueBoxInfo()
            txtAudioName.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
            txtAudioName.lineBreakMode = .byTruncatingMiddle
            txtAudioName.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtAudioName)
        }
        
        if sliderAudio == nil {
            sliderAudio = UISlider()
            mainBubbleViewAbs.addSubview(sliderAudio)
        }
        
        if txtAudioTime == nil {
            txtAudioTime = UILabel()
            txtAudioTime.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.regular)
            txtAudioTime.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtAudioTime)
        }
    }
    
    private func manageAudioViewPosition(){
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
           make.height.equalTo(56.0)
           make.width.equalTo(56.0)
       }
        
        indicatorViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(btnPlayAbs.snp.leading)
            make.trailing.equalTo(btnPlayAbs.snp.trailing)
            make.top.equalTo(btnPlayAbs.snp.top)
            make.bottom.equalTo(btnPlayAbs.snp.bottom)
        }
        
        txtAudioName.snp.makeConstraints { (make) in
            make.leading.equalTo(btnPlayAbs.snp.trailing).offset(4.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10.0)
            make.top.equalTo(btnPlayAbs.snp.top)
        }
        
        sliderAudio.snp.makeConstraints { (make) in
            make.leading.equalTo(btnPlayAbs.snp.trailing).offset(4.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-8.0)
            make.centerY.equalTo(btnPlayAbs.snp.centerY)
        }
        
        txtAudioTime.snp.makeConstraints { (make) in
            make.leading.equalTo(btnPlayAbs.snp.trailing).offset(4.0)
            make.bottom.equalTo(btnPlayAbs.snp.bottom)
            make.height.equalTo(15.0)
        }
    }
    
    private func removeAudioView(){
        txtAudioTime?.removeFromSuperview()
        txtAudioTime = nil
        
        btnPlayAbs?.removeFromSuperview()
        btnPlayAbs = nil
        
        sliderAudio?.removeFromSuperview()
        sliderAudio = nil
    }
    
    private func setAudio(){
        
        let attachment: IGFile! = finalRoomMessage.attachment
        if isIncommingMessage {
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
            btnPlayAbs.setTitle("", for: UIControl.State.normal)
        } else {
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
            btnPlayAbs.setTitle("", for: UIControl.State.normal)
        }
        
        if self.attachment?.status != .ready {
            indicatorViewAbs.layer.cornerRadius = 16.0
            indicatorViewAbs.layer.masksToBounds = true
            indicatorViewAbs.delegate = self
        }
        
        txtAudioName.text = attachment.name
        sliderAudio.setValue(0.0, animated: false)
        btnPlayAbs.layer.cornerRadius = 16.0
        btnPlayAbs.layer.masksToBounds = true
        
        let timeM = Int(attachment.duration / 60)
        let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
        txtAudioTime.text = "0:00 / \(timeM):\(timeS)"
    }
    
    /****************************************************************************/
    /******************************* Audio Player *******************************/
    
    /** check current voice state and if is playing update values to current state */
    private func checkPlayerState(){
        IGPlayer.shared.startPlayer(btnPlayPause: btnPlayAbs, slider: sliderAudio, timer: txtAudioTime, roomMessage: self.finalRoomMessage, justUpdate: true,room: self.room)
    }
    
    private func voiceGustureRecognizers() {
        let play = UITapGestureRecognizer(target: self, action: #selector(didTapOnPlay(_:)))
        btnPlayAbs?.addGestureRecognizer(play)
    }
    
    @objc func didTapOnPlay(_ gestureRecognizer: UITapGestureRecognizer) {
        IGGlobal.isVoice = false // determine the file is not voice and is music

        IGPlayer.shared.startPlayer(btnPlayPause: btnPlayAbs, slider: sliderAudio, timer: txtAudioTime, roomMessage: self.finalRoomMessage,room: self.room)
    }
}




