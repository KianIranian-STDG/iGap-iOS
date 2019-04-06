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
    static var createdViewDic: [Int64 : UIView] = [:]
    var buttonActionDic: [UIButton : IGStructAdditionalButton] = [:]
    var buttonViewDic: [UIButton : UIView] = [:]
    
    let SCREAN_WIDTH = UIScreen.main.bounds.width
    let OUT_LAYOUT_SPACE: CGFloat = 10
    let IN_LAYOUT_SPACE: CGFloat = 5
    let ROW_HEIGHT: CGFloat = 35
    let IMAGE_SIZE: CGFloat = 30
    let MAX_KEYBOARD_HEIGHT: CGFloat = 216
    let MIN_LAYOUT_WIDTH: CGFloat = 50
    let STACK_VIEW_SPACE: CGFloat = 5
    
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
        var customViewHeight = rowHeight
        if rowCount > 1 || isKeyboard {
           customViewHeight = rowHeight + (OUT_LAYOUT_SPACE * 2) // do -> (SPACE * 2) because of -> offset(SPACE) for top & bottom , at mainStackView makeConstraints
        }
        
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
        parent.alpha = 0.0
        parent.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int(customViewHeight))
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = STACK_VIEW_SPACE
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        parent.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            if isKeyboard {
                make.top.equalTo(parent.snp.top).offset(OUT_LAYOUT_SPACE)
                make.left.equalTo(parent.snp.left).offset(OUT_LAYOUT_SPACE)
                make.right.equalTo(parent.snp.right).offset(-OUT_LAYOUT_SPACE)
                make.bottom.equalTo(parent.snp.bottom).offset(-OUT_LAYOUT_SPACE)
            } else {
                make.top.equalTo(parent.snp.top)
                make.left.equalTo(parent.snp.left)
                make.right.equalTo(parent.snp.right)
                make.bottom.equalTo(parent.snp.bottom)
            }
            make.height.equalTo(rowHeight)
            make.width.equalTo(rowWidth)
        }

        for (index, row) in additionalArrayMain.enumerated() {
            var delay = (Double(index) * 0.25)
            if isKeyboard {
                delay = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.distribution = .fillEqually
                stackView.spacing = self.STACK_VIEW_SPACE
                stackView.translatesAutoresizingMaskIntoConstraints = false
                
                for additionalButton in row {
                    stackView.addArrangedSubview(self.makeBotButton(parentView: stackView, additionalButton: additionalButton, isKeyboard: isKeyboard))
                }
                mainStackView.addArrangedSubview(stackView)
                if (index == additionalArrayMain.endIndex - 1){
                    parent.fadeIn(0.2)
                }
            }
        }
        
        return parent
    }
    
    private func makeBotButton(parentView: UIView, additionalButton: IGStructAdditionalButton, isKeyboard: Bool) -> UIView {
        let view = UIView()
        var img : UIImageView!
        let btn = UIButton()
        
        buttonActionDic[btn] = additionalButton
        buttonViewDic[btn] = view
        
        btn.addTarget(self, action: #selector(onBotButtonClick), for: .touchUpInside)
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        view.addSubview(btn)
        
        
        if additionalButton.imageUrl != nil {
            img = UIImageView()
            img.setImage(url: additionalButton.imageUrl!)
            view.addSubview(img)
            
            img.snp.makeConstraints { (make) in
                make.leading.equalTo(view.snp.leading).offset(IN_LAYOUT_SPACE)
                make.centerY.equalTo(view.snp.centerY)
                make.height.equalTo(IMAGE_SIZE)
                make.width.equalTo(IMAGE_SIZE)
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
            make.height.equalTo(IMAGE_SIZE)
        }
        
        btn.titleLabel?.font = UIFont.igFont(ofSize: 17.0)
        btn.setTitle(additionalButton.label, for: UIControl.State.normal)
        btn.removeUnderline()
        
        /*
        if isKeyboard {
            view.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.8)
        } else {
            view.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.3)
        }
        */
        view.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.5)
        
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 18.0

        return view
    }
    
    @objc private func onBotButtonClick(sender: UIButton){
        IGMessageViewController.additionalObserver.onBotClick()
        if let structAdditional = buttonActionDic[sender] {
            manageAdditionalActions(structAdditional: structAdditional)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.buttonViewDic[sender]!.backgroundColor = UIColor.customKeyboardButton()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                UIView.animate(withDuration: 0.2, animations: {
                    self.buttonViewDic[sender]!.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.5)
                })
            }
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
            IGMessageViewController.additionalObserver.onAdditionalLinkClick(structAdditional: structAdditional)
            break
            
        case ButtonActionType.STREAM_PLAY.rawValue :
            break
            
        case ButtonActionType.PAY_BY_WALLET.rawValue :
            break
            
        case ButtonActionType.PAY_DIRECT.rawValue :
            break
            
        case ButtonActionType.REQUEST_PHONE.rawValue :
            IGMessageViewController.additionalObserver.onAdditionalRequestPhone(structAdditional: structAdditional)
            break
            
        case ButtonActionType.REQUEST_LOCATION.rawValue :
            IGMessageViewController.additionalObserver.onAdditionalRequestLocation(structAdditional: structAdditional)
            break
            
        case ButtonActionType.SHOWA_ALERT.rawValue :
            break
            
        default:
            break
        }
    }
}
