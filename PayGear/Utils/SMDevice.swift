//
//  SMDevice.swift
//  PayGear
//
//  Created by amir soltani on 6/30/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation


class SMDevice{
    
    static func getDevice()->String{
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                return "5"
            case 1334:
                return "6"
            case 1920, 2208:
                return "+"
            case 2436:
                return "x"
            default:
                return "u"
            }
        }
        
      return ""
    }
    
}
