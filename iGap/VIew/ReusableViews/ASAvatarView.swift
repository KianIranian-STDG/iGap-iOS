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


class ASAvatarView: ASDisplayNode {
    
    private var initialLettersView: ASDisplayNode?
    private var initialLettersLabel: ASTextNode?
    var avatarASImageView: ASNetworkImageNode?

    private var hasAvatar: Bool = false
    

    // MARK: - Initializers
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        configure()
    }
    
    deinit {
        initialLettersView = nil
        initialLettersLabel = nil
        avatarASImageView = nil
    }
    
    private func configure() {
        layer.cornerRadius = frame.width / 2.0
        layer.masksToBounds = true
        backgroundColor = .purple
        
        if initialLettersView == nil {
            initialLettersView = ASDisplayNode()
            initialLettersView?.style.preferredSize = CGSize(width: 50, height: 50)
        }
        
        if initialLettersLabel == nil {
            initialLettersLabel = ASTextNode()
//            initialLettersLabel?.style.preferredSize = CGSize(width: 50, height: 50)
            initialLettersLabel?.style.width = ASDimension(unit: .points, value: 50)
        }
        
        if avatarASImageView == nil {
            avatarASImageView = ASNetworkImageNode()
            avatarASImageView?.style.preferredSize = CGSize(width: 50, height: 50)
        }
        
        
        
        
//        self.subnodes!.forEach {
//            $0.removeFromSupernode()
//        }
//        self.initialLettersView = ASDisplayNode()
//        addSubnode(self.initialLettersView!)
//        initialLettersView!.style.height = ASDimension(unit: .points, value: 50.0)

//        self.initialLettersLabel = ASTextNode()

//        addSubnode(self.initialLettersLabel!)
//        self.avatarASImageView = ASNetworkImageNode()
//        addSubnode(self.avatarASImageView!)
//        avatarASImageView!.style.height = ASDimension(unit: .points, value: 50.0)
//        avatarASImageView!.style.width = ASDimension(unit: .points, value: 50.0)

    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        let stack = ASStackLayoutSpec()
//        stack.direction = .vertical
//        stack.style.flexShrink = 1.0
//        stack.style.flexGrow = 1.0
//        stack.justifyContent = .spaceBetween
//        stack.alignItems = .stretch
//        stack.spacing = 5
        
        
        let centerInitial = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: initialLettersLabel!)
        let initalOverlay = ASOverlayLayoutSpec(child: initialLettersView!, overlay: centerInitial)
        return ASOverlayLayoutSpec(child: initalOverlay, overlay: avatarASImageView!)
        
