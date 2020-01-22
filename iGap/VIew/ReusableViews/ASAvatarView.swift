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
    
    

    // MARK: - Initializers
    override init() {
        super.init()
        configure()
    }
    

    
    
    
    private func configure() {
        self.layer.cornerRadius = self.frame.width / 2.0
        self.layer.masksToBounds = true
        self.backgroundColor = .purple
//        let subViewsFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.subnodes!.forEach {
            $0.removeFromSupernode()
        }
        self.initialLettersView = ASDisplayNode()        
        addSubnode(self.initialLettersView!)
        initialLettersView?.backgroundColor = .red
        initialLettersView!.style.height = self.style.height

    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec()
        stack.direction = .vertical
        stack.style.flexShrink = 1.0
        stack.style.flexGrow = 1.0
        stack.justifyContent = .spaceAround
//        stack.spacing = 5
        
        stack.children?.append(self.initialLettersView!)

        return stack

    }
    
}
