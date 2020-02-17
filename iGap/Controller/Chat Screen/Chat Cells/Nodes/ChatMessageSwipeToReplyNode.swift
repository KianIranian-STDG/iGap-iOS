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

final class ChatMessageSwipeToReplyNode: ASDisplayNode {
    private let backgroundNode: ASImageNode
    
    init(fillColor: UIColor, strokeColor: UIColor, foregroundColor: UIColor) {
        self.backgroundNode = ASImageNode()
        self.backgroundNode.isLayerBacked = true
        self.backgroundNode.image = UIImage(named: "ig_message_reply")
        
        super.init()
        
        self.addSubnode(self.backgroundNode)
        self.backgroundNode.frame = CGRect(origin: CGPoint(), size: CGSize(width: 33.0, height: 33.0))
    }
}
