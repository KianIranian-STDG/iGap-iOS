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
import SwiftEventBus
import IGProtoBuff

@objc protocol ChatDelegate : AnyObject{
    
    func openuserProfile(message : IGRoomMessage)
}

class BaseBubbleNode: ASCellNode {
    private var finalRoom: IGRoom!
    private var finalRoomType: IGRoom.IGType!
    var message: IGRoomMessage?
    private var isIncomming: Bool
    private var shouldShowAvatar : Bool
    private var isFromSameSender : Bool
    private let bubbleImgNode = ASImageNode()
    private let txtTimeNode = ASTextNode()
    private let txtNameNode = ASTextNode()
    private let txtStatusNode = ASTextNode()
    private var subNode = ASDisplayNode()
    
    private(set) var bubbleNode = ASCellNode()
    private var replyForwardViewNode = ASReplyForwardNode()
    
    private var imgNodeReply = ASImageNode()
    
    private let avatarImageViewNode = ASAvatarView()
    private let avatarBtnViewNode = ASButtonNode()
    weak var delegate : ChatDelegate!
    
    weak var generalMessageDelegate: IGMessageGeneralCollectionViewCellDelegate?
    
    var pan: UIPanGestureRecognizer!
    var tapMulti: UITapGestureRecognizer!
    
    private var currentSwipeToReplyTranslation: CGFloat = 0.0
    private var swipeToReplyNode: ChatMessageSwipeToReplyNode?
    private var swipeToReplyFeedback: HapticFeedback?

