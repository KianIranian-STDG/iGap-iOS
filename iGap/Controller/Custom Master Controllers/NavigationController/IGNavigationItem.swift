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
import MBProgressHUD
protocol HandleBackNavigation {
    func diselect()
}
var currentPageName : String! = ""

class IGNavigationItem: UINavigationItem {
    var delegate : HandleBackNavigation?
    
    var rightViewContainer:  IGTappableView?
    var centerViewContainer: IGTappableView?
    var leftViewContainer:   IGTappableView?
    var backViewContainer:   IGTappableView?
    var callViewContainer:   IGTappableView?
    var returnToCall:        IGTappableView?
    var navigationController: IGNavigationController?
    private var centerViewMainLabel: UILabel?
    private var centerViewSubLabel:  UILabel?
    private var typingIndicatorView: IGDotActivityIndicator?
    var isUpdatingUserStatusForAction : Bool = false
    var isProccesing: Bool = true
    var hud = MBProgressHUD()
    
    private var tapOnRightView:  (()->())?
    private var tapOncenterView: (()->())?
    private var tapOnLeftView:   (()->())?
    private var tapOnBackView:   (()->())?
    
    //MARK: - Initilizers
    override init(title: String) {
        super.init(title: title)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func configure() {
        let rightViewFrame = CGRect(x:0, y:0, width: 40, height:40)
        rightViewContainer = IGTappableView(frame: rightViewFrame)
        rightViewContainer!.backgroundColor = UIColor.clear
        let rightBarButton = UIBarButtonItem(customView: rightViewContainer!)
        self.rightBarButtonItem = rightBarButton
        returnToCallMethod()
    }
    
    //MARK: - Connecting
    func setNavigationItemForConnecting() {
        setNavigationItemWithCenterActivityIndicator(text: "CONNECTING".localizedNew)
    }
    
    func setNavigationItemForWaitingForNetwork() {
        setNavigationItemWithCenterActivityIndicator(text: "WAITING_NETWORK".localizedNew)
    }
    
    private func returnToCallMethod(){
        
        if !IGCall.callPageIsEnable {
            return
        }
        
        self.returnToCall = IGTappableView(frame: CGRect(x: 0, y: 0, width: 140, height: 35))
        self.titleView = self.returnToCall
        
        self.returnToCall?.backgroundColor = UIColor.returnToCall()
        self.returnToCall?.layer.cornerRadius = 15
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        label.textAlignment = .center
        label.textColor = UIColor.iGapBarsInfo()
        label.text = "RETURN_TO_CALL".localizedNew
        self.titleView?.addSubview(label)
        
        self.titleView?.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.titleView!.snp.centerX)
            make.centerY.equalTo(self.titleView!.snp.centerY)
        }
        
