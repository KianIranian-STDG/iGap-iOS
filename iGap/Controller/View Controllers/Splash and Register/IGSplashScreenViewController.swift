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
import Gifu
import SnapKit

class IGSplashScreenViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: GIFImageView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
//    var lang = ""
    var numberOfPages: Int = 4
    var pageIndex: Int = 0
    var titleStrs = [String]()
    var descriptions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locale = Locale.userPreferred // e.g "en_US"
        print(locale.languageCode)  // e.g "en"
        
        skipButton.removeUnderline()
        startButton.removeUnderline()
        
        IGContactManager.importedContact = false
        
        self.navigationController?.isNavigationBarHidden = true
        
        addSwipegestureRecognizer()
        
        pageControll.numberOfPages = numberOfPages
        pageControll.isUserInteractionEnabled = false
        
        startButton.layer.borderWidth = 0
        startButton.layer.cornerRadius = 10
        startButton.alpha = 1.0
        
        skipButton.layer.borderWidth = 0
        skipButton.layer.cornerRadius = 8
        skipButton.isHidden = true
//        startButton.setTitle("LETS_GO".localized, for: .normal)
        startButton.titleLabel?.font = UIFont.igFont(ofSize: 15)
        titleStrs = [
            "Chat",
            "Nearby Feature",
            "iLand",
            "Security & Privacy"
        ]
        descriptions = [
            "You can have one-on-one or group chats and even create your own channel and add members in order to share information with millions of people.",
            "Leave a new world around me. Around you, find your friends, entertainment centers, art, business and other and enjoy your moments ...",
            "iLand! without limitation\nwith wonderful events as taking a taxi, pay bills and booking hotels and flights . Oh Also you can play games, watch films and listen to music",
            "iGap attaches the utmost importance to your security and privacy using the individual encryption algorithms and guarantees a safe and secure connection between you, your friends and family."
        ]
        
        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_INSTALL_USER)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.languageView.isHidden = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.dismissLangModal),
                                               name: NSNotification.Name(rawValue: kIGGoDissmissLangNotificationName),
                                               object: nil)

        if !LocaleManager.isLanguageSelected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.gifImageView.fadeOut(0.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                    
                    self.setView(view: self.languageView, hidden: false)
                }
            }
        } else {
            self.gifImageView.isHidden = true
            self.languageView.isHidden = true
            dismissLangModal()
        }
        
    }
    
    @objc private func dismissLangModal() {
        startButton.setTitle("LETS_GO".localized, for: .normal)
        let images = ["ic_init_cominucation", "ic_init_nearby", "ic_init_iland", "ic_init_security"]
        
        titleStrs = [
            "CHAT".localized,
            "NEARBY_FEATURES".localized,
            "ILAND".localized,
            "SECURITY_And_PRIVACY".localized
        ]
        
        descriptions = [
            "CHAT_DESCRIPTION".localized,
            "NEARBY_FEATURES_DESCRIPTION".localized,
            "ILAND_DESCRIPTION".localized,
            "SECURITY_And_PRIVACY_DESCRIPTION".localized
        ]
        
        for i in 0..<numberOfPages {
            let imageView = UIImageView(frame: CGRect.zero)
            imageView.image = UIImage(named: images[i])
            imageView.tag = i
            self.topView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.width.equalTo(170)
                make.height.equalTo(170)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(60.0)
            })
            
            let titleLbl = UILabel(frame: CGRect.zero)
            titleLbl.text = titleStrs[i]
            titleLbl.textColor = UIColor(named: themeColor.labelColor.rawValue)
            titleLbl.font = UIFont.igFont(ofSize: 17, weight: .bold)
            titleLbl.textAlignment = .center
            titleLbl.numberOfLines = 1
            titleLbl.tag = i
            self.topView.addSubview(titleLbl)
            titleLbl.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(15.0)
                make.width.equalToSuperview().offset(-32.0)
                make.centerX.equalToSuperview()
            })
            
            let desciptionLabel = UILabel(frame: CGRect.zero)
            desciptionLabel.text = descriptions[i]
            desciptionLabel.textColor = UIColor(named: themeColor.labelColor.rawValue)
            desciptionLabel.font = UIFont.igFont(ofSize: 17)
            desciptionLabel.textAlignment = .center
            desciptionLabel.numberOfLines = 0
            desciptionLabel.tag = i
            self.topView.addSubview(desciptionLabel)
            desciptionLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLbl.snp.bottom).offset(8.0)
                make.width.equalToSuperview().offset(-32.0)
                make.centerX.equalToSuperview()
            })
            
            if i != 0 {
                imageView.alpha = 0.0
                titleLbl.alpha = 0.0
                desciptionLabel.alpha = 0.0
            }
        }
        languageView.fadeIn(0.5)
        hideLangView()
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.8, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func hideLangView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.languageView.isHidden = true
            self.languageView.isUserInteractionEnabled = false
        })
        splashView.fadeOut(0.5)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func didTapOnSkipButton(_ sender: UIButton) {
//        self.performSegue(withIdentifier: "showPhoneNumber", sender: self)
    }
    
    @IBAction func didTapOnStartButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showPhoneNumber", sender: self)
    }    
    
    func addSwipegestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if pageIndex > 0 {
                    changeView(for: pageIndex - 1)
                }
            case UISwipeGestureRecognizer.Direction.left:
                if pageIndex < (numberOfPages - 1) {
                    changeView(for: pageIndex + 1)
                }
            default:
                break
            }
        }
    }
    
    func changeView(for page: Int) {
        pageControll.currentPage = page
        pageIndex = page
        UIView.animate(withDuration: 0.5, animations: {
            for view in self.topView.subviews {
                if (view == self.skipButton && self.pageIndex != self.numberOfPages - 1) || view.tag == self.pageIndex {
                    view.alpha = 1.0
                } else if view != self.startButton && view != self.pageControll {
                    view.alpha = 0.0
                }
            }
        }) { (completed) in }
    }
}