    override func didLoad() {
        super.didLoad()
        self.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        manageGestureRecognizers()
        if !(IGGlobal.shouldMultiSelect) {
            makeSwipeToReply() // Telegram Func
            
        }
    }
    private func makeSwipeToReply() {// Telegram Func
        let replyRecognizer = ChatSwipeToReplyRecognizer(target: self, action: #selector(self.swipeToReplyGesture(_:)))

        self.view.addGestureRecognizer(replyRecognizer)

    }
    
    @objc func swipeToReplyGesture(_ recognizer: ChatSwipeToReplyRecognizer) {
        switch recognizer.state {
            case .began:
                self.currentSwipeToReplyTranslation = 0.0
                if self.swipeToReplyFeedback == nil {
                    self.swipeToReplyFeedback = HapticFeedback()
                    self.swipeToReplyFeedback?.prepareImpact()
                }
            case .changed:
                var translation = recognizer.translation(in: self.view)
                translation.x = max(-80.0, min(0.0, translation.x))
                var animateReplyNodeIn = false
                if (translation.x < -45.0) != (self.currentSwipeToReplyTranslation < -45.0) {
                    if translation.x < -45.0, self.swipeToReplyNode == nil {
                        self.swipeToReplyFeedback?.impact()

                        let swipeToReplyNode = ChatMessageSwipeToReplyNode(fillColor: UIColor.black, strokeColor: UIColor.red, foregroundColor: .white)
                        self.swipeToReplyNode = swipeToReplyNode
                        self.insertSubnode(swipeToReplyNode, at: 0)
                        animateReplyNodeIn = true
                    }
                }
                self.currentSwipeToReplyTranslation = translation.x
                var bounds = self.bounds
                bounds.origin.x = -translation.x
                self.bounds = bounds
            
                if let swipeToReplyNode = self.swipeToReplyNode {
                    swipeToReplyNode.frame = CGRect(origin: CGPoint(x: bounds.size.width, y: round(33.0) / 2.0), size: CGSize(width: 33.0, height: 33.0))
                    
                    swipeToReplyNode.alpha = min(1.0, abs(translation.x / 45.0))

            }
            case .ended:
                self.swipeToReplyFeedback = nil
                
                var bounds = self.bounds
                bounds.origin.x = 0.0
                self.bounds = bounds
                if let swipeToReplyNode = self.swipeToReplyNode {
                    self.swipeToReplyNode = nil
                    swipeToReplyNode.removeFromSupernode()
                }

                self.generalMessageDelegate?.swipToReply(cellMessage: self.message!)

            case .cancelled:
                self.swipeToReplyFeedback = nil
                
                var bounds = self.bounds
                bounds.origin.x = 0.0
                self.bounds = bounds
                if let swipeToReplyNode = self.swipeToReplyNode {
                    self.swipeToReplyNode = nil
                    swipeToReplyNode.removeFromSupernode()
                }
            
        default:
                break
        }
    }

    init(message : IGRoomMessage, finalRoomType : IGRoom.IGType, finalRoom : IGRoom, isIncomming: Bool, bubbleImage: UIImage, isFromSameSender: Bool, shouldShowAvatar: Bool) {
        self.finalRoom = finalRoom
        self.finalRoomType = finalRoomType
        self.message = message
        self.isIncomming = isIncomming
        self.shouldShowAvatar = shouldShowAvatar
        self.isFromSameSender = isFromSameSender
        self.bubbleImgNode.image = bubbleImage
        super.init()
        
        setupView()
        
    }
    
    
    private func setupView() {
        if !(finalRoomType == .chat) {
            if let name = message!.authorUser?.userInfo {
                txtNameNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeAsyncText(for: txtNameNode, with: name.displayName, textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
            } else {
                txtNameNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
                IGGlobal.makeAsyncText(for: txtNameNode, with: "", textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
        }
        
        var msg = message
        
        if let repliedMessage = message?.repliedTo {
            msg = repliedMessage


        } else if let forwardedFrom = message?.forwardedFrom {
            msg = forwardedFrom

            
        } else {
            msg = message
            
        }
        var finalType : IGRoomMessageType = msg!.type

        if finalType == .text {
            bubbleNode = IGTextNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if finalType == .image || finalType == .imageAndText {
            bubbleNode = IGImageNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if finalType == .video || finalType == .videoAndText {
            bubbleNode = IGVideoNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if finalType == .file || finalType == .fileAndText {
            bubbleNode = IGFileNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if finalType == .voice {
            bubbleNode = IGVoiceNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if finalType == .location {
            bubbleNode = IGLocationNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if finalType == .audio {
            bubbleNode = IGMusicNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }  else if finalType == .audioAndText {
            bubbleNode = IGMusicNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }else if finalType == .contact {
            bubbleNode = IGContactNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if finalType == .sticker {
            bubbleNode = IGStrickerNormalNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        } else if finalType == .wallet && msg!.wallet?.type == 2  { //CardToCard
            bubbleNode = IGCardToCardReceiptNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }  else if finalType == .wallet && msg!.wallet?.type == 0  { //moneyTransfer
                  bubbleNode = IGMoneytransferReceiptNode(message: msg!, isIncomming: isIncomming, finalRoomType: self.finalRoomType, finalRoom: self.finalRoom)
        }


        
        
        
        
        
        if let time = message!.creationTime {
            txtTimeNode.textContainerInset = UIEdgeInsets(top: 0, left: (isIncomming ? 0 : 6), bottom: 0, right: (isIncomming ? 6 : 0))
            IGGlobal.makeAsyncText(for: txtTimeNode, with: time.convertToHumanReadable(), textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont, alignment: .center)
            
        }
        
        if message!.type == .text ||  message!.type == .image ||  message!.type == .imageAndText ||  message!.type == .file ||  message!.type == .fileAndText || message!.type == .voice || message!.type == .location || message!.type == .video || message!.type == .videoAndText || message!.type == .audio ||  message!.type == .audioAndText || message!.type == .contact || message!.type == .sticker || message!.type == .wallet {
            if(isIncomming){
                
                
                if self.finalRoom.type == .channel || self.finalRoom.type == .group {
                    if self.finalRoom.type == .group {

                        if !isFromSameSender  {
                            avatarImageViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                            avatarImageViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                            avatarImageViewNode.clipsToBounds = true

                            //clearButton on top of ASAvatarView
                            avatarBtnViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                            avatarBtnViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                            avatarBtnViewNode.clipsToBounds = true
                        }
                        
                    } else {
                        avatarImageViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                        avatarImageViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                        avatarImageViewNode.clipsToBounds = true

                        //clearButton on top of ASAvatarView
                        avatarBtnViewNode.style.preferredSize = CGSize(width: kAMMessageCellNodeAvatarImageSize, height: kAMMessageCellNodeAvatarImageSize)
                        avatarBtnViewNode.cornerRadius = kAMMessageCellNodeAvatarImageSize/2
                        avatarBtnViewNode.clipsToBounds = true
                    }
                }
                
                //set size of status marker to zero for incomming messages
                txtStatusNode.style.preferredSize = CGSize.zero
                
            }else{
                if self.finalRoom.type == .channel || self.finalRoom.type == .group {
                    avatarImageViewNode.style.preferredSize = CGSize.zero
                    avatarBtnViewNode.style.preferredSize = CGSize.zero

                }
                manageMessageStatus()

                
            }
            //Add SubNodes
            if finalType == .sticker {
                addSubnode(subNode)
            }
            
            addSubnode(bubbleImgNode)
            if finalRoomType == .group && isIncomming {
                addSubnode(txtNameNode)
            }
            addSubnode(replyForwardViewNode)
            addSubnode(bubbleNode)
            addSubnode(txtTimeNode)
            addSubnode(txtStatusNode)
            if self.finalRoom.type == .channel || self.finalRoom.type == .group {
                if self.finalRoom.type == .channel {
                    addSubnode(avatarImageViewNode)
                    addSubnode(avatarBtnViewNode)//Button with clear BG in order to handle tap on avatar
                    //Avatar
                    if (finalRoomType == .chat) || (finalRoomType == .group)  {
                        if let user = message!.authorUser?.user {
                            avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.clear
                            avatarImageViewNode.setUser(user)
                        } else if let userId = message!.authorUser?.userId {
                            avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.white
                            avatarImageViewNode.avatarASImageView!.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
                            SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(message!.roomId)", sender: (action: ChatMessageAction.userInfo, userId: userId))
                        } else {
                            print("COMES HERE")
                        }

                    } else {
                        
                        print("COMES HERE CHANNEL")
                        print("=====-----=======")
                        avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.clear
                        avatarImageViewNode.setRoom(self.finalRoom)

                        
                    }
                    
                    //Taps
                    avatarBtnViewNode.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)


                } else {
                    if !isFromSameSender {
                        addSubnode(avatarImageViewNode)
                        addSubnode(avatarBtnViewNode)//Button with clear BG in order to handle tap on avatar
                        //Avatar
                        if (finalRoomType == .chat) || (finalRoomType == .group)  {
                            if let user = message!.authorUser?.user {
                                avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.clear
                                avatarImageViewNode.setUser(user)
                            } else if let userId = message!.authorUser?.userId {
                                avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.white
                                avatarImageViewNode.avatarASImageView!.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
                                SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(message!.roomId)", sender: (action: ChatMessageAction.userInfo, userId: userId))
                            } else {
                                print("COMES HERE")
                            }

                        } else {
                            
                            print("COMES HERE CHANNEL")
                            print("=====-----=======")
                            avatarImageViewNode.avatarASImageView!.backgroundColor = UIColor.clear
                            avatarImageViewNode.setRoom(self.finalRoom)

                            
                        }
                        
                        //Taps
                        avatarBtnViewNode.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)


                    } else {
                        avatarImageViewNode.removeFromSupernode()
                        avatarBtnViewNode.removeFromSupernode()
                    }
                }


            } else {
                avatarImageViewNode.removeFromSupernode()
                avatarBtnViewNode.removeFromSupernode()
                
            }
            addSubnode(imgNodeReply)
            if finalRoomType! != .channel {
                imgNodeReply.alpha = 0
                imgNodeReply.isUserInteractionEnabled = false
            }else {
                imgNodeReply.alpha = 0.5
                imgNodeReply.isUserInteractionEnabled = true
            }
    
            
            
        }
        
        
    }
    
    /*
     ******************************************************************
     ************************* Status Manager *************************
     ******************************************************************
     */
    
    private func manageMessageStatus(){
        
        switch message!.status {
        case .sending:
            if isIncomming {
                let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)

            } else {
                let Color = ThemeManager.currentTheme.LabelColor
                IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)

            }
            
            txtStatusNode.backgroundColor = UIColor.clear

            break
        case .sent:

            if isIncomming {
                let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)

            } else {
                let Color = ThemeManager.currentTheme.LabelColor
                IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)

            }
            
            txtStatusNode.backgroundColor = UIColor.clear

            
            break
        case .delivered:

            if isIncomming {
                let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)

            } else {
                let Color = ThemeManager.currentTheme.LabelColor
                IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)

            }
            
            txtStatusNode.backgroundColor = UIColor.clear

            break
        case .seen,.listened:


            
            if isIncomming {
                let Color = ThemeManager.currentTheme.MessageTextReceiverColor
                IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: Color, size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)

            } else {
                let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
                let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
                let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

                if currentTheme == "IGAPDay" || currentTheme == "IGAPNight" {
                    
                    if currentColorSetLight == "IGAPBlack" {
                        let Color = ThemeManager.currentTheme.LabelColor
                        IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                    } else {
                        let Color = ThemeManager.currentTheme.LabelColor
                        IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                    }

                } else {
                    let Color = ThemeManager.currentTheme.LabelColor
                    IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: .iGapGreen(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
                }


            }
            
            txtStatusNode.backgroundColor = UIColor.clear

            break
        case .failed, .unknown:
            IGGlobal.makeAsyncText(for: self.txtStatusNode, with: "", textColor: .failedColor(), size: 15, numberOfLines: 1, font: .fontIcon, alignment: .center)
            txtStatusNode.backgroundColor = UIColor.clear

            break
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.alignItems = .stretch
        stack.spacing = 10
        if finalRoomType == .group && isIncomming {
            if message?.type != .sticker || message?.type != .log || message?.type != .unread {
                
                stack.children?.append(txtNameNode)
                
            }
        }
        var layoutMsg = message

        //check if has reply or Forward
        if let repliedMessage = message?.repliedTo {
            layoutMsg = repliedMessage
            stack.children?.append(replyForwardViewNode)
            replyForwardViewNode.setReplyForward(isReply: true, extraMessage : layoutMsg!)
            
            stack.children?.append(bubbleNode)
        } else if let forwardedFrom = message?.forwardedFrom {
            layoutMsg = forwardedFrom

            if message?.type != .sticker || message?.type != .log {
                replyForwardViewNode.setReplyForward(isReply: false, extraMessage : layoutMsg!)
                stack.children?.append(replyForwardViewNode)

            }
            stack.children?.append(bubbleNode)
        } else {
            layoutMsg = message

            stack.children?.append(bubbleNode)

        }
        
        
        let textNodeVerticalOffset = CGFloat(6)
        txtTimeNode.style.alignSelf = .end
        
        let verticalSpec = ASBackgroundLayoutSpec()
        if message?.type != .sticker || message?.type == .log {
            verticalSpec.background = bubbleImgNode
        }
        
        /**************************************************************/
        /************DIFFRENT NODES SHOULD BE ADDED HERE**************/
        /**************************************************************/
        
        
        
        
        
        /**************************************************************/
        /************TEXT NODE**************/
        /**************************************************************/
        
        if let _ = bubbleNode  as? IGTextNode{ // Only Contains Text
            var msg = layoutMsg!.message
            if let forwardMessage = message?.forwardedFrom {
                msg = forwardMessage.message
            }
            if let msgcount = msg {
                
                if(msgcount.count <= 20)  {
                    
                    if (self.finalRoomType == .channel) {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode])
                        
                        let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .end, alignItems: ASStackLayoutAlignItems.end, children: isIncomming ? [stack , timeStatusStack] : [stack , timeStatusStack])
                        horizon.verticalAlignment = .bottom
                        
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 15 ,bottom: 8,right: 10),child: horizon)
                        
                    } else {
                        
                        
                        if ((layoutMsg!.additional?.data) != nil), layoutMsg!.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue {
                            
                            if isIncomming {
                                stack.children?.append(txtTimeNode)
                                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 15 ,bottom: 8,right: 10),child: stack)
                                
                            } else {
                                let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                                timeStatusStack.verticalAlignment = .center
                                
                                stack.children?.append(timeStatusStack)
                                verticalSpec.child = ASInsetLayoutSpec(
                                    insets: UIEdgeInsets(top: 8,left: 15 ,bottom: 8,right: 10),child: stack)
                                
                            }

                        } else {
                            let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                            timeStatusStack.verticalAlignment = .center
                            
                            let horizon = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .end, alignItems: ASStackLayoutAlignItems.end, children: [stack , timeStatusStack])
                            horizon.verticalAlignment = .bottom

                            verticalSpec.child = ASInsetLayoutSpec(
                                insets: UIEdgeInsets(top: 8,left: 15 ,bottom: 8,right: 10),child: horizon)

                        }
                        
                    }
                    
                }else{
                    
                    if (self.finalRoomType == .channel) {
                        
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 15 ,bottom: 8,right: 10),child: stack)
                        
                    } else {
                        
                        if isIncomming {
                            stack.children?.append(txtTimeNode)
                            verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 15 ,bottom: 8,right: 10),child: stack)
                            
                        } else {
                            let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                            timeStatusStack.verticalAlignment = .center
                            
                            stack.children?.append(timeStatusStack)
                            verticalSpec.child = ASInsetLayoutSpec(
                                insets: UIEdgeInsets(top: 8,left: 15 ,bottom: 8,right: 10),child: stack)
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            
        }
            /**************************************************************/
            /************IMAGE AND IMAGE TEXT NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGImageNode{
            if layoutMsg!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode])
                    
                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 10,bottom: 8,right: 10),child: stack)
                    
                    
                    
                } else {
                    
                    if isIncomming {
                        //                        stack.children?.append(txtTimeNode)
                        //                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode])
                        
                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                        
                        
                    } else {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center
                        
                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                        
                    }
                    
                }
                
            }
            
            
        }
            
            /**************************************************************/
            /************VIDEO AND VIDEO TEXT NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGVideoNode{
            if layoutMsg!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 10,bottom: 8,right: 10),child: stack)
                    
                } else {
                    
                    if isIncomming {
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                        
                    } else {
                        
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center
                        
                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                        
                    }
                    
                }
                
            }
            
            
        }

            
            /**************************************************************/
            /************FILE NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGFileNode {
            
            if layoutMsg!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                } else {
                    
                    if isIncomming {
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    } else {
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center
                        
                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    }
                    
                }
                
            }
            
        }
            /**************************************************************/
            /************RECEIPT NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGCardToCardReceiptNode {
            
            
            if (self.finalRoomType == .channel) {
                
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 14),child: stack)
            } else {
                
                if isIncomming {
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 14),child: stack)
                    
                } else {
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [])
                    timeStatusStack.verticalAlignment = .center
                    
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 8,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
            
            
        }
        else if let _ = bubbleNode as? IGMoneytransferReceiptNode {
            
            
            if (self.finalRoomType == .channel) {
                
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 14),child: stack)
            } else {
                
                if isIncomming {
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 14),child: stack)
                    
                } else {
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [])
                    timeStatusStack.verticalAlignment = .center
                    
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 8,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
            
            
        }
            
            /**************************************************************/
            /************VOICE NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGVoiceNode {
            
            if layoutMsg!.attachment != nil{
                
                if (self.finalRoomType == .channel) {
                    
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                    
                } else {
                    
                    if isIncomming {
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    } else {
                        let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                        timeStatusStack.verticalAlignment = .center
                        
                        stack.children?.append(timeStatusStack)
                        verticalSpec.child = ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    }
                    
                }
                
            }
            
        }
            
            /**************************************************************/
            /************MUSIC NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGMusicNode {
            
            if let msattachment = layoutMsg!.attachment{
                
                if layoutMsg!.attachment != nil{
                    
                    if (self.finalRoomType == .channel) {
                        
                        stack.children?.append(txtTimeNode)
                        verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                        
                    } else {
                        
                        if isIncomming {
                            stack.children?.append(txtTimeNode)
                            verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset, bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                            
                        } else {
                            let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                            timeStatusStack.verticalAlignment = .center
                            
                            stack.children?.append(timeStatusStack)
                            verticalSpec.child = ASInsetLayoutSpec(
                                insets: UIEdgeInsets(top: 8,left: 12 + textNodeVerticalOffset,bottom: 8,right: 12 + textNodeVerticalOffset),child: stack)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
            
            
            /**************************************************************/
            /************LOCATION NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGLocationNode{
            
            if (self.finalRoomType == .channel) {
                
                stack.children?.append(txtTimeNode)
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                
            } else {
                
                if isIncomming {
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                } else {
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                    timeStatusStack.verticalAlignment = .center
                    
                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
        }
            /**************************************************************/
            /************CONTACT NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGContactNode{
            
            if (self.finalRoomType == .channel) {
                
                stack.children?.append(txtTimeNode)
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                
            } else {
                
                if isIncomming {
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                } else {
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                    timeStatusStack.verticalAlignment = .center
                    
                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
            
            
        }
            
            /**************************************************************/
            /************NORMAL STICKER NODE**************/
            /**************************************************************/
            
        else if let _ = bubbleNode as? IGStrickerNormalNode{
            
            if (self.finalRoomType == .channel) {
                
                stack.children?.append(txtTimeNode)
                verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                
            } else {
                
                if isIncomming {
                    stack.children?.append(txtTimeNode)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 14,bottom: 8,right: 5),child: stack)
                    
                } else {
                    subNode.style.preferredSize = CGSize(width: 100, height: 30)
                    subNode.backgroundColor = UIColor(white: 0, alpha: 0.6)
                    subNode.layer.cornerRadius = 5
                    let timeStatusBackBox = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: [txtTimeNode,txtStatusNode])
                    timeStatusBackBox.verticalAlignment = .center
                    let backBox = ASBackgroundLayoutSpec(child: timeStatusBackBox, background: subNode)
                    
                    let timeStatusStack = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .end, children: [backBox])
                    
                    stack.children?.append(timeStatusStack)
                    verticalSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8,left: 5,bottom: 8,right: 14),child: stack)
                    
                }
                
            }
            
            
            
        }
        
        
        //        space it
        
        var insetSpec : ASInsetLayoutSpec!
        if isFromSameSender {
            if self.finalRoom.type == .channel {
                insetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0), child: verticalSpec)

            } else if self.finalRoom.type == .group {
                insetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 10), child: verticalSpec)
                
            } else {
                insetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 10), child: verticalSpec)

            }
        } else {
            insetSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 14, left: 5, bottom: 0, right: 0) : UIEdgeInsets(top: 14, left: 4, bottom: 0, right: 0), child: verticalSpec)
        }
        
        
        let stackSpec = ASStackLayoutSpec()
        stackSpec.direction = .vertical
        stackSpec.justifyContent = .spaceAround
        stackSpec.alignItems = isIncomming ? .start : .end
        stackSpec.style.flexShrink = 1.0
        stackSpec.style.flexGrow = 1.0
        
        stackSpec.spacing = 0
        stackSpec.children = [insetSpec]
        
        
        imgNodeReply.style.width = ASDimension(unit: .points, value: 32)
        imgNodeReply.style.height = ASDimension(unit: .points, value: 32)
        //checks if is from same sender or not handles showing avatar for diffrent types of room types
        if !isFromSameSender {
            if self.finalRoom.type == .group {
                let ASBGStack = ASBackgroundLayoutSpec(child: avatarBtnViewNode, background: avatarImageViewNode)
                
                let stackHSpec = ASStackLayoutSpec()
                stackHSpec.direction = .horizontal
                stackHSpec.spacing = 5
                stackHSpec.verticalAlignment = .bottom

                stackHSpec.children = isIncomming ? [ASBGStack,stackSpec, imgNodeReply] : [imgNodeReply, stackSpec,ASBGStack]
                stackHSpec.style.flexShrink = 1.0
                stackHSpec.style.flexGrow = 1.0
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 4) : UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5), child: stackHSpec)
                
                return insetHSpec


            } else if self.finalRoom.type == .chat {
                let stackHSpec = ASStackLayoutSpec()
                stackHSpec.direction = .horizontal
                stackHSpec.spacing = 5
                stackHSpec.verticalAlignment = .bottom

                stackHSpec.children = isIncomming ? [stackSpec, imgNodeReply] : [imgNodeReply, stackSpec]
                stackHSpec.style.flexShrink = 1.0
                stackHSpec.style.flexGrow = 1.0
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 5), child: stackHSpec)
                
                return insetHSpec

            } else  {
                let ASBGStack = ASBackgroundLayoutSpec(child: avatarBtnViewNode, background: avatarImageViewNode)
                let stackHSpec = ASStackLayoutSpec()
                stackHSpec.direction = .horizontal
                stackHSpec.spacing = 5
                stackHSpec.verticalAlignment = .bottom

                stackHSpec.children = isIncomming ? [ASBGStack,stackSpec, imgNodeReply] : [imgNodeReply, stackSpec,ASBGStack]
                stackHSpec.style.flexShrink = 1.0
                stackHSpec.style.flexGrow = 1.0
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 5), child: stackHSpec)
                
                return insetHSpec

            }
        } else {
            if self.finalRoom.type == .channel {
                
                let ASBGStack = ASBackgroundLayoutSpec(child: avatarBtnViewNode, background: avatarImageViewNode)
                let stackHSpec = ASStackLayoutSpec()
                stackHSpec.direction = .horizontal
                stackHSpec.spacing = 5
                stackHSpec.verticalAlignment = .bottom

                stackHSpec.children = isIncomming ? [ASBGStack,stackSpec, imgNodeReply] : [imgNodeReply, stackSpec,ASBGStack]
                stackHSpec.style.flexShrink = 1.0
                stackHSpec.style.flexGrow = 1.0
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 5), child: stackHSpec)
                
                return insetHSpec

            } else {
                let stackHSpec = ASStackLayoutSpec()
                stackHSpec.direction = .horizontal
                stackHSpec.spacing = 5
                stackHSpec.verticalAlignment = .bottom

                stackHSpec.children = isIncomming ? [stackSpec, imgNodeReply] : [imgNodeReply, stackSpec]
                stackHSpec.style.flexShrink = 1.0
                stackHSpec.style.flexGrow = 1.0
                
                let insetHSpec = ASInsetLayoutSpec(insets: isIncomming ? UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 4) : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 5), child: stackHSpec)
                
                return insetHSpec

            }

        }

        
    }
    //- Hint : Check tap on user profile
    @objc func handleUserTap() {
        
        if(delegate != nil){
            if let msg = message{
                self.delegate.openuserProfile(message: msg)
                
            }
        }
    }
}

