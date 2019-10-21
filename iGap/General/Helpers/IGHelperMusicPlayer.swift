/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff
import RealmSwift
import UIKit
import SwiftEventBus

// IMPORTANT TODO - convert current class to builder
class MusicFile: NSObject {
    var songName: String;
    var singerName: String;
    var songTime: Float;
    var currentTime: Float;

    init(songName: String,singerName: String,songTime: Float,currentTime: Float) {
        self.songName = songName
        self.singerName = singerName
        self.songTime = songTime
        self.currentTime = currentTime


    }
}

class IGHelperMusicPlayer {
    enum MusicCurrentState : Int {
        case Playing = 0
        case Stoped = 1
    }

    var progressBarTimer: Timer!
    private var isRunning = true
    var valueToAdd: Float! = 0.0
    var currentMusicTime: Float! = 0.0
    var musicTotalTime: Float! = 0

    private var actionClose: (() -> Void)?
    private var actionPlay: (() -> Void)?
    private var actionPause: (() -> Void)?
    private var actionNextMusic: (() -> Void)?
    private var actionPreviousMusic: (() -> Void)?
    private var actionShuffleMusics: (() -> Void)?
    private var actionRepeatMusics: (() -> Void)?
    private var actionChangeTime: (() -> Void)?

    static let shared = IGHelperMusicPlayer()
    var progressView : UIProgressView!
    var btnPlay : UIButton!
    var topView : UIView!
    var bgView : UIView!
    let window = UIApplication.shared.keyWindow
    
    private init() {}
    
    
    ///Top Music Player tobe shown  in Room List and Message page
    ///
    func showTopMusicPlayer(view: UIViewController? = nil,constraintView: UIView? = nil,constraintStackView: UIStackView? = nil, close: (() -> Void)? = nil, btnPlayPause: (() -> Void)? = nil,songTime : Float! = 0.0,singerName: String? = nil,songName: String? = nil) -> UIView {
        var alertView = view
        if alertView == nil {
            alertView = UIApplication.topViewController()
        }

        if self.bgView == nil {
            print("CHECK BGVIEW: isNIL")
        } else {
            print("CHECK BGVIEW: isNotNIL")

        }
        if self.bgView == nil {
 
                self.bgView = self.createMainView()

            
            ///add play pause button to it's superView
            let btn = UIButton()
            btnPlay = btn
            self.bgView.addSubview(btnPlay)
            self.createPausePlayButton(btn: btnPlay, view: self.bgView)
            let tapGestureRecognizerPlay = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnPlayPause))
            tapGestureRecognizerPlay.numberOfTapsRequired = 1
            tapGestureRecognizerPlay.numberOfTouchesRequired = 1
            btnPlay.addGestureRecognizer(tapGestureRecognizerPlay)

            ///add clsoe button to it's superView
            let CloseButton = UIButton()
            self.bgView.addSubview(CloseButton)
            self.createCloseButton(btn: CloseButton, view: self.bgView)
            let tapGestureRecognizerClose = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnClose))
            tapGestureRecognizerClose.numberOfTapsRequired = 1
            tapGestureRecognizerClose.numberOfTouchesRequired = 1
            CloseButton.addGestureRecognizer(tapGestureRecognizerClose)
            
            
            //labels
            let lblSinger = UILabel()
            let lblSong = UILabel()
            self.bgView.addSubview(lblSong)
            self.bgView.addSubview(lblSinger)
            lblSinger.text = singerName ?? "UNKNOWN_ARTIST".MessageViewlocalizedNew
            lblSong.text = songName ?? "VOICES_MESSAGE".MessageViewlocalizedNew
            
            musicTotalTime = songTime

            self.createLabelsInPlayer(songName: lblSong, singerName: lblSinger, view: self.bgView)
            self.actionClose = close
            
            
            
            
            ////borders
            let borderTop = UIView()///border Top
            let borderBottom = UIView()///border Bottom
            self.bgView.addSubview(borderTop)
            self.bgView.addSubview(borderBottom)

            self.creatBorders(topBorder: borderTop, bottomBorder: borderBottom, view: self.bgView)
            
            
            
            //progressView
            let pv = UIProgressView()
            progressView = pv
            self.bgView.addSubview(progressView)

            self.createProgressView(pv: progressView, view: self.bgView)
