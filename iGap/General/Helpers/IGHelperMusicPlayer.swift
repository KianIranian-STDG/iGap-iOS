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
            if constraintView != nil {//if is in chatPage page cause it has constraint to its super stackView
                self.bgView = self.createMainView(view: alertView,constraintView: constraintView)
            }
            else if constraintStackView != nil {
                self.bgView = self.createMainView(view: alertView,constraintStackView: constraintStackView!)
            } else {
                self.bgView = self.createMainView(view: alertView)

            }
            
            ///add play pause button to it's superView
            let PlayPauseButton = self.createPausePlayButton(view: self.bgView)
            self.bgView.addSubview(PlayPauseButton)
            ///add clsoe button to it's superView
            let CloseButton = self.createPausePlayButton(view: self.bgView)
            let tapGestureRecognizerClose = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnClose))
            tapGestureRecognizerClose.numberOfTapsRequired = 1
            tapGestureRecognizerClose.numberOfTouchesRequired = 1
            CloseButton.addGestureRecognizer(tapGestureRecognizerClose)
            self.actionClose = close

            self.bgView.addSubview(CloseButton)
            
        } else {
            return self.bgView
        }
        return UIView()
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
        self.bgView.removeFromSuperview()
    }
    private func createMainView(view: UIViewController!,constraintView: UIView? = nil , constraintStackView : UIStackView? = nil) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(named: themeColor.modalViewBackgroundColor.rawValue)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        view.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
//        view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
//        view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
//        if constraintView != nil {
//            view.topAnchor.constraint(equalTo: constraintView!.topAnchor, constant: 0).isActive = true
//        } else {
//            view.topAnchor.constraint(equalTo: constraintStackView!.topAnchor, constant: 0).isActive = true
//        }

        return view
    }
    ///Pause-Play Button
    private func createPausePlayButton(view: UIView!) -> UIButton {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        button.titleLabel?.font = UIFont.iGapFonticon(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        button.widthAnchor.constraint(equalToConstant: 35).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        return button
    }
    
    private func createCloseButton(view: UIView!) -> UIButton {
        let button = UIButton()
        button.setTitle("🌩", for: .normal)
        button.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        button.titleLabel?.font = UIFont.iGapFonticon(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        button.widthAnchor.constraint(equalToConstant: 35).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        return button
    }

    
    
}
