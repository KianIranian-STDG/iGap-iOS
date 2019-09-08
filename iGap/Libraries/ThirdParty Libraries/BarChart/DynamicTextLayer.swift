/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import Foundation


extension String {
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
}

class DynamicTextLayer : CATextLayer {
    var adjustsFontSizeToFitWidth = false
    
    override func layoutSublayers() {
        super.layoutSublayers()
        if adjustsFontSizeToFitWidth {
            fitToFrame()
        }
    }
    
    func fitToFrame(){
        // Calculates the string size.
        var stringSize: CGSize  {
            get { return (string as? String)!.size(OfFont: UIFont(name: (font as! UIFont).fontName, size: fontSize)!) }
        }
        // Adds inset from the borders. Optional
        let inset: CGFloat = 2
        // Decreases the font size until criteria met
        while frame.width < stringSize.width + inset {
            fontSize -= 1
        }
    }
}
