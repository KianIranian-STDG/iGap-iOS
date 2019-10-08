//
//  IGHelperUIViewView.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 10/8/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import IGProtoBuff
import RealmSwift
enum helperWindowView : Int {
    case ReturnCall = 0
    case Music = 1
}


// IMPORTANT TODO - convert current class to builder
class IGHelperUIViewView {
    
    static let shared = IGHelperUIViewView()
    
    func show(mode : helperWindowView) {
        guard let window = UIApplication.shared.keyWindow else {
            //if this block runs we were unable to get a reference to the main window
            print("you have probably called this method in viewDidLoad or at some earlier point where the main window reference might be nil")
            return
        }
        switch mode {
        case .Music :
            break
        case .ReturnCall :
            creatReturnToCallView(window: window)
            break
        default :
            break
        }

    }
    func remove() {
        guard let window = UIApplication.shared.keyWindow else {
            //if this block runs we were unable to get a reference to the main window
            return
        }
        for everyView in window.subviews {
            if everyView.tag == 101 {
                everyView.removeFromSuperview()
            }
        }
        //add some custom view, for simplicity I've added a black view
    }
    private func creatMusicView() {
        
    }
    private func creatReturnToCallView(window: UIWindow,userId: Int64? = nil ,userName: String? = nil, isIncommmingCall: Bool = true, sdp: String? = nil, type:IGPSignalingOffer.IGPType = .voiceCalling, mode:String? = nil, showAlert: Bool = true) {

        
        
        //BG view
        let backView = UIViewX()
        backView.tag = 100
        backView.backgroundColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
        window.addSubview(backView)
        //constraints
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backView.rightAnchor.constraint(equalTo: window.rightAnchor, constant: -10).isActive = true
        backView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: (IGGlobal.topbarHeight) * -1).isActive = true
        backView.layer.cornerRadius = 50/2
        backView.shadowRadius = 1
        backView.shadowOpacity = 0.5
        backView.shadowColor = .black

        //popIn animate
            backView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.8, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                backView.transform = CGAffineTransform.identity
            }, completion: nil)

        //End
        //Label
        let lblIcon = UILabel()
        lblIcon.tag = 104
        lblIcon.font = UIFont.iGapFonticon(ofSize: 20)
        lblIcon.text = ""
        lblIcon.textAlignment = .center
        lblIcon.textColor = UIColor.white
        backView.addSubview(lblIcon)
        lblIcon.translatesAutoresizingMaskIntoConstraints = false
        lblIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        lblIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        lblIcon.centerYAnchor.constraint(equalTo: backView.centerYAnchor, constant: 0).isActive = true
        lblIcon.centerXAnchor.constraint(equalTo: backView.centerXAnchor, constant: 0).isActive = true


        //End

    }
}