//MARK: - Gesture Recognizers

extension BaseBubbleNode: UIGestureRecognizerDelegate {
    
    func manageGestureRecognizers() {
        if !IGGlobal.shouldMultiSelect  {
            
            let tapAndHold = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnCell(_:)))
            tapAndHold.minimumPressDuration = 0.2
            self.view.addGestureRecognizer(tapAndHold)
            
            self.view.isUserInteractionEnabled = true
            
            if message?.repliedTo != nil {
                let onReplyClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnReply(_:)))
                replyForwardViewNode.view.addGestureRecognizer(onReplyClick)
                replyForwardViewNode.isUserInteractionEnabled = true
                if !(IGGlobal.shouldMultiSelect) {
                    replyForwardViewNode.isUserInteractionEnabled = true
                }else {
                    replyForwardViewNode.isUserInteractionEnabled = false
                    
                }
            }
            
            if message?.forwardedFrom != nil {
                let onForwardClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnForward(_:)))
                replyForwardViewNode.view.addGestureRecognizer(onForwardClick)
                if !(IGGlobal.shouldMultiSelect) {
                    replyForwardViewNode.isUserInteractionEnabled = true
                }else {
                    replyForwardViewNode.isUserInteractionEnabled = false
                }
            }
            
            if bubbleNode as? IGFileNode != nil {
                let onFileClick = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                bubbleNode.view.addGestureRecognizer(onFileClick)
                
                if !(IGGlobal.shouldMultiSelect) {
                    (bubbleNode as! IGFileNode).imgNode.isUserInteractionEnabled = true
                }
                else {
                    (bubbleNode as! IGFileNode).imgNode.isUserInteractionEnabled = false
                }
            }
            
            if bubbleNode as? IGImageNode != nil || bubbleNode as? IGVideoNode != nil {
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
                bubbleNode.view.addGestureRecognizer(tap1)
                if !(IGGlobal.shouldMultiSelect) {
                    bubbleNode.isUserInteractionEnabled = true
                }
                else {
                    bubbleNode.isUserInteractionEnabled = false
                }
            }
            
            //            if animationView != nil {
            //                let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnAttachment(_:)))
            //                animationView?.addGestureRecognizer(tap2)
            //                if !(IGGlobal.shouldMultiSelect) {
            //                    animationView?.isUserInteractionEnabled = true
            //                }
            //                else {
            //                    animationView?.isUserInteractionEnabled = false
            //                }
            //            }
            //            if btnReturnToMessageAbs != nil {
            //                let tapReturnToMessage = UITapGestureRecognizer(target: self, action: #selector(didTapOnReturnToMessage(_:)))
            //                btnReturnToMessageAbs?.addGestureRecognizer(tapReturnToMessage)
            //            }
            //
            //            let statusGusture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFailedStatus(_:)))
            //            txtStatusAbs?.addGestureRecognizer(statusGusture)
            //            txtStatusAbs?.isUserInteractionEnabled = true
            //
            //            let tap5 = UITapGestureRecognizer(target: self, action: #selector(didTapOnSenderAvatar(_:)))
            //            avatarViewAbs?.addGestureRecognizer(tap5)
            //
            //            let tapVoteUp = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteUp(_:)))
            //            txtVoteUpAbs?.addGestureRecognizer(tapVoteUp)
            //            txtVoteUpAbs?.isUserInteractionEnabled = true
            //
            //            let tapVoteDown = UITapGestureRecognizer(target: self, action: #selector(didTapOnVoteDown(_:)))
            //            txtVoteDownAbs?.addGestureRecognizer(tapVoteDown)
            //            txtVoteDownAbs?.isUserInteractionEnabled = true
            
        }
    }
    
    @objc func didTapAndHoldOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if !(IGGlobal.shouldMultiSelect) {
                self.generalMessageDelegate?.didTapAndHoldOnMessage(cellMessage: message!)
            }
        default:
            break
        }
    }
    
    func didTapAttachmentOnCell(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            if message!.attachment != nil {
                didTapOnAttachment(gestureRecognizer)
            }
        }
    }
    
    @objc func onMultiForwardTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.generalMessageDelegate?.didTapOnMultiForward(cellMessage: message!, isFromCloud: IGGlobal.isCloud(room: finalRoom))
    }
    
    @objc func didTapOnAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.generalMessageDelegate?.didTapOnAttachment(cellMessage: message!)
        }
    }
    
    @objc func didTapOnReply(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.generalMessageDelegate?.didTapOnReply(cellMessage: message!)
        }
    }
    
    @objc func didTapOnForward(_ gestureRecognizer: UITapGestureRecognizer) {
        self.generalMessageDelegate?.didTapOnForward(cellMessage: message!)
    }
    
    @objc func didTapOnReturnToMessage(_ gestureRecognizer: UITapGestureRecognizer) {
        self.generalMessageDelegate?.didTapOnReturnToMessage()
    }
    
    @objc func didTapOnFailedStatus(_ gestureRecognizer: UITapGestureRecognizer) {
        if message!.status == .failed {
            self.generalMessageDelegate?.didTapOnFailedStatus(cellMessage: message!)
        }
    }
    
    func didTapOnForwardedAttachment(_ gestureRecognizer: UITapGestureRecognizer) {
        self.generalMessageDelegate?.didTapOnForwardedAttachment(cellMessage: message!)
        
    }
    
    @objc func didTapOnSenderAvatar(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {
            self.generalMessageDelegate?.didTapOnSenderAvatar(cellMessage: message!)
        }
    }
    
    //    @objc func didTapOnVoteUp(_ gestureRecognizer: UITapGestureRecognizer) {
    //        var messageVote: IGRoomMessage! = message
    //        if let forward = message!.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
    //            messageVote = forward
    //        }
    //        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsUp)
    //    }
    //
    //    @objc func didTapOnVoteDown(_ gestureRecognizer: UITapGestureRecognizer) {
    //        var messageVote: IGRoomMessage! = message
    //        if let forward = message!.forwardedFrom, forward.authorRoom != nil { // just channel has authorRoom, so don't need check room type
    //            messageVote = forward
    //        }
    //        IGChannelAddMessageReactionRequest.sendRequest(roomId: (messageVote.authorRoom?.id)!, messageId: messageVote.id, reaction: IGPRoomMessageReaction.thumbsDown)
    //    }
    //
    //    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //        return true
    //    }
    //
    //    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        if pan != nil {
    //            let direction = pan.direction(in: superview!)
    //            if direction.contains(.Left) {
    //                return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    //            } else {
    //                return false
    //            }
    //        }
    //        else {
    //            return false
    //        }
    //    }
    
    
    
    
    /*
     ******************************************************************
     ************************** Swipe to Reply ************************
     ******************************************************************
     */
    
    private func makeSwipeImage() {

        
        imgNodeReply.contentMode = .scaleAspectFit
        imgNodeReply.image = UIImage(named: "ig_message_reply")
        imgNodeReply.alpha = 0.5
        
    }
    
    private func swipePositionManager(){
        if finalRoom.isInvalidated {
            return
        }
        if finalRoomType == .chat || finalRoomType == .group {
            if pan != nil {
                
                if (pan.state == UIGestureRecognizer.State.changed) {
                    
                    //                    self.insertSubview(imgReply, belowSubview: self.contentView)
                    //                    insertSubnode(imgNodeReply, belowSubnode: self)
                    
                    let p: CGPoint = pan.translation(in: view)
                    let width = self.view.frame.width
                    let height = self.view.frame.height
                    self.view.frame = CGRect(x: p.x,y: 0, width: width, height: height);
                    self.imgNodeReply.frame = CGRect(x: p.x + width + imgNodeReply.frame.size.width, y: (height/2) - (imgNodeReply.frame.size.height) / 2 , width: CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT), height: CGFloat(CellSizeCalculator.IMG_REPLY_DEFAULT_HEIGHT))
                    
                } else if (pan.state == UIGestureRecognizer.State.ended) || (pan.state == UIGestureRecognizer.State.cancelled) {
                    imgNodeReply.removeFromSupernode()
                }
            }
            else {
                return
            }
        }
    }
    
    @objc func onSwipe(_ pan: UIPanGestureRecognizer) {
        
        let minReplySwipeValue: CGFloat = 80
        
        if pan.state == UIGestureRecognizer.State.began {
            
        } else if pan.state == UIGestureRecognizer.State.changed {

            self.setNeedsLayout()
            //            UIView.animate(withDuration: 0.2, animations: {[weak self] in
            //                guard let sSelf = self else {
            //                    return
            //                }
            //
            //                let p: CGPoint = sSelf.pan.translation(in: sSelf.view)
            //                sSelf.view.frame.origin.x = p.x
            //            })
            
            if finalRoomType! != .channel {
                UIView.animate(withDuration: 0.2, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    
                    let p: CGPoint = sSelf.pan.translation(in: sSelf.view)
                    sSelf.view.frame.origin.x = p.x
                    sSelf.imgNodeReply.alpha = ((-p.x) * CGFloat(0.5))/60
                    
                }) {[weak self] (done) in
                    guard let sSelf = self else {
                        return
                    }
                    
                    sSelf.imgNodeReply.isUserInteractionEnabled = true
                    
                }
            }else {
                UIView.animate(withDuration: 0.2) {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    let p: CGPoint = sSelf.pan.translation(in: sSelf.view)
                    sSelf.view.frame.origin.x = p.x
                }
            }
            
        } else {

          
            let shouldReply = pan.translation(in: self.view).x < -minReplySwipeValue
            let direction = pan.direction(in: view.superview!)
            
            if finalRoomType! != .channel {
                UIView.animate(withDuration: 0.2, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    
                    sSelf.view.frame.origin.x = 0
                    sSelf.imgNodeReply.alpha = 0
                    
                }) {[weak self] (done) in
                    guard let sSelf = self else {
                        return
                    }
                    
                    sSelf.imgNodeReply.isUserInteractionEnabled = true
                    
                }
            }else {
                UIView.animate(withDuration: 0.2) {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.view.frame.origin.x = 0
                }
            }
            
            
            if direction.contains(.Left) {
                switch message!.status {
                    
                case .failed, .unknown , .sending:
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    })
                    break
                default :
                    if (shouldReply) {
                        let tableView = view.superview!.superview!.superview as! UITableView
                        let indexPath = tableView.indexPathForRow(at: view.center)!
                        tableView.delegate?.tableView?(tableView, performAction: #selector(onSwipe(_:)), forRowAt: indexPath, withSender: nil)
                        
                        UIView.animate(withDuration: 0.2, animations: {[weak self] in
                            guard let sSelf = self else {
                                return
                            }
                            sSelf.view.setNeedsLayout()
                            sSelf.generalMessageDelegate?.swipToReply(cellMessage: sSelf.message!)
                            sSelf.view.layoutIfNeeded()
                        })
                        
                    } else {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.view.setNeedsLayout()
                            self.view.layoutIfNeeded()
                        })
                    }
                    break
                }
                
            } else if direction.contains(.Down) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if pan != nil {
            let direction = pan.direction(in: self.view)
            if direction.contains(.Left)
            {
                return abs((pan.velocity(in: self.view)).x) > abs((pan.velocity(in: self.view)).y)
            }
            else {
                return true
            }
            
            
        }
        else {
            return true
            
        }
    }
    
}
