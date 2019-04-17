//
//  IGConstants.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import UIKit


@objcMembers
class SMQRCode:NSObject{
    
    static let URL                 = "https://paygear.ir/dl?jj="
    
    public enum SMAccountType:String {
        case User                = "8"
        case Merchant            = "9"
    }
    
}
struct SMDirection {
    
    public enum SMPageDirection : String {
        
        case RTL = "RightToLeft"
        case LTR = "LeftToRight"
    }
    
    static func PageAffineTransform() -> CGAffineTransform {
        return (SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue) ? CGAffineTransform(scaleX: -1,y: 1) : CGAffineTransform(scaleX: 1,y: 1)
    }
    
    static func TextAlignment() -> NSTextAlignment {
        return (SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue) ? .left : .right
    }
}



