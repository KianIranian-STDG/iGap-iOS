//
//  IGPrint.swift
//  iGap
//
//  Created by ahmad mohammadi on 5/13/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

enum ModuleType: String {
    case Koknus = "Koknus"
}


func IGPrint<T: Any>(module: ModuleType, description: String? = nil , string: T...) {
    
    #if DEBUG
    print("=-=-=-=-=-=***** Start: \(module.rawValue) *****=-=-=-=-=-=")
    if let meth = description {
        print("=-=-=-=-=-= \(meth) =-=-=-=-=-=")
    }
    print("=-=-=-=-=-= \(string) =-=-=-=-=-=")
    print("=-=-=-=-=-=***** End: \(module.rawValue) *****=-=-=-=-=-=")
    #endif
    
}

