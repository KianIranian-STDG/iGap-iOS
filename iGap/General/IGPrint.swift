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

enum ModuleType: String {
    case Koknus = "Koknus"
    case igap = "iGap"
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

