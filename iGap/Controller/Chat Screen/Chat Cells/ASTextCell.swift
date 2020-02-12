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

let mineImage = UIImage(named: "BubbleOutOne")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14).withRenderingMode(.alwaysTemplate)
let someoneImage = UIImage(named: "BubbleOutOne")!.withHorizontallyFlippedOrientation().stretchableImage(withLeftCapWidth: 21, topCapHeight: 14).withRenderingMode(.alwaysTemplate)
let tailLesImage = UIImage(named: "BubbleOutThree")!.withHorizontallyFlippedOrientation().stretchableImage(withLeftCapWidth: 21, topCapHeight: 14).withRenderingMode(.alwaysTemplate)
let mineTailLesImage = UIImage(named: "BubbleOutThree")!.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14).withRenderingMode(.alwaysTemplate)

class ASTextCell : ASCellNode {
    let bubbleNode = ASImageNode()
    let messageNode = ASTextNode()


    required init(isOutgoing : Bool! = true) {
      super.init()


    }
}

