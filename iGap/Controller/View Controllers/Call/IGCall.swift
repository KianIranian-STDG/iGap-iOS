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
import RealmSwift
import AVFoundation
import IGProtoBuff
import SnapKit
import WebRTC

class IGCall: UIViewController, CallStateObserver, ReturnToCallObserver, VideoCallObserver {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var viewTransparent: UIView!
    @IBOutlet weak var txtiGap: UILabel!
    @IBOutlet weak var txtCallerName: UILabel!
    @IBOutlet weak var txtCallState: UILabel!
    @IBOutlet weak var txtCallTime: UILabel!
    @IBOutlet weak var btnAnswer: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnSpeaker: UIButton!
    @IBOutlet weak var btnSwitchCamera: UIButton!
    @IBOutlet weak var localCameraView: RTCEAGLVideoView!
    @IBOutlet weak var remoteCameraView: RTCEAGLVideoView!
    
    let SWITCH_CAMERA_DELAY : Int64 = 3000
    
    var userId: Int64!
    var isIncommingCall: Bool!
    var callSdp: String?
    var callType: IGPSignalingOffer.IGPType = .voiceCalling

    private var remoteTrack: RTCVideoTrack!
    private var room: IGRoom!
    private var isSpeakerEnable = false
    private var isMuteEnable = false
    private var callIsConnected = false
    private var callTimer: Timer!
    private var recordedTime: Int = 0
    private var player: AVAudioPlayer?
    private var remoteTrackAdded: Bool = false
    private var latestSwitchCamera: Int64 = IGGlobal.getCurrentMillis()
    
    internal static var callStateStatic: String!
    internal static var sendLeaveRequest = true
    internal static var callPageIsEnable = false // this varibale will be used for detect that call page is enable or no. connection state of call isn't important now!
    internal static var staticReturnToCall: ReturnToCallObserver!

    /************************************************/
    /***************** User Actions *****************/
    /************************************************/
    
    @IBAction func btnAnswer(_ sender: UIButton) {
        stopSound()
        txtCallState.text = "Communicating..."
        RTCClient.getInstance()?.answerCall()
        manageView(stateAnswer: false)
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        RTCClient.getInstance()?.sendLeaveCall()
        self.playSound(sound: "igap_disconnect")
        self.dismmis()
    }
    
    @IBAction func btnMute(_ sender: UIButton) {
        if isMuteEnable {
            btnMute.setTitle("", for: UIControlState.normal)
        } else {
            btnMute.setTitle("", for: UIControlState.normal)
        }
        muteCall(mute: isMuteEnable)
        isMuteEnable = !isMuteEnable
    }
    
    @IBAction func btnSwitchCamera(_ sender: UIButton) {
        DispatchQueue.main.async {
            let currentTimeMillis = IGGlobal.getCurrentMillis()
            if currentTimeMillis - self.SWITCH_CAMERA_DELAY > self.latestSwitchCamera {
                self.latestSwitchCamera = currentTimeMillis
                RTCClient.getInstance(justReturn: true)?.switchCamera()
            }
        }
    }
    