//            self.progressBarTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateProgressView), userInfo: nil, repeats: true)

            
            SwiftEventBus.onMainThread(self, name: EventBusManager.updateMediaTimer) { result in
                print(result?.object as! Float)
                self.updateProgressView(currentTime: result?.object as! Float)
            }

            return self.bgView
        } else {
            return self.bgView
        }
    }
    
    func removeTopPlayer() {
        SwiftEventBus.post(EventBusManager.hideTopMusicPlayer)
        self.isRunning = false
        if btnPlay != nil {
            btnPlay.setTitle("", for: .normal)
        }
        if progressView != nil {
            progressView.progress = 0.0
        }

        currentMusicTime = 0
        if self.bgView != nil {
            self.bgView.removeFromSuperview()
            for subview in self.bgView.subviews {
                subview.removeFromSuperview()
            }

            self.bgView = nil
            
            

        }
    }
    //MARK: - Development funcs

       @objc func didTapOnClose() {
           if self.actionClose != nil {
           actionClose!()
           } else {
               self.removeMainViewFromSuperView()
           }
       }
    @objc func didTapOnPlayPause() {
        if self.actionPlay != nil {
            UIView.transition(with: btnPlay,
                              duration: 0.3,
            options: .transitionFlipFromTop,
            animations: {
                if  !(IGGlobal.isPaused){
//                    SwiftEventBus.post(EventBusManager.stopMusicPlayer)
                    self.stopTimer()

                }  else {
//                    SwiftEventBus.post(EventBusManager.playMusicPlayer)
                    self.resumeTimer()

                }

            },
            completion: nil)
            IGGlobal.isPaused = !IGGlobal.isPaused

//        actionPlay!()
        } else {
//            actionPlay!()
            UIView.transition(with: btnPlay,
                              duration: 0.3,
            options: .transitionFlipFromTop,
            animations: {
                print(IGGlobal.isPaused)
                if  (IGGlobal.isPaused){
//                    SwiftEventBus.post(EventBusManager.stopMusicPlayer)
                    self.resumeTimer()

                }  else {
//                    SwiftEventBus.post(EventBusManager.playMusicPlayer)
                    self.stopTimer()
                    


                }
            },
            completion: nil)
            print(IGGlobal.isPaused)
            IGGlobal.isPaused = !IGGlobal.isPaused
            print(IGGlobal.isPaused)

        }
    }
    func updateProgressView(currentTime : Float!){
        IGGlobal.isPaused = false

        currentMusicTime = currentTime
        print("CURRENT TIME:",currentMusicTime!,(musicTotalTime))
        let percent = ((currentMusicTime * 100) / (musicTotalTime)) / 100
        progressView.progress = percent
        progressView.setProgress(progressView.progress, animated: true)

        if currentMusicTime! >= (musicTotalTime) {
            progressView.progress = 0.0
            print("REACHED END OF MUSIC:",currentMusicTime, (musicTotalTime))
            self.btnPlay.setTitle("", for: .normal)
            self.removeMainViewFromSuperView()
            

        } else {
            
        }
        

//        self.progressView.progress = percent
     }
    
    
    func stopTimer() {
        
        self.btnPlay.setTitle("", for: .normal)
        IGPlayer.shared.pauseMusic()

        
    }
    func resumeTimer() {
        self.btnPlay.setTitle("", for: .normal)
        IGPlayer.shared.playMusic()

    }

    //MARK: - Create / Remove funcs
    ///TopMusicPlayer funcs
    ///MainView creation
    private func removeMainViewFromSuperView() {
        SwiftEventBus.post(EventBusManager.hideTopMusicPlayer)
        self.isRunning = false
        btnPlay.setTitle("", for: .normal)
        currentMusicTime = 0

        if progressView != nil {
            progressView.progress = 0.0
        }
        if self.bgView != nil {
            self.bgView.removeFromSuperview()
        }
        for subview in self.bgView.subviews {
            subview.removeFromSuperview()
        }
        let musicFile = MusicFile(songName: "VOICES_MESSAGE".MessageViewlocalizedNew , singerName: "UNKNOWN_ARTIST".MessageViewlocalizedNew, songTime: 0.0, currentTime: 0.0)
        self.bgView = nil
        
    }
    private func createMainView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(named: themeColor.receiveMessageBubleBGColor.rawValue)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true

        view.tag = 404
        return view
    }
    ///Pause-Play Button
    private func createPausePlayButton(btn: UIButton!,view:UIView!)  {
        btn.setTitle("", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btn.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        btn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
    }
    
    private func createCloseButton(btn: UIButton!,view:UIView!)  {
        btn.setTitle("🌩", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btn.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        btn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
    }
    private func creatBorders(topBorder:UIView!,bottomBorder:UIView!,view: UIView!) {
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.heightAnchor.constraint(equalToConstant:  0.5).isActive = true
        topBorder.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        topBorder.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        topBorder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        topBorder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        topBorder.backgroundColor = .darkGray
        bottomBorder.backgroundColor = .darkGray
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        bottomBorder.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        bottomBorder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true

    }
    private func createProgressView(pv:UIProgressView!,view: UIView!) {
        pv.progress = 0.0
        pv.progressTintColor = UIColor.iGapGreen()
        pv.progressViewStyle = .bar

        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.heightAnchor.constraint(equalToConstant: 2).isActive = true
        pv.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        pv.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 1).isActive = true
        pv.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        pv.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true

    }
    private func createLabelsInPlayer(songName: UILabel!,singerName: UILabel!,view:UIView!) {
        songName.numberOfLines = 1
        songName.textAlignment = .center
        songName.font = UIFont.igFont(ofSize: 10 , weight: .bold)
        songName.textColor = UIColor(named: themeColor.labelColor.rawValue)
        songName.translatesAutoresizingMaskIntoConstraints = false
        songName.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        songName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 45).isActive = true
        songName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -45).isActive = true

        singerName.numberOfLines = 1
        singerName.textAlignment = .center
        singerName.font = UIFont.igFont(ofSize: 10,weight : .light)
        singerName.textColor = UIColor(named: themeColor.labelColor.rawValue)
        singerName.translatesAutoresizingMaskIntoConstraints = false
        singerName.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        singerName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 45).isActive = true
        singerName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -45).isActive = true

    }

    
    
}
