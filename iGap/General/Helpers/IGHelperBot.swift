/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import SnapKit

class IGHelperBot {
    
    static let shared = IGHelperBot()
    
    var data: Data?
    var buttonActionDic: [UIButton : IGStructAdditionalButton] = [:]
    
    let SCREAN_WIDTH = UIScreen.main.bounds.width
    let OUT_LAYOUT_SPACE: CGFloat = 10
    let IN_LAYOUT_SPACE: CGFloat = 5
    let ROW_HEIGHT: CGFloat = 40
    let MAX_KEYBOARD_HEIGHT: CGFloat = 220
    let MIN_LAYOUT_WIDTH: CGFloat = 50
    
    private func computeWidth() -> CGFloat {
        return SCREAN_WIDTH - (OUT_LAYOUT_SPACE * 2)
    }
    
    public func computeHeight(rowCount: CGFloat) -> CGFloat {
        return (rowCount * (ROW_HEIGHT + OUT_LAYOUT_SPACE)) + OUT_LAYOUT_SPACE
    }
    
    /**************************************************/
    /**************** View Maker Start ****************/
    
    func makeBotView(additionalArrayMain: [[IGStructAdditionalButton]], isKeyboard: Bool = false) -> UIView {
        
        let rowCount = CGFloat(additionalArrayMain.count)
        let rowWidth = computeWidth()
        let rowHeight = computeHeight(rowCount: rowCount)
        var customViewHeight = rowHeight + (OUT_LAYOUT_SPACE * 2) // do -> (SPACE * 2) because of -> offset(SPACE) for top & bottom , at mainStackView makeConstraints
        
        var parent: UIView!
        if isKeyboard {
            if customViewHeight > MAX_KEYBOARD_HEIGHT {
                customViewHeight = MAX_KEYBOARD_HEIGHT
            }
            parent = UIScrollView()
            parent.backgroundColor = UIColor.white
        } else {
            parent = UIView()
            parent.backgroundColor = UIColor.clear
        }
        parent.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int(customViewHeight))
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        parent.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.top.equalTo(parent.snp.top).offset(OUT_LAYOUT_SPACE)
            make.left.equalTo(parent.snp.left).offset(OUT_LAYOUT_SPACE)
            make.right.equalTo(parent.snp.right).offset(-OUT_LAYOUT_SPACE)
            make.bottom.equalTo(parent.snp.bottom).offset(-OUT_LAYOUT_SPACE)
            make.height.equalTo(rowHeight)
            make.width.equalTo(rowWidth)
        }
        
        for row in additionalArrayMain {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            for additionalButton in row {
                stackView.addArrangedSubview(makeBotButton(parentView: stackView, additionalButton: additionalButton, isKeyboard: isKeyboard))
            }
            mainStackView.addArrangedSubview(stackView)
        }
        
        return parent
    }
    
    private func makeBotButton(parentView: UIView, additionalButton: IGStructAdditionalButton, isKeyboard: Bool) -> UIView {
        let view = UIView()
        var img : UIImageView!
        let btn = UIButton()
        
        buttonActionDic[btn] = additionalButton
        
        btn.addTarget(self, action: #selector(onBotButtonClick), for: .touchUpInside)
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        view.addSubview(btn)
        
        let internalViewSize = ROW_HEIGHT - (IN_LAYOUT_SPACE * 2)
        
        if additionalButton.imageUrl != nil {
            img = UIImageView()
            img.setImage(url: additionalButton.imageUrl!)
            view.addSubview(img)
            
            img.snp.makeConstraints { (make) in
                make.leading.equalTo(view.snp.leading).offset(IN_LAYOUT_SPACE)
                make.centerY.equalTo(view.snp.centerY)
                make.height.equalTo(internalViewSize)
                make.width.equalTo(internalViewSize)
            }
        }
        
        btn.snp.makeConstraints { (make) in
            if additionalButton.imageUrl != nil {
                make.leading.equalTo(img.snp.trailing).offset(IN_LAYOUT_SPACE)
            } else {
                make.leading.equalTo(view.snp.leading).offset(IN_LAYOUT_SPACE)
            }
            make.trailing.equalTo(view.snp.trailing).offset(-IN_LAYOUT_SPACE)
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(internalViewSize)
        }
        
        btn.titleLabel?.font = UIFont.igFont(ofSize: 17.0)
        btn.setTitle(additionalButton.label, for: UIControlState.normal)
        btn.removeUnderline()
        
        if isKeyboard {
            view.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.8)
        } else {
            view.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.3)
        }
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5.0

        return view
    }
    
    @objc private func onBotButtonClick(sender: UIButton){
        if let structAdditional = buttonActionDic[sender] {
            manageAdditionalActions(structAdditional: structAdditional)
        }
    }
    
    /***************** View Maker End *****************/
    /**************************************************/
    
    private func manageAdditionalActions(structAdditional: IGStructAdditionalButton){
        switch structAdditional.actionType {
            
        case ButtonActionType.NONE.rawValue :
            break
            
        case ButtonActionType.JOIN_LINK.rawValue :
            if let observer = IGMessageViewController.messageViewControllerObserver {
                IGHelperJoin.getInstance(viewController: observer.onMessageViewControllerDetection()).requestToCheckInvitedLink(invitedLink: structAdditional.value)
            }
            break
            
        case ButtonActionType.BOT_ACTION.rawValue :
            IGMessageViewController.additionalObserver.onAdditionalSendMessage(structAdditional: structAdditional)
            break
            
        case ButtonActionType.USERNAME_LINK.rawValue :
            if let observer = IGMessageViewController.messageViewControllerObserver {
                IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: observer.onMessageViewControllerDetection(), username: structAdditional.value, joinToRoom: false)
            }
            break
            
        case ButtonActionType.WEB_LINK.rawValue :
            if let observer = IGMessageViewController.messageViewControllerObserver {
                IGHelperOpenLink.openLink(urlString: structAdditional.value, navigationController: observer.onNavigationControllerDetection(), forceOpenInApp: true)
            }
            break
            
        case ButtonActionType.WEBVIEW_LINK.rawValue :
            break
            
        case ButtonActionType.STREAM_PLAY.rawValue :
            break
            
        case ButtonActionType.PAY_BY_WALLET.rawValue :
            break
            
        case ButtonActionType.PAY_DIRECT.rawValue :
            break
            
        case ButtonActionType.REQUEST_PHONE.rawValue :
            break
            
        case ButtonActionType.REQUEST_LOCATION.rawValue :
            break
            
        case ButtonActionType.SHOWA_ALERT.rawValue :
            break
            
        default:
            break
        }
    }
}
