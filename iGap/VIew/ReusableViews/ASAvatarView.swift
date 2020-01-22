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
        configure()
    }
    

    
    
    
    private func configure() {
        self.layer.cornerRadius = self.frame.width / 2.0
        self.layer.masksToBounds = true
        self.backgroundColor = .purple
        self.subnodes!.forEach {
            $0.removeFromSupernode()
        }
        self.initialLettersView = ASDisplayNode()        
        addSubnode(self.initialLettersView!)
        initialLettersView?.backgroundColor = .red
        initialLettersView!.style.height = ASDimension(unit: .points, value: 50.0)

            self.initialLettersLabel = ASTextNode()
            let attribbutes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]

            self.initialLettersLabel!.attributedText = NSAttributedString(string: "تست", attributes: attribbutes)
            addSubnode(self.initialLettersLabel!)
            self.avatarASImageView = ASNetworkImageNode()
            addSubnode(self.avatarASImageView!)




    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.justifyContent = .spaceBetween
        stack.alignItems = .stretch
//        stack.spacing = 5
        
        stack.children?.append(self.initialLettersView!)
        if hasAvatar {
            let ASCStack = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.initialLettersLabel!)
            let ASBGStack = ASBackgroundLayoutSpec(child: ASCStack, background: self.avatarASImageView!)

            return ASBGStack

        } else {
            let ASCStack = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.initialLettersLabel!)
            let ASBGStack = ASBackgroundLayoutSpec(child: ASCStack, background: self.initialLettersView!)

            return ASBGStack

        }
        
    }
    func setUser(_ user: IGRegisteredUser) {
        if user.isInvalidated {
            return
        }

        if user.avatar != nil {
            hasAvatar = true
        } else {
            hasAvatar = false
        }
        if hasAvatar {
            self.initialLettersLabel?.removeFromSupernode() //removes the initial label if the user has Avatar
            self.avatarASImageView?.setAvatar(avatar: user.avatar!.file!)
        } else {
            self.avatarASImageView?.removeFromSupernode() //removes the Avatar Image Node if the user has not Avatar
            let attribbutes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)]

            self.initialLettersLabel!.attributedText = NSAttributedString(string: user.initials, attributes: attribbutes)
            let color = UIColor.hexStringToUIColor(hex: user.color)
            self.initialLettersView!.backgroundColor = color

        }


        
    }
    
}
