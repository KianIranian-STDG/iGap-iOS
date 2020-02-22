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

class IGStickerNode: ASCellNode {
    private var LiveStickerView = ASDisplayNode { () -> UIView in
        let animationView = AnimationView()
        return animationView
    }
    private var NormalGiftStickerView = ASDisplayNode { () -> UIView in
        let animationView = UIImageView()
        return animationView
    }
    private var finalRoom: IGRoom!
    private var finalRoomType: IGRoom.IGType!
    private var message: IGRoomMessage!
    private var isIncomming : Bool?

    
    init(message: IGRoomMessage, isIncomming: Bool,finalRoomType : IGRoom.IGType,finalRoom: IGRoom) {
        self.message = message
        self.isIncomming = isIncomming
        self.finalRoom = finalRoom
        self.finalRoomType = finalRoomType
        super.init()
        setupView()
    }
    deinit {
        print("CHECK DEINIT FOR STICKERNODE SELF: \(self) REMOVED")
        print("CHECK DEINIT FOR STICKERNODE LIVESTICKERVIEW: \(LiveStickerView) REMOVED" )
        print("CHECK DEINIT FOR STICKERNODE NORMALGIFVIEW: \(NormalGiftStickerView) REMOVED" )
        print("CHECK DEINIT FOR STICKERNODE FINALROOM: \(finalRoom) REMOVED" )
        print("CHECK DEINIT FOR STICKERNODE MESSAGE: \(message) REMOVED" )
        print("CHECK DEINIT FOR STICKERNODE ISINCOMMING: \(isIncomming) REMOVED" )
    }
    func setupView() {
        

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
                        } else  {
                            (self.NormalGiftStickerView.view as! UIImageView).setSticker(for: file)
                        }
                        
                    }
                }
            } else {
                if let stickerStruct = IGHelperJson.parseStickerMessage(data: (self.message!.additional?.data)!) {
                    
                    DispatchQueue.main.async {
                        IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerStruct.token) { (file) in
                            (self.NormalGiftStickerView.view as! UIImageView).setSticker(for: file)
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
            (sSelf.LiveStickerView.view as! AnimationView).frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            (sSelf.LiveStickerView.view as! AnimationView).contentMode = .scaleAspectFit
            (sSelf.LiveStickerView.view as! AnimationView).loopMode = .loop
            (sSelf.LiveStickerView.view as! AnimationView).backgroundBehavior = .pauseAndRestore
            (sSelf.LiveStickerView.view as! AnimationView).forceDisplayUpdate()

        }
    }
    
    private func initNormalGiftSticker() {
        self.NormalGiftStickerView.style.height = ASDimensionMake(.points, 200)
        self.NormalGiftStickerView.style.width = ASDimensionMake(.points, 200)

        addSubnode(NormalGiftStickerView)
    }
    

    

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        switch message?.additional?.dataType {
            
        case AdditionalType.STICKER.rawValue :
            if (self.message!.attachment?.name!.hasSuffix(".json") ?? false) {
                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0), child: LiveStickerView)
                
                return insetSpec

            } else {
                let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0), child: NormalGiftStickerView)
                
                return insetSpec

            }
        case AdditionalType.GIFT_STICKER.rawValue :
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0), child: NormalGiftStickerView)
            
            return insetSpec

        default :
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0), child: NormalGiftStickerView)
            
            return insetSpec

            
        }

    }
    
}

