/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation
import AsyncDisplayKit

class ASReplyForwardNode: ASDisplayNode {

    var isReply : Bool = true //if false means it's Forward
    private var verticalView : ASDisplayNode?
    override init() {
        super.init()
        configure()
    }

    
    private func configure() {
        self.subnodes!.forEach {
            $0.removeFromSupernode()
        }


        self.verticalView = ASDisplayNode()
        self.verticalView!.style.height = ASDimension(unit: .points, value: 40.0)
        self.verticalView!.style.width = ASDimension(unit: .points, value: 3.0)
        verticalView?.backgroundColor = .blue
        addSubnode(self.verticalView!)

    }

        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
            let stack = ASStackLayoutSpec()
            stack.direction = .horizontal
            stack.style.flexShrink = 1.0
            stack.style.flexGrow = 1.0
            stack.justifyContent = .spaceBetween
            stack.alignItems = .center
    //        stack.spacing = 5
            
            stack.children?.append(self.verticalView!)
            
            let stackV = ASStackLayoutSpec()
            stackV.direction = .vertical
            stackV.style.flexShrink = 1.0
            stackV.style.flexGrow = 1.0
            stackV.justifyContent = .center
            stackV.children?.append(stack)
            return stackV

        }
    func setReplyForward(isReply: Bool) {
        self.isReply = isReply
        if self.isReply {
            self.backgroundColor = .purple

        } else {
            self.backgroundColor = .red
            self.verticalView!.style.height = ASDimension(unit: .points, value: 100.0)
//            self.style.height = ASDimension(unit: .points, value: 50.0 + self.verticalView!.style.height.value)

        }
    }
}
