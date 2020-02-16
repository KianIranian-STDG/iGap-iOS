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
import Lottie

public enum logMessageType:Int {
    
    case unread            = 1 // exp: 12 unread messages
    case log            = 2 //exp : ali was added to group
    case time            = 3 //time between chats
    case progress            = 4 //progress for loading new chats
    case emptyBox            = 5 //progress for loading new chats
    case unknown            = 6 //unknown message
}
class IGLogNode: ASCellNode {
    
    private let txtLogMessage = ASTextNode()
    let progressNode = ASDisplayNode { () -> UIView in
        let animationView = AnimationView()
        return animationView
    }
    private var bgTextNode = ASDisplayNode()
    private var bgProgressNode = ASDisplayNode()
    private var bgNode = ASDisplayNode()
    private var finalRoom: IGRoom!
    private var finalRoomType: IGRoom.IGType!
    var message: IGRoomMessage?
    private var logType: logMessageType!

    
    init(message: IGRoomMessage? = nil, logType: logMessageType = .log, finalRoomType : IGRoom.IGType,finalRoom: IGRoom) {
        if message != nil {
            self.message = message
        }
        self.logType = logType
        self.finalRoom = finalRoom
        self.finalRoomType = finalRoomType
        if logType == .progress {
        }
        super.init()
        setupView()
    }
    override func didLoad() {
        super.didLoad()
        self.view.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    func setupView() {
        addSubnode(self.bgNode)
        
        if self.logType == .progress {
            addSubnode(self.progressNode)

            self.progressNode.style.height = ASDimensionMake(.points, 50)
            self.progressNode.style.width = ASDimensionMake(.points, 50)
            self.progressNode.backgroundColor = UIColor.white
            self.progressNode.layer.cornerRadius = 25
            DispatchQueue.main.async {
                (self.progressNode.view as! AnimationView).play()
                (self.progressNode.view as! AnimationView).frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                (self.progressNode.view as! AnimationView).contentMode = .scaleAspectFit
                let animation = Animation.named("messageLoader")
                (self.progressNode.view as! AnimationView).animation = animation
                (self.progressNode.view as! AnimationView).contentMode = .scaleAspectFit
                (self.progressNode.view as! AnimationView).play()
                (self.progressNode.view as! AnimationView).loopMode = .loop
                (self.progressNode.view as! AnimationView).backgroundBehavior = .pauseAndRestore
                (self.progressNode.view as! AnimationView).forceDisplayUpdate()

            }
            self.progressNode.alpha = 0.8

        } else if logType == .emptyBox { } else {
            addSubnode(self.bgTextNode)
            addSubnode(self.txtLogMessage)

            self.bgNode.style.height = ASDimensionMake(.points, 50)
            self.bgTextNode.style.height = ASDimensionMake(.points, 40)
            self.bgNode.backgroundColor = UIColor.clear
            
            switch logType {
                
            case .unread:
                setUnreadMessage(message!)
            case .log:
                setLogMessage(message!)
            case .time:
                setTime(message!.message!)
            case .unknown:
                setUnknownMessage()

            default:
                break
            }
        }

    }
    func setTime(_ time: String) {
        IGGlobal.makeAsyncText(for: self.txtLogMessage, with:time, textColor: .white, size: 15, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
        self.txtLogMessage.backgroundColor = UIColor.logBackground()
        self.txtLogMessage.layer.cornerRadius = 10.0
        self.txtLogMessage.clipsToBounds = true
        let logSize = (time.width(withConstrainedHeight: 20, font: UIFont.igFont(ofSize: 16)))
        self.txtLogMessage.style.width =  ASDimensionMake(.points, logSize + 10)

    }
    func setLogMessage(_ message: IGRoomMessage) {
        if message.log?.type == .pinnedMessage {
            IGGlobal.makeAsyncText(for: self.txtLogMessage, with: IGRoomMessage.detectPinMessage(message: message), textColor: .white, size: 15, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .center)

        } else {
            IGGlobal.makeAsyncText(for: self.txtLogMessage, with:IGRoomMessageLog.textForLogMessage(message), textColor: .white, size: 15, weight: .regular, numberOfLines: 1, font: .igapFont, alignment: .center)


        }
        self.txtLogMessage.backgroundColor = UIColor.logBackground()
        self.txtLogMessage.layer.cornerRadius = 10.0
        self.txtLogMessage.clipsToBounds = true
        let logSize = (IGRoomMessageLog.textForLogMessage(message).width(withConstrainedHeight: 20, font: UIFont.igFont(ofSize: 16)))
        self.txtLogMessage.style.width =  ASDimensionMake(.points, logSize)
    }
    
    func setUnknownMessage(){
        
        IGGlobal.makeAsyncText(for: self.txtLogMessage, with: IGStringsManager.UnknownMessage.rawValue.localized, textColor: .white, size: 15, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
        self.bgTextNode.layer.cornerRadius = 10.0
        self.bgTextNode.backgroundColor = UIColor.logBackground()
    }
    
    func setUnreadMessage(_ message: IGRoomMessage){
        IGGlobal.makeAsyncText(for: self.txtLogMessage, with: (message.message?.inLocalizedLanguage())!, textColor: .white, size: 15, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
        self.bgTextNode.layer.cornerRadius = 0.0
        self.bgTextNode.backgroundColor = UIColor.unreadBackground()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {


        if self.logType == .progress {
            let centerBoxText = ASCenterLayoutSpec(centeringOptions: .XY, child: progressNode)
            let backBox = ASBackgroundLayoutSpec(child: centerBoxText, background: self.bgNode)
            backBox.style.flexGrow = 0.0

            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0), child: backBox)
                
            
            return insetSpec

        } else if logType == .emptyBox {
            let verticalBox = ASStackLayoutSpec()
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0), child: verticalBox)
                
            
            return insetSpec

        } else {
            let centerBoxText = ASCenterLayoutSpec(centeringOptions: .XY, child: txtLogMessage)
            let backTextBox = ASBackgroundLayoutSpec(child: centerBoxText, background: self.bgTextNode)
            let backBox = ASBackgroundLayoutSpec(child: backTextBox, background: self.bgNode)
            backBox.style.flexGrow = 1.0

            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0), child: backBox)
                
            
            return insetSpec

        }

    }
    
}