    @IBAction func btnChat(_ sender: UIButton) {
        IGRecentsTableViewController.needGetInfo = false
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "chatRoom.peer.id = %lld", userId)
        if let roomInfo = realm.objects(IGRoom.self).filter(predicate).first {
            room = roomInfo
            performSegue(withIdentifier: "showRoomMessages", sender: self)
        } else {
            IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                        IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        self.room = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                        self.performSegue(withIdentifier: "showRoomMessages", sender: self)
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoomMessages" {
            let navigationController = segue.destination as! IGNavigationController
            let messageViewController = navigationController.topViewController as! IGMessageViewController
            messageViewController.room = room
            messageViewController.customizeBackItem = true
        }
    }
    
    @IBAction func btnSpeaker(_ sender: UIButton) {
        if isSpeakerEnable {
            speakerState(state: AVAudioSessionPortOverride.none)
        } else {
            speakerState(state: AVAudioSessionPortOverride.speaker)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IGCall.staticReturnToCall = self
        IGCall.callPageIsEnable = true
        
        localCameraViewCustomize()
        buttonViewCustomize(button: btnAnswer, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0), imgName: "IG_Tabbar_Call_On")
        buttonViewCustomize(button: btnCancel, color: UIColor.red, imgName: "IG_Nav_Bar_Plus")
        buttonViewCustomize(button: btnMute, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 0.2), imgName: "IG_Tabbar_Call_On")
        buttonViewCustomize(button: btnChat, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 0.2), imgName: "")
        buttonViewCustomize(button: btnSpeaker, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 0.2), imgName: "")
        buttonViewCustomize(button: btnSwitchCamera, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 0.2), imgName: "")
        
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", userId)
        guard let userRegisteredInfo = realm.objects(IGRegisteredUser.self).filter(predicate).first else {
            return
        }
        txtCallerName.text = userRegisteredInfo.displayName
        txtCallState.text = "Communicating..."
        
        setCallMode(callType: callType, userInfo: userRegisteredInfo)
        
        RTCClient.getInstance()?
            .initCallStateObserver(stateDelegate: self)
            .initVideoCallObserver(videoDelegate: self)
            .setCallType(callType: callType)
        
        
        manageView(stateAnswer: isIncommingCall)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.isIncommingCall {
                self.incommingCall()
            } else {
                self.outgoingCall()
            }
        }
    }
    
    private func localCameraViewCustomize(){
        localCameraView.layer.cornerRadius = 10
        localCameraView.layer.borderWidth = 0.3
        localCameraView.layer.borderColor = UIColor.white.cgColor
        localCameraView.layer.masksToBounds = true
    }
    
    private func buttonViewCustomize(button: UIButton, color: UIColor, imgName: String = ""){

        //button.removeUnderline()
        button.backgroundColor = color
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius = 0.1
        button.layer.shadowOpacity = 0.1
        
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.masksToBounds = false
        button.layer.cornerRadius = button.frame.width / 2
    }
    
    private func incommingCall() {
        
        guard let connection = RTCClient.getInstance() else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.incommingCall()
            }
            return
        }
        
        if connection.getPeerConnection() == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                RTCClient.getInstance()?.configure()
                self.incommingCall()
            }
            return
        }
        
        connection.startConnection(onPrepareConnection: { () -> Void in
            connection.sendRinging()
            connection.createAnswerForOfferReceived(withRemoteSDP: self.callSdp)
            guard let delegate = RTCClient.getInstance()?.callStateDelegate else {
                return
            }
            delegate.onStateChange(state: RTCClientConnectionState.IncommingCall)
        })
    }
    
    private func outgoingCall() {
        RTCClient.getInstance()?.callStateDelegate.onStateChange(state: RTCClientConnectionState.Dialing)
        RTCClient.getInstance()?.startConnection(onPrepareConnection: { () -> Void in
            RTCClient.getInstance()?.makeOffer(userId: self.userId)
        })
    }
    
    private func setCallMode(callType: IGPSignalingOffer.IGPType, userInfo: IGRegisteredUser){
        
        if callType == .videoCalling {
            remoteCameraView.isHidden = false
            localCameraView.isHidden = false
            imgAvatar.isHidden = true
            btnSwitchCamera.isEnabled = true
            speakerState(state: AVAudioSessionPortOverride.speaker)
            
        } else if callType == .voiceCalling {
            remoteCameraView.isHidden = true
            localCameraView.isHidden = true
            imgAvatar.isHidden = false
            btnSwitchCamera.isEnabled = false
            btnSwitchCamera.setTitle("", for: UIControlState.normal)
            
            if let avatar = userInfo.avatar {
                setImageMain(avatar: avatar)
            }
        }
    }
    
    private func manageView(stateAnswer: Bool){
        if stateAnswer {
            btnMute.isHidden = true
            btnSpeaker.isHidden = true
            btnChat.isHidden = true
            btnSwitchCamera.isHidden = true
            txtCallTime.isHidden = true

        } else {
            btnMute.isHidden = false
            btnSpeaker.isHidden = false
            btnChat.isHidden = false
            btnSwitchCamera.isHidden = false
            txtCallTime.isHidden = false
            btnAnswer.isHidden = true
            txtCallTime.isHidden = true
            
            btnCancel.snp.updateConstraints { (make) in
                make.bottom.equalTo(btnChat.snp.top).offset(-54)
                make.width.equalTo(70)
                make.height.equalTo(70)
                make.centerX.equalTo(self.view.snp.centerX)
            }
        }
    }
    
    private func enabelActions(enable: Bool = true){
        if enable {
            btnMute.isEnabled = true
            btnSpeaker.isEnabled = true
            btnChat.isEnabled = true
            btnSwitchCamera.isEnabled = true
        } else {
            btnMute.isEnabled = false
            btnSpeaker.isEnabled = false
            btnChat.isEnabled = false
            btnSwitchCamera.isEnabled = false
        }
    }
    
    private func addRemoteVideoTrack(){
        guard let remote = self.remoteTrack else {
            return
        }
        
        if remoteTrackAdded { return }
        remoteTrackAdded = true
        
        DispatchQueue.main.async {
            if self.remoteCameraView == nil {
                let videoView = RTCEAGLVideoView(frame: self.view.bounds)
                if let local = self.localCameraView {
                    self.view.insertSubview(videoView, belowSubview: local)
                } else {
                    self.view.addSubview(videoView)
                }
                self.remoteCameraView = videoView
            }
            remote.add(self.remoteCameraView!)
        }
    }
    
    private func speakerState(state: AVAudioSessionPortOverride){
        if state == .none {
            btnSpeaker.setTitle("", for: UIControlState.normal)
            isSpeakerEnable = false
        } else {
            btnSpeaker.setTitle("", for: UIControlState.normal)
            isSpeakerEnable = true
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.overrideOutputAudioPort(state)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    private func muteCall(mute: Bool){
        for audioTrack in RTCClient.mediaStream.audioTracks {
            audioTrack.isEnabled = mute
        }
    }
    
    func onRemoteVideoCallStream(videoTrack: RTCVideoTrack) {
        self.remoteTrack = videoTrack
        if callIsConnected {
            addRemoteVideoTrack()
        }
    }
    
    func onLocalVideoCallStream(videoTrack: RTCVideoTrack) {
        DispatchQueue.main.async {
            if self.localCameraView == nil {
                let videoView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width:100, height: 100))
                self.view.addSubview(videoView)
                self.localCameraView = videoView
            }
            videoTrack.add(self.self.localCameraView!)
        }
    }
    
    func onStateChange(state: RTCClientConnectionState) {
        
        DispatchQueue.main.async {
            switch state {
                
            case .Connecting:
                RTCClient.needNewInstance = false
                break
                
            case .Connected:
                self.addRemoteVideoTrack()
                
                self.txtCallTime.isHidden = false
                self.txtCallState.text = "Connected"
                
                if !self.callIsConnected {
                    self.callIsConnected = true
                    self.playSound(sound: "igap_connect")
                }
                
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try audioSession.setActive(true)
                    if self.callType == .videoCalling && self.isSpeakerEnable {
                        try audioSession.overrideOutputAudioPort(.speaker)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                if self.callTimer == nil {
                    self.callTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
                    self.callTimer?.fire()
                }
                break
                
            case .Finished, .Disconnected:
                self.txtCallState.text = "Disconnected"
                self.playSound(sound: "igap_disconnect")
                self.dismmis()
                RTCClient.getInstance(justReturn: true)?.callStateDelegate = nil
                break
                
            case .Missed:
                self.txtCallState.text = "Missed"
                self.dismmis()
                break
                
            case .NotAnswered:
                self.txtCallState.text = "NotAnswered"
                self.playSound(sound: "igap_noresponse")
                self.dismmis()
                break
                
            case .Rejected:
                self.txtCallState.text = "Rejected"
                self.playSound(sound: "igap_disconnect")
                self.dismmis()
                break
                
            case .TooLong:
                self.txtCallState.text = "TooLong"
                self.playSound(sound: "igap_disconnect")
                self.dismmis()
                break
                
            case .Failed:
                self.txtCallState.text = "Failed"
                self.playSound(sound: "igap_noresponse")
                self.dismmis()
                break
                
            case .Unavailable:
                self.txtCallState.text = "Unavailable"
                self.playSound(sound: "igap_noresponse")
                self.dismmis()
                break
                
            case .IncommingCall:
                self.txtCallState.text = "IncommingCall..."
                self.playSound(sound: "tone", repeatEnable: true)
                break
                
            case .Ringing:
                self.txtCallState.text = "Ringing..."
                self.playSound(sound: "igap_ringing", repeatEnable: true)
                break
                
            case .Dialing:
                self.txtCallState.text = "Dialing..."
                self.playSound(sound: "igap_signaling", repeatEnable: true)
                break
                
            case .signalingOfferForbiddenYouAreTalkingWithYourOtherDevices:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "You Are Talking With Your Other Devices", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenTheUserIsInConversation:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "The User Is In Conversation", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenDialedNumberIsNotActive:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "Dialed Number Is Not Active", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenUserIsBlocked:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "User Is Blocked", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenIsNotAllowedToCommunicate:
                self.playSound(sound: "igap_disconnect")
                let alert = UIAlertController(title: "Signaling Forbidden", message: "Is Not Allowed To Communicate", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            default:
                break
            }
        }
    }
    
    func returnToCall() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateTimerLabel() {
        recordedTime += 1
        let minute = String(format: "%02d", Int(recordedTime/60))
        let seconds = String(format: "%02d", Int(recordedTime%60))
        self.txtCallTime.text = minute + ":" + seconds
    }
    
    private func dismmis() {
        RTCClient.getInstance(justReturn: true)?.disconnect()
        IGCall.callPageIsEnable = false
        callIsConnected = false
        
        if let timer = callTimer {
            timer.invalidate()
        }
        
        if IGCall.sendLeaveRequest {
            IGCall.sendLeaveRequest = false
            sendLeaveCall()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.getLatestCallLog()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stopSound()
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func sendLeaveCall(){
        IGSignalingLeaveRequest.Generator.generate().success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.sendLeaveCall()
                break
            default:
                break
            }
        }).send()
    }
    
    private func getLatestCallLog(){
        IGSignalingGetLogRequest.Generator.generate(offset: Int32(0), limit: 1).success { (responseProtoMessage) in
            
            if let logResponse = responseProtoMessage as? IGPSignalingGetLogResponse {
               let _ = IGSignalingGetLogRequest.Handler.interpret(response: logResponse)
            }
            
            }.error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.getLatestCallLog()
                    break
                default:
                    break
                }
            }).send()
    }
    
    
    func playSound(sound: String, repeatEnable: Bool = false) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        
            stopSound()
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            if repeatEnable {
                player.numberOfLoops = -1
            }
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound(){
        if player != nil {
            player?.stop()
        }
    }
    
    func setImageMain(avatar: IGAvatar) {
        if let originalFile = avatar.file {
            do {
                if originalFile.attachedImage != nil {
                    imgAvatar.image = originalFile.attachedImage
                } else {
                    var image: UIImage?
                    let path = originalFile.path()
                    if FileManager.default.fileExists(atPath: path!.path) {
                        image = UIImage(contentsOfFile: path!.path)
                    }
                    
                    if image != nil {
                        self.imgAvatar.image = image
                        self.viewTransparent.isHidden = false
                    } else {
                        throw NSError(domain: "asa", code: 1234, userInfo: nil)
                    }
                }
            } catch {
                IGDownloadManager.sharedManager.download(file: originalFile, previewType:.originalFile, completion: { (attachment) -> Void in
                    DispatchQueue.main.async {
                        let path = originalFile.path()
                        if let data = try? Data(contentsOf: path!) {
                            if let image = UIImage(data: data) {
                                self.viewTransparent.isHidden = false
                                self.imgAvatar.image = image
                            }
                        }
                    }
                }, failure: {
                    
                })
            }
        }
    }
}