        self.returnToCall?.addAction {
            if IGCall.staticReturnToCall != nil {
                IGCall.staticReturnToCall.returnToCall()
            }
        }
    }
    
    private func setNavigationItemWithCenterActivityIndicator(text: String) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        self.centerViewContainer?.subviews.forEach { $0.removeFromSuperview() }
        self.centerViewContainer?.removeFromSuperview()
        self.centerViewContainer = IGTappableView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        
        self.titleView = centerViewContainer
        
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 15.0,weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.iGapBarsInfo()
        label.text = text
        self.titleView?.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.centerViewContainer!.snp.centerX)
            make.centerY.equalTo(self.centerViewContainer!.snp.centerY).offset(-5)
        }
        
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        self.titleView?.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        activityIndicatorView.snp.makeConstraints { (make) in
            make.right.equalTo(label.snp.left).offset(-4)
            make.centerY.equalTo(self.centerViewContainer!.snp.centerY)
            make.width.equalTo(20.0)
            make.height.equalTo(20.0)
        }
    }
    
    
    //MARK: - Navigation VCs
    func addNavigationViewItems(rightItemText: String?, title: String?, width: CGFloat = 150) {
        if title != nil {
            addTitleLabel(title: title!, width: width)
        }
        if rightItemText != nil {
            addModalViewRightItem(title: rightItemText!)
        }
        addNavigationBackItem()
    }
    
    func addNavigationBackItem() {
        //self.hidesBackButton = true
        let backViewFrame = CGRect(x:0, y:0, width: 50, height:50)
        backViewContainer = IGTappableView(frame: backViewFrame)
        backViewContainer!.backgroundColor = UIColor.clear
        let backArrowImageView = UIImageView(frame: CGRect(x: 5, y: 10, width: 25, height: 25))
        if IGGlobal.shouldMultiSelect {
            backArrowImageView.image = UIImage(named: "ig_cross_icon")
            
        }
        else {
            backArrowImageView.image = UIImage(named: "IG_Nav_Bar_BackButton")
            
        }
        backViewContainer?.addSubview(backArrowImageView)
        let backBarButton = UIBarButtonItem(customView: backViewContainer!)
        self.leftBarButtonItem = backBarButton
        self.title = ""
        
        backViewContainer?.addAction {
            IGGlobal.shouldShowChart = false
            self.backViewContainer?.isUserInteractionEnabled = false
            guard let numberOfPages = self.navigationController?.viewControllers.count else { return }
            if IGGlobal.shouldMultiSelect {
                self.delegate?.diselect()
                
            }
            else {
                if numberOfPages == 2  {
                    IGGlobal.shouldMultiSelect = false
                    currentPageName = ""
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    
    //MARK: - Modal VCs
    func addModalViewItems(leftItemText: String?, rightItemText: String?, title: String?) {
        self.hidesBackButton = true
        if title != nil {
            addTitleLabel(title: title!)
        }
        if rightItemText != nil{
            addModalViewRightItem(title: rightItemText!)
        }
        if leftItemText != nil{
            addModalViewLeftItem(title: leftItemText!)
        }
    }
    
    func addCallViewContainer(){
        let rightViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        callViewContainer = IGTappableView(frame: rightViewFrame)
        callViewContainer!.backgroundColor = UIColor.clear
        let rightBarButton = UIBarButtonItem(customView: callViewContainer!)
        self.rightBarButtonItem = rightBarButton
        
        let composeButtonFrame = CGRect(x: 15, y: 2.5, width: 35, height: 35)
        let composeButtonImageView = UIImageView(frame: composeButtonFrame)
        composeButtonImageView.image = UIImage(named:"IG_Tabbar_Call_On")
        callViewContainer!.addSubview(composeButtonImageView)
    }
    
    private func addTitleLabel(title: String , width: CGFloat = 150) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        label.font = UIFont.igFont(ofSize: 17.0, weight: .bold)
        label.textAlignment = .center
        label.text = title
        label.textColor = UIColor.iGapBarsInfo()
        
        titleView.addSubview(label)
        self.titleView = titleView
    }
    
    public func addModalViewRightItem(title: String, iGapFont: Bool = false, fontSize: CGFloat = 20.0, xPosition: Double = -5.0) {
        let rightViewFrame = CGRect(x:0, y:0, width: 60, height:40)
        rightViewContainer = IGTappableView(frame: rightViewFrame)
        rightViewContainer!.backgroundColor = UIColor.clear
        let rightBarButton = UIBarButtonItem(customView: rightViewContainer!)
        self.rightBarButtonItem = rightBarButton
        
        var labelFrame: CGRect!
        var label: UILabel!
        if iGapFont {
            labelFrame = CGRect(x: xPosition, y: 0, width: 50, height:40)
            label = UILabel(frame: labelFrame)
            label.font = UIFont.iGapFontico(ofSize: fontSize)
        } else {
            labelFrame = CGRect(x: -50, y: 0, width: 100, height:40)
            label = UILabel(frame: labelFrame)
            label.font = UIFont.igFont(ofSize: 15.0, weight: .bold)
            
        }
        label.textAlignment = .right
        label.text = title
        label.textAlignment = .right
        label.textColor = UIColor.iGapBarsInfo()
        rightViewContainer!.addSubview(label)
    }
    
    private func addModalViewLeftItem(title: String) {
        let leftViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        leftViewContainer = IGTappableView(frame: leftViewFrame)
        leftViewContainer!.backgroundColor = UIColor.clear
        let leftBarButton = UIBarButtonItem(customView: leftViewContainer!)
        self.leftBarButtonItem = leftBarButton
        
        let labelFrame = CGRect(x: 0, y: 4.5, width: 100, height:31)
        let label = UILabel(frame: labelFrame)
        label.text = title
        label.font = UIFont.igFont(ofSize: 15.0, weight: .bold)
        
        label.textAlignment = .left
        label.textColor = UIColor.iGapBarsInfo()
        leftViewContainer!.addSubview(label)
    }
    
    //MARK: - Phone Book
    func setPhoneBookNavigationItems() {
        addiGapLogo()
        addSettingButton()
        addComopseButton()
        
    }
    private func addSettingButton() {
        if leftViewContainer?.subviews.count != nil {
            if leftViewContainer!.subviews.count > 0 {
                
                leftViewContainer!.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                
            }
            
        }
        let leftViewFrame = CGRect(x:0, y:0, width: 50, height:40)
        leftViewContainer = IGTappableView(frame: leftViewFrame)
        leftViewContainer!.backgroundColor = UIColor.clear
        let leftBarButton = UIBarButtonItem(customView: leftViewContainer!)
        self.leftBarButtonItem = leftBarButton
        let _ : String = SMLangUtil.loadLanguage()
        
        
        
        let settingViewFrame = CGRect(x: 3, y: 6.5, width: 25, height:25)
        let settingButtonImageView = UIImageView(frame: settingViewFrame)
        
        settingButtonImageView.image = UIImage(named: "IG_NavBar_EditMode")
        leftViewContainer!.addSubview(settingButtonImageView)
    }
    
    private func addComopseButton() {
        
        if rightViewContainer?.subviews.count != nil {
            
            if rightViewContainer!.subviews.count > 0 {
                
                rightViewContainer!.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                
            }
            
        }
        let composeButtonFrame = CGRect(x: 10, y: 7.5, width: 21, height: 21)
        let composeButtonImageView = UIImageView(frame: composeButtonFrame)
        let _ : String = SMLangUtil.loadLanguage()
        
        
        composeButtonImageView.image = UIImage(named: "IG_Nav_Bar_Plus")
        rightViewContainer!.addSubview(composeButtonImageView)
    }
    
    
    //MARK: - Call List
    func setCallListNavigationItems() {
        addiGapLogo()
        addPlusButton()
        addMoreSettingsButton()
        
    }
    private func addMoreSettingsButton() {
        if leftViewContainer?.subviews.count != nil {
            
            if leftViewContainer!.subviews.count > 0 {
                
                leftViewContainer!.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                
            }
            
        }
        let callListViewFrame =  CGRect(x: 10, y: 7.5, width: 21, height: 21)
        let callListButtonImageView = UIImageView(frame: callListViewFrame)
        
        callListButtonImageView.image = UIImage(named: "IG_NavBar_More")
        callListButtonImageView.removeFromSuperview()
        leftViewContainer!.addSubview(callListButtonImageView)
        
        
    }
    
    private func addPlusButton() {
        
        
        if rightViewContainer?.subviews.count != nil {
            if rightViewContainer!.subviews.count > 0 {
                
                rightViewContainer!.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                
            }
            
        }
        let callListViewFrame = CGRect(x: 10, y: 7.5, width: 21, height: 21)
        let callListButtonImageView = UIImageView(frame: callListViewFrame)
        
        callListButtonImageView.image = UIImage(named: "IG_Nav_Bar_Plus")
        callListButtonImageView.removeFromSuperview()
        
        rightViewContainer!.addSubview(callListButtonImageView)
        
    }
    
    //MARK: - Discovery
    
    func setDiscoveriesNavigationItems() {
        addFavoriteButton()
        addScoreButton()
        addiGapLogo()
    }
    
    
    private func addFavoriteButton() {
        if leftViewContainer?.subviews.count != nil {
            
            if leftViewContainer!.subviews.count > 0 {
                
                leftViewContainer!.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                
            }
            
        }
        let settingViewFrame =  CGRect(x: 10, y: 7.5, width: 21, height: 21)
        let settingButtonImageView = UIImageView(frame: settingViewFrame)
        
        settingButtonImageView.image = UIImage(named: "IG_Nav_Bar_Flag")
        settingButtonImageView.removeFromSuperview()
        leftViewContainer!.addSubview(settingButtonImageView)
        
        
    }
    
    
    private func addScoreButton() {
        
        
        if rightViewContainer?.subviews.count != nil {
            if rightViewContainer!.subviews.count > 0 {
                
                rightViewContainer!.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                
            }
            
        }
        let composeButtonFrame = CGRect(x: 10, y: 7.5, width: 21, height: 21)
        let composeButtonImageView = UIImageView(frame: composeButtonFrame)
        
        composeButtonImageView.image = UIImage(named: "IG_NavBar_Score")
        composeButtonImageView.removeFromSuperview()
        
        rightViewContainer!.addSubview(composeButtonImageView)
        
    }
    //MARK: - Chat List
    func setChatListsNavigationItems() {
        addSettingButton()
        addComopseButton()
        addiGapLogo()
    }
    private func removeSettingButton() {
        
    }
    
    
    
    
    func addiGapLogo() {
        
        if IGCall.callPageIsEnable {
            AppDelegate.isFirstEnterToApp = false
            return
        }
        
        if IGAppManager.connectionStatusStatic != IGAppManager.ConnectionStatus.iGap {
            return
        }
        
        if IGTabBarController.currentTabStatic == .Recent || AppDelegate.isFirstEnterToApp || IGTabBarController.currentTabStatic == .Contact  {
            AppDelegate.isFirstEnterToApp = false
            let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 67, height: 40))
            let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 67, height: 20))
            logoImageView.image = UIImage(named: "IG_Nav_Bar_Logo")
            logoImageView.contentMode = .scaleAspectFit
            titleView.addSubview(logoImageView)
            
            self.titleView = titleView
        }
        else if IGTabBarController.currentTabStatic == .Contact  {
            
            let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 67, height: 40))
            let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 67, height: 20))
            logoImageView.image = UIImage(named: "IG_Nav_Bar_Logo")
            logoImageView.contentMode = .scaleAspectFit
            titleView.addSubview(logoImageView)
            
            self.titleView = titleView
            
        } else {
            //Hint: call top code block again, because we want show iGap logo for all tabs
            let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 67, height: 40))
            let logoImageView = UIImageView(frame: CGRect(x: 0, y: 8, width: 67, height: 23))
            logoImageView.image = UIImage(named: "IG_Nav_Bar_Logo")
            logoImageView.contentMode = .scaleAspectFit
            titleView.addSubview(logoImageView)
            
            self.titleView = titleView
            
            /*
             var title = ""
             var width: Double!
             
             if IGTabBarController.currentTabStatic == .Dashboard {
             title = "Dashboard"
             width = 100
             } else if IGTabBarController.currentTabStatic == .Call {
             title = "Calls History"
             width = 110
             }
             
             /*
             if IGTabBarController.currentTabStatic == .Chat {
             title = "Chats"
             width = 60
             } else if IGTabBarController.currentTabStatic == .Group {
             title = "Groups"
             width = 65
             } else if IGTabBarController.currentTabStatic == .Channel {
             title = "Channels"
             width = 80
             } else if IGTabBarController.currentTabStatic == .Call {
             title = "Calls History"
             width = 110
             }
             */
             
             let titleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 40))
             let lableView = UILabel(frame: CGRect(x: 0, y: 8, width: width, height: 23))
             lableView.text = title
             lableView.textColor = UIColor.iGapBarsInfo()
             lableView.font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.bold)
             
             titleView.addSubview(lableView)
             self.titleView = titleView
             */
        }
    }
    //MARK: - Messages View
    func setNavigationBarForRoom(_ room: IGRoom) {
        if  IGGlobal.shouldMultiSelect {
            addNavigationBackItem()
        }
        else {
            setRoomAvatar(room)
            setRoomInfo(room)
            addNavigationBackItem()
            
        }
    }
    
    func updateNavigationBarForRoom(_ room: IGRoom) {
        if IGGlobal.shouldMultiSelect {
            
        }
        else {
            
        }
        if IGCall.callPageIsEnable || centerViewMainLabel == nil {
            return
        }
        
        self.centerViewMainLabel!.text = room.title
        
        if isCloud(room: room){
            return
        }
        
        if room.currenctActionsByUsers.count != 0 {
            if typingIndicatorView == nil {
                typingIndicatorView = IGDotActivityIndicator()
                self.centerViewContainer!.addSubview(typingIndicatorView!)
                typingIndicatorView!.snp.makeConstraints { (make) in
                    make.left.equalTo(self.centerViewSubLabel!.snp.right)
                    make.centerY.equalTo(self.centerViewSubLabel!.snp.centerY)
                    make.width.equalTo(40)
                }
            }
            
            self.centerViewSubLabel!.text = room.currentActionString()
        } else {
            
            typingIndicatorView?.removeFromSuperview()
            typingIndicatorView = nil
            self.centerViewSubLabel!.snp.makeConstraints { (make) in
                make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(3)
                make.leading.equalTo(self.centerViewContainer!.snp.leading).offset(5)
            }
            
            if let peer = room.chatRoom?.peer {
                if room.currenctActionsByUsers.first?.value.1 != .typing {
                    setLastSeenLabelForUser(peer, room: room)
                }
            } else if let groupRoom = room.groupRoom {
                
                self.centerViewSubLabel!.text = "\(groupRoom.participantCount) " + "MEMBER".localizedNew
                
            } else if let channelRoom = room.channelRoom {
                self.centerViewSubLabel!.text = "\(channelRoom.participantCount) " + "MEMBER".localizedNew
            }
        }
    }
    
    private func initilizeNavigationBarForRoom(_ room: IGRoom) {}
    
    private func setRoomAvatar(_ room: IGRoom) {
        let avatarViewFrame = CGRect(x: 0, y: 0, width: 40, height:40)
        
        let avatarView = IGAvatarView(frame: avatarViewFrame)
        avatarView.setRoom(room, showMainAvatar: true)
        rightViewContainer!.addSubview(avatarView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.setRoomAvatar(room)
        }
    }
    
    private func setRoomInfo(_ room: IGRoom) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        var userId: Int64 = 0
        
        if let id = room.chatRoom?.peer?.id {
            userId = id
        }
        
        self.centerViewContainer?.subviews.forEach { $0.removeFromSuperview() }
        self.centerViewContainer = IGTappableView()
        let callView = IGTappableView()
        
        let titleContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        
        self.titleView = titleContainerView
        titleContainerView.addSubview(self.centerViewContainer!)
        titleContainerView.addSubview(callView)
        
        callView.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView.snp.top)
            make.bottom.equalTo(titleContainerView.snp.bottom)
            make.trailing.equalTo(titleContainerView.snp.trailing)
            make.width.equalTo(50)
        }
        
        self.centerViewContainer?.snp.makeConstraints { (make) in
            make.top.equalTo(titleContainerView.snp.top)
            make.bottom.equalTo(titleContainerView.snp.bottom)
            make.leading.equalTo(titleContainerView.snp.leading)
            make.trailing.equalTo(callView.snp.leading)
        }
        
        if userId != 0 && userId != IGAppManager.sharedManager.userID() && !room.isReadOnly && !(room.chatRoom?.peer?.isBot)! { // check isReadOnly for iGapMessanger
            let callViewLabel = UILabel()
            callViewLabel.textColor = UIColor.iGapBarsInfo()
            callViewLabel.textAlignment = .center
            callViewLabel.font = UIFont.iGapFontico(ofSize: 18.0)
            callViewLabel.text = ""
            callView.addSubview(callViewLabel)
            callViewLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(callView.snp.centerX)
                make.centerY.equalTo(callView.snp.centerY)
            }
            
            callView.addAction {
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: userId, isIncommmingCall: false)
                }
            }
        }
        
        self.centerViewMainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 18))
        self.centerViewMainLabel!.text = room.title
        self.centerViewMainLabel!.textColor = UIColor.iGapBarsInfo()
        self.centerViewMainLabel!.textAlignment = .center
        self.centerViewMainLabel!.font = UIFont.igFont(ofSize: 16.0, weight: .bold)//boldSystemFont(ofSize: 16)
        self.centerViewContainer!.addSubview(self.centerViewMainLabel!)
        self.centerViewMainLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(self.centerViewContainer!.snp.top)
            make.leading.equalTo(self.centerViewContainer!.snp.leading).offset(5).priority(.required)
            make.width.lessThanOrEqualToSuperview().offset(-25)
        }
        
        self.centerViewSubLabel = UILabel()//frame: CGRect(x: 0, y: 20, width: 200, height: 16))
        self.centerViewSubLabel!.textColor = UIColor.iGapBarsInfo()
        self.centerViewSubLabel!.textAlignment = .left
        self.centerViewSubLabel!.font = UIFont.igFont(ofSize: 12.0, weight: .regular)//boldSystemFont(ofSize: 12)
        self.centerViewContainer!.addSubview(self.centerViewSubLabel!)
        self.centerViewSubLabel!.snp.makeConstraints { (make) in
            make.top.equalTo(self.centerViewMainLabel!.snp.bottom).offset(-3)
            make.leading.equalTo(self.centerViewContainer!.snp.leading).offset(5)
            make.trailing.lessThanOrEqualTo((self.titleView?.snp.trailing)!).offset(-80)
        }
        
        let verifiedFrame = CGRect(x: 20, y: 5, width: 25, height: 25)
        let imgVerified = UIImageView(frame: verifiedFrame)
        imgVerified.image = UIImage(named:"IG_Verify")
        
        if room.mute == .mute {
            let muteFrame = CGRect(x: 20, y: 5, width: 25, height: 25)
            let imgMute = UIImageView(frame: muteFrame)
            imgMute.image = UIImage(named:"IG_Chat_List_Mute")
            
            imgMute.image = imgMute.image!.withRenderingMode(.alwaysTemplate)
            imgMute.tintColor = UIColor.iGapBarsInfo()
            
            self.centerViewContainer!.addSubview(imgMute)
            imgMute.snp.makeConstraints { (make) in
                make.top.equalTo(self.centerViewMainLabel!.snp.top).offset(3)
                make.right.equalTo(self.centerViewMainLabel!.snp.right).offset(20)
            }
            
            if isVerified(room: room) {
                self.centerViewContainer!.addSubview(imgVerified)
                imgVerified.snp.makeConstraints { (make) in
                    make.width.equalTo(20)
                    make.height.equalTo(20)
                    make.top.equalTo(self.centerViewMainLabel!.snp.top).offset(3)
                    make.right.equalTo(imgMute.snp.right).offset(25)
                }
            }
        } else {
            if isVerified(room: room) {
                self.centerViewContainer!.addSubview(imgVerified)
                imgVerified.snp.makeConstraints { (make) in
                    make.width.equalTo(20)
                    make.height.equalTo(20)
                    make.top.equalTo(self.centerViewMainLabel!.snp.top).offset(3)
                    make.right.equalTo(self.centerViewMainLabel!.snp.right).offset(25)
                }
            }
        }
        
        if let peer = room.chatRoom?.peer {
            if room.currenctActionsByUsers.first?.value.1 != .typing {
                setLastSeenLabelForUser(peer , room: room)
            }
        } else if let groupRoom = room.groupRoom {
            self.centerViewSubLabel!.text = "\(groupRoom.participantCount)" + "MEMBER".localizedNew
        } else if let channelRoom = room.channelRoom {
            self.centerViewSubLabel!.text = "\(channelRoom.participantCount)" + "MEMBER".localizedNew
        }
    }
    
    private func isVerified(room: IGRoom) -> Bool {
        var verified = false
        if room.type == .chat {
            if let user = room.chatRoom?.peer {
                if user.isVerified {
                    verified = true
                }
            }
        } else if room.type == .channel {
            if (room.channelRoom?.isVerified)! {
                verified = true
            }
        }
        return verified
    }
    
    private func isBot(room: IGRoom) -> Bool {
        if !room.isInvalidated && room.type == .chat {
            if let user = room.chatRoom?.peer {
                if user.isBot {
                    return true
                }
            }
        }
        return false
    }
    
    private func setLastSeenLabelForUser(_ user: IGRegisteredUser , room : IGRoom) {
        if !(room.isInvalidated) && !(user.isInvalidated) {
            if isCloud(room: room){
                return
            }
            
            if isBot(room: room){
                self.centerViewSubLabel!.text = "BOT".localizedNew
                return
            }
            
            if room.currenctActionsByUsers.first?.value.1 != .typing && typingIndicatorView == nil {
                
                switch user.lastSeenStatus {
                case .longTimeAgo:
                    self.centerViewSubLabel!.text = "A_LONG_TIME_AGO".localizedNew
                    break
                case .lastMonth:
                    self.centerViewSubLabel!.text = "LAST_MONTH".localizedNew
                    break
                case .lastWeek:
                    self.centerViewSubLabel!.text = "LAST_WEAK".localizedNew
                    break
                case .online:
                    self.centerViewSubLabel!.text = "ONLINE".localizedNew
                    break
                case .exactly:
                    self.centerViewSubLabel!.text = "\(user.lastSeen!.humanReadableForLastSeen())".inLocalizedLanguage()
                    break
                case .recently:
                    self.centerViewSubLabel!.text = "A_FEW_SEC_AGO".localizedNew
                    break
                case .support:
                    self.centerViewSubLabel!.text = "IGAP_SUPPORT".localizedNew
                    break
                case .serviceNotification:
                    self.centerViewSubLabel!.text = "SERVICE_NOTIFI".localizedNew
                    break
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // TODO - saeed - use realm notification listener
                    self.setLastSeenLabelForUser(user , room: room)
                }
            }
        }
        else {
            print("ERROR HAPPEND IN REALM")
        }
        
    }
    
    
    private func isCloud(room: IGRoom) -> Bool {
        if !room.isInvalidated, room.chatRoom?.peer?.id == IGAppManager.sharedManager.userID() {
            self.centerViewSubLabel!.text = "MY_CLOUD".localizedNew
            return true
        }
        return false
    }
    
}
