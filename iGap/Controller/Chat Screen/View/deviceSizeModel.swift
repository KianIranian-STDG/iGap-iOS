//
//  deviceSizeModel.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/19/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import UIKit

class deviceSizeModel {
    
    class func getShareModalSize() -> (CGFloat){

        print(UIDevice.current.modelName)

        switch UIDevice.current.modelName {
        case "iPhone1,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone1,2":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone2,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone3,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone3,3":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone4,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone5,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone5,2":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone5,3":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone5,4":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone6,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone6,2":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPhone7,1":
            return (UIScreen.main.bounds.size.height - 150)
        case "iPhone7,2":
            return (UIScreen.main.bounds.size.height - 150)
        case "iPhone8,1":
            return (UIScreen.main.bounds.size.height - 150)
        case "iPhone8,2":
            return (UIScreen.main.bounds.size.height - 200)
        case "iPhone8,4":
            return (UIScreen.main.bounds.size.height - 200)
        case "iPhone9,1":
            return (UIScreen.main.bounds.size.height - 220)
        case "iPhone9,2":
            return (UIScreen.main.bounds.size.height - 220)
        case "iPhone9,3":
            return (UIScreen.main.bounds.size.height - 220)
        case "iPhone9,4":
            return (UIScreen.main.bounds.size.height - 220)
        case "iPhone10,1":
            return (UIScreen.main.bounds.size.height - 240)
        case "iPhone10,2":
            return (UIScreen.main.bounds.size.height - 260)
        case "iPhone10,4":
            return (UIScreen.main.bounds.size.height - 240)
        case "iPhone10,5":
            return (UIScreen.main.bounds.size.height - 260)
        case "iPhone10,6":
            return (UIScreen.main.bounds.size.height - 260)
        case "iPhone11,2":
            return (UIScreen.main.bounds.size.height - 260)
        case "iPhone11,4":
            return (UIScreen.main.bounds.size.height - 260)
        case "iPhone11,6":
            return (UIScreen.main.bounds.size.height - 260)
        case "iPhone11,8":
            return (UIScreen.main.bounds.size.height - 260)

            ///IPOD
        case "iPod1,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPod2,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPod3,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPod4,1":
            return (UIScreen.main.bounds.size.height - 70)
        case "iPod7,1":
            return (UIScreen.main.bounds.size.height - 70)


        default:
            return (UIScreen.main.bounds.size.height - 250)

        }
    }

}
extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

