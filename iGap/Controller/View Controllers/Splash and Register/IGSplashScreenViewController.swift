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
    var lang = ""
    var numberOfPages: Int = 3
    var pageIndex: Int = 0
    var descriptions = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        startButton.setTitle("LETS_GO".localizedNew, for: .normal)
        startButton.titleLabel?.font = UIFont.igFont(ofSize: 15)
        descriptions = ["You can make thoroughly free and secure voice and video calls to anyone on iGap and save your money. iGap voice and video call is P2P-based with no server\'s interference in voice and video transmission.",
                            "Leave a new world around me. Around you, find your friends, entertainment centers, art, business and other and enjoy your moments ...",
                            "You can have one-on-one or group chats and even create your own channel and add members in order to share information with millions of people."]
        
        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_INSTALL_USER)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.languageView.isHidden = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.dismissLangModalFA),
                                               name: NSNotification.Name(rawValue: kIGGoDissmissLangFANotificationName),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.dismissLangModalEN),
                                               name: NSNotification.Name(rawValue: kIGGoDissmissLangENNotificationName),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.dismissLangModalAR),
                                               name: NSNotification.Name(rawValue: kIGGoDissmissLangARNotificationName),
                                               object: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.gifImageView.fadeOut(0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                
                self.setView(view: self.languageView, hidden: false)

            }
        }
    }
    @objc private func dismissLangModalFA() {
        lang = "Fa"
        let images = ["IG_Splash_Cute_2", "IG_Splash_Cute_3", "IG_Splash_Cute_1"]

        descriptions = ["شما میتوانید بر بستر آیگپ با سایر کاربرانِ آیگپ تماس صوتیِ و تصویری کاملاً رایگان و امن برقرار کنید و در هزینه های خود صرفه جویی نمایید، همچنین تماس ها در آیگپ P2P بوده و حتی سرور های آیگپ هم در جابجایی صدا و تصویر شما دخالت ندارند.",
                        "با اطراف من پا به دنیای جدید بگذارید. در اطرافتان دوستان خود، مراکز تفریحی، هنری، تجاری و ... را پیدا کنید و از لحظه های خود لذت ببرید ...",
                        "شما میتوانید در آیگپ بصورت دونفره و یا گروهی به گفتگو بپردازید و خیالتان راحت باشد که همیشه به گفتگو های خود دسترسی دارید، همچنین میتوانید کانال بسازید و در آن عضو بگیرید و اطلاعات خود را بین میلیون ها کاربر دیگر نیز به اشتراک بگذارید."]
        startButton.setTitle("بزن بریم", for: .normal)

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
            
            let desciptionLabel = UILabel(frame: CGRect.zero)
            desciptionLabel.text = descriptions[i]
            desciptionLabel.font = UIFont.igFont(ofSize: 17)
            desciptionLabel.textAlignment = .center
            desciptionLabel.numberOfLines = 0
            desciptionLabel.tag = i
            self.topView.addSubview(desciptionLabel)
            desciptionLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(15.0)
                make.width.equalToSuperview().offset(-32.0)
                make.centerX.equalToSuperview()
            })
            
            if i != 0 {
                imageView.alpha = 0.0
                desciptionLabel.alpha = 0.0
            }
        }
        languageView.fadeIn(0.5)
        hideLangView()
    }
    @objc private func dismissLangModalEN() {
        lang = "En"
        startButton.setTitle("Let's Go", for: .normal)
        let images = ["IG_Splash_Cute_2", "IG_Splash_Cute_3", "IG_Splash_Cute_1"]

        descriptions = ["You can make thoroughly free and secure voice and video calls to anyone on iGap and save your money. iGap voice and video call is P2P-based with no server\'s interference in voice and video transmission.",
                        "Leave a new world around me. Around you, find your friends, entertainment centers, art, business and other and enjoy your moments ...",
                        "You can have one-on-one or group chats and even create your own channel and add members in order to share information with millions of people."]
        
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
            
            let desciptionLabel = UILabel(frame: CGRect.zero)
            desciptionLabel.text = descriptions[i]
            desciptionLabel.font = UIFont.igFont(ofSize: 17)
            desciptionLabel.textAlignment = .center
            desciptionLabel.numberOfLines = 0
            desciptionLabel.tag = i
            self.topView.addSubview(desciptionLabel)
            desciptionLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(15.0)
                make.width.equalToSuperview().offset(-32.0)
                make.centerX.equalToSuperview()
            })
            
            if i != 0 {
                imageView.alpha = 0.0
                desciptionLabel.alpha = 0.0
            }
        }
        languageView.fadeIn(0.5)
        hideLangView()
    }
    @objc private func dismissLangModalAR() {
        lang = "Ar"
        descriptions = ["You can make thoroughly free and secure voice and video calls to anyone on iGap and save your money. iGap voice and video call is P2P-based with no server\'s interference in voice and video transmission.",
                        "Leave a new world around me. Around you, find your friends, entertainment centers, art, business and other and enjoy your moments ...",
                        "You can have one-on-one or group chats and even create your own channel and add members in order to share information with millions of people."]

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
        if lang == "Fa" {
            
        }
        else if lang == "En" {
            
        }
        else {
            
        }
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
