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
enum helperWindowView : Int {
    case ReturnCall = 0
    case Music = 1
}


// IMPORTANT TODO - convert current class to builder
class IGHelperUIViewView {
    var tempTimer : Int = 0
    var counter : Timer!
    static let shared = IGHelperUIViewView()
    
    func show(mode : helperWindowView,userID:Int64!,isIncomming: Bool! = true,lastRecordedTime : Int? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            //if this block runs we were unable to get a reference to the main window
            print("you have probably called this method in viewDidLoad or at some earlier point where the main window reference might be nil")
            return
        }
        switch mode {
        case .Music :
            break
        case .ReturnCall :
            creatReturnToCallView(window: window,userId:userID,isIncommmingCall: isIncomming!,lastRecordedTime: lastRecordedTime)
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
            if everyView.tag == 100 {
                //popIn animate
                tempTimer = 0
                if counter != nil {
                    counter.invalidate()
                }
                UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                        everyView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    }, completion: {
                        (value: Bool) in
                        everyView.removeFromSuperview()
                    })
            }
        }
        //add some custom view, for simplicity I've added a black view
    }
    private func creatMusicView() {
        
    }
    private func creatReturnToCallView(window: UIWindow,userId: Int64? = nil ,userName: String? = nil, isIncommmingCall: Bool = true, sdp: String? = nil, type:IGPSignalingOffer.IGPType = .voiceCalling, mode:String? = nil, showAlert: Bool = true,lastRecordedTime: Int? = nil) {

        
        
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
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
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

        //tapHandling on backView
        let tappy = myBackViewGesture(target: self, action: #selector(self.openCallPage))
        tappy.userID = userId!
        tappy.isIncomming = isIncommmingCall
        tappy.window = window
        tappy.lastRecordedTime = lastRecordedTime!
        backView.addGestureRecognizer(tappy)

        counter = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)


        //End

    }
    
    @objc func updateTimerLabel() {
        
        tempTimer += 1
    }
    @objc func openCallPage(sender: myBackViewGesture){
        self.showCallPage(userId: sender.userID, isIncommmingCall: sender.isIncomming, type: IGPSignalingOffer.IGPType.voiceCalling, showAlert: false, window: sender.window,lastRecordedTime: sender.lastRecordedTime)
    }
    private func showCallPage(userId: Int64 ,userName: String? = nil, isIncommmingCall: Bool = true, sdp: String? = nil, type:IGPSignalingOffer.IGPType = .voiceCalling, mode:String? = nil, showAlert: Bool = true,window : UIWindow,lastRecordedTime : Int? = nil){
        
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let callPage = storyboard.instantiateViewController(withIdentifier: "IGCall") as! IGCall
            //Mark:- show Display Name of caller User if Nil we are not in terminate State
            callPage.callerName = userName ?? IGStringsManager.Unknown.rawValue.localized
            //End
            callPage.userId = userId
            callPage.isIncommingReturnCall = isIncommmingCall
            callPage.callType = type
            callPage.callSdp = sdp
            callPage.recordedTime = lastRecordedTime! + tempTimer
        print("|||||||||TIMER||||||||||")
        print(tempTimer)
        print(lastRecordedTime)
        print("|||||||||TIMER||||||||||")
            callPage.isReturnCall = true
            var currentController = window.rootViewController
            if let presentedController = currentController!.presentedViewController {
                currentController = presentedController
            }
            self.remove()

            callPage.modalPresentationStyle = .fullScreen
            currentController!.present(callPage, animated: true, completion: nil)
        

        
    }
    class myBackViewGesture: UITapGestureRecognizer {
        var userID = Int64()
        var lastRecordedTime = Int()
        var isIncomming = Bool()
        var window = UIWindow()
        
    }
}

