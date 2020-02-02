/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import AsyncDisplayKit
import IGProtoBuff
import SwiftEventBus

class IGTextNode: AbstractNode {
    var ASbuttonActionDic: [ASButtonNode : IGStructAdditionalButton] = [:]
    var ASbuttonViewDic: [ASButtonNode : ASDisplayNode] = [:]

//    private let textNode = MsgTextTextNode()
    

    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = true,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()

//        msgTextNode.isUserInteractionEnabled = true
        if let additionalData = message.additional?.data, message.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
                let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (self.finalRoom.type == .chat && !(self.finalRoom.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
                addSubnode(msgTextNode)

            } else {
                addSubnode(msgTextNode)
            }
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let textNodeVerticalOffset = CGFloat(6)
        
        let mainBoxV = ASStackLayoutSpec.vertical()
        mainBoxV.justifyContent = .spaceAround

        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0 ,
            bottom: 0,
            right: 0), child: msgTextNode)
        mainBoxV.children?.append(insetSpec)
        if let additionalData = message.additional?.data, message.additional?.dataType == AdditionalType.UNDER_MESSAGE_BUTTON.rawValue,
            let additionalStruct = IGHelperJson.parseAdditionalButton(data: additionalData), (isIncomming || (self.finalRoom.type == .chat && !(self.finalRoom.chatRoom?.peer!.isBot)! && additionalStruct[0][0].actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue)) {
 
            let buttonBox = makeBotNode(roomId: finalRoom.id, additionalArrayMain: additionalStruct)
            mainBoxV.children?.append(buttonBox)
  
            return mainBoxV

            
        } else {
            return mainBoxV

        }

        
    }
    
    func makeBotNode(roomId: Int64, additionalArrayMain: [[IGStructAdditionalButton]], isKeyboard: Bool = false) -> ASLayoutSpec {
        let buttonBoxV = ASStackLayoutSpec.vertical()
        buttonBoxV.justifyContent = .center
        buttonBoxV.style.flexShrink = 1.0
        buttonBoxV.style.flexGrow = 1.0
        buttonBoxV.alignItems = .stretch
        buttonBoxV.spacing = 5

        for (index, row) in additionalArrayMain.enumerated() {
        
                  let buttonBoxH = ASStackLayoutSpec.horizontal()
                  buttonBoxH.justifyContent = .spaceAround
                    buttonBoxH.spacing = 5
                    buttonBoxH.style.flexShrink = 1.0
                    buttonBoxH.style.flexGrow = 1.0
                    buttonBoxH.alignItems = .stretch
            
                  for additionalButton in row {
                    let view = ASDisplayNode()
                    let img = ASNetworkImageNode()
                    let button = ASButtonNode()
                    button.style.flexShrink = 1.0
                    button.style.flexGrow = 1.0
                    button.style.height = ASDimensionMake(.points, 50)
                    button.layer.cornerRadius = 10
                    button.contentVerticalAlignment = .center
                    button.contentHorizontalAlignment = .middle
                    button.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor

                    img.style.height = ASDimensionMake(.points, 30)
                    img.style.width = ASDimensionMake(.points, 30)
                    ASbuttonActionDic[button] = additionalButton
                    ASbuttonViewDic[button] = view
                    if !(IGGlobal.shouldMultiSelect) {
                        button.addTarget(self, action: #selector(onBotButtonClick), forControlEvents: ASControlNodeEvent.touchUpInside)

                    }
                    addSubnode(button)
                    if additionalButton.imageUrl != nil {
                        img.url = (additionalButton.imageUrl)
                        view.addSubnode(img)
                    }
                    if additionalButton.actionType == IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue {
                        button.setTitle(IGStringsManager.CardToCard.rawValue.localized, with: .igFont(ofSize: 15), with: .white, for: .normal)

                    } else {
                        button.setTitle(additionalButton.label, with: .igFont(ofSize: 15), with: .white, for: .normal)
                    }

                      buttonBoxH.children?.append(button)
                  }
                    buttonBoxV.children?.append(buttonBoxH)
            
          }
        return buttonBoxV
    }
    @objc private func onBotButtonClick(sender: ASButtonNode){
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sender.isEnabled = true
        }
        
        if let structAdditional = ASbuttonActionDic[sender] {
            manageAdditionalActions(roomId: sender.accessibilityIdentifier!, structAdditional: structAdditional)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.ASbuttonViewDic[sender]!.backgroundColor = UIColor.customKeyboardButton()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                UIView.animate(withDuration: 0.2, animations: {
                    self.ASbuttonViewDic[sender]!.backgroundColor = UIColor.customKeyboardButton().withAlphaComponent(0.5)
                })
            }
        }
    }
    
    
    private func manageAdditionalActions(roomId: String, structAdditional: IGStructAdditionalButton){
        if !(IGGlobal.shouldMultiSelect) {

            switch structAdditional.actionType {
                
            case IGPDiscoveryField.IGPButtonActionType.none.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.joinLink.rawValue :
                IGHelperJoin.getInstance().requestToCheckInvitedLink(invitedLink: structAdditional.value)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.botAction.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.usernameLink.rawValue :
                IGHelperChatOpener.checkUsernameAndOpenRoom(username: structAdditional.value, joinToRoom: false)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.webLink.rawValue :
                IGHelperOpenLink.openLink(urlString: structAdditional.value, forceOpenInApp: true)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.webViewLink.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.billMenu.rawValue :
                IGFinancialServiceBill.BillInfo = nil
                IGFinancialServiceBill.isTrafficOffenses = false
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: structAdditional.value)
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.trafficBillMenu.rawValue :
                IGFinancialServiceBill.BillInfo = nil
                IGFinancialServiceBill.isTrafficOffenses = true
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: structAdditional.value)
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                break
                
            case IGPDiscoveryField.IGPButtonActionType.streamPlay.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.payByWallet.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.payDirect.rawValue :
                guard let jsonValue = structAdditional.valueJson as? String, let json = jsonValue.toJSON() as? [String:AnyObject], let token = json["token"] as? String else {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    break
                }
                IGGlobal.prgShow()
                IGApiPayment.shared.orderCheck(token: token, completion: { (success, payment, errorMessage) in
                    IGGlobal.prgHide()
                    let paymentView = IGPaymentView.sharedInstance
                    
                    if success {
                        guard let paymentData = payment else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            return
                        }
                        
                        paymentView.show(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Pay.rawValue.localized, payToken: token, payment: paymentData)
                    } else {
                        
                        paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Pay.rawValue.localized, message: errorMessage ?? "", payToken: token)
                    }
                })
                break
                
            case IGPDiscoveryField.IGPButtonActionType.requestPhone.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.requestLocation.rawValue :
                SwiftEventBus.postToMainThread(roomId, sender: (structAdditional.actionType, structAdditional))
                break
                
            case IGPDiscoveryField.IGPButtonActionType.showAlert.rawValue :
                break
                
            case IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue :
                if let valueJson = structAdditional.valueJson, let finalData = IGHelperJson.parseAdditionalCardToCardInChat(data: valueJson) {
                    let tmpAmount = finalData.amount
                    let tmpCardNumber = finalData.cardNumber
                    IGHelperFinancial.shared.sendCardToCardRequestWithAmount(toUserId: finalData.userId , amount: (tmpAmount), destinationCard: tmpCardNumber)
                }
                break
                
            default:
                break
            }
        }
    }
}


