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
import SnapKit
import Lottie

class ASAnimationManager: ASDisplayNode {
    
    private var LiveStickerView = ASDisplayNode { () -> UIView in
        let animationView = AnimationView()
        return animationView
    }
    private var NormalGiftStickerView: ASNetworkImageNode?
    private var message : IGRoomMessage?

    // MARK: - Initializers
    init(message: IGRoomMessage) {
        self.message = message

        super.init()
        configure()
    }
    private func configure() {
        
        switch message?.additional?.dataType {
            
        case AdditionalType.STICKER.rawValue :
            if (self.message!.attachment?.name!.hasSuffix(".json") ?? false) {
                initAnimatedSticker()
            }  else {
                initNormalGiftSticker()
            }
        case AdditionalType.GIFT_STICKER.rawValue :
            initNormalGiftSticker()

        default : break
            
        }
        manageAttachment()
    }
    private func manageAttachment() {

        if self.message!.additional?.dataType == AdditionalType.STICKER.rawValue {
            
            if let stickerStruct = IGHelperJson.parseStickerMessage(data: (self.message!.additional?.data)!) {
                //IGGlobal.imgDic[stickerStruct.token!] = self.imgMediaAbs
                DispatchQueue.main.async {
                    IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerStruct.token) { (file) in
                        
                        if (self.message!.attachment?.name!.hasSuffix(".json") ?? false) {
                            (self.LiveStickerView.view as! AnimationView).setLiveSticker(for: file)
                        } else {
                            self.NormalGiftStickerView!.setSticker(for: file)
                        }
                        
                    }
                }
            } else {
                if let stickerStruct = IGHelperJson.parseStickerMessage(data: (self.message!.additional?.data)!) {
                    
                    DispatchQueue.main.async {
                        IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerStruct.token) { (file) in
                            self.NormalGiftStickerView!.setSticker(for: file)
                        }
                    }
                }
            }
            return
        }

        
    }
    private func initAnimatedSticker() {
        addSubnode(LiveStickerView)
        self.LiveStickerView.style.height = ASDimensionMake(.points, 200)
        self.LiveStickerView.style.width = ASDimensionMake(.points, 200)

        DispatchQueue.main.async {[weak self] in
            guard let sSelf = self else {
                return
            }
            (sSelf.LiveStickerView.view as! AnimationView).play()
            (sSelf.LiveStickerView.view as! AnimationView).frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            (sSelf.LiveStickerView.view as! AnimationView).contentMode = .scaleAspectFit
            (sSelf.LiveStickerView.view as! AnimationView).play()
            (sSelf.LiveStickerView.view as! AnimationView).loopMode = .loop
            (sSelf.LiveStickerView.view as! AnimationView).backgroundBehavior = .pauseAndRestore
            (sSelf.LiveStickerView.view as! AnimationView).forceDisplayUpdate()

        }
    }
    
    private func initNormalGiftSticker() {
        NormalGiftStickerView = ASNetworkImageNode()
        self.NormalGiftStickerView!.style.height = ASDimensionMake(.points, 200)
        self.NormalGiftStickerView!.style.width = ASDimensionMake(.points, 200)

        addSubnode(NormalGiftStickerView!)
    }
    

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let stackBox = ASStackLayoutSpec()
        stackBox.direction = .vertical
        switch message?.additional?.dataType {
            
        case AdditionalType.STICKER.rawValue :
            if (self.message!.attachment?.name!.hasSuffix(".json") ?? false) {
                stackBox.children = [LiveStickerView]
            } else {
                stackBox.children = [NormalGiftStickerView!]
            }
        case AdditionalType.GIFT_STICKER.rawValue :
            stackBox.children = [NormalGiftStickerView!]

        default : break
            
        }

        return stackBox
        
    }
    
}
