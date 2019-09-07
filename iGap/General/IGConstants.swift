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


@objcMembers
class SMQRCode:NSObject{
    
    static let URL                 = "https://paygear.ir/dl?jj="
    
    public enum SMAccountType:String {
        case User                = "8"
        case Merchant            = "9"
        case HyperMe             = "50"

    }
    
}

struct SMDirection {
    
    public enum SMPageDirection : String {
        
        case RTL = "RightToLeft"
        case LTR = "LeftToRight"
    }
    
    static func PageAffineTransform() -> CGAffineTransform {
        return (SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue) ? CGAffineTransform(scaleX: 1,y: 1) : CGAffineTransform(scaleX: -1,y: 1)
    }
    
    static func TextAlignment() -> NSTextAlignment {
        return (SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue) ? .left : .right
    }
}



