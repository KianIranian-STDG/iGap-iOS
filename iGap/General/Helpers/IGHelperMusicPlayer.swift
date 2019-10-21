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
class IGHelperMusicPlayer {
    enum MusicCurrentState : Int {
        case Playing = 0
        case Stoped = 1
    }

    private var actionClose: (() -> Void)?
    private var actionPlay: (() -> Void)?
    private var actionPause: (() -> Void)?
    private var actionNextMusic: (() -> Void)?
    private var actionPreviousMusic: (() -> Void)?
    private var actionShuffleMusics: (() -> Void)?
    private var actionRepeatMusics: (() -> Void)?
    private var actionChangeTime: (() -> Void)?

    static let shared = IGHelperMusicPlayer()
    var topView : UIView!
    var bgView : UIView!
    let window = UIApplication.shared.keyWindow
    
    private init() {}
    
    
    ///Top Music Player tobe shown  in Room List and Message page
    ///
    func showTopMusicPlayer(view: UIViewController? = nil,constraintView: UIView? = nil,constraintStackView: UIStackView? = nil, close: (() -> Void)? = nil, btnPlayPause: (() -> Void)? = nil) -> UIView {
        var alertView = view
        if alertView == nil {
            alertView = UIApplication.topViewController()
        }

        if self.bgView == nil {
 
                self.bgView = self.createMainView()

            
            ///add play pause button to it's superView
            let PlayPauseButton = UIButton()
            self.bgView.addSubview(PlayPauseButton)
            self.createPausePlayButton(btn: PlayPauseButton, view: self.bgView)
            ///add clsoe button to it's superView
            let CloseButton = UIButton()
            self.bgView.addSubview(CloseButton)
            self.createCloseButton(btn: CloseButton, view: self.bgView)
            let tapGestureRecognizerClose = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnClose))
            tapGestureRecognizerClose.numberOfTapsRequired = 1
            tapGestureRecognizerClose.numberOfTouchesRequired = 1
            CloseButton.addGestureRecognizer(tapGestureRecognizerClose)
            self.actionClose = close
            
            
            
            
            ////borders
            let borderTop = UIView()///border Top
            let borderBottom = UIView()///border Bottom
            self.bgView.addSubview(borderTop)
            self.bgView.addSubview(borderBottom)

            self.creatBorders(topBorder: borderTop, bottomBorder: borderBottom, view: self.bgView)
            return self.bgView
        } else {
            return self.bgView
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

    //MARK: - Create / Remove funcs
    ///TopMusicPlayer funcs
    ///MainView creation
    private func removeMainViewFromSuperView() {
        SwiftEventBus.post(EventBusManager.hideTopMusicPlayer)
        self.bgView.removeFromSuperview()
        
    }
    private func createMainView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(named: themeColor.messageLogCellBGColor.rawValue)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true

        view.tag = 404
        return view
    }
    ///Pause-Play Button
    private func createPausePlayButton(btn: UIButton!,view:UIView!)  {
        btn.setTitle("", for: .normal)
        btn.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        btn.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btn.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        btn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
    }
    
    private func createCloseButton(btn: UIButton!,view:UIView!)  {
        btn.setTitle("🌩", for: .normal)
        btn.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        btn.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btn.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        btn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    private func creatBorders(topBorder:UIView!,bottomBorder:UIView!,view: UIView!) {
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        topBorder.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        topBorder.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        topBorder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        topBorder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        topBorder.backgroundColor = .darkGray
        bottomBorder.backgroundColor = .darkGray
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomBorder.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        bottomBorder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true

    }
    private func createProgressView(pv:UIProgressView!,view: UIView!) {
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.heightAnchor.constraint(equalToConstant: 2).isActive = true
        pv.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        pv.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 1).isActive = true
        pv.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        pv.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true

    }

    
    
}