//        stack.children?.append(self.initialLettersView!)
//        if hasAvatar {
//            let ASCStack = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.avatarASImageView!)
//            let ASBGStack = ASBackgroundLayoutSpec(child: ASCStack, background: self.initialLettersView!)
//
//            return ASBGStack
//
//        } else {
//            let ASCStack = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.initialLettersLabel!)
//            let ASBGStack = ASBackgroundLayoutSpec(child: ASCStack, background: self.initialLettersView!)
//
//            return ASBGStack
//
//        }
        
    }
    func setUser(_ user: IGRegisteredUser) {
        if user.isInvalidated {
            return
        }

//        if user.avatar != nil {
//            hasAvatar = true
//        } else {
//            hasAvatar = false
//        }
//        if hasAvatar {
//            self.initialLettersLabel?.removeFromSupernode() //removes the initial label if the user has Avatar
//            self.avatarASImageView?.setAvatar(avatar: user.avatar!.file!)
////            self.avatarASImageView?.image = UIImage(named: "AppIcon")
//        } else {
//            self.avatarASImageView?.removeFromSupernode() //removes the Avatar Image Node if the user has not Avatar
//
//            IGGlobal.makeAsyncText(for: self.initialLettersLabel!, with: user.initials, textColor: .white, size: 15, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
//            let color = UIColor.hexStringToUIColor(hex: user.color)
//            self.initialLettersView!.backgroundColor = color
//
//        }
        
//        self.avatarASImageView?.image = UIImage(named: "AppIcon")
        
        IGGlobal.makeAsyncText(for: self.initialLettersLabel!, with: user.initials, textColor: .white, size: 15, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
        self.initialLettersView!.backgroundColor = UIColor.hexStringToUIColor(hex: user.color)
        if user.avatar != nil {
//            self.avatarASImageView?.setAvatar(avatar: user.avatar!.file!)
            getAvatar(networkAvatarNode: avatarASImageView!, avatar: user.avatar!.file!) { (image) in
                if let img = image {
                    self.avatarASImageView?.image = img
                }
            }
            
        }
    }
    
    
    private func getAvatar(networkAvatarNode: ASNetworkImageNode, avatar: IGFile, type: PreviewType = PreviewType.largeThumbnail, completion: @escaping((UIImage?)->Void)) {
           
                // remove imageview from download list on t on cell reuse
        //        DispatchQueue.main.async {
                    let keys = (ASNetworkimagesMap as NSDictionary).allKeys(for: networkAvatarNode) as! [String]
                    keys.forEach { (key) in
                        ASNetworkimagesMap.removeValue(forKey: key)
                    }
        //        }
                
                var file : IGFile!
                var previewType : PreviewType!

                if type == .largeThumbnail ,let largeThumbnail = avatar.largeThumbnail {
                    file = largeThumbnail
                    previewType = PreviewType.largeThumbnail
                } else {
                    file = avatar.smallThumbnail
                    previewType = PreviewType.smallThumbnail
                }
                
                if IGGlobal.isFileExist(path: avatar.localPath, fileSize: avatar.size) {
                    //            self.sd_setImage(with: avatar.path(), completed: nil)
                    if let data = try? Data(contentsOf: avatar.localUrl!) {
                        if let image = UIImage(data: data) {
                            completion(image)
                        }
                    }
                } else {
                    if file != nil {

                        let path = file.localUrl
                        if IGGlobal.isFileExist(path: path, fileSize: file.size) {
                            //                    self.sd_setImage(with: path, completed: nil)
                            if let data = try? Data(contentsOf: path!) {
                                if let image = UIImage(data: data) {
                                    completion(image)
                                }
                            }
                            
                        } else {
                            file = file.detach()
                            ASNetworkimagesMap[file.token!] = networkAvatarNode
                            DispatchQueue.main.async {
                                
                                IGDownloadManager.sharedManager.download(file: file, previewType: previewType, completion: { (attachment) -> Void in
                                    DispatchQueue.main.async {
                                        if let imageMain = ASNetworkimagesMap[attachment.token!] {
                                            let path = attachment.localUrl
                                            //imageMain.sd_setImage(with: path)
                                            DispatchQueue.global(qos:.userInteractive).async {
                                                if let data = try? Data(contentsOf: path!) {
                                                    if let image = UIImage(data: data) {
                                                        DispatchQueue.main.async {
                                                            imageMain.image = image
                                                            completion(image)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }, failure: {
                                    print("ERROR HAPPEND IN DOWNLOADNING AVATAR")
                                })
                                
                            }
                        }
                    }
                }
    }
    
    
    func setRoom(_ room: IGRoom) {
        
        if room.isInvalidated {
            return
        }
        
        self.avatarASImageView!.image = nil

        
        var ownerId: Int64 = room.id
        if room.type == .chat {
            ownerId = (room.chatRoom?.peer!.id)!
        }
        
        if let avatar = IGAvatar.getLastAvatar(ownerId: ownerId), let avatarFile = avatar.file {
            self.avatarASImageView!.setAvatar(avatar: avatarFile)
            hasAvatar = true
        } else { /// HINT: old version dosen't have owernId so currently we have to check this state
            var file: IGFile?
            if room.type == .chat, let avatar = room.chatRoom?.peer?.avatar?.file {
                file = avatar
            } else if room.type == .group, let avatar = room.groupRoom?.avatar?.file {
                file = avatar
            } else if room.type == .channel, let avatar = room.channelRoom?.avatar?.file {
                file = avatar
            }
            
            if file != nil {
                self.avatarASImageView!.setAvatar(avatar: file!)
                hasAvatar = true
            } else {
                hasAvatar = false

            }
        }

                if hasAvatar {
                    self.initialLettersLabel?.removeFromSupernode() //removes the initial label if the user has Avatar
                } else {
                    self.avatarASImageView?.removeFromSupernode() //removes the Avatar Image Node if the user has not Avatar
                    
                    if self.frame.size.width < 40 {
                        IGGlobal.makeAsyncText(for: self.initialLettersLabel!, with: room.initilas!, textColor: .white, size: 10, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
                        let color = UIColor.hexStringToUIColor(hex: room.colorString)
                        self.initialLettersView!.backgroundColor = color
                    } else if self.frame.size.width < 60 {
                        IGGlobal.makeAsyncText(for: self.initialLettersLabel!, with: room.initilas!, textColor: .white, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
                        let color = UIColor.hexStringToUIColor(hex: room.colorString)
                        self.initialLettersView!.backgroundColor = color
                    } else {
                        IGGlobal.makeAsyncText(for: self.initialLettersLabel!, with: room.initilas!, textColor: .white, size: 17, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .center)
                        let color = UIColor.hexStringToUIColor(hex: room.colorString)
                        self.initialLettersView!.backgroundColor = color
                    }

                    
                }



    }
    
    
}
