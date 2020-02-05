  
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
